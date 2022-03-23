package jp.manse.webservice;

import com.brightcove.player.edge.CatalogError;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public final class EdgeTaskResult<T> {
    private T result;
    private List<CatalogError> errorList = new ArrayList();

    EdgeTaskResult(T result) {
        this.result = result;
    }

    EdgeTaskResult(List<CatalogError> errorlist) {
        this.errorList.addAll(errorlist);
    }

    public T getResult() {
        return this.result;
    }

    public List<CatalogError> getErrorList() {
        return Collections.unmodifiableList(this.errorList);
    }
}