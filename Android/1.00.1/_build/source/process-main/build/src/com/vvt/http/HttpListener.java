package com.vvt.http;

import com.vvt.http.response.HttpResponse;
import com.vvt.http.response.SentProgress;

public interface HttpListener {
	
	//fields for AsyncCallback approach
	public static final int HTTP_CONNECT_ERROR = 1;
	public static final int HTTP_TRANSPORT_ERROR = 2;
	public static final int HTTP_ERROR = 3;
	public static final int HTTP_SENT_PROGRESS = 4;
	public static final int HTTP_RESPONSE = 5;
	public static final int HTTP_SUCCESS = 6;

	public void onHttpConnectError(Exception e);
	public void onHttpTransportError(Exception e);
	public void onHttpError(int httpStatusCode, Exception e);
	public void onHttpSentProgress(SentProgress progress);
	public void onHttpResponse(HttpResponse response);
	public void onHttpSuccess(HttpResponse response);
	
}
