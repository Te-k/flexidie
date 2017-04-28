package com.vvt.phoenix.prot.test.simulation;

import javax.crypto.SecretKey;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;
import com.vvt.phoenix.prot.command.response.SendDeactivateResponse;
import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.UnstructuredManager;

public class DeactivationSimulator implements FxHttpListener {
	//Debug Information
	private static final String TAG = "DeactivationSimulator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Fields
	//private byte mState;
	private KeyExchangeResponse mKeyExchangeResponse;
	private SecretKey mAesKey;
	private boolean mIsEncrypt;
	
	//Constructor
	public DeactivationSimulator(){
		//mState = 0;
	}
	
	public void simulateDeactivation(){
		mIsEncrypt = true;
		runState0();
	}
	
	public void simulateDeactivationNoEncrypt(){
		mIsEncrypt = false;
		runState0();
	}
	
	/**
	 * State 0  = key exchange
	 */
	private void runState0(){
		/*KeyExchange keyExchange = new KeyExchange();
		keyExchange.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured");
		keyExchange.setKeyExchangeListener(this);
		keyExchange.doKeyExchange();*/
		
		UnstructuredManager uManager = new UnstructuredManager("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured");
		mKeyExchangeResponse = uManager.doKeyExchange(1, 1);
		
		/*//1 create
		FxHttpClient httpManager = new FxHttpClient(this);
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured");
		request.setMethod("POST");
		//request.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured");
		
		//2 prepare key exchange request
		KeyExchangeRequest keyEx = new KeyExchangeRequest();
		keyEx.setCode(0);
		keyEx.setEncodeType(1);		
		
		//3 parse data
		byte[] data = null;
		try {
			data = UnstructParser.parseRequest(keyEx);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		
		//4 set body of request
		PostByteItem byteItem = new PostByteItem();
		byteItem.setBytes(data);
		request.addDataItem(byteItem);
		request.addDataItem(data);
		
		//5 post it!
		httpManager.execute(request);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured", request, this);
*/	}
	
	/*private void runState1(){
		//1 perform Deactivation Request
		SendDeactivate req = new SendDeactivate();
		//1.1 set All header data
		Simulator.setRequestAttributes(req);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseClientRequest(req);
		
		//3 generate AES key
		mAesKey = AESKeyGenerator.generate();
		
		//4 construct request header (with encrypt)
		byte[] result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId(), 
				mAesKey, tail);
		
		//5 create http component
		FxHttp httpManager = new FxHttp();
		httpManager.setHttpListener(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway");
		httpRequest.setMethod("POST");
		//httpRequest.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway");
		
		//6 set body of http request
		PostByteItem byteItem = new PostByteItem();
		byteItem.setBytes(result);
		httpRequest.addDataItem(byteItem);
		
		httpRequest.addDataItem(result);
		
		//7 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
	}*/
	
	/*private void runState1NoEncrypt(){
		//1 perform Deactivation Request
		SendDeactivate req = new SendDeactivate();
		//1.1 set All header data
		Simulator.setRequestAttributes(req);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseClientRequest(req);
		
		//4 construct request header (non encrypt)
		byte[] result = Simulator.constructRequestHeaderNoEncrypt(mKeyExchangeResponse.getSessionId(), tail);
		
		//5 create http component
		FxHttp httpManager = new FxHttp();
		httpManager.setHttpListener(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway");
		httpRequest.setMethod("POST");
		//httpRequest.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway");
		
		//6 set body of http request
		PostByteItem byteItem = new PostByteItem();
		byteItem.setBytes(result);
		httpRequest.addDataItem(byteItem);
		
		httpRequest.addDataItem(result);
		
		//7 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
	}*/

	
	///////////////////////////////////////////////// Listener //////////////////////////////
	/*@Override
	public void onKeyExchangeError(Throwable err) {
		if(LOCAL_LOGE)Log.e(TAG, "onKeyExchangeError: "+err.getMessage());
		
	}

	@Override
	public void onKeyExchangeSuccess(KeyExchangeResponse keyExchangeResponse) {
		if(LOCAL_LOGE)Log.v(TAG, "onKeyExchangeSuccess");
		
		//2 initiate KeyExchageResponse
		mKeyExchangeResponse = keyExchangeResponse;
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+mKeyExchangeResponse.getCmdEcho()+"\nStatus Code: "+mKeyExchangeResponse.getStatusCode());
		
		if(mIsEncrypt)runState1();
		else runState1NoEncrypt();
	}*/
	
	@Override
	public void onHttpError(Throwable err, String msg) {
		//if(LOCAL_LOGE)Log.e(TAG, "In state "+mState+": "+err.getMessage());
		//if(LOCAL_LOGE)Log.e(TAG, "onHTTPError: "+err.getMessage());
		if(LOCAL_LOGE)Log.e(TAG, "onHTTPError: "+msg+": "+err.getMessage());
	}

	@Override
	//public void onHTTPProgress(String progress) {
	//public void onHTTPProgress(FxHttpStatusReporter progress) {
	public void onHttpSentProgress(SentProgress progress) {
		//if(LOCAL_LOGV)Log.v(TAG, "onHTTPProgress called");
		//SentProgress sentProgress = (SentProgress)progress;
		//Log.v(TAG, "HTTP progress: "+sentProgress);
		Log.v(TAG, "HTTP progress: "+progress);
	}
	
	@Override
	public void onHttpResponse(FxHttpResponse response) {
		// TODO Auto-generated method stub
		
	}

	@Override
	//public void onHTTPSuccess(byte[] result) {
	//public void onHTTPSuccess(FxHttpStatusReporter responseReporter) {
	public void onHttpSuccess(FxHttpResponse response) {
		if(LOCAL_LOGV)Log.v(TAG, "onHTTPSuccess called");
		
		//FxHttpResponse response = (FxHttpResponse) responseReporter;
		byte[] result = response.getBody();
		/*
		// key exchange state
		if(mState == 0){
			//1 write response to file
			//FileIO fileIO = new FileIO(mContext);
			try {
				FileIO.writeToFile("/sdcard/keyExchangeResponse.dat", result);
			} catch (FileNotFoundException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			} catch (IOException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			} catch (SecurityException e){
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			}
			
			//2 initiate KeyExchageResponse
			try {
				mKeyExchangeResponse = (KeyExchangeResponse) UnstructParser.parseResponse(result);
			} catch (DataCorruptedException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			}
			
			//3 goto next state (Activate)
			mState = 1;
			if(mIsEncrypt)runState1();
			else runState1NoEncrypt();
			
		}else if(mState == 1){ // send Activation
		*/				
			//processActivationResponse(result);
		SendDeactivateResponse responseObj = (SendDeactivateResponse) Simulator.constructResponseObject(result, mAesKey);
			
			//display some info
			if(LOCAL_LOGV){
				Log.v(TAG, "STATUS_CODE: "+responseObj.getStatusCode());
				Log.v(TAG, "Message: "+responseObj.getMessage());
			}
			
		//}
		
	}

	

	

}
