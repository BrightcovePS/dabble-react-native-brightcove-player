package jp.manse.webservice

import com.brightcove.player.event.EventEmitter
import com.google.gson.JsonElement
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.adapter.rxjava.RxJavaCallAdapterFactory
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query
import rx.Observable
import java.lang.Exception
import java.util.concurrent.TimeUnit

interface APIService {

    @GET("accounts/{account}/videos")
    fun getAllVideos(
        @Path("account") accountId: String,
        @Query("limit") pageSize: String
    ): Observable<Response<JsonElement>>

    companion object {
        fun create(eventEmitter: EventEmitter, apiConfig: APIConfig): APIService {
            // For logging
            val logging = HttpLoggingInterceptor()
            logging.setLevel(HttpLoggingInterceptor.Level.BODY)

            // For Request configuration
            val client: OkHttpClient = OkHttpClient.Builder()
                .addInterceptor(
                    APIInterceptor(
                        eventEmitter,
                        apiConfig.policy,
                        apiConfig.brightcoveAuthorizationToken
                    )
                )
                .addInterceptor(logging)
                .callTimeout(apiConfig.callTimeoutInMillis, TimeUnit.MILLISECONDS)
                .readTimeout(apiConfig.readTimeoutInMillis, TimeUnit.MILLISECONDS)
                .build()

            // Retrofit object initialization
            val retrofit: Retrofit = Retrofit.Builder()
                .baseUrl(apiConfig.baseURL)
                .addCallAdapterFactory(RxJavaCallAdapterFactory.create())
                .addConverterFactory(GsonConverterFactory.create())
                .client(client)
                .build()

            // Create instance for APIService from the Retrofit instance
            return retrofit.create(APIService::class.java)
        }
    }
}