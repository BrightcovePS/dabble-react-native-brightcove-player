package jp.manse.up_next;

import androidx.annotation.NonNull;


import com.brightcove.player.edge.BrightcoveTokenAuthorizer;
import com.brightcove.player.edge.CatalogError;
import com.brightcove.player.edge.PlaylistListener;
import com.brightcove.player.edge.VideoParseException;
import com.brightcove.player.edge.VideoParser;
import com.brightcove.player.event.Component;
import com.brightcove.player.event.Emits;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.ListensFor;
import com.brightcove.player.model.Playlist;
import com.brightcove.player.model.Video;
import com.brightcove.player.network.HttpRequestConfig;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.Iterator;
import java.util.List;

import jp.manse.webservice.EdgeTaskResult;
import jp.manse.webservice.ReactEdgeTask;

@Emits(
        events = {}
)
@ListensFor(
        events = {}
)
public class GetAllVideosTask extends ReactEdgeTask<Playlist> implements Component {
    private PlaylistListener playlistListener;

    public GetAllVideosTask(@NonNull EventEmitter eventEmitter, @NonNull String baseURL, @NonNull HttpRequestConfig httpRequestConfig, @NonNull String account, @NonNull String policy) {
        super(eventEmitter, baseURL, httpRequestConfig, account, policy);
    }

    public void getVideos(PlaylistListener playlistListener) {
        this.playlistListener = playlistListener;

        try {
            URI uri = this.createURI("accounts", this.account, "videos");
            this.execute(uri);
        } catch (URISyntaxException var4) {
            var4.printStackTrace();
        }
    }

    protected void onPostExecute(EdgeTaskResult<Playlist> result) {
        Playlist playlist = result.getResult();
        if (playlist != null) {
            this.playlistListener.onPlaylist(playlist);
        } else {
            List<CatalogError> errorList = result.getErrorList();
            this.playlistListener.onError(errorList);
            if (errorList.size() == 1) {
                this.callDeprecatedOnErrorStringCallback(this.playlistListener, ((CatalogError) errorList.get(0)).getMessage());
            }
        }

    }

    protected Playlist processData(@NonNull JSONObject data) throws JSONException, VideoParseException {
        Playlist playlist = VideoParser.buildPlaylistFromJSON(data, this.eventEmitter);
        this.configureAuthorizationTokenToPlaylistVideos(playlist);
        return playlist;
    }

    private void configureAuthorizationTokenToPlaylistVideos(@NonNull Playlist playlist) {
        BrightcoveTokenAuthorizer authorizer = new BrightcoveTokenAuthorizer();

        for (Video video : playlist.getVideos()) {
            authorizer.configure(video, this.httpRequestConfig.getBrightcoveAuthorizationToken());
        }

    }
}
