package com.vvt.phoenix.http.test;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.FxHttp;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.request.FxHttpRequest;
import com.vvt.phoenix.http.request.MethodType;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;

public class StopTaskTest implements FxHttpListener {
	// Debugging
	private static final String TAG = "StopTaskTest";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	// Constants
	private static final String FILE_PATH = "/sdcard/web.html";
	private static final String URL = "http://droidsans.com";
	
	// Members
	
	
	public void testStopTask(){
		// 1 create http component
		FxHttp httpClient = new FxHttp();
		httpClient.setHttpListener(this);
		
		// 2 create request
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl(URL);
		httpRequest.setMethod(MethodType.GET);
		
		// 3 execute
		httpClient.execute(httpRequest);
		
		// 4 Emergency stop !
		httpClient.forceStop();
	}

	@Override
	public void onHttpError(Throwable err, String msg) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHttpResponse(FxHttpResponse response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHttpSentProgress(SentProgress progress) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onHttpSuccess(FxHttpResponse result) {
		// TODO Auto-generated method stub
		
	}
}
