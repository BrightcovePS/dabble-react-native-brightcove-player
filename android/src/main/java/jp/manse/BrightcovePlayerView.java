package jp.manse;

import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Handler;
import android.util.Log;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import com.brightcove.player.display.ExoPlayerVideoDisplayComponent;
import com.brightcove.player.edge.Catalog;
import com.brightcove.player.edge.OfflineCatalog;
import com.brightcove.player.edge.VideoListener;
import com.brightcove.player.event.Event;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventListener;
import com.brightcove.player.event.EventType;
import com.brightcove.player.mediacontroller.BrightcoveMediaController;
import com.brightcove.player.model.Video;
import com.brightcove.player.view.BaseVideoView;
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

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import jp.manse.up_next.UpNextViewOverlay;
import jp.manse.util.AudioFocusManager;

public class BrightcovePlayerView extends RelativeLayout implements LifecycleEventListener, AudioFocusManager.AudioFocusChangedListener {
    private final static int SEEK_OFFSET = 15000;
    private final static double ONE_SEC_DOUBLE = 1000d;
    private final static String CURRENT_TIME = "currentTime";
    private final static String DURATION = "duration";
    private final static String BUFFER_PROGRESS = "bufferProgress";
    private final ThemedReactContext context;
    private final ReactApplicationContext applicationContext;
    private final AudioFocusManager audioFocusManager;
    private final EventEmitter eventEmitter;
    private final BrightcoveExoPlayerVideoView playerVideoView;
    private final Runnable measureAndLayout = () -> {
        measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
        layout(getLeft(), getTop(), getRight(), getBottom());
    };
    private BrightcoveMediaController mediaController;
    private final UpNextViewOverlay.UpNextStatusListener onUpNextStatusListener = new UpNextViewOverlay.UpNextStatusListener() {
        @Override
        public void onShow(Video video) {
            mediaController.hide();
        }

        @Override
        public void onClose(Video video) {
            mediaController.show();
        }
    };
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
    private int bitRate = 0;
    private float playbackRate = 1;
    private UpNextViewOverlay upNextViewOverlay;
    private final OnClickListener forwardRewindClickListener = v -> {
        if (mediaController != null) {
            mediaController.show();
        }
        if (v.getId() == R.id.fast_forward_btn) {
            fastForward();
        } else if (v.getId() == R.id.rewind_btn) {
            rewind();
        }
    };
    private final UpNextViewOverlay.OnPlayUpNextListener onPlayUpNextListener = video -> {
        WritableMap event = Arguments.createMap();
        event.putString(BrightcovePlayerManager.VIDEO_ID, video.getId());
        event.putString(BrightcovePlayerManager.REFERENCE_ID, video.getReferenceId());
        sendJSEvent(BrightcovePlayerManager.EVENT_ON_PLAY_NEXT_VIDEO, event);
        playVideo(video);
    };
    /**
     * Please do not use this variable any other purpose. it may lead into video size issue
     * one of condition to refresh the video size
     **/
    private int prevOrientationForRefreshVideoLayout = Configuration.ORIENTATION_PORTRAIT;

    /**
     * Please do not use this variable any other purpose. it may lead into video size issue
     * one of condition to refresh the video size
     **/
    private boolean prevFullscreenForRefreshVideoLayout = false;

    // Storing this view height and width for accurate video sizing on refresh layout operation
    private int viewHeight;
    private int viewWidth;

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
        this.upNextViewOverlay = new UpNextViewOverlay(context, accountId, policyKey);
        addUpNextOverlay();
        this.requestLayout();
        eventEmitter = playerVideoView.getEventEmitter();
        upNextViewOverlay.setEventEmitter(eventEmitter);
        initMediaController(this.playerVideoView);
        this.mediaController = this.playerVideoView.getBrightcoveMediaController();
        // Create AudioFocusManager instance and register BrightcovePlayerView as a listener
        this.audioFocusManager = new AudioFocusManager(this.context);
        this.audioFocusManager.registerListener(this);
        EventListener eventListener = event -> {
            switch (event.getType()) {
                case EventType.VIDEO_SIZE_KNOWN:
                    refreshVideoLayoutSize(true);
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
                    sendJSEvent(BrightcovePlayerManager.EVENT_END, Arguments.createMap());
                    break;
                case EventType.PROGRESS:
                    WritableMap progressMap = Arguments.createMap();
                    Long playHead = (Long) event.properties.get(Event.PLAYHEAD_POSITION_LONG);
                    if (playHead != null) {
                        progressMap.putDouble(CURRENT_TIME, playHead / ONE_SEC_DOUBLE);
                    }
                    refreshVideoLayoutSize(false);
                    sendJSEvent(BrightcovePlayerManager.EVENT_PROGRESS, progressMap);
                    break;
                case EventType.VIDEO_DURATION_CHANGED:
                    Long duration = (Long) event.properties.get(Event.VIDEO_DURATION_LONG);
                    WritableMap durationMap = Arguments.createMap();
                    if (duration != null) {
                        durationMap.putDouble(DURATION, duration / ONE_SEC_DOUBLE);
                        upNextViewOverlay.setVideoDuration(duration);
                    }
                    sendJSEvent(BrightcovePlayerManager.EVENT_CHANGE_DURATION, durationMap);
                    break;
                case EventType.BUFFERED_UPDATE:
                    Integer percentComplete = (Integer) event.properties.get(Event.PERCENT_COMPLETE);
                    WritableMap bufferUpdateMap = Arguments.createMap();
                    if (percentComplete != null) {
                        bufferUpdateMap.putDouble(BUFFER_PROGRESS, percentComplete / 100d);
                    }
                    sendJSEvent(BrightcovePlayerManager.EVENT_UPDATE_BUFFER_PROGRESS, bufferUpdateMap);
                    break;
                case EventType.ENTER_FULL_SCREEN:
                case EventType.EXIT_FULL_SCREEN:
                    mediaController.hide();
                    requestLayout();
                    break;
                case EventType.DID_EXIT_FULL_SCREEN:
                case EventType.DID_ENTER_FULL_SCREEN:
                    onToggleFullScreen();
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

    private void onToggleFullScreen() {
        new Handler().postDelayed(mediaController::show, 300);
        sendJSEvent(BrightcovePlayerManager.EVENT_TOGGLE_ANDROID_FULLSCREEN, Arguments.createMap());
    }

    private void addUpNextOverlay() {
        this.upNextViewOverlay = new UpNextViewOverlay(context, accountId, policyKey);
        addView(upNextViewOverlay.getUpNextContainer());
        upNextViewOverlay.setOnClickUpNextListener(onPlayUpNextListener);
        upNextViewOverlay.setUpNextStatusListener(onUpNextStatusListener);
    }

    private void setSeekControlConfig() {
        HashMap<String, Object> map = new HashMap<>();
        map.put(Event.SEEK_DEFAULT_LONG, seekDuration);
        eventEmitter.emit(EventType.SEEK_CONTROLLER_CONFIGURATION, map);
    }

    private void sendJSEvent(String eventName, WritableMap map) {
        ((ReactContext) BrightcovePlayerView.this.getContext()).getJSModule(RCTEventEmitter.class).receiveEvent(BrightcovePlayerView.this.getId(), eventName, map);
    }

    public void setPolicyKey(String policyKey) {
        this.policyKey = policyKey;
        upNextViewOverlay.setPolicyKey(policyKey);
        this.loadVideo();
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
        upNextViewOverlay.setAccountId(accountId);
        this.loadVideo();
    }

    public void setVideoId(String videoId) {
        this.videoId = videoId;
        this.referenceId = null;
        upNextViewOverlay.setVideoId(videoId);
        upNextViewOverlay.setVideoReferenceId(null);
        this.loadVideo();
    }

    public void setPlaylistId(String playlistId) {
        if (playlistId != null && !playlistId.equals(this.playlistId)) {
            upNextViewOverlay.clearPlaylist();
        }
        upNextViewOverlay.setPlayListId(playlistId);
        upNextViewOverlay.setPlayListReferenceId(null);
        this.playlistId = playlistId;
        this.playlistReferenceId = null;
    }

    public void setPlaylistReferenceId(String playlistReferenceId) {
        if (playlistReferenceId != null && !playlistReferenceId.equals(this.playlistReferenceId)) {
            upNextViewOverlay.clearPlaylist();
        }
        upNextViewOverlay.setPlayListReferenceId(playlistReferenceId);
        upNextViewOverlay.setPlayListId(null);
        this.playlistReferenceId = playlistReferenceId;
        this.playlistId = null;
    }

    public void setReferenceId(String referenceId) {
        this.referenceId = referenceId;
        upNextViewOverlay.setVideoReferenceId(referenceId);
        upNextViewOverlay.setVideoId(null);
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
        fullscreenEventMap.putBoolean(BrightcovePlayerManager.FULLSCREEN, fullscreen);
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

    /**
     * @return boolean flag of comparison between video id and reference id with player
     * video current video object video id and reference id
     */
    private boolean isSameVideo() {
        return (playerVideoView != null && playerVideoView.getCurrentVideo() != null)
                && ((videoId != null && videoId.equals(playerVideoView.getCurrentVideo().getId()))
                || (referenceId != null && referenceId.equals(playerVideoView.getCurrentVideo().getReferenceId())));
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
            } catch (Exception ignored) {
            }
            return;
        }

        // if the videoId / reference id same as current video then boycott the playback get video API
        if (isSameVideo()) {
            return;
        }

        VideoListener listener = new VideoListener() {
            @Override
            public void onVideo(Video video) {
                playVideo(video);
            }
        };
        Catalog catalog = new Catalog.Builder(this.playerVideoView.getEventEmitter(), accountId)
                .setPolicy(policyKey)
                .build();

        if (this.videoId != null) {
            catalog.findVideoByID(this.videoId, listener);
        } else if (this.referenceId != null) {
            catalog.findVideoByReferenceID(this.referenceId, listener);
        }
    }

    private void playVideo(Video video) {
        upNextViewOverlay.hideUpNext();
        videoId = video.getId();
        referenceId = video.getReferenceId();
        upNextViewOverlay.setVideoId(videoId);
        upNextViewOverlay.setVideoReferenceId(referenceId);
        BrightcovePlayerView.this.playerVideoView.clear();
        BrightcovePlayerView.this.playerVideoView.add(video);
        BrightcovePlayerView.this.playerVideoView.setOnPreparedListener(mp -> {
            if (!playerVideoView.isPlaying() && BrightcovePlayerView.this.autoPlay) {
                BrightcovePlayerView.this.playerVideoView.start();
            }
        });
        upNextViewOverlay.resetUpNextCancel();
        upNextViewOverlay.prepareNextVideo();
    }

    /**
     * Refresh video player size as per surface render size to avoid below issue
     * https://github.com/BrightcoveOS/android-player-samples/issues/161
     * The video size has been set to refresh in to situations. those are,
     * Fullscreen / normal mode.
     * Portrait / landscape
     *
     * @param isVideoSizeKnownEvent to apply video size without any conditions on [EventType.VIDEO_SIZE_KNOWN] event listen
     **/
    private void refreshVideoLayoutSize(boolean isVideoSizeKnownEvent) {
        int orientation = getResources().getConfiguration().orientation;

        if (isVideoSizeKnownEvent || orientation != this.prevOrientationForRefreshVideoLayout || playerVideoView.isFullScreen() != prevFullscreenForRefreshVideoLayout) {
            // Get the width and height from player surface view render view
            float width = Objects.requireNonNull(playerVideoView.getRenderView()).getWidth();
            float height = Objects.requireNonNull(playerVideoView.getRenderView()).getHeight();

            int videoWidth = (int) width;
            int videoHeight = (int) height;
            float aspectRatio;

            // Calculate video player size as per player surface view render size
            if (viewWidth > viewHeight) {
                aspectRatio = width / height;
                videoHeight = viewHeight;
                videoWidth = (int) (videoHeight * aspectRatio);
            } else if (viewHeight > viewWidth) {
                aspectRatio = height / width;
                videoWidth = viewWidth;
                videoHeight = (int) (videoWidth * aspectRatio);
            }

            // Reconfiguring the previously calculated video size when calculated video width/height overflow on screen
            if (videoWidth > viewWidth) {
                aspectRatio = height / width;
                videoWidth = viewWidth;
                videoHeight = (int) (videoWidth * aspectRatio);
            } else if (videoHeight > viewHeight) {
                aspectRatio = width / height;
                videoHeight = viewHeight;
                videoWidth = (int) (videoHeight * aspectRatio);
            }

            // Apply video width and height to player view
            RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(videoWidth, videoHeight);
            layoutParams.addRule(CENTER_IN_PARENT, TRUE);
            playerVideoView.setLayoutParams(layoutParams);

            WritableMap event = Arguments.createMap();
            event.putInt(BrightcovePlayerManager.WIDTH, videoWidth);
            event.putInt(BrightcovePlayerManager.HEIGHT, videoHeight);
            sendJSEvent(BrightcovePlayerManager.EVENT_ON_VIDEO_SIZE, event);

            // Cache previous state of orientation and fullscreen to refresh video player size only these state changes
            this.prevOrientationForRefreshVideoLayout = orientation;
            this.prevFullscreenForRefreshVideoLayout = playerVideoView.isFullScreen();
        }
    }

    private void printKeys(Map<String, Object> map) {
        Log.d("debug", "-----------");
        for (Map.Entry<String, Object> entry : map.entrySet()) {
            Log.d("debug", entry.getKey());
        }
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

    private void fastForward() {
        long seekMax = mediaController.getBrightcoveSeekBar().getMax();
        long seekPos = mediaController.getBrightcoveSeekBar().getProgress() + seekDuration;
        if (seekMax > seekPos) {
            upNextViewOverlay.resetUpNextCancel();
            playerVideoView.seekTo(seekPos);
        }
    }

    private void rewind() {
        long seekPos = mediaController.getBrightcoveSeekBar().getProgress() - seekDuration;
        if (seekPos > 0) {
            upNextViewOverlay.resetUpNextCancel();
            playerVideoView.seekTo(seekPos);
        }
    }

    @Override
    protected void onSizeChanged(int width, int height, int oldw, int oldh) {
        upNextViewOverlay.onPlayerSizeChanged(width, height);
        super.onSizeChanged(width, height, oldw, oldh);
        // Storing view size to calculate video view in better manner
        viewHeight = height;
        viewWidth = width;
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
        upNextViewOverlay.dispose();
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
