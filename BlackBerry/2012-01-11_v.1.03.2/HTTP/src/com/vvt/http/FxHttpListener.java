package com.vvt.http;

import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;

public interface FxHttpListener {
	
	public void onHttpError(Throwable err, String msg);	
	public void onHttpSentProgress(SentProgress progress);	
	public void onHttpResponse(FxHttpResponse response);	// for receiving server response (connection still working) 	
	public void onHttpSuccess(FxHttpResponse result);
}
