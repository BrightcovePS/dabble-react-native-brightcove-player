package jp.manse.up_next

import com.brightcove.player.model.Playlist
import jp.manse.webservice.ReactErrorListener

abstract class ReactPlaylistListener : ReactErrorListener() {
    abstract fun onPlaylist(playlist: Playlist?)
}
