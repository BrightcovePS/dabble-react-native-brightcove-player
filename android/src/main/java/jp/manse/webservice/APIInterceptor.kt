package jp.manse.webservice

import android.text.TextUtils
import com.brightcove.player.event.*
import okhttp3.Interceptor
import okhttp3.Request
import okhttp3.Response
import java.net.URI
import java.net.URISyntaxException
import java.util.HashMap

@Emits(events = ["analyticsCatalogRequest", "analyticsCatalogResponse"])
@ListensFor(events = [])
class APIInterceptor(
    eventEmitter: EventEmitter,
    private val policy: String = "",
    private val brightcoveAuthorizationToken: String = ""
) : Interceptor, Component {

    private var startResponseTimeMs: Long = 0
    private var eventEmitter: EventEmitter =
        RegisteringEventEmitter.build(eventEmitter, APIInterceptor::class.java)

    override fun intercept(chain: Interceptor.Chain): Response {
        val requestBuilder: Request.Builder = chain.request()
            .newBuilder()
        // Apply token to every request to be authorized
        if (policy == "") {
            this.maybeAddAuthTokenToHeaders(brightcoveAuthorizationToken, requestBuilder)
        } else {
            requestBuilder.addHeader(
                BRIGHTCOVE_POLICY_HEADER_KEY,
                policy
            )
        }

        val request: Request = requestBuilder.build()

        val url = request.url.toUri()
        emitAnalyticsCatalogRequest(url)
        val response = chain.proceed(request)
        emitAnalyticsCatalogResponse(url)
        return response
    }

    private fun maybeAddAuthTokenToHeaders(authToken: String, requestBuilder: Request.Builder) {
        if (!TextUtils.isEmpty(authToken)) {
            requestBuilder.addHeader(BRIGHTCOVE_AUTH_HEADER_KEY, authToken)
        }
    }

    private fun emitAnalyticsCatalogRequest(uri: URI) {
        val properties: MutableMap<String, Any> = HashMap()
        try {
            properties[CATALOG_URL] = uri
        } catch (exception: URISyntaxException) {
            exception.printStackTrace()
        }
        eventEmitter.emit(ANALYTICS_CATALOG_REQUEST, properties)
        startResponseTimeMs = System.currentTimeMillis()
    }

    private fun emitAnalyticsCatalogResponse(uri: URI) {
        val properties: MutableMap<String, Any> = HashMap()
        try {
            properties[CATALOG_URL] = uri
        } catch (exception: URISyntaxException) {
            exception.printStackTrace()
        }
        val responseTimeMs = System.currentTimeMillis() - startResponseTimeMs
        properties[RESPONSE_TIME_MS] = responseTimeMs
        eventEmitter.emit(ANALYTICS_CATALOG_RESPONSE, properties)
    }

    companion object {
        private const val BRIGHTCOVE_POLICY_HEADER_KEY = "BCOV-POLICY"
        private const val BRIGHTCOVE_AUTH_HEADER_KEY = "BCOV-Auth"
        private const val CATALOG_URL = "catalogUrl"
        private const val RESPONSE_TIME_MS = "responseTimeMs"
        private const val ANALYTICS_CATALOG_REQUEST = "analyticsCatalogRequest"
        private const val ANALYTICS_CATALOG_RESPONSE = "analyticsCatalogResponse"
    }
}