package com.fx.android.common.http;


public interface IHttpWrapperCallback {
	
	void onHttpResponse(HttpWrapperResponse aResponse, HttpWrapperException aException);

}
