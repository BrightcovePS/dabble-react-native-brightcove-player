package jp.manse.up_next;

import com.brightcove.player.model.Playlist;

import jp.manse.webservice.ReactErrorListener;

public abstract class ReactPlaylistListener extends ReactErrorListener {
    public ReactPlaylistListener() {
    }

    public abstract void onPlaylist(Playlist var1);
}

