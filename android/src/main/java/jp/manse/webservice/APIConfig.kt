package jp.manse.webservice

data class APIConfig(
    var policy: String = "",
    var account: String = "",
    var baseURL: String = "",
    var brightcoveAuthorizationToken: String = "",
    var callTimeoutInMillis: Long = DEFAULT_TIME_OUT_MILLIS,
    var readTimeoutInMillis: Long = DEFAULT_TIME_OUT_MILLIS
) {
    companion object {
        const val DEFAULT_TIME_OUT_MILLIS: Long = 30000
    }
}
