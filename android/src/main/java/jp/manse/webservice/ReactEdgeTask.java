package jp.manse.webservice;

import android.os.AsyncTask;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.brightcove.player.edge.CatalogError;
import com.brightcove.player.edge.ErrorListener;
import com.brightcove.player.edge.VideoParseException;
import com.brightcove.player.event.Component;
import com.brightcove.player.event.Emits;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.ListensFor;
import com.brightcove.player.event.RegisteringEventEmitter;
import com.brightcove.player.network.HttpRequestConfig;
import com.brightcove.player.network.HttpService;
import com.brightcove.player.util.ErrorUtil;
import com.brightcove.player.util.EventEmitterUtil;
import com.brightcove.player.util.Objects;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Emits(
        events = {"analyticsCatalogRequest", "analyticsCatalogResponse", "error"}
)
@ListensFor(
        events = {}
)
public abstract class ReactEdgeTask<T> extends AsyncTask<URI, Void, EdgeTaskResult<T>> implements Component {
    private long startResponseTimeMs;
    static final Gson GSON_ERROR_PARSER = (new GsonBuilder()).excludeFieldsWithoutExposeAnnotation().create();
    private static final String BRIGHTCOVE_POLICY_HEADER_KEY = "BCOV-POLICY";
    protected EventEmitter eventEmitter;
    @NonNull
    protected String baseURL;
    @NonNull
    protected String account;
    @NonNull
    private String policy;
    protected URI uri;
    protected HttpService httpService;
    protected List<String> errors;
    protected final HttpRequestConfig httpRequestConfig;

    public ReactEdgeTask(@NonNull EventEmitter eventEmitter, @NonNull String baseURL, @NonNull HttpRequestConfig httpRequestConfig, @NonNull String account, @NonNull String policy) {
        this.eventEmitter = RegisteringEventEmitter.build(eventEmitter, ReactEdgeTask.class);
        this.baseURL = baseURL;
        this.account = account;
        this.policy = policy;
        this.httpService = new HttpService();
        this.errors = new ArrayList();
        this.httpRequestConfig = httpRequestConfig;
    }

    @NonNull
    protected EdgeTaskResult<T> doInBackground(URI... params) {
        if (params != null && params.length == 1) {
            this.uri = params[0];
            Map<String, String> headers = new HashMap();
            if (this.policy.equals("")) {
                this.maybeAddAuthTokenToHeaders(headers, this.httpRequestConfig.getBrightcoveAuthorizationToken());
            } else {
                headers.put(BRIGHTCOVE_POLICY_HEADER_KEY, this.policy);
            }

            headers.putAll(this.httpRequestConfig.getRequestHeaders());

            EdgeTaskResult result;
            try {
                this.emitAnalyticsCatalogRequest(this.uri);
                String data = this.httpService.doGetRequest(this.uri, headers);
                data = data == null ? null : data.trim();
                this.emitAnalyticsCatalogResponse();
                if (TextUtils.isEmpty(data)) {
                    result = this.createErrorResult((new ReactCatalogError.Builder()).setMessage("No data was found that matched your request: " + this.uri).build());
                } else if (this.isArray(data)) {
                    result = this.createErrorResult(this.processError(data));
                } else {
                    JSONObject jsonData = HttpService.parseToJSONObject(data);
                    result = this.createSuccessfulResult(this.processData(jsonData));
                }
            } catch (Exception var6) {
                String errorMessage = this.getThrowableMessage(var6, this.uri.toString());
                result = this.createErrorResult((new ReactCatalogError.Builder()).setMessage(errorMessage).setError(var6).build());
                EventEmitterUtil.emitError(this.eventEmitter, errorMessage, var6);
            }

            return result;
        } else {
            throw new IllegalArgumentException(ErrorUtil.getMessage("uriRequired"));
        }
    }

    private boolean isArray(String response) {
        return response.startsWith("[") && response.endsWith("]");
    }

    private EdgeTaskResult<T> createSuccessfulResult(T processData) {
        return new EdgeTaskResult(processData);
    }

    private EdgeTaskResult<T> createErrorResult(ReactCatalogError error) {
        List<ReactCatalogError> errorList = new ArrayList();
        errorList.add(error);
        return new EdgeTaskResult(errorList);
    }

    private EdgeTaskResult<T> createErrorResult(List<CatalogError> errorList) {
        return new EdgeTaskResult(errorList);
    }

    protected abstract T processData(@NonNull JSONObject var1) throws Exception;

    private List<CatalogError> processError(@NonNull String arrayData) {
        List<CatalogError> catalogErrorList = (List)GSON_ERROR_PARSER.fromJson(arrayData, (new TypeToken<List<CatalogError>>() {
        }).getType());
        Iterator var3 = catalogErrorList.iterator();

        while(var3.hasNext()) {
            CatalogError catalogError = (CatalogError)var3.next();
            Map<String, Object> properties = new HashMap();
            properties.put("error_code", catalogError.getCatalogErrorCode());
            properties.put("error_subcode", catalogError.getCatalogErrorSubcode());
            properties.put("message", catalogError.getMessage());
            this.eventEmitter.emit("error", properties);
        }

        return catalogErrorList;
    }

    private void emitAnalyticsCatalogRequest(URI uri) {
        Map<String, Object> properties = new HashMap();
        properties.put("catalogUrl", uri);
        this.eventEmitter.emit("analyticsCatalogRequest", properties);
        this.startResponseTimeMs = System.currentTimeMillis();
    }

    private void emitAnalyticsCatalogResponse() {
        Map<String, Object> properties = new HashMap();
        properties.put("catalogUrl", this.uri);
        long responseTimeMs = System.currentTimeMillis() - this.startResponseTimeMs;
        properties.put("responseTimeMs", responseTimeMs);
        this.eventEmitter.emit("analyticsCatalogResponse", properties);
    }

    private void maybeAddAuthTokenToHeaders(@NonNull Map<String, String> headers, @NonNull String authToken) {
        if (!TextUtils.isEmpty(authToken)) {
            headers.put("BCOV-Auth", authToken);
        }

    }

    protected URI createURI(String... params) throws URISyntaxException {
        StringBuilder urlBuilder = new StringBuilder();
        urlBuilder.append(this.baseURL);
        String key;
        if (params != null && params.length > 0) {
            String[] paramsTemp = params;
            int paramsLength = params.length;

            for(int i = 0; i < paramsLength; ++i) {
                key = paramsTemp[i];
                urlBuilder.append('/');
                urlBuilder.append(key);
            }
        }

        int counter = 0;
        Iterator queryParamsIterator = this.httpRequestConfig.getQueryParameters().entrySet().iterator();

        while(queryParamsIterator.hasNext()) {
            Map.Entry<String, String> entry = (Map.Entry)queryParamsIterator.next();
            key = (String)entry.getKey();
            String value = (String)entry.getValue();
            if (key != null && value != null) {
                if (counter == 0) {
                    urlBuilder.append('?');
                } else {
                    urlBuilder.append('&');
                }

                urlBuilder.append(key).append('=').append(value);
                ++counter;
            }
        }

        return new URI(urlBuilder.toString());
    }

    @NonNull
    private String getThrowableMessage(Throwable throwable, String... params) {
        String message = "";
        if (throwable instanceof JSONException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage("mediaRequestInvalidJSON"), (Object[])params);
        } else if (throwable instanceof IllegalArgumentException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage("mediaRequestNoJSON"), (Object[])params);
        } else if (throwable instanceof VideoParseException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage("videoParseException"), (Object[])params);
        } else if (throwable instanceof IOException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage("uriError"), (Object[])params);
        } else if (throwable.getLocalizedMessage() != null) {
            message = throwable.getLocalizedMessage();
        }

        return message;
    }

    public void callDeprecatedOnErrorStringCallback(@NonNull ErrorListener errorListener, @NonNull String message) {
        Objects.requireNonNull(errorListener, "ErrorListener cannot be null");
        Objects.requireNonNull(message, "Message cannot be null");
        if (!TextUtils.isEmpty(message)) {
            errorListener.onError(message);
        }

    }

}
