package jp.manse.webservice

import android.text.TextUtils
import com.brightcove.player.model.BrightcoveError
import com.brightcove.player.util.Objects
import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class ReactCatalogError private constructor(builder: Builder = Builder()) :
    BrightcoveError {

    @Expose
    @SerializedName("error_code")
    val catalogErrorCode: String

    @Expose
    @SerializedName("error_subcode")
    val catalogErrorSubcode: String

    @Expose
    @SerializedName("message")
    private val mMessage: String

    private val mError: Throwable? = builder.error

    override fun getErrorCode(): BrightcoveError.ErrorCode {
        return BrightcoveError.ErrorCode.CATALOG_ERROR
    }

    override fun getMessage(): String {
        return mMessage
    }

    override fun getThrowable(): Throwable? {
        return mError
    }

    override fun equals(other: Any?): Boolean {
        return if (this === other) {
            true
        } else if (other != null && this.javaClass == other.javaClass) {
            val that = other as ReactCatalogError
            catalogErrorCode == that.catalogErrorCode && catalogErrorSubcode == that.catalogErrorSubcode && mMessage == that.mMessage && mError == that.mError
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return java.util.Objects.hash(
            catalogErrorCode, catalogErrorSubcode, mMessage, mError
        )
    }

    override fun toString(): String {
        return "CatalogError{CatalogErrorCode='$catalogErrorCode', CatalogErrorSubcode='$catalogErrorSubcode', Message='$mMessage', Throwable=$mError}"
    }

    internal class Builder {
        var catalogErrorCode = ""
        var catalogErrorSubcode = ""
        var message: String? = null
        var error: Throwable? = null

        fun setCatalogErrorCode(catalogErrorCode: String) = apply {
            this.catalogErrorCode = Objects.requireNonNull(
                catalogErrorCode,
                "Catalog error code cannot be null"
            ) as String
        }

        fun setCatalogErrorSubcode(catalogErrorSubcode: String) = apply {
            this.catalogErrorSubcode = Objects.requireNonNull(
                catalogErrorSubcode,
                "Catalog error subcode cannot be null"
            ) as String
        }

        fun setMessage(message: String) = apply {
            this.message = Objects.requireNonNull(message, "Message cannot be null") as String
        }

        fun setError(error: Throwable?) = apply {
            this.error = error
        }

        fun build(): ReactCatalogError {
            if (TextUtils.isEmpty(message) && error != null && error!!.localizedMessage != null) {
                message = error!!.localizedMessage
            }
            return ReactCatalogError(this)
        }
    }

    companion object {
        private const val EMPTY = ""
    }

    init {
        catalogErrorCode = builder.catalogErrorCode
        catalogErrorSubcode = builder.catalogErrorSubcode
        mMessage = if (null == builder.message) EMPTY else builder.message!!
    }
}