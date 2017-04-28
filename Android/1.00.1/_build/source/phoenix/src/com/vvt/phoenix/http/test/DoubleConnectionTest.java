package com.vvt.phoenix.http.test;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.FxHttp;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.request.FxHttpRequest;
import com.vvt.phoenix.http.request.MethodType;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;
import com.vvt.phoenix.util.FileUtil;

public class DoubleConnectionTest implements FxHttpListener {
	// Debugging
	private static final String TAG = "DoubleConnectionTest";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	// Constants
	private static final String URL_1 = "http://www.vervata.com";
	private static final String FILE_PATH_1 = "/sdcard/web_1.html";
	private static final String HEADER_PATH_1 = "/sdcard/web_1_header.txt";
	private static final String URL_2 = "http://www.flexispy.com";
	private static final String FILE_PATH_2 = "/sdcard/web_2.html";
	private static final String HEADER_PATH_2 = "/sdcard/web_2_header.txt";
	
	// Members
	private FxHttpRequest httpRequest1;
	private FxHttpRequest httpRequest2;
	
	public void testDoubleGet(){
		// 1 create first http component
		FxHttp httpClient1 = new FxHttp();
		httpClient1.setHttpListener(this);
		// 2 create first request
		httpRequest1 = new FxHttpRequest();
		httpRequest1.setUrl(URL_1);
		httpRequest1.setMethod(MethodType.GET);
		
		// 3 create second http component
		FxHttp httpClient2 = new FxHttp();
		httpClient2.setHttpListener(this);
		// 4 create second request
		httpRequest2 = new FxHttpRequest();
		httpRequest2.setUrl(URL_2);
		httpRequest2.setMethod(MethodType.GET);
		
		// 5 execute both request
		httpClient1.execute(httpRequest1);
		httpClient2.execute(httpRequest2);
		
	}

	@Override
	public void onHttpError(Throwable err, String msg) {
		if(LOCAL_LOGE){
			Log.e(TAG, "+++ onHttpError() +++");
			Log.e(TAG, msg);
		}
		
		
	}
	
	@Override
	public void onHttpSentProgress(SentProgress progress) {
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ onHttpSentProgress +++");
		}
	}

	@Override
	public void onHttpResponse(FxHttpResponse response) {
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ onHttpResponse +++");
		}
		
		try{
			if(response.getRequest().equals(httpRequest1)){
				FileUtil.appendToFile(FILE_PATH_1, response.getBody());	
				
			}else if(response.getRequest().equals(httpRequest2)){
				FileUtil.appendToFile(FILE_PATH_2, response.getBody());
				
			}
		}catch(FileNotFoundException fe){
			Log.e(TAG, "FileNotFoundException: "+fe.getMessage());
			return;
		}catch(SecurityException se){
			Log.e(TAG, "SecurityException: "+se.getMessage());
			return;
		}catch(IOException ioe){
			Log.e(TAG, "IOException: "+ioe.getMessage());
			return;
		}
		
	}

	@Override
	public void onHttpSuccess(FxHttpResponse result) {
		if(LOCAL_LOGV){
			Log.v(TAG, "+++ onHttpSuccess +++");
		}
		
		try{
			if(result.getRequest().equals(httpRequest1)){
				//FileUtil.writeToFile(FILE_PATH_1, result.getBody());	
				writeHeaderToFile(result, HEADER_PATH_1);
				
			}else if(result.getRequest().equals(httpRequest2)){
				//FileUtil.writeToFile(FILE_PATH_2, result.getBody());
				writeHeaderToFile(result, HEADER_PATH_2);
				
			}
			
		}catch(SecurityException se){
			Log.e(TAG, "SecurityException: "+se.getMessage());
			return;
		}
		
	}
	
	private void writeHeaderToFile(FxHttpResponse response, String filepaht){
		Map<String, List<String>> header = response.getAllHeader();
		Iterator<String> keyIter = header.keySet().iterator();
		while(keyIter.hasNext()){
			String key = keyIter.next();
			String value = header.get(key).get(0);
			try {
				FileUtil.appendToFile(filepaht, value.getBytes());
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
			//Log.v(TAG, "Key: "+key+", Value: "+header.get(key));
		}
	}
}
