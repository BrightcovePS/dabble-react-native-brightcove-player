package jp.manse.webservice;

import androidx.annotation.NonNull;

import com.brightcove.player.edge.PlaylistListener;
import com.brightcove.player.event.AbstractComponent;
import com.brightcove.player.event.Emits;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.ListensFor;
import com.brightcove.player.network.HttpRequestConfig;
import com.brightcove.player.util.Objects;

import java.util.HashMap;
import java.util.Map;

import jp.manse.up_next.GetAllVideosTask;

@Emits(
        events = {"account"}
)
@ListensFor(
        events = {}
)
public class ReactCatalog extends AbstractComponent {
    public static final String DEFAULT_EDGE_BASE_URL = "https://edge.api.brightcove.com/playback/v1";
    public static final String DEFAULT_EPA_BASE_URL = "https://edge-auth.api.brightcove.com/playback/v1";
    @NonNull
    private final String account;
    @NonNull
    private final String policy;
    @NonNull
    private final String baseURL;
    Map<String, String> properties;

    protected ReactCatalog(ReactCatalog.AbstractBuilder<?> builder) {
        super(builder.eventEmitter, com.brightcove.player.edge.Catalog.class);
        this.account = builder.account;
        this.policy = builder.policy;
        this.baseURL = builder.baseURL;
        this.properties = builder.properties;
        this.emitAccountEvent();
    }

    private void emitAccountEvent() {
        Map<String, Object> properties = new HashMap();
        properties.put("value", this.account);
        this.eventEmitter.emit("account", properties);
    }

    public void getAllVideos(@NonNull HttpRequestConfig httpRequestConfig, @NonNull PlaylistListener playlistListener) {
        (new GetAllVideosTask(this.eventEmitter, this.baseURL, httpRequestConfig, this.account, this.policy)).getVideos(playlistListener);
    }

    public Map<String, String> getProperties() {
        return this.properties;
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
        private static final String EMPTY_BASE_URL = "";
        @NonNull
        private final EventEmitter eventEmitter;
        @NonNull
        private final String account;
        @NonNull
        private String policy;
        @NonNull
        private String baseURL;
        @NonNull
        private Map<String, String> properties;

        protected abstract T self();

        protected AbstractBuilder(@NonNull EventEmitter eventEmitter, @NonNull String account) {
            this.eventEmitter = (EventEmitter)Objects.requireNonNull(eventEmitter, "EventEmitter cannot be null");
            this.account = (String)Objects.requireNonNull(account, "Account cannot be null");
            this.policy = "";
            this.baseURL = "";
            this.properties = new HashMap();
        }

        public T setPolicy(@NonNull String policy) {
            this.policy = (String)Objects.requireNonNull(policy, "Policy cannot be null");
            return this.self();
        }

        public T setBaseURL(@NonNull String baseURL) {
            this.baseURL = (String)Objects.requireNonNull(baseURL, "Base URL cannot be null");
            return this.self();
        }

        public T setProperties(@NonNull Map<String, String> properties) {
            this.properties = (Map)Objects.requireNonNull(properties, "properties Map cannot be null");
            return this.self();
        }

        public ReactCatalog build() {
            if (this.baseURL.equals(EMPTY_BASE_URL)) {
                this.baseURL = this.policy.equals(EMPTY_BASE_URL) ? DEFAULT_EPA_BASE_URL : DEFAULT_EDGE_BASE_URL;
            }

            return new ReactCatalog(this);
        }
    }
}
