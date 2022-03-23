package jp.manse.webservice;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.brightcove.player.model.BrightcoveError;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import java.util.Objects;

public final class ReactCatalogError implements BrightcoveError {
    private static final String EMPTY = "";
    @Expose
    @SerializedName("error_code")
    @NonNull
    private final String mCatalogErrorCode;
    @Expose
    @SerializedName("error_subcode")
    @NonNull
    private final String mCatalogErrorSubcode;
    @Expose
    @SerializedName("message")
    @NonNull
    private final String mMessage;
    @Nullable
    private final Throwable mError;

    private ReactCatalogError() {
        this(new ReactCatalogError.Builder());
    }

    private ReactCatalogError(@NonNull ReactCatalogError.Builder builder) {
        this.mError = builder.error;
        this.mCatalogErrorCode = builder.catalogErrorCode;
        this.mCatalogErrorSubcode = builder.catalogErrorSubcode;
        this.mMessage = builder.message;
    }

    @NonNull
    public ErrorCode getErrorCode() {
        return ErrorCode.CATALOG_ERROR;
    }

    @NonNull
    public String getMessage() {
        return this.mMessage;
    }

    @Nullable
    public Throwable getThrowable() {
        return this.mError;
    }

    @NonNull
    public String getCatalogErrorCode() {
        return this.mCatalogErrorCode;
    }

    @NonNull
    public String getCatalogErrorSubcode() {
        return this.mCatalogErrorSubcode;
    }

    public boolean equals(Object o) {
        if (this == o) {
            return true;
        } else if (o != null && this.getClass() == o.getClass()) {
            ReactCatalogError that = (ReactCatalogError)o;
            return this.mCatalogErrorCode.equals(that.mCatalogErrorCode) && this.mCatalogErrorSubcode.equals(that.mCatalogErrorSubcode) && this.mMessage.equals(that.mMessage) && Objects.equals(this.mError, that.mError);
        } else {
            return false;
        }
    }

    public int hashCode() {
        return Objects.hash(new Object[]{this.mCatalogErrorCode, this.mCatalogErrorSubcode, this.mMessage, this.mError});
    }

    @NonNull
    public String toString() {
        return "CatalogError{CatalogErrorCode='" + this.mCatalogErrorCode + '\'' + ", CatalogErrorSubcode='" + this.mCatalogErrorSubcode + '\'' + ", Message='" + this.mMessage + '\'' + ", Throwable=" + this.mError + '}';
    }

    static class Builder {
        @NonNull
        private String catalogErrorCode = "";
        @NonNull
        private String catalogErrorSubcode = "";
        @NonNull
        private String message = "";
        @Nullable
        private Throwable error = null;

        Builder() {
        }

        ReactCatalogError.Builder setCatalogErrorCode(@NonNull String catalogErrorCode) {
            this.catalogErrorCode = (String)com.brightcove.player.util.Objects.requireNonNull(catalogErrorCode, "Catalog error code cannot be null");
            return this;
        }

        ReactCatalogError.Builder setCatalogErrorSubcode(@NonNull String catalogErrorSubcode) {
            this.catalogErrorSubcode = (String)com.brightcove.player.util.Objects.requireNonNull(catalogErrorSubcode, "Catalog error subcode cannot be null");
            return this;
        }

        ReactCatalogError.Builder setMessage(@NonNull String message) {
            this.message = (String)com.brightcove.player.util.Objects.requireNonNull(message, "Message cannot be null");
            return this;
        }

        ReactCatalogError.Builder setError(@Nullable Throwable error) {
            this.error = error;
            return this;
        }

        ReactCatalogError build() {
            if (TextUtils.isEmpty(this.message) && this.error != null && this.error.getLocalizedMessage() != null) {
                this.message = this.error.getLocalizedMessage();
            }

            return new ReactCatalogError(this);
        }
    }
}
