package jp.manse.webservice

import com.brightcove.player.event.*
import jp.manse.up_next.GetAllVideoRepo
import jp.manse.up_next.ReactPlaylistListener

@Emits(events = ["account"])
@ListensFor(events = [])
open class ReactCatalog(eventEmitter: EventEmitter, apiConfig: APIConfig) :
    AbstractComponent(eventEmitter, ReactCatalog::class.java) {

    private val account: String = apiConfig.account
    private val apiService: APIService

    private fun emitAccountEvent() {
        val properties: MutableMap<String, Any> = HashMap()
        properties[Event.VALUE] = account
        eventEmitter.emit(EventType.ACCOUNT, properties)
    }

    fun getAllVideos(playlistListener: ReactPlaylistListener) {
        GetAllVideoRepo(eventEmitter, apiService, account).getVideos(playlistListener)
    }

    companion object {
        const val DEFAULT_EDGE_BASE_URL = "https://edge.api.brightcove.com/playback/v1/"
        const val DEFAULT_EPA_BASE_URL = "https://edge-auth.api.brightcove.com/playback/v1/"
        const val EMPTY_TEXT = ""
    }

    init {
        if (apiConfig.baseURL === EMPTY_TEXT) {
            apiConfig.baseURL =
                if (apiConfig.policy == EMPTY_TEXT) DEFAULT_EPA_BASE_URL else DEFAULT_EDGE_BASE_URL
        }

        apiService = APIService.create(eventEmitter, apiConfig)
        emitAccountEvent()
    }
}