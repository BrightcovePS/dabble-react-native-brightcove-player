package jp.manse.webservice;

import com.google.gson.JsonElement;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface APIService {
    String ALL_VIDEOS_END_POINT = "accounts/{account}/videos";
    String ACCOUNT = "account";
    String LIMIT = "limit";

    @GET(ALL_VIDEOS_END_POINT)
    Call<JsonElement> getAllVideos(@Path(ACCOUNT) String accountId, @Query(LIMIT) String pageSize);
}
