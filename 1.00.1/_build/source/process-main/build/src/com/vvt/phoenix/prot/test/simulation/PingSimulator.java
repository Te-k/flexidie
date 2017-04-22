package com.vvt.phoenix.prot.test.simulation;

import java.io.FileNotFoundException;
import java.io.IOException;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.http.FxHttp;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.request.FxHttpRequest;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;
import com.vvt.phoenix.prot.parser.UnstructProtParser;
import com.vvt.phoenix.prot.unstruct.PingResponse;
import com.vvt.phoenix.util.FileUtil;

public class PingSimulator implements FxHttpListener {
	//Debug Information
	private static final String TAG = "PingSimulator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	

	// Members
	//private PingRequest mPingRequest;
	private PingResponse mPingResponse;
	private String mUrl = "http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured";

	public void testPing(){
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ testPing() +++");
		}
		
		// 1 prepare request 
		//mPingRequest = new PingRequest();
		//mPingRequest.setCode(0);
		
		// 2 parse request
		byte[] data = null;
		try {
			//data = UnstructProtParser.parseRequest(mPingRequest);
			data = UnstructProtParser.parsePingRequet(1);
		} catch (Exception e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
		
		// write data to file
		try {
			FileUtil.writeToFile("/sdcard/PingRequest.dat", data);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		// 3 prepare http
		FxHttp http = new FxHttp();
		http.setHttpListener(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl(mUrl);
		httpRequest.setMethod("POST");
		httpRequest.addDataItem(data);
		
		// 4 Ping It !
		http.execute(httpRequest);
	}

	@Override
	public void onHttpError(Throwable err, String msg) {
		if(LOCAL_LOGE){
			Log.e(TAG, "+++ onHttpError +++");
			Log.e(TAG, msg);
		}
		
	}

	@Override
	public void onHttpResponse(FxHttpResponse response) {
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ onHttpResponse() +++");
		}
		
		
		// 1 get raw response and show response code
		byte[] result = response.getBody();
		Log.v(TAG, "Response code: "+response.getResponseCode());
		
		// 2 write raw response to file
		try {
			FileUtil.writeToFile("/sdcard/PingResponse.dat", result);
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (SecurityException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		// 3 initiate PingResponse
		try {
			mPingResponse = (PingResponse) UnstructProtParser.parsePingResponse(result);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
		
		// 4 display msg
		if(LOCAL_LOGV){
			//Log.v(TAG, "CMD echo: "+mPingResponse.getCmdEcho());
			Log.v(TAG, "Status Code: "+mPingResponse.getStatusCode());
		}
		
		
	}

	@Override
	public void onHttpSentProgress(SentProgress progress) {
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ onHttpSentProgress() +++");
		}
		
	}

	@Override
	public void onHttpSuccess(FxHttpResponse result) {
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ onHttpSuccess() +++");
		}
		
	}
}
