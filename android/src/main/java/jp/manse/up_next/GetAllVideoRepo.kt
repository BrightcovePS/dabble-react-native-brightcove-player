package jp.manse.up_next

import com.brightcove.player.edge.VideoParseException
import com.brightcove.player.edge.VideoParser
import com.brightcove.player.event.Component
import com.brightcove.player.event.EventEmitter
import com.brightcove.player.model.Playlist
import jp.manse.webservice.APIService
import jp.manse.webservice.EdgeResponseHandler
import jp.manse.webservice.EdgeTaskResult
import jp.manse.webservice.ReactCatalogError
import org.json.JSONException
import org.json.JSONObject
import rx.android.schedulers.AndroidSchedulers
import rx.schedulers.Schedulers

class GetAllVideoRepo(
    private val eventEmitter: EventEmitter,
    private val apiService: APIService,
    private val account: String,
    private var pageSize: String = ALL_VIDEOS_PAGE_SIZE
) : Component, EdgeResponseHandler<Playlist>(eventEmitter) {

    private var playlistListener: ReactPlaylistListener? = null

    fun getVideos(playlistListener: ReactPlaylistListener) {
        this.playlistListener = playlistListener
        val allVideosObservable = apiService.getAllVideos(account, pageSize)
        allVideosObservable.subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({
                parseResponse(it)
            }, {
                onFailureResponse(it)
            })
        allVideosObservable.subscribe {

        }
    }

    companion object {
        private const val ALL_VIDEOS_PAGE_SIZE = "1000"
    }

    @Throws(JSONException::class, VideoParseException::class)
    override fun processData(data: JSONObject): Playlist {
        return VideoParser.buildPlaylistFromJSON(data, eventEmitter)
    }

    override fun onPostExecute(data: EdgeTaskResult<Playlist>) {
        val playlist = data.getResult()
        if (playlist != null) {
            playlistListener!!.onPlaylist(playlist)
        } else {
            val errorList: List<ReactCatalogError> = data.getErrorList()
            playlistListener!!.onError(errorList)
        }
    }

}