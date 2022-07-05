package jp.manse;


import androidx.annotation.Nullable;

import com.brightcove.player.event.EventType;
import com.facebook.infer.annotation.Assertions;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.HashMap;
import java.util.Map;


public class BrightcovePlayerManager extends ViewGroupManager<BrightcovePlayerView> {
    public static final String REGISTRATION_NAME = "registrationName";
    public static final String REACT_CLASS = "BrightcovePlayer";
    public static final int COMMAND_SEEK_TO = 1;
    public static final String EVENT_READY = "ready";
    public static final String EVENT_PLAY = "play";
    public static final String EVENT_PAUSE = "pause";
    public static final String EVENT_END = "end";
    public static final String EVENT_PROGRESS = "progress";
    public static final String EVENT_TOGGLE_ANDROID_FULLSCREEN = "toggle_android_fullscreen";
    public static final String EVENT_CHANGE_DURATION = "change_duration";
    public static final String EVENT_UPDATE_BUFFER_PROGRESS = "update_buffer_progress";
    public static final String EVENT_ON_PLAY_NEXT_VIDEO = "on_play_next_video";
    public static final String EVENT_ON_PLAY_NEXT_VIDEO_REGISTER_NAME = "onPlayNextVideo";
    public static final String EVENT_ON_READY_REGISTER_NAME = "onReady";
    public static final String EVENT_ON_PLAY_REGISTER_NAME = "onPlay";
    public static final String EVENT_ON_PAUSE_REGISTER_NAME = "onPause";
    public static final String EVENT_ON_END_REGISTER_NAME = "onEnd";
    public static final String EVENT_ON_PROGRESS_REGISTER_NAME = "onProgress";
    public static final String EVENT_ON_CHANGE_DURATION_REGISTER_NAME = "onChangeDuration";
    public static final String EVENT_ON_UPDATE_BUFFER_PROGRESS_REGISTER_NAME = "onUpdateBufferProgress";
    public static final String EVENT_ON_TOGGLE_ANDROID_FULLSCREEN_REGISTER_NAME = "onToggleAndroidFullscreen";
    public static final String EVENT_ON_VIDEO_SIZE_REGISTER_NAME = "onVideoSize";
    public static final String EVENT_ON_VIDEO_SIZE = "on_video_size";
    public static final String EVENT_ON_ERROR = "on_error";
    public static final String EVENT_ON_ERROR_VIDEO_REGISTER_NAME = "onError";
    public static final int ONE_SEC = 1000;
    public static final String VIDEO_ID = "videoId";
    public static final String REFERENCE_ID = "referenceId";
    public static final String VIDEO_TOKEN = "videoToken";
    public static final String POLICY_KEY = "policyKey";
    public static final String ACCOUNT_ID = "accountId";
    public static final String PLAYLIST_ID = "playlistId";
    public static final String PLAYLIST_REFERENCE_ID = "playlistReferenceId";
    public static final String AUTO_PLAY = "autoPlay";
    public static final String PLAY = "play";
    public static final String DISABLE_DEFAULT_CONTROL = "disableDefaultControl";
    public static final String VOLUME = "volume";
    public static final String BITRATE = "bitRate";
    public static final String PLAYBACK_REPORT = "playbackRate";
    public static final String FULLSCREEN = "fullscreen";
    public static final String SEEK_DURATION = "seekDuration";
    public static final String HEIGHT = "height";
    public static final String WIDTH = "width";
    public static final String ERROR = "error";

    private final ReactApplicationContext applicationContext;

    public BrightcovePlayerManager(ReactApplicationContext context) {
        super();
        this.applicationContext = context;
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public BrightcovePlayerView createViewInstance(ThemedReactContext ctx) {
        return new BrightcovePlayerView(ctx, applicationContext);
    }

    @ReactProp(name = POLICY_KEY)
    public void setPolicyKey(BrightcovePlayerView view, String policyKey) {
        view.setPolicyKey(policyKey);
    }

    @ReactProp(name = ACCOUNT_ID)
    public void setAccountId(BrightcovePlayerView view, String accountId) {
        view.setAccountId(accountId);
    }

    /**
     * The videoId or referenceId should be present to load the player view
     */
    @ReactProp(name = VIDEO_ID)
    public void setVideoId(BrightcovePlayerView view, String videoId) {
        view.setVideoId(videoId);
    }

    @ReactProp(name = PLAYLIST_ID)
    public void setPlayListId(BrightcovePlayerView view, String playlistId) {
        view.setPlaylistId(playlistId);
    }

    @ReactProp(name = PLAYLIST_REFERENCE_ID)
    public void setPlayListReferenceId(BrightcovePlayerView view, String playlistReferenceId) {
        view.setPlaylistReferenceId(playlistReferenceId);
    }

    @ReactProp(name = REFERENCE_ID)
    public void setReferenceId(BrightcovePlayerView view, String referenceId) {
        view.setReferenceId(referenceId);
    }

    @ReactProp(name = VIDEO_TOKEN)
    public void setVideoToken(BrightcovePlayerView view, String videoToken) {
        view.setVideoToken(videoToken);
    }

    @ReactProp(name = AUTO_PLAY)
    public void setAutoPlay(BrightcovePlayerView view, boolean autoPlay) {
        view.setAutoPlay(autoPlay);
    }

    @ReactProp(name = PLAY)
    public void setPlay(BrightcovePlayerView view, boolean play) {
        view.setPlay(play);
    }

    @ReactProp(name = DISABLE_DEFAULT_CONTROL)
    public void setDefaultControlDisabled(BrightcovePlayerView view, boolean disableDefaultControl) {
        view.setDefaultControlDisabled(disableDefaultControl);
    }

    @ReactProp(name = VOLUME)
    public void setVolume(BrightcovePlayerView view, float volume) {
        view.setVolume(volume);
    }

    @ReactProp(name = BITRATE)
    public void setBitRate(BrightcovePlayerView view, float bitRate) {
        view.setBitRate((int) bitRate);
    }

    @ReactProp(name = PLAYBACK_REPORT)
    public void setPlaybackRate(BrightcovePlayerView view, float playbackRate) {
        view.setPlaybackRate(playbackRate);
    }

    @ReactProp(name = FULLSCREEN)
    public void setFullscreen(BrightcovePlayerView view, boolean fullscreen) {
        view.setFullscreen(fullscreen);
    }

    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of(
                EventType.SEEK_TO,
                COMMAND_SEEK_TO
        );
    }

    @ReactProp(name = SEEK_DURATION)
    public void setSeekDuration(BrightcovePlayerView view, double seekDuration) {
        view.setSeekDuration((long) seekDuration);
    }


    @Override
    public void receiveCommand(BrightcovePlayerView view, int commandType, @Nullable ReadableArray args) {
        Assertions.assertNotNull(view);
        Assertions.assertNotNull(args);
        if (commandType == COMMAND_SEEK_TO && args != null) {
            view.seekTo((long) (args.getDouble(0) * ONE_SEC));
        }
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }

    @Override
    public @Nullable
    Map<String, Object> getExportedCustomDirectEventTypeConstants() {
        Map<String, Object> map = new HashMap<>();
        map.put(EVENT_READY, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_READY_REGISTER_NAME));
        map.put(EVENT_PLAY, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_PLAY_REGISTER_NAME));
        map.put(EVENT_PAUSE, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_PAUSE_REGISTER_NAME));
        map.put(EVENT_END, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_END_REGISTER_NAME));
        map.put(EVENT_PROGRESS, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_PROGRESS_REGISTER_NAME));
        map.put(EVENT_CHANGE_DURATION, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_CHANGE_DURATION_REGISTER_NAME));
        map.put(EVENT_UPDATE_BUFFER_PROGRESS, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_UPDATE_BUFFER_PROGRESS_REGISTER_NAME));
        map.put(EVENT_TOGGLE_ANDROID_FULLSCREEN, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_TOGGLE_ANDROID_FULLSCREEN_REGISTER_NAME));
        map.put(EVENT_ON_PLAY_NEXT_VIDEO, (Object) MapBuilder.of(REGISTRATION_NAME, EVENT_ON_PLAY_NEXT_VIDEO_REGISTER_NAME));
        map.put(EVENT_ON_VIDEO_SIZE, MapBuilder.of(REGISTRATION_NAME, EVENT_ON_VIDEO_SIZE_REGISTER_NAME));
        map.put(EVENT_ON_ERROR, MapBuilder.of(REGISTRATION_NAME, EVENT_ON_ERROR_VIDEO_REGISTER_NAME));
        return map;
    }
}
