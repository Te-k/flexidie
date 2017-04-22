package com.vvt.phoenix.http.test;

import java.io.FileNotFoundException;
import java.io.IOException;

import android.content.Context;
import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.FxHttp;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.request.ContentType;
import com.vvt.phoenix.http.request.FxHttpRequest;
import com.vvt.phoenix.http.request.MethodType;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;
import com.vvt.phoenix.util.FileUtil;

public class HttpTester implements FxHttpListener {
	//Debug Information
	private static final String TAG = "HttpTester";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;

	//Fields
	private Context mContext;
	private boolean mIsTestGetHtml;
	
	public void testGetHtml(){
		mIsTestGetHtml = true;
		
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://www.vervata.com");
		request.setMethod(MethodType.GET);
		//request.setConnecTimeOut(1);
		//request.setReadTimeOut(1);
		request.setContentType(ContentType.BINARY_STREAM);
		request.setRequestHeader("VVT", "FXS");	// just test
		
		FxHttp http = new FxHttp();
		http.setHttpListener(this);
		http.execute(request);
	}
	
	public void testGetImage(){
		mIsTestGetHtml = false;
		
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://www.vervata.com/images/logos/logo_vervata.jpg");
		request.setMethod("GET");
		
		FxHttp http = new FxHttp();
		http.setHttpListener(this);
		http.execute(request);
	}
	
///////////////////////////////////// http handler /////////////////////////////////////////////////////	
	@Override
	public void onHttpError(Throwable err, String msg) {
		if(LOCAL_LOGE)Log.e(TAG, "onHTTPError() called");
	
		if(LOCAL_LOGE)Log.e(TAG, "onHTTPError: "+msg+": "+err.getMessage());
	}

	@Override
	public void onHttpSentProgress(SentProgress progress) {
		if(LOCAL_LOGV){
			Log.v(TAG, "onHTTPProgress() -> "+progress);
		}
	}


	@Override
	public void onHttpResponse(FxHttpResponse response) {
		Log.v(TAG, "HTTP response: "+new String(response.getBody()));
		
	}
	
	@Override
	public void onHttpSuccess(FxHttpResponse result) {
		if(LOCAL_LOGV){
			Log.v(TAG, "onHTTPSuccess() called");
			if(mIsTestGetHtml){
				try {
					FileUtil.writeToFile("/sdcard/web.html", result.getBody());
				} catch (FileNotFoundException e) {
					if(LOCAL_LOGE)Log.e(TAG, "FileNotFoundException");
				} catch (SecurityException e) {
					if(LOCAL_LOGE)Log.e(TAG, "SecurityException");
				} catch (IOException e) {
					if(LOCAL_LOGE)Log.e(TAG, "IOException");
				}
				
				Log.v(TAG, "Webpage data has been stored at /sdcard/web.html");
			}else{
				try {
					FileUtil.writeToFile("/sdcard/image.jpg", result.getBody());
				} catch (FileNotFoundException e) {
					if(LOCAL_LOGE)Log.e(TAG, "FileNotFoundException");
				} catch (SecurityException e) {
					if(LOCAL_LOGE)Log.e(TAG, "SecurityException");
				} catch (IOException e) {
					if(LOCAL_LOGE)Log.e(TAG, "IOException");
				}
				
				Log.v(TAG, "Image data has been stored at /sdcard/image.jpg");
			}
		}
	}
	
}
