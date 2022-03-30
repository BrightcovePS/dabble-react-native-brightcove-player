package jp.manse.up_next;

import androidx.annotation.NonNull;


import com.brightcove.player.edge.PlaylistListener;
import com.brightcove.player.edge.VideoParseException;
import com.brightcove.player.edge.VideoParser;
import com.brightcove.player.event.Component;
import com.brightcove.player.event.Emits;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.ListensFor;
import com.brightcove.player.model.Playlist;
import com.google.gson.JsonElement;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;

import jp.manse.webservice.EdgeTaskResult;
import jp.manse.webservice.ReactCatalogError;
import jp.manse.webservice.ReactEdgeTask;
import retrofit2.Call;

@Emits(
        events = {}
)
@ListensFor(
        events = {}
)
public class GetAllVideosTask extends ReactEdgeTask<Playlist> implements Component {
    private ReactPlaylistListener playlistListener;

    public GetAllVideosTask(@NonNull Call<JsonElement> apiCall, @NonNull EventEmitter eventEmitter) {
        super(apiCall, eventEmitter);
    }

    public void getVideos(ReactPlaylistListener playlistListener) {
        this.playlistListener = playlistListener;
        doCallAPICall();
    }

    protected void onPostExecute(EdgeTaskResult<Playlist> result) {
        Playlist playlist = result.getResult();
        if (playlist != null) {
            this.playlistListener.onPlaylist(playlist);
        } else {
            List<ReactCatalogError> errorList = result.getErrorList();
            this.playlistListener.onError(errorList);
        }
    }

    protected Playlist processData(@NonNull JSONObject data) throws JSONException, VideoParseException {
        return VideoParser.buildPlaylistFromJSON(data, this.eventEmitter);
    }
}
