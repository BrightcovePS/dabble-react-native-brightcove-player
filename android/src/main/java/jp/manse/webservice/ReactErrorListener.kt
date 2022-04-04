package jp.manse.webservice

import android.util.Log

abstract class ReactErrorListener {
    private val tag = this.javaClass.simpleName
    fun onError(errors: List<ReactCatalogError?>) {
        Log.e(tag, errors.toString())
    }
}