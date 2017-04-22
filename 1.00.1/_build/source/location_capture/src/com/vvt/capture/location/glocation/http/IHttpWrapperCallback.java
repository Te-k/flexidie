package com.vvt.capture.location.glocation.http;

public interface IHttpWrapperCallback {

	void onHttpResponse(HttpWrapperResponse aResponse,
			HttpWrapperException aException);

}
