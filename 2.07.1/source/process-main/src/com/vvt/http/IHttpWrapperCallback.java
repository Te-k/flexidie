package com.vvt.http;

public interface IHttpWrapperCallback {
	void onHttpResponse(HttpWrapperResponse aResponse, HttpWrapperException aException);
}
