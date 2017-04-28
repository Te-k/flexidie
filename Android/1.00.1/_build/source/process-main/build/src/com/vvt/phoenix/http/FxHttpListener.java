package com.vvt.phoenix.http;

import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;

public interface FxHttpListener {

	public void onHttpError(Throwable err, String msg);
	
	public void onHttpSentProgress(SentProgress progress);
	
	// for receiving server response (connection still working)
	public void onHttpResponse(FxHttpResponse response); 
	
	public void onHttpSuccess(FxHttpResponse result);

	
}
