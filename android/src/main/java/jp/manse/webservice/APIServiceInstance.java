package jp.manse.webservice;

import androidx.annotation.NonNull;

import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.util.Objects;

import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class APIServiceInstance {

    public static class Builder extends APIServiceInstance.AbstractBuilder<APIServiceInstance.Builder> {
        public Builder() {
            super();
        }

        protected APIServiceInstance.Builder self() {
            return this;
        }
    }

    protected abstract static class AbstractBuilder<T extends APIServiceInstance.AbstractBuilder<T>> {
        public static final String DEFAULT_EDGE_BASE_URL = "https://edge.api.brightcove.com/playback/v1/";
        public static final String DEFAULT_EPA_BASE_URL = "https://edge-auth.api.brightcove.com/playback/v1/";
        public static final long DEFAULT_TIME_OUT_MILLIS = 30000;
        private static final String EMPTY_BASE_URL = "";

        @NonNull
        private String policy;
        @NonNull
        private String brightcoveAuthorizationToken;
        @NonNull
        private String baseURL;
        private long timeoutInMillis = DEFAULT_TIME_OUT_MILLIS;

        protected AbstractBuilder() {
            this.policy = "";
            this.baseURL = "";
            this.brightcoveAuthorizationToken = "";
        }

        protected abstract T self();

        public T setPolicy(@NonNull String policy) {
            this.policy = (String) Objects.requireNonNull(policy, "Policy cannot be null");
            return this.self();
        }

        public T setBrightcoveAuthorizationToken(@NonNull String authorizationToken) {
            this.brightcoveAuthorizationToken = (String) Objects.requireNonNull(authorizationToken, "authorizationToken cannot be null");
            return this.self();
        }

        /**
         * Please apply [baseURL] if it is not default URL
         * "https://edge.api.brightcove.com/playback/v1"
         * "https://edge-auth.api.brightcove.com/playback/v1"
        * */
        public T setBaseURL(@NonNull String baseURL) {
            this.baseURL = (String) Objects.requireNonNull(baseURL, "Base URL cannot be null");
            return this.self();
        }

        /**
         * This timeout will apply for both call and response
         * */
        public T setTimeoutInMills(long timeout) {
            this.timeoutInMillis = (Long) Objects.requireNonNull(timeout, "Base URL cannot be null");
            return this.self();
        }

        /**
         * Create instance for API service class to proceed on Webservice.
         * If the [baseURL] is provided then we will go head default URL.
         * Also, we will configure OkHttpClient configurations as retrofit documentation.
         */
        public APIService build() {
            // If the baseURL is empty will apply default url here
            if (this.baseURL.equals(EMPTY_BASE_URL)) {
                this.baseURL = this.policy.equals(EMPTY_BASE_URL) ? DEFAULT_EPA_BASE_URL : DEFAULT_EDGE_BASE_URL;
            }

            // For logging
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);

            try {
                // For Request configuration
                OkHttpClient client = new OkHttpClient.Builder()
                        .addInterceptor(new HeaderInterceptor(policy))
                        .addInterceptor(logging)
                        .callTimeout(timeoutInMillis, TimeUnit.MILLISECONDS)
                        .readTimeout(timeoutInMillis, TimeUnit.MILLISECONDS)
                        .build();

                // Retrofit object initialization
                Retrofit retrofit = new Retrofit.Builder()
                        .baseUrl(baseURL)
                        .addConverterFactory(GsonConverterFactory.create())
                        .client(client)
                        .build();
                // Create instance for APIService from the Retrofit instance
                return retrofit.create(APIService.class);
            }
            catch (Exception exception){
                System.out.println("Retrofit Object init =============> "+ exception.getMessage());
            }

            return  null;
        }
    }
}
