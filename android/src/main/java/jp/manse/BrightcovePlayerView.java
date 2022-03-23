package jp.manse;

import android.graphics.Color;
import android.util.Log;
import android.widget.ImageButton;
import android.view.LayoutInflater;
import android.view.SurfaceView;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.brightcove.player.display.ExoPlayerVideoDisplayComponent;
import com.brightcove.player.edge.Catalog;
import com.brightcove.player.edge.OfflineCatalog;
import com.brightcove.player.edge.PlaylistListener;
import com.brightcove.player.edge.VideoListener;
import com.brightcove.player.event.Event;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventListener;
import com.brightcove.player.event.EventType;
import com.brightcove.player.mediacontroller.BrightcoveMediaController;
import com.brightcove.player.model.Playlist;
import com.brightcove.player.model.Video;
import com.brightcove.player.view.BaseVideoView;
import com.brightcove.player.network.HttpRequestConfig;
import com.brightcove.player.view.BrightcoveExoPlayerVideoView;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.android.exoplayer2.C;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.PlaybackParameters;
import com.google.android.exoplayer2.RendererCapabilities;
import com.google.android.exoplayer2.source.TrackGroup;
import com.google.android.exoplayer2.source.TrackGroupArray;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.MappingTrackSelector;
import com.google.gson.Gson;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import jp.manse.util.AudioFocusManager;
import jp.manse.util.ImageLoader;
import jp.manse.webservice.ReactCatalog;

public class BrightcovePlayerView extends RelativeLayout implements LifecycleEventListener, AudioFocusManager.AudioFocusChangedListener {
    private final static int SEEK_OFFSET = 15000;
    private final static String ALL_VIDEOS_PAGE_SIZE = "1000";
    private final static double WIDTH_PORT_PERCENT = 0.7;
    private final static double HEIGHT_PERCENT = 0.6;
    private final ThemedReactContext context;
    private final ReactApplicationContext applicationContext;
    private final AudioFocusManager audioFocusManager;
    private final Runnable measureAndLayout = () -> {
        measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
        layout(getLeft(), getTop(), getRight(), getBottom());
    };
    private BrightcoveExoPlayerVideoView playerVideoView;
    private BrightcoveMediaController mediaController;
    private String policyKey;
    private String accountId;
    private String videoId;
    private String playlistId;
    private String playlistReferenceId;
    private String referenceId;
    private String videoToken;
    private long seekDuration = SEEK_OFFSET;
    private boolean autoPlay = true;
    private boolean playing = false;
    private boolean loadingAllVideos = false;
    private int bitRate = 0;
    private float playbackRate = 1;
    private Video nextVideo;
    private Playlist playList;
    private Playlist allVideos;
    private LinearLayout upNextContainer;
    private ImageLoader imageLoader;
    private Catalog catalog;
    private double upNextBannerWidth;
    private double upNextBannerHeight;
    private EventEmitter eventEmitter;
    private final OnClickListener forwardRewindClickListener = v -> {
        if (v.getId() == R.id.fast_forward_btn) {
            long seekMax = mediaController.getBrightcoveSeekBar().getMax();
            long seekPos = playerVideoView.getCurrentPositionLong() + seekDuration;
            if (seekMax > seekPos) {
                playerVideoView.seekTo(seekPos);
            }
        } else if (v.getId() == R.id.rewind_btn) {
            eventEmitter.emit(EventType.REWIND);
        }
    };

    public BrightcovePlayerView(ThemedReactContext context, ReactApplicationContext applicationContext) {
        super(context);
        this.context = context;
        this.applicationContext = applicationContext;
        this.applicationContext.addLifecycleEventListener(this);
        this.setBackgroundColor(Color.BLACK);
        this.playerVideoView = new BrightcoveExoPlayerVideoView(this.context);
        this.addView(this.playerVideoView);
        this.playerVideoView.setLayoutParams(new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        this.playerVideoView.finishInitialization();
        addUpNext();
        this.requestLayout();
        eventEmitter = playerVideoView.getEventEmitter();
        initMediaController(this.playerVideoView);
        this.mediaController = this.playerVideoView.getBrightcoveMediaController();
        // Create AudioFocusManager instance and register BrightcovePlayerView as a listener
        this.audioFocusManager = new AudioFocusManager(this.context);
        this.audioFocusManager.registerListener(this);
        EventListener eventListener = event -> {
            switch (event.getType()) {
                case EventType.VIDEO_SIZE_KNOWN:
                    fixVideoLayout();
                    updateBitRate();
                    updatePlaybackRate();
                    break;
                case EventType.READY_TO_PLAY:
                    sendJSEvent(BrightcovePlayerManager.EVENT_READY, Arguments.createMap());
                    break;
                case EventType.DID_PLAY:
                    audioFocusManager.requestFocus();
                    BrightcovePlayerView.this.playing = true;
                    sendJSEvent(BrightcovePlayerManager.EVENT_PLAY, Arguments.createMap());
                    break;
                case EventType.DID_PAUSE:
                    audioFocusManager.abandonFocus();
                    BrightcovePlayerView.this.playing = false;
                    sendJSEvent(BrightcovePlayerManager.EVENT_PAUSE, Arguments.createMap());
                    break;
                case EventType.COMPLETED:
                    if (upNextContainer.getVisibility() != VISIBLE) {
                        showUpNext();
                    }
                    sendJSEvent(BrightcovePlayerManager.EVENT_END, Arguments.createMap());
                    break;
                case EventType.PROGRESS:
                    WritableMap progressMap = Arguments.createMap();
                    Long playHead = (Long) event.properties.get(Event.PLAYHEAD_POSITION_LONG);
                    if (playHead != null) {
                        progressMap.putDouble("currentTime", playHead / 1000d);
                        int duration = playerVideoView.getBrightcoveMediaController().getBrightcoveSeekBar().getMax();
                        float difference = duration - playHead;
                        if (difference <= 10000 && nextVideo == null && !loadingAllVideos) {
                            // Pick random video from video cloud
                            prepareNextFromAllVideos();
                        }
                        if (difference <= 5000 && upNextContainer.getVisibility() != VISIBLE) {
                            showUpNext();
                        }
                    }
                    sendJSEvent(BrightcovePlayerManager.EVENT_PROGRESS, progressMap);
                    break;
                case EventType.VIDEO_DURATION_CHANGED:
                    Long duration = (Long) event.properties.get(Event.VIDEO_DURATION_LONG);
                    WritableMap durationMap = Arguments.createMap();
                    if (duration != null) {
                        durationMap.putDouble("duration", duration / 1000d);
                    }
                    sendJSEvent(BrightcovePlayerManager.EVENT_CHANGE_DURATION, durationMap);
                    break;
                case EventType.BUFFERED_UPDATE:
                    Integer percentComplete = (Integer) event.properties.get(Event.PERCENT_COMPLETE);
                    WritableMap bufferUpdateMap = Arguments.createMap();
                    if (percentComplete != null) {
                        bufferUpdateMap.putDouble("bufferProgress", percentComplete / 100d);
                    }
                    sendJSEvent(BrightcovePlayerManager.EVENT_UPDATE_BUFFER_PROGRESS, bufferUpdateMap);
                    break;
                case EventType.DID_EXIT_FULL_SCREEN:
                case EventType.DID_ENTER_FULL_SCREEN:
                    mediaController.show();
                    sendJSEvent(BrightcovePlayerManager.EVENT_TOGGLE_ANDROID_FULLSCREEN, Arguments.createMap());
                    break;
            }
        };
        eventEmitter.on(EventType.VIDEO_SIZE_KNOWN, eventListener);
        eventEmitter.on(EventType.READY_TO_PLAY, eventListener);
        eventEmitter.on(EventType.DID_PLAY, eventListener);
        eventEmitter.on(EventType.DID_PAUSE, eventListener);
        eventEmitter.on(EventType.COMPLETED, eventListener);
        eventEmitter.on(EventType.PROGRESS, eventListener);
        // This event is sent by the BrightcovePlayer Activity when the onConfigurationChanged has been called.
        eventEmitter.on(EventType.DID_EXIT_FULL_SCREEN, eventListener);
        eventEmitter.on(EventType.DID_ENTER_FULL_SCREEN, eventListener);
        eventEmitter.on(EventType.VIDEO_DURATION_CHANGED, eventListener);
        eventEmitter.on(EventType.BUFFERED_UPDATE, eventListener);
        setSeekControlConfig();
    }

    private void setSeekControlConfig() {
        HashMap<String, Object> map = new HashMap<>();
        map.put(Event.SEEK_DEFAULT_LONG, seekDuration);
        eventEmitter.emit(EventType.SEEK_CONTROLLER_CONFIGURATION, map);
    }

    private void sendJSEvent(String eventName, WritableMap map) {
        ((ReactContext) BrightcovePlayerView.this.getContext()).getJSModule(RCTEventEmitter.class).receiveEvent(BrightcovePlayerView.this.getId(), eventName, map);
    }

    private void showUpNext() {
        if (nextVideo != null) {
            ImageView upNextPoster = upNextContainer.findViewById(R.id.up_next_poster);
            upNextPoster.setLayoutParams(new ViewGroup.LayoutParams((int) upNextBannerWidth, (int) upNextBannerHeight));
            loadImage(nextVideo, upNextPoster);
            TextView upNextTitle = upNextContainer.findViewById(R.id.up_next_title);
//            upNextTitle.setText(nextVideo.getName());
            upNextTitle.setText("jingle bells jingle bells jingle all the way | Xmas Music Rhymes, Again jingle bells jingle bells jingle all the way");
            upNextTitle.setLayoutParams(new LinearLayout.LayoutParams((int) upNextBannerWidth, ViewGroup.LayoutParams.WRAP_CONTENT));
            upNextContainer.setVisibility(VISIBLE);
        }
    }

    private void hideUpNext() {
        if (upNextContainer != null) {
            upNextContainer.setVisibility(INVISIBLE);
        }
    }

    private void addUpNext() {
        upNextContainer = (LinearLayout) LayoutInflater.from(getContext()).inflate(R.layout.up_next_layout, null);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        params.addRule(CENTER_IN_PARENT, RelativeLayout.TRUE);
//        params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE);
//        params.rightMargin = getResources().getDimensionPixelSize(R.dimen.margin_large);
//        params.bottomMargin = getResources().getDimensionPixelSize(R.dimen.margin_xxxlarge);
        addView(upNextContainer, params);
        upNextContainer.setVisibility(INVISIBLE);
        upNextContainer.findViewById(R.id.close_up_next_action).setOnClickListener(v -> hideUpNext());
        upNextContainer.findViewById(R.id.up_next_poster).setOnClickListener(v -> {
            if (nextVideo != null) {
                WritableMap event = Arguments.createMap();
                event.putString("videoId", nextVideo.getId());
                event.putString("referenceId", nextVideo.getReferenceId());
                ReactContext reactContext = (ReactContext) BrightcovePlayerView.this.getContext();
                reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(BrightcovePlayerView.this.getId(), BrightcovePlayerManager.EVENT_ON_PLAY_NEXT_VIDEO, event);
                playVideo(nextVideo);
            }
        });
    }

    public void setPolicyKey(String policyKey) {
        this.policyKey = policyKey;
        this.loadVideo();
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
        this.loadVideo();
    }

    public void setVideoId(String videoId) {
        this.videoId = videoId;
        this.referenceId = null;
        this.loadVideo();
    }

    public void setPlaylistId(String playlistId) {
        if (playlistId != null && !playlistId.equals(this.playlistId)) {
            playList = null;
        }
        this.playlistId = playlistId;
    }

    public void setPlaylistReferenceId(String playlistReferenceId) {
        if (playlistReferenceId != null && !playlistReferenceId.equals(this.playlistReferenceId)) {
            playList = null;
        }
        this.playlistReferenceId = playlistReferenceId;
    }

    public void setReferenceId(String referenceId) {
        this.referenceId = referenceId;
        this.videoId = null;
        this.loadVideo();
    }

    public void setVideoToken(String videoToken) {
        this.videoToken = videoToken;
        this.loadVideo();
    }

    public void setAutoPlay(boolean autoPlay) {
        this.autoPlay = autoPlay;
    }

    public void setPlay(boolean play) {
        if (this.playing == play) return;
        if (play) {
            this.playerVideoView.start();
        } else {
            this.playerVideoView.pause();
        }
    }

    public void setDefaultControlDisabled(boolean disabled) {
        playerVideoView.getBrightcoveMediaController().hide();
        playerVideoView.getBrightcoveMediaController().setShowHideTimeout(disabled ? 1 : 4000);
    }

    public void setFullscreen(boolean fullscreen) {
        playerVideoView.getBrightcoveMediaController().show();
        WritableMap fullscreenEventMap = Arguments.createMap();
        fullscreenEventMap.putBoolean("fullscreen", fullscreen);
        sendJSEvent(BrightcovePlayerManager.EVENT_TOGGLE_ANDROID_FULLSCREEN, fullscreenEventMap);
    }

    public void setSeekDuration(long seekDuration) {
        this.seekDuration = seekDuration;
        setSeekControlConfig();
    }

    public void setVolume(float volume) {
        Map<String, Object> details = new HashMap<>();
        details.put(Event.VOLUME, volume);
        this.playerVideoView.getEventEmitter().emit(EventType.SET_VOLUME, details);
    }

    public void setBitRate(int bitRate) {
        this.bitRate = bitRate;
        this.updateBitRate();
    }

    public void setPlaybackRate(float playbackRate) {
        if (playbackRate == 0) return;
        this.playbackRate = playbackRate;
        this.updatePlaybackRate();
    }

    public void seekTo(long time) {
        this.playerVideoView.seekTo(time);
    }

    private void updateBitRate() {
        if (this.bitRate == 0) return;
        ExoPlayerVideoDisplayComponent videoDisplay = ((ExoPlayerVideoDisplayComponent) this.playerVideoView.getVideoDisplay());
        ExoPlayer player = videoDisplay.getExoPlayer();
        DefaultTrackSelector trackSelector = videoDisplay.getTrackSelector();
        if (player == null) return;
        MappingTrackSelector.MappedTrackInfo mappedTrackInfo = trackSelector.getCurrentMappedTrackInfo();
        if (mappedTrackInfo == null) return;
        Integer rendererIndex = null;
        for (int i = 0; i < mappedTrackInfo.getRendererCount(); i++) {
            TrackGroupArray trackGroups = mappedTrackInfo.getTrackGroups(i);
            if (trackGroups.length != 0 && player.getRendererType(i) == C.TRACK_TYPE_VIDEO) {
                rendererIndex = i;
                break;
            }
        }

        if (rendererIndex == null) return;
        if (bitRate == 0) {
            trackSelector.setParameters(trackSelector.buildUponParameters().clearSelectionOverrides(rendererIndex));
            return;
        }
        int resultBitRate = -1;
        int targetGroupIndex = -1;
        int targetTrackIndex = -1;
        TrackGroupArray trackGroups = mappedTrackInfo.getTrackGroups(rendererIndex);
        for (int groupIndex = 0; groupIndex < trackGroups.length; groupIndex++) {
            TrackGroup group = trackGroups.get(groupIndex);
            if (group != null) {
                for (int trackIndex = 0; trackIndex < group.length; trackIndex++) {
                    Format format = group.getFormat(trackIndex);
                    if (format != null && mappedTrackInfo.getTrackSupport(rendererIndex, groupIndex, trackIndex)
                            == RendererCapabilities.FORMAT_HANDLED) {
                        if (resultBitRate == -1 ||
                                (resultBitRate > bitRate ? (format.bitrate < resultBitRate) :
                                        (format.bitrate <= bitRate && format.bitrate > resultBitRate))) {
                            targetGroupIndex = groupIndex;
                            targetTrackIndex = trackIndex;
                            resultBitRate = format.bitrate;
                        }
                    }
                }
            }
        }
        if (targetGroupIndex != -1 && targetTrackIndex != -1) {
            trackSelector.setParameters(trackSelector.buildUponParameters().setSelectionOverride(rendererIndex, trackGroups,
                    new DefaultTrackSelector.SelectionOverride(targetGroupIndex, targetTrackIndex)));
        }
    }

    private void updatePlaybackRate() {
        ExoPlayer expPlayer = ((ExoPlayerVideoDisplayComponent) this.playerVideoView.getVideoDisplay()).getExoPlayer();
        if (expPlayer != null) {
            expPlayer.setPlaybackParameters(new PlaybackParameters(playbackRate, 1f));
        }
    }

    private void loadVideo() {
        if (accountId == null || policyKey == null) {
            return;
        }

        if (this.videoToken != null && !this.videoToken.equals("")) {
            OfflineCatalog offlineCatalog = new OfflineCatalog.Builder(this.context, this.playerVideoView.getEventEmitter(), accountId)
                    .setPolicy(policyKey)
                    .build();
            try {
                Video video = offlineCatalog.findOfflineVideoById(this.videoToken);
                if (video != null) {
                    playVideo(video);
                }
            } catch (Exception e) {
            }
            return;
        }
        VideoListener listener = new VideoListener() {
            @Override
            public void onVideo(Video video) {
                playVideo(video);
            }
        };
        catalog = new Catalog.Builder(this.playerVideoView.getEventEmitter(), accountId)
                .setPolicy(policyKey)
                .build();
        if (this.videoId != null) {
            catalog.findVideoByID(this.videoId, listener);
        } else if (this.referenceId != null) {
            catalog.findVideoByReferenceID(this.referenceId, listener);
        }
    }

    private void playVideo(Video video) {
        hideUpNext();
        videoId = video.getId();
        referenceId = video.getReferenceId();
        BrightcovePlayerView.this.playerVideoView.clear();
        BrightcovePlayerView.this.playerVideoView.add(video);
        BrightcovePlayerView.this.playerVideoView.setOnPreparedListener(mp -> {
            if (!playerVideoView.isPlaying() && BrightcovePlayerView.this.autoPlay) {
                BrightcovePlayerView.this.playerVideoView.start();
            }
        });
        prepareNextVideo();
    }

    private void fixVideoLayout() {
        int viewWidth = this.getMeasuredWidth();
        int viewHeight = this.getMeasuredHeight();
        SurfaceView surfaceView = (SurfaceView) this.playerVideoView.getRenderView();
        surfaceView.measure(viewWidth, viewHeight);
        int surfaceWidth = surfaceView.getMeasuredWidth();
        int surfaceHeight = surfaceView.getMeasuredHeight();
        int leftOffset = (viewWidth - surfaceWidth) / 2;
        int topOffset = (viewHeight - surfaceHeight) / 2;
        surfaceView.layout(leftOffset, topOffset, leftOffset + surfaceWidth, topOffset + surfaceHeight);
    }

    private void printKeys(Map<String, Object> map) {
        Log.d("debug", "-----------");
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            Log.d("debug", entry.getKey());
        }
    }

    private void prepareNextVideo() {
        nextVideo = null;
        if ((playlistId == null || playlistId.isEmpty()) && (playlistReferenceId == null || playlistReferenceId.isEmpty())) {
            return;
        }
        PlaylistListener listener = new PlaylistListener() {
            @Override
            public void onPlaylist(Playlist playlistRes) {
                playList = playlistRes;
                nextVideo = getNextVideo();
            }
        };
        if (playList == null) {
            fetchPlayList(listener);
        } else {
            nextVideo = getNextVideo();
        }
    }

    private void prepareNextFromAllVideos() {
        nextVideo = null;
        PlaylistListener listener = new PlaylistListener() {
            @Override
            public void onPlaylist(Playlist playlistRes) {
                loadingAllVideos = false;
                System.out.println("================> All Videos ==============> " + (playlistRes != null && playlistRes.getVideos() != null));
                if (playlistRes != null && playlistRes.getVideos() != null) {
                    System.out.println("================> All Videos Size ==============> " + playlistRes.getVideos().size());
                    allVideos = playlistRes;
                    nextVideo = getNextRandomVideo();
                }
            }
        };
        if (allVideos == null) {
            try {
                loadingAllVideos = true;
                fetchAllVideos(listener);
            } catch (Exception e) {
                loadingAllVideos = false;
            }
        } else {
            nextVideo = getNextRandomVideo();
        }
    }

    private Video getNextVideo() {
        Video nextVideo = null;
        if (playList != null) {
            for (int i = 0; i < playList.getVideos().size(); i++) {
                Video video = playList.getVideos().get(i);
                if (i < playList.getVideos().size() - 1 && (video.getId().equals(videoId) || video.getReferenceId().equals(referenceId))) {
                    nextVideo = playList.getVideos().get(i + 1);
                    break;
                }
            }
        }
        return nextVideo;
    }

    private Video getNextRandomVideo() {
        Video video = null;
        while (video == null || video.getId().equals(videoId)) {
            video = getRandomFromAllVideos();
        }
        return video;
    }

    private Video getRandomFromAllVideos() {
        Random random = new Random();
        int randomVideoIndex = random.nextInt(allVideos.getVideos().size());
        return allVideos.getVideos().get(randomVideoIndex);
    }

    private void fetchPlayList(PlaylistListener listener) {
        if (playlistReferenceId != null && !playlistReferenceId.isEmpty()) {
            catalog.findPlaylistByReferenceID(playlistReferenceId, listener);
        } else if (playlistId != null && !playlistId.isEmpty()) {
            catalog.findPlaylistByID(playlistId, listener);
        }
    }

    private void fetchAllVideos(PlaylistListener listener) {
        ReactCatalog reactCatalog = new ReactCatalog.Builder(this.playerVideoView.getEventEmitter(), accountId)
                .setPolicy(policyKey)
                .build();
        HttpRequestConfig config = new HttpRequestConfig.Builder().addQueryParameter("limit", ALL_VIDEOS_PAGE_SIZE).build();
        reactCatalog.getAllVideos(config, listener);
    }

    private void loadImage(Video video, ImageView imageView) {
        if (video == null) {
            imageView.setImageResource(android.R.color.transparent);
            return;
        }
        if (video.getPosterImage() == null) {
            imageView.setImageResource(android.R.color.transparent);
            return;
        }
        if (this.imageLoader != null) {
            this.imageLoader.cancel(true);
        }
        String url = video.getPosterImage().toString();
        this.imageLoader = new ImageLoader(imageView);
        this.imageLoader.execute(url);
    }

    private void initMediaController(BaseVideoView brightcoveVideoView) {
        brightcoveVideoView.setMediaController(
                new BrightcoveMediaController(
                        brightcoveVideoView,
                        R.layout.player_controls
                )
        );
        initButtons();

        // This event is sent by the BrightcovePlayer Activity when the onConfigurationChanged has been called.
        eventEmitter.on(EventType.CONFIGURATION_CHANGED, event -> initButtons());
    }

    private void initButtons() {
        ImageButton rewindBtn = playerVideoView.findViewById(R.id.rewind_btn);
        ImageButton forwardBtn = playerVideoView.findViewById(R.id.fast_forward_btn);
        rewindBtn.setOnClickListener(forwardRewindClickListener);
        forwardBtn.setOnClickListener(forwardRewindClickListener);
    }

    @Override
    protected void onSizeChanged(int width, int height, int oldw, int oldh) {
        if (height < width) {
            upNextBannerHeight = height * HEIGHT_PERCENT;
            upNextBannerWidth = (upNextBannerHeight / 9) * 16;
        } else if (width < height) {
            upNextBannerWidth = width * WIDTH_PORT_PERCENT;
            upNextBannerHeight = (upNextBannerWidth / 16) * 9;
        }
        System.out.println("Size updates ====================> " + upNextBannerWidth + " " + upNextBannerHeight);

        super.onSizeChanged(width, height, oldw, oldh);
    }

    @Override
    public void onHostResume() {
        // Register to audio focus changes when the screen resumes
        audioFocusManager.registerListener(this);
    }

    @Override
    public void onHostPause() {
        // Unregister from audio focus changes when the screen goes in the background
        audioFocusManager.unregisterListener();
    }

    @Override
    public void onHostDestroy() {
        this.playerVideoView.destroyDrawingCache();
        this.playerVideoView.clear();
        this.removeAllViews();
        this.applicationContext.removeLifecycleEventListener(this);
    }

    @Override
    public void requestLayout() {
        super.requestLayout();

        // The spinner relies on a measure + layout pass happening after it calls requestLayout().
        // Without this, the widget never actually changes the selection and doesn't call the
        // appropriate listeners. Since we override onLayout in our ViewGroups, a layout pass never
        // happens after a call to requestLayout, so we simulate one here.
        post(measureAndLayout);
    }

    @Override
    public void audioFocusChanged(boolean hasFocus) {
        // Pause the video when it looses focus
        if (!hasFocus && playerVideoView.isPlaying()) {
            playerVideoView.pause();
        }
    }
}
