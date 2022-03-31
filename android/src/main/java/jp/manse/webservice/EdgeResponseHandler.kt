package jp.manse.webservice

import com.brightcove.player.edge.VideoParseException
import com.brightcove.player.event.*
import com.brightcove.player.network.HttpService
import com.brightcove.player.util.ErrorUtil
import com.brightcove.player.util.EventEmitterUtil
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonElement
import com.google.gson.reflect.TypeToken
import org.json.JSONException
import org.json.JSONObject
import retrofit2.Response
import java.io.IOException
import java.net.URL
import java.util.*

@Emits(events = ["error"])
@ListensFor(events = [])
abstract class EdgeResponseHandler<T>(
    eventEmitter: EventEmitter?
) : Component {

    private var eventEmitter: EventEmitter =
        RegisteringEventEmitter.build(eventEmitter, EdgeResponseHandler::class.java)
    private var startResponseTimeMs: Long = 0

    @Throws(Exception::class)
    protected abstract fun processData(data: JSONObject): T

    protected abstract fun onPostExecute(data: EdgeTaskResult<T>)

    /**
     * Do the API call which is requested with retrofit Call object and process the response string into
     * [EdgeTaskResult] as return of response
     */
    fun parseResponse(response: Response<JsonElement>) {
        val result: EdgeTaskResult<T>
        try {
            if (response.body() == null) {
                result = createErrorResult(
                    ReactCatalogError.Builder().setMessage(
                        "No data was found that matched your request"
                    ).build()
                )
                onPostExecute(result)
                return
            }
            var data = response.body().toString()
            data = data.trim { it <= ' ' }
            result = when {
                data.isEmpty() -> {
                    createErrorResult(
                        ReactCatalogError.Builder().setMessage(
                            "No data was found that matched your request"
                        ).build()
                    )
                }
                isArray(data) -> {
                    createErrorResult(processError(data))
                }
                else -> {
                    val jsonData = HttpService.parseToJSONObject(data)
                    createSuccessfulResult(processData(jsonData))
                }
            }
            onPostExecute(result)
        } catch (exception: Exception) {
            onFailureResponse(exception, response.raw().request.url.toUrl())
        }
    }

    /**
     * Generate error based on exception and return in [onPostExecute]
     */
    protected fun onFailureResponse(exception: Throwable, url: URL? = null) {
        val result: EdgeTaskResult<T>
        val errorMessage = if (url == null) "" else getThrowableMessage(exception, url)
        result = createErrorResult(
            ReactCatalogError.Builder().setMessage(errorMessage).setError(exception).build()
        )
        EventEmitterUtil.emitError(eventEmitter, errorMessage, Exception(exception.message))
        onPostExecute(result)
    }

    private fun isArray(response: String): Boolean {
        return response.startsWith("[") && response.endsWith("]")
    }

    private fun createSuccessfulResult(processData: T): EdgeTaskResult<T> {
        return EdgeTaskResult(processData)
    }

    private fun createErrorResult(error: ReactCatalogError): EdgeTaskResult<T> {
        val errorList: MutableList<ReactCatalogError> = ArrayList()
        errorList.add(error)
        return EdgeTaskResult(errorList)
    }

    private fun createErrorResult(errorList: List<ReactCatalogError>): EdgeTaskResult<T> {
        return EdgeTaskResult<T>(errorList)
    }

    private fun processError(arrayData: String): List<ReactCatalogError> {
        val catalogErrorList: List<ReactCatalogError> = GSON_ERROR_PARSER.fromJson(
            arrayData,
            object : TypeToken<List<ReactCatalogError?>?>() {}.type
        ) as List<ReactCatalogError>
        for (catalogError in catalogErrorList) {
            val properties: MutableMap<String, Any> = HashMap()
            properties[ERROR_CODE] = catalogError.catalogErrorCode
            properties[ERROR_SUB_CODE] = catalogError.catalogErrorSubcode
            properties[MESSAGE] = catalogError.message
            eventEmitter.emit(EventType.ERROR, properties)
        }
        return catalogErrorList
    }

    private fun getThrowableMessage(throwable: Throwable, params: URL): String {
        var message = ""
        if (throwable is JSONException) {
            message = String.format(
                Locale.getDefault(), ErrorUtil.getMessage(
                    MEDIA_REQUEST_INVALID_JSON
                ), params
            )
        } else if (throwable is IllegalArgumentException) {
            message = String.format(
                Locale.getDefault(),
                ErrorUtil.getMessage(MEDIA_REQUEST_NO_JSON),
                params
            )
        } else if (throwable is VideoParseException) {
            message = String.format(
                Locale.getDefault(),
                ErrorUtil.getMessage(VIDEO_PARSER_EXCEPTION),
                params
            )
        } else if (throwable is IOException) {
            message = String.format(Locale.getDefault(), ErrorUtil.getMessage(URI_ERROR), params)
        } else if (throwable.localizedMessage != null) {
            message = throwable.localizedMessage!!
        }
        return message
    }

    companion object {
        val GSON_ERROR_PARSER: Gson = GsonBuilder().excludeFieldsWithoutExposeAnnotation().create()
        private const val ERROR_CODE = "error_code"
        private const val ERROR_SUB_CODE = "error_subcode"
        private const val MESSAGE = "message"
        private const val MEDIA_REQUEST_INVALID_JSON = "mediaRequestInvalidJSON"
        private const val MEDIA_REQUEST_NO_JSON = "mediaRequestNoJSON"
        private const val VIDEO_PARSER_EXCEPTION = "videoParseException"
        private const val URI_ERROR = "uriError"
    }
}