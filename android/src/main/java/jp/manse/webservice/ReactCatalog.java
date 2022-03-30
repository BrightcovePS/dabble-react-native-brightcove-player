package jp.manse.webservice;

import androidx.annotation.NonNull;

import com.brightcove.player.event.AbstractComponent;
import com.brightcove.player.event.Emits;
import com.brightcove.player.event.Event;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventType;
import com.brightcove.player.event.ListensFor;
import com.brightcove.player.util.Objects;
import com.google.gson.JsonElement;

import java.util.HashMap;
import java.util.Map;

import jp.manse.up_next.GetAllVideosTask;
import jp.manse.up_next.ReactPlaylistListener;
import retrofit2.Call;

@Emits(
        events = {"account"}
)
@ListensFor(
        events = {}
)
public class ReactCatalog extends AbstractComponent {
    private static final String ALL_VIDEOS_PAGE_SIZE = "1000";

    @NonNull
    private final String account;
    private final APIService apiService;

    protected ReactCatalog(ReactCatalog.AbstractBuilder<?> builder) {
        super(builder.eventEmitter, ReactCatalog.class);
        this.account = builder.account;
        String policy = builder.policy;
        String baseURL = builder.baseURL;
        apiService = new APIServiceInstance.Builder()
                .setPolicy(policy)
                .setBaseURL(baseURL)
                .build();
        this.emitAccountEvent();
    }

    private void emitAccountEvent() {
        Map<String, Object> properties = new HashMap<>();
        properties.put(Event.VALUE, this.account);
        this.eventEmitter.emit(EventType.ACCOUNT, properties);
    }

    public void getAllVideos(@NonNull ReactPlaylistListener playlistListener) {
        Call<JsonElement> getAllVideosCall = apiService.getAllVideos(account, ALL_VIDEOS_PAGE_SIZE);
        (new GetAllVideosTask(getAllVideosCall, this.eventEmitter)).getVideos(playlistListener);
    }


    public static class Builder extends ReactCatalog.AbstractBuilder<ReactCatalog.Builder> {
        public Builder(@NonNull EventEmitter eventEmitter, @NonNull String account) {
            super(eventEmitter, account);
        }

        protected ReactCatalog.Builder self() {
            return this;
        }
    }

    protected abstract static class AbstractBuilder<T extends ReactCatalog.AbstractBuilder<T>> {
        @NonNull
        private final EventEmitter eventEmitter;
        @NonNull
        private final String account;
        @NonNull
        private String policy;
        @NonNull
        private String baseURL;

        protected AbstractBuilder(@NonNull EventEmitter eventEmitter, @NonNull String account) {
            this.eventEmitter = (EventEmitter) Objects.requireNonNull(eventEmitter, "EventEmitter cannot be null");
            this.account = (String) Objects.requireNonNull(account, "Account cannot be null");
            this.policy = "";
            this.baseURL = "";
        }

        protected abstract T self();

        public T setPolicy(@NonNull String policy) {
            this.policy = (String) Objects.requireNonNull(policy, "Policy cannot be null");
            return this.self();
        }

        public T setBaseURL(@NonNull String baseURL) {
            this.baseURL = (String) Objects.requireNonNull(baseURL, "Base URL cannot be null");
            return this.self();
        }


        public ReactCatalog build() {
            return new ReactCatalog(this);
        }
    }
}
