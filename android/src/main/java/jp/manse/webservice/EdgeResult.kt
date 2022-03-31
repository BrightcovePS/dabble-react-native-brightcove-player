package jp.manse.webservice

import java.util.*

class EdgeResult<T> {
    private var result: T? = null
    private val errorList: MutableList<ReactCatalogError> = ArrayList()

    internal constructor(result: T) {
        this.result = result
    }

    internal constructor(errorList: List<ReactCatalogError>?) {
        this.errorList.addAll(errorList!!)
    }

    fun getResult(): T? {
        return result
    }

    fun getErrorList(): List<ReactCatalogError> {
        return Collections.unmodifiableList(errorList)
    }
}