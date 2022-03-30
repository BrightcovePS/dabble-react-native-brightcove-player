package jp.manse.webservice;


import android.text.TextUtils;

import androidx.annotation.NonNull;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

public class HeaderInterceptor implements Interceptor {
    private static final String BRIGHTCOVE_POLICY_HEADER_KEY = "BCOV-POLICY";
    private static final String BRIGHTCOVE_AUTH_HEADER_KEY = "BCOV-Auth";

    private final String policy;
    private String brightcoveAuthorizationToken;

    HeaderInterceptor(String policy) {
        this.policy = policy;
    }

    public void setBrightcoveAuthorizationToken(String brightcoveAuthorizationToken) {
        this.brightcoveAuthorizationToken = brightcoveAuthorizationToken;
    }

    @NonNull
    @Override
    public Response intercept(Chain chain) throws IOException {
        Request.Builder requestBuilder = chain.request()
                .newBuilder();
        // Apply token to every request to be authorized
        if (this.policy.equals("")) {
            this.maybeAddAuthTokenToHeaders(brightcoveAuthorizationToken, requestBuilder);
        } else {
            requestBuilder.addHeader(BRIGHTCOVE_POLICY_HEADER_KEY, this.policy);
        }
        Request request = requestBuilder.build();
        return chain.proceed(request);
    }

    private void maybeAddAuthTokenToHeaders(@NonNull String authToken, Request.Builder requestBuilder) {
        if (!TextUtils.isEmpty(authToken)) {
            requestBuilder.addHeader(BRIGHTCOVE_AUTH_HEADER_KEY, authToken);
        }
    }
}
