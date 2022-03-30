package jp.manse.webservice;

import android.util.Log;

import androidx.annotation.NonNull;

import java.util.List;

public abstract class ReactErrorListener {
    private final String TAG = this.getClass().getSimpleName();

    public ReactErrorListener() {
    }

    public void onError(@NonNull List<ReactCatalogError> errors) {
        Log.e(this.TAG, errors.toString());
    }
}