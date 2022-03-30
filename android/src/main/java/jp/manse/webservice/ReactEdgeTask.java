package jp.manse.webservice;

import androidx.annotation.NonNull;

import com.brightcove.player.edge.VideoParseException;
import com.brightcove.player.event.Component;
import com.brightcove.player.event.Emits;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventType;
import com.brightcove.player.event.ListensFor;
import com.brightcove.player.event.RegisteringEventEmitter;
import com.brightcove.player.network.HttpService;
import com.brightcove.player.util.ErrorUtil;
import com.brightcove.player.util.EventEmitterUtil;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.reflect.TypeToken;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

@Emits(
        events = {"analyticsCatalogRequest", "analyticsCatalogResponse", "error"}
)
@ListensFor(
        events = {}
)
public abstract class ReactEdgeTask<T>  implements Component {
    private static final String ERROR_CODE = "error_code";
    private static final String ERROR_SUB_CODE = "error_subcode";
    private static final String CATALOG_URL = "catalogUrl";
    private static final String RESPONSE_TIME_MS = "responseTimeMs";
    private static final String ANALYTICS_CATALOG_REQUEST = "analyticsCatalogRequest";
    private static final String ANALYTICS_CATALOG_RESPONSE = "analyticsCatalogResponse";
    private static final String MESSAGE = "message";
    private static final String MEDIA_REQUEST_INVALID_JSON = "mediaRequestInvalidJSON";
    private static final String MEDIA_REQUEST_NO_JSON = "mediaRequestNoJSON";
    private static final String VIDEO_PARSER_EXCEPTION = "videoParseException";
    private static final String URI_ERROR = "uriError";

    static final Gson GSON_ERROR_PARSER = (new GsonBuilder()).excludeFieldsWithoutExposeAnnotation().create();
    protected EventEmitter eventEmitter;
    protected List<String> errors;
    private final Call<JsonElement> apiCall;
    private long startResponseTimeMs;
    private final URL url;

    public ReactEdgeTask(@NonNull Call<JsonElement> apiCall, EventEmitter eventEmitter) {
        this.apiCall = apiCall;
        // Assign URL to send on analytics
        url = apiCall.request().url().url();
        this.eventEmitter = RegisteringEventEmitter.build(eventEmitter, ReactEdgeTask.class);
        this.errors = new ArrayList<>();
    }

    /**
    * Do the API call which is requested with retrofit Call object and process the response string into
     * [EdgeTaskResult] as return of response
    * */
    public void doCallAPICall() {
        // Put analytics entry while API call
        emitAnalyticsCatalogRequest(url);

        apiCall.enqueue(new Callback<JsonElement>() {
            @Override
            public void onResponse(@NonNull Call<JsonElement> call, @NonNull Response<JsonElement> response) {
                emitAnalyticsCatalogResponse(url);
                EdgeTaskResult<T> result;
                try {
                    if (response.body() == null) {
                        result = createErrorResult((new ReactCatalogError.Builder()).setMessage("No data was found that matched your request: " + url).build());
                        onPostExecute(result);
                        return;
                    }
                    String data = response.body().toString();
                    data = data.trim();
                    if (data.length() == 0) {
                        result = createErrorResult((new ReactCatalogError.Builder()).setMessage("No data was found that matched your request: " + url).build());
                    } else if (isArray(data)) {
                        result = createErrorResult(processError(data));
                    } else {
                        JSONObject jsonData = HttpService.parseToJSONObject(data);
                        result = createSuccessfulResult(processData(jsonData));
                    }
                    onPostExecute(result);
                }catch (Exception exception){
                    onFailureResponse(url, exception);
                }
            }

            @Override
            public void onFailure(@NonNull Call<JsonElement> call, @NonNull Throwable exception) {
                onFailureResponse(url, exception);
            }
        });
    }

    private void emitAnalyticsCatalogRequest(URL uri) {
        Map<String, Object> properties = new HashMap<>();
        try {
            properties.put(CATALOG_URL, uri.toURI());
        } catch (URISyntaxException exception) {
            exception.printStackTrace();
        }
        this.eventEmitter.emit(ANALYTICS_CATALOG_REQUEST, properties);
        this.startResponseTimeMs = System.currentTimeMillis();
    }

    private void emitAnalyticsCatalogResponse(URL uri) {
        Map<String, Object> properties = new HashMap<>();
        try {
            properties.put(CATALOG_URL, uri.toURI());
        } catch (URISyntaxException exception) {
            exception.printStackTrace();
        }
        long responseTimeMs = System.currentTimeMillis() - this.startResponseTimeMs;
        properties.put(RESPONSE_TIME_MS, responseTimeMs);
        this.eventEmitter.emit(ANALYTICS_CATALOG_RESPONSE, properties);
    }

    /**
     * Generate error based on exception and return in [onPostExecute
     * */
    private void onFailureResponse(URL url, Throwable exception){
        EdgeTaskResult<T> result;
        String errorMessage = getThrowableMessage(exception, url);
        result = createErrorResult((new ReactCatalogError.Builder()).setMessage(errorMessage).setError(exception).build());
        EventEmitterUtil.emitError(eventEmitter, errorMessage, new Exception(exception.getMessage()));
        onPostExecute(result);
    }

    private boolean isArray(String response) {
        return response.startsWith("[") && response.endsWith("]");
    }

    private EdgeTaskResult<T> createSuccessfulResult(T processData) {
        return new EdgeTaskResult<T>(processData);
    }

    private EdgeTaskResult<T> createErrorResult(ReactCatalogError error) {
        List<ReactCatalogError> errorList = new ArrayList<>();
        errorList.add(error);
        return new EdgeTaskResult(errorList);
    }

    private EdgeTaskResult<T> createErrorResult(List<ReactCatalogError> errorList) {
        return new EdgeTaskResult(errorList);
    }

    protected abstract T processData(@NonNull JSONObject data) throws Exception;

    protected abstract void onPostExecute(@NonNull EdgeTaskResult<T> data);

    private List<ReactCatalogError> processError(@NonNull String arrayData) {
        List<ReactCatalogError> catalogErrorList = (List) GSON_ERROR_PARSER.fromJson(arrayData, (new TypeToken<List<ReactCatalogError>>() {
        }).getType());

        for (ReactCatalogError catalogError : catalogErrorList) {
            Map<String, Object> properties = new HashMap<>();
            properties.put(ERROR_CODE, catalogError.getCatalogErrorCode());
            properties.put(ERROR_SUB_CODE, catalogError.getCatalogErrorSubcode());
            properties.put(MESSAGE, catalogError.getMessage());
            this.eventEmitter.emit(EventType.ERROR, properties);
        }

        return catalogErrorList;
    }

    @NonNull
    private String getThrowableMessage(Throwable throwable, URL params) {
        String message = "";
        if (throwable instanceof JSONException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage(MEDIA_REQUEST_INVALID_JSON), params);
        } else if (throwable instanceof IllegalArgumentException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage(MEDIA_REQUEST_NO_JSON), params);
        } else if (throwable instanceof VideoParseException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage(VIDEO_PARSER_EXCEPTION), params);
        } else if (throwable instanceof IOException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage(URI_ERROR), params);
        } else if (throwable.getLocalizedMessage() != null) {
            message = throwable.getLocalizedMessage();
        }

        return message;
    }

}
