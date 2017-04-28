package com.vvt.httpdemo;

import java.util.Arrays;

import android.app.Activity;
import android.os.Bundle;
import android.os.SystemClock;
import android.util.Log;

import com.vvt.http.Http;
import com.vvt.http.HttpListener;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.HttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.HttpResponse;
import com.vvt.http.response.SentProgress;

public class HttpDemoActivity extends Activity implements HttpListener{
	
	private static final String TAG = "HttpDemoActivity";
	
	private Http mHttp;
	private boolean mFinished;
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        mHttp = new Http();
        
        makeHttpReqeust();
       
        //test double request
        makeHttpReqeust();
        
    }
    
    private void makeHttpReqeust(){
    	HttpRequest request = new HttpRequest();
		//request.addDataItem("Hello Server".getBytes());
        byte[] input = {0x0, 0x64, 0x0, 0x1, 0x1};
        request.addDataItem(input);
		request.setConnectionTimeOut(60000);
		request.setContentType(ContentType.BINARY_OCTET_STREAM);
		request.setMethodType(MethodType.POST);
		//request.setUrl("http://192.168.2.60");
		request.setUrl("http://192.168.2.116/RainbowCore/gateway/unstructured");
		//request.setUrl("http://192.168.2.116/RainbowCore/gateway/xx");
		//request.setUrl("http://58.137.119.227:880/RainbowCore/gateway/unstructured");
		
		
		if(mHttp.execute(request, this)){
			Log.v(TAG, "Http is accepted our request.");
		}else{
			Log.w(TAG, "Http is not accepted our request.");
		}
    }
    
    @Override
	public void onHttpError(int httpStatusCode, Exception e) {
		Log.e(TAG, String.format("> onHttpError # code %d, message %s", httpStatusCode, e.getMessage()));
		
	}

	@Override
	public void onHttpSentProgress(SentProgress progress) {
		Log.v(TAG, String.format("> onHttpSentProgress # Sending %d bytes from %d bytes", progress.getSentSize(), progress.getTotalSize()));
	}

	@Override
	public void onHttpResponse(HttpResponse response) {
		Log.v(TAG, String.format("> onHttpResponse #\nCode: %d\nContent Type: %s\nBody: %s", 
				response.getResponseCode(), response.getResponseContentType().toString(), Arrays.toString(response.getBody())));
		
		ContentType requestMimeType = response.getHttpRequest().getContentType();
		//requestMimeType = ContentType.FORM_POST;
		ContentType responseMimeType = response.getResponseContentType();
		if(requestMimeType == responseMimeType){
			Log.i(TAG, "> onHttpResponse # MIME type is correct");
		}else{
			Log.w(TAG, "> onHttpResponse # MIME type is not correct");
		}
	}

	@Override
	public void onHttpSuccess(HttpResponse response) {
		Log.i(TAG, String.format("> onHttpSuccess #\nCode: %d\nContent Type: %s\nBody: %s", 
				response.getResponseCode(), response.getResponseContentType().toString(), Arrays.toString(response.getBody())));
		
		//test request again
		if(!mFinished){
			SystemClock.sleep(100);
			makeHttpReqeust();
			mFinished = true;
		}
	}

	@Override
	public void onHttpConnectError(Exception e) {
		Log.e(TAG, String.format("> onHttpConnectError # Message : %s", e.getMessage()));
	}

	@Override
	public void onHttpTransportError(Exception e) {
		Log.e(TAG, String.format("> onHttpTransportError # Message : %s", e.getMessage()));
		
	}
}