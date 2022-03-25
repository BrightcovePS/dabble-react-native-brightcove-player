package jp.manse.up_next;

import static android.widget.RelativeLayout.CENTER_IN_PARENT;

import android.os.CountDownTimer;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.brightcove.player.edge.Catalog;
import com.brightcove.player.edge.PlaylistListener;
import com.brightcove.player.event.Event;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventListener;
import com.brightcove.player.event.EventType;
import com.brightcove.player.model.Playlist;
import com.brightcove.player.model.Video;
import com.brightcove.player.network.HttpRequestConfig;
import com.brightcove.player.util.Objects;
import com.facebook.react.bridge.ReactContext;

import java.util.Random;

import jp.manse.util.ImageLoader;
import jp.manse.R;
import jp.manse.webservice.ReactCatalog;

public class UpNextView {
    private final static String ALL_VIDEOS_PAGE_SIZE = "1000";
    private final static double WIDTH_PORT_PERCENT = 0.7;
    private final static double HEIGHT_PERCENT = 0.6;
    private final static int UP_NEXT_COUNT_DOWN_TIME = 5000;
    private final static int ONE_SEC = 1000;
    private LinearLayout upNextContainer;
    private EventEmitter eventEmitter;
    private boolean loadingAllVideos = false;
    private double upNextBannerWidth;
    private double upNextBannerHeight;
    private Playlist allVideos;
    private Video nextVideo;
    private Playlist playList;
    private long videoDuration;
    private String videoId;
    private String videoReferenceId;
    private String playlistId;
    private String playlistReferenceId;
    private ImageLoader imageLoader;
    private ReactContext context;
    private OnPlayUpNextListener onPlayUpNextListener;
    private String accountId;
    private String policyKey;
    private Catalog catalog;
    private CountDownTimer upNextTimer;
    private boolean upNextOverlayCancelled = false;
    private int downSecondCounter = 5;

    public UpNextView(@NonNull ReactContext context, @NonNull String account, @NonNull String policyKey) {
        this.context = context;
        this.accountId = account;
        this.policyKey = policyKey;
        configureTimer();
    }

    private void configureTimer() {
        upNextTimer = new CountDownTimer(UP_NEXT_COUNT_DOWN_TIME, ONE_SEC) {
            @Override
            public void onTick(long millisUntilFinished) {
                if (upNextContainer != null) {
                    ((TextView) upNextContainer.findViewById(R.id.count_down_txt)).setText(String.valueOf(downSecondCounter));
                    downSecondCounter --;
                }
            }

            @Override
            public void onFinish() {
                onFinishTimer();
            }
        };
    }

    private void onFinishTimer() {
        cancelTimer();
        onClose();
        if (onPlayUpNextListener != null) {
            onPlayUpNextListener.onPlayNext(nextVideo);
        }
    }

    public void startUpNextTimer() {
        if (upNextTimer == null) {
            configureTimer();
        }
        upNextContainer.findViewById(R.id.count_down_txt).setVisibility(View.VISIBLE);
        upNextContainer.findViewById(R.id.count_down_cancel_action).setVisibility(View.VISIBLE);
        upNextTimer.start();
    }

    public LinearLayout getUpNextContainer() {
        upNextContainer = (LinearLayout) LayoutInflater.from(context).inflate(R.layout.up_next_layout, null);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        params.addRule(CENTER_IN_PARENT, RelativeLayout.TRUE);
        upNextContainer.setVisibility(View.INVISIBLE);
        upNextContainer.findViewById(R.id.count_down_cancel_action).setOnClickListener(v -> cancelTimer());
        upNextContainer.findViewById(R.id.close_up_next_action).setOnClickListener(v -> onClose());
        upNextContainer.findViewById(R.id.play_up_next_action).setOnClickListener(v -> {
            if (nextVideo != null && onPlayUpNextListener != null) {
                onPlayUpNextListener.onPlayNext(nextVideo);
            }
        });
        upNextContainer.setLayoutParams(params);
        return upNextContainer;
    }

    private void cancelTimer() {
        upNextContainer.findViewById(R.id.count_down_txt).setVisibility(View.INVISIBLE);
        upNextContainer.findViewById(R.id.count_down_cancel_action).setVisibility(View.INVISIBLE);
        if (upNextTimer != null) {
            upNextTimer.cancel();
        }
    }

    public void showUpNext() {
        if (nextVideo != null) {
            startUpNextTimer();
            ImageView upNextPoster = upNextContainer.findViewById(R.id.up_next_poster);
            upNextPoster.setLayoutParams(new ViewGroup.LayoutParams((int) upNextBannerWidth, (int) upNextBannerHeight));
            View upNextPosterBorder = upNextContainer.findViewById(R.id.up_next_poster_border);
            upNextPosterBorder.setLayoutParams(new ViewGroup.LayoutParams((int) upNextBannerWidth, (int) upNextBannerHeight));
            loadImage(nextVideo, upNextPoster);
            TextView upNextTitle = upNextContainer.findViewById(R.id.up_next_title);
            upNextTitle.setText(nextVideo.getName());
            upNextTitle.setLayoutParams(new LinearLayout.LayoutParams((int) upNextBannerWidth, ViewGroup.LayoutParams.WRAP_CONTENT));
            upNextContainer.setVisibility(View.VISIBLE);
        }
    }

    private void onClose() {
        upNextOverlayCancelled = true;
        hideUpNext();
    }

    public void resetUpNextCancel() {
        downSecondCounter = 5;
        upNextOverlayCancelled = false;
    }

    public void hideUpNext() {
        cancelTimer();
        if (upNextContainer != null) {
            upNextContainer.setVisibility(View.INVISIBLE);
        }
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

    public void prepareNextVideo() {
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
                if (playlistRes != null && playlistRes.getVideos() != null) {
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
                if (i < playList.getVideos().size() - 1 && (video.getId().equals(videoId) || video.getReferenceId().equals(videoReferenceId))) {
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
        ReactCatalog reactCatalog = new ReactCatalog.Builder(eventEmitter, accountId)
                .setPolicy(policyKey)
                .build();
        HttpRequestConfig config = new HttpRequestConfig.Builder().addQueryParameter("limit", ALL_VIDEOS_PAGE_SIZE).build();
        reactCatalog.getAllVideos(config, listener);
    }

    public void setVideoDuration(long videoDuration) {
        this.videoDuration = videoDuration;
    }

    public void setVideoId(String videoId) {
        this.videoId = videoId;
    }

    public void setVideoReferenceId(String referenceId) {
        videoReferenceId = referenceId;
    }

    public void setPlayListId(String playlistId) {
        this.playlistId = playlistId;
    }

    public void setPlayListReferenceId(String playlistReferenceId) {
        this.playlistReferenceId = playlistReferenceId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
        createCatalogInstance();
    }

    public void setPolicyKey(String policyKey) {
        this.policyKey = policyKey;
        createCatalogInstance();
    }

    public void clearPlaylist() {
        playList = null;
    }

    private void createCatalogInstance() {
        if (accountId == null || eventEmitter == null) {
            return;
        }
        catalog = new Catalog.Builder(this.eventEmitter, accountId)
                .setPolicy(policyKey)
                .build();
    }

    public void setEventEmitter(@NonNull EventEmitter eventEmitter) {
        this.eventEmitter = eventEmitter;
        createCatalogInstance();
        EventListener eventListener = event -> {
            switch (event.getType()) {
                case EventType.SEEKBAR_DRAGGING_STOP:
                    resetUpNextCancel();
                    break;
                case EventType.COMPLETED:
                    if (upNextContainer.getVisibility() != View.VISIBLE && !upNextOverlayCancelled) {
                        showUpNext();
                    }
                    break;
                case EventType.PROGRESS:
                    Long progress = (Long) event.properties.get(Event.PLAYHEAD_POSITION_LONG);
                    if (progress != null) {
                        float difference = videoDuration - progress;
                        if (difference <= 10000 && nextVideo == null && !loadingAllVideos) {
                            // Pick random video from video cloud
                            prepareNextFromAllVideos();
                        }
                        if (difference <= 5000 && upNextContainer.getVisibility() != View.VISIBLE && !upNextOverlayCancelled) {
                            showUpNext();
                        }
                    }
                    break;
            }
        };
        eventEmitter.on(EventType.COMPLETED, eventListener);
        eventEmitter.on(EventType.PROGRESS, eventListener);
        eventEmitter.on(EventType.SEEKBAR_DRAGGING_STOP, eventListener);
    }

    public void onPlayerSizeChanged(int width, int height) {
        if (height < width) {
            upNextBannerHeight = height * HEIGHT_PERCENT;
            upNextBannerWidth = (upNextBannerHeight / 9) * 16;
        } else if (width < height) {
            upNextBannerWidth = width * WIDTH_PORT_PERCENT;
            upNextBannerHeight = (upNextBannerWidth / 16) * 9;
        }
    }

    public void dispose() {
        context = null;
        upNextContainer = null;
        loadingAllVideos = false;
        upNextBannerWidth = 0;
        upNextBannerHeight = 0;
        allVideos = null;
        playList = null;
        playlistId = null;
        playlistReferenceId = null;
        videoId = null;
        videoDuration = 0;
        videoReferenceId = null;
        onPlayUpNextListener = null;
        accountId = null;
        policyKey = null;
        catalog = null;
        imageLoader = null;
    }

    public void setOnClickUpNextListener(@NonNull OnPlayUpNextListener onPlayUpNextListener) {
        this.onPlayUpNextListener = (OnPlayUpNextListener) Objects.requireNonNull(onPlayUpNextListener, "Policy cannot be null");
    }

    public interface OnPlayUpNextListener {
        void onPlayNext(Video video);
    }
}
