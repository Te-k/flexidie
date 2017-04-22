package com.vvt.phoenix.prot.test.simulation;
/*package com.vvt.protocol.test.simulation;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import javax.crypto.SecretKey;

import android.util.Log;

import com.vvt.compressor.GZIPCompressor;
import com.vvt.compressor.GZIPListener;
import com.vvt.config.Customization;
import com.vvt.crc.CRC32Checksum;
import com.vvt.crc.CRC32Listener;
import com.vvt.crypto.AESCipher;
import com.vvt.crypto.AESEncryptListener;
import com.vvt.crypto.AESKeyGenerator;
import com.vvt.http.FxHttp;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.protocol.ProtocolParser;
import com.vvt.protocol.request.SendRequest;
import com.vvt.protocol.response.CommandNext;
import com.vvt.protocol.response.SendResponse;
import com.vvt.protocol.response.ServerResponse;
import com.vvt.protocol.unstruct.AcknowledgeListener;
import com.vvt.protocol.unstruct.Acknowledgement;
import com.vvt.protocol.unstruct.KeyExchange;
import com.vvt.protocol.unstruct.KeyExchangeListener;
import com.vvt.protocol.unstruct.response.AckResponse;
import com.vvt.protocol.unstruct.response.KeyExchangeResponse;
import com.vvt.util.FileUtil;

public class SendSimulator implements KeyExchangeListener, AcknowledgeListener, FxHttpListener, GZIPListener, AESEncryptListener, CRC32Listener {
	
	//Debug Information
	//private static final String TAG = "com.vvt.test.simulator.SendSimulator";
	private static final String TAG = "SendSimulator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Fields
	private byte mState;
	private KeyExchangeResponse mKeyExchangeResponse;
	private SecretKey mAesKey;
	private boolean mIsEncrypt;
	SendRequest mSendRequest;
	private FileInputStream mReadyPayload;
	
	//Constants
	private static final int EVENT_COUNT = 1048576;//10737418;	// build 1 GB payload
	private static final String DIR_PATH = "/sdcard/";
	private static final String PAYLOAD_PATH = DIR_PATH+"payload.dat";
	
	public SendSimulator(){
		mState = 0;
	}
	
	public void simulateSend(boolean isEncrypt){
		mIsEncrypt = isEncrypt;
		doKeyExchange();
		
		//TODO debug
		mState = 1;
		doSend();
	}
	
	
	*//**
	 * State 0  = key exchange
	 *//*
	private void doKeyExchange(){
		if(LOCAL_LOGV)Log.v(TAG, "start keyExchange...");
		
		KeyExchange keyExchange = new KeyExchange();
		keyExchange.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
		keyExchange.setKeyExchangeListener(this);
		keyExchange.doKeyExchange();
		
		//1 create
		FxHttpClient httpManager = new FxHttpClient(this);
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured");
		request.setMethod("POST");
		
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
		
		//6 debug
		try {
			FileIO.writeToFile(DIR_PATH+"keyExchangeSentData.dat", data);
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
	}
	
	private void doSend(){
		if(LOCAL_LOGV)Log.v(TAG, "start send request");
		//1 perform Send Request
		mSendRequest = new SendRequest();
		//1.1 set all request object attributes
		Simulator.setRequestAttributes(mSendRequest);
		//1.2 set ENCRYPTION_CODE
		mSendRequest.setEncryptionCode(1);
		//request.setEncryptionCode(0);
		//1.3 get payload
		FileInputStream payload = Simulator.createPayload(EVENT_COUNT, PAYLOAD_PATH);
		//FileInputStream payload = null;
		try {
			payload = FileUtil.getFileInputStream("/sdcard/payload.dat");
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (SecurityException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		//String payload = Simulator.createPayload();
		//1.4 compress payload
		if(payload != null){
			GZIPCompressor gzip = new GZIPCompressor();
			try {
				gzip.compress(payload,"/sdcard/payloadCompressed.dat", this);
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (SecurityException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}	
		
		//1.5 generate AES key
		mAesKey = AESKeyGenerator.generate();
		//1.6 encrypt payload
		byte[] smsEventEncrypted = null;
		try {
			smsEventEncrypted = AESCipher.encryptSynchronous(mAesKey, smsRawEvent);
		} catch (InvalidKeyException e) {
			if(LOCAL_LOGE)Log.e(TAG, "InvalidKeyException");
		}
		//1.7 set encrypted payload size
		request.setPayloadSize(smsEventEncrypted.length);
		//request.setPayloadSize(smsRawEvent.length);
		//1.8 set compression code
		request.setCompressionCode(0);	// not compress yet (^ ^")
		//1.9 set event count
		request.setEventCount(1);
		//1.10 set CRC32 of encrypted payload
		int crc = (int) CRC32Checksum.calculateSynchronous(smsEventEncrypted);
		//int crc = (int) CRC32Checksum.calculateSynchronous(smsRawEvent);
		request.setPayloadCrc32(crc);
		
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseRequest(request);
		
		//3 generate AES key
		//mAesKey = AESKeyGenerator.generate();
		
		//4 construct request header (with encrypt)
		byte[] result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId()
				,mAesKey, tail);
		//byte[] result = Simulator.constructRequestHeaderNoEncrypt(1, tail);	//force sessionID to 1
		
		//5 append with payload
		DataBuffer buffer = new DataBuffer();
		buffer.writeBytes(result);
		buffer.writeBytes(smsEventEncrypted);
		//buffer.writeBytes(smsRawEvent);
		
		//5 create http component
		FxHttpClient httpManager = new FxHttpClient();
		FxHttpRequest httpRequest = new FxHttpRequest();
		
		//6 set body of http request
		PostByteItem byteItem = new PostByteItem(buffer.toArray());
		httpRequest.addItem(byteItem);
		
		//7 post it!
		httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
		
		//TODO debug
		try {
			FileIO.writeToFile("/sdcard/sentData.txt", buffer.toArray());
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
	}
	
	private void doSendAcknowledge(){
		if(LOCAL_LOGV)Log.v(TAG, "send Acknowledge...");
		
		Acknowledgement acknowledge = new Acknowledgement();
		acknowledge.setAcknowledgeListener(this);
		acknowledge.setDeviceId("354957031517900");
		acknowledge.setSessionId(mKeyExchangeResponse.getSessionId());
		acknowledge.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway/unstructured");
		acknowledge.doAcknowledge();
		
		
		//1 create
		FxHttpClient httpManager = new FxHttpClient(this);
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured");
		request.setMethod("POST");
		
		//2 prepare key exchange request
		AckRequest ackReq = new AckRequest();
		ackReq.setCode(0);
		ackReq.setDeviceId("354957031517900".getBytes());
		ackReq.setSessionId(mKeyExchangeResponse.getSessionId());
		
		//3 parse data
		byte[] data = null;
		try {
			data = UnstructParser.parseRequest(ackReq);
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
		
	}
	
	@Override
	public void onCompressSuccess(FileInputStream result) {
		if(LOCAL_LOGV)Log.v(TAG, "onCompressSuccess() called");
		//1 generate AES key
		mAesKey = AESKeyGenerator.generate();
		//2 encrypt payload
		AESCipher cipher = new AESCipher();
		try {
			cipher.encryptASynchronous(mAesKey, result, "/sdcard/payloadEncrypted.dat", this);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//skip compression and go to calculate crc32
		//1 set payload size
		int payloadSize = 0;
		try {
			payloadSize = FileIO.readBytes(result).length;	// Warning ! after this line result will be alredy readed
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
		mSendRequest.setPayloadSize(payloadSize);
		
		//2 set compression code
		mSendRequest.setCompressionCode(1);
		
		//3 set event count
		mSendRequest.setEventCount(EVENT_COUNT);
		
		//4 calculate crc32
		try {
			result = FileIO.getFileInputStream(DIR_PATH+"payloadEncrypted.dat");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		CRC32Checksum crc = new CRC32Checksum();
		crc.calculateASynchronous(result, this);
		
	}	
	@Override
	public void onCompressError(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onCompressError() called");
			Log.e(TAG, err.getMessage());
		}
		
	}
	
	@Override
	public void onAESEncryptSuccess(FileInputStream result) {
		if(LOCAL_LOGV)Log.v(TAG, "onAESEncryptSuccess() called");
		//mReadyPayload = result;
		
		//1 set payload size
		int payloadSize = 0;
		try {
			payloadSize = FileUtil.readBytes(result).length;	// Warning ! after this line result will be alredy readed
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
		mSendRequest.setPayloadSize(payloadSize);
		
		//2 set compression code
		mSendRequest.setCompressionCode(1);
		
		//3 set event count
		mSendRequest.setEventCount(EVENT_COUNT);
		
		//4 calculate crc32
		try {
			result = FileUtil.getFileInputStream(DIR_PATH+"payloadEncrypted.dat");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		CRC32Checksum crc = new CRC32Checksum();
		crc.calculateASynchronous(result, this);
	
		
		
	}
	@Override
	public void onAESEncryptError(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onAESEncryptError() called");
			Log.e(TAG, err.getMessage());
		}
		
	}
	
	@Override
	public void onCalculateCRC32Success(long crc) {
		if(LOCAL_LOGV)Log.v(TAG, "onCalculateCRC32Success() called");
		
		//1 set payload crc32
		mSendRequest.setPayloadCrc32((int) crc);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseRequest(mSendRequest);
		
		//3 generate AES key
		//mAesKey = AESKeyGenerator.generate();
		
		//4 construct request header (with encrypt)
		byte[] result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId()
				,mAesKey, tail);
		//byte[] result = Simulator.constructRequestHeaderNoEncrypt(1, tail);	//force sessionID to 1
		
		//5 append with payload
		//DataBuffer buffer = new DataBuffer();
		//buffer.writeBytes(result);
		byte[] payload = null;
		try {
			payload = FileUtil.readBytes(DIR_PATH+"payloadEncrypted.dat");
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
		//buffer.writeBytes(payload);
		
		//5 create http component
		FxHttp httpManager = new FxHttp();
		httpManager.setHttpListener(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl("http://192.168.2.201:8080/Phoenix-WAR-Core/gateway");
		httpRequest.setMethod("POST");
		
		//6 set body of http request
		//PostByteItem byteItem = new PostByteItem(buffer.toArray());
		PostByteItem byteItem = new PostByteItem();
		byteItem.setBytes(result);
		//PostByteItem fileItem = new PostByteItem(payload);
		PostFileItem fileItem = new PostFileItem();
		fileItem.setFilePath(DIR_PATH+"payloadEncrypted.dat");
		httpRequest.addDataItem(byteItem);
		httpRequest.addFileDataItem(fileItem);
		
		httpRequest.addDataItem(result);
		httpRequest.addFileDataItem(DIR_PATH+"payloadEncrypted.dat");
		
		//7 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
		
	}
	@Override
	public void onCalculateCRC32Error(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onCalculateCRC32Error() called");
			Log.e(TAG, err.getMessage());
		}
		
	}
	
	
	public void doSendNoEncrypt(){
		//1 perform Deactivation Request
		SendRequest request = new SendRequest();
		//1.1 set All header data
		Simulator.setRequestAttributes(request);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseRequest(request);
		
		//4 construct request header (non encrypt)
		byte[] result = Simulator.constructRequestHeaderNoEncrypt(mKeyExchangeResponse.getSessionId(), tail);
		
		//5 create http component
		FxHttpClient httpManager = new FxHttpClient();
		FxHttpRequest httpRequest = new FxHttpRequest();
		
		//6 set body of http request
		PostByteItem byteItem = new PostByteItem(result);
		httpRequest.addItem(byteItem);
		
		//7 post it!
		httpManager.postContent("http://192.168.2.224:8080/Phoenix-WAR-Core/gateway", httpRequest, this);
	}

	@Override
	public void onHttpError(Throwable err, String msg) {
		if(LOCAL_LOGE){
			//Log.e(TAG, "In state "+mState+": "+err.getMessage());
			if(LOCAL_LOGE)Log.e(TAG, "onHTTPError: "+msg+": "+err.getMessage());
		}
		
		
	}

	@Override
	//public void onHTTPProgress(String progress) {
	public void onHttpSentProgress(SentProgress progress) {
	//public void onHTTPProgress(FxHttpStatusReporter progress) {
		//if(LOCAL_LOGV)Log.v(TAG, "onHTTPProgress called");
		//SentProgress sentProgress = (SentProgress)progress;
		//Log.v(TAG, "HTTP progress: "+sentProgress);
		Log.v(TAG, "HTTP progress: "+progress);
	}
	
	@Override
	//public void onHTTPResponse(FxHttpStatusReporter response) {
	public void onHttpResponse(FxHttpResponse response) {	
		FxHttpResponse FxHttpResponse = (FxHttpResponse)response;
		Log.v(TAG, "HTTP response: "+new String(FxHttpResponse.getBody()));
		Log.v(TAG, "HTTP response: "+new String(response.getBody()));
		try {
			FileUtil.writeToFile("/sdcard/f.dat", response.getBody());
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
		
	}

	@Override
	//public void onHTTPSuccess(byte[] result) {
	//public void onHTTPSuccess(FxHttpStatusReporter reporterResponse) {
	public void onHttpSuccess(FxHttpResponse response) {
		if(LOCAL_LOGV)Log.v(TAG, "onHTTPSuccess called");
		//FxHttpResponse response = (FxHttpResponse) reporterResponse;
		
		byte[] result = response.getBody();
		
		
		// key exchange state
		if(mState == 0){
			//1 write response to file
			try {
				FileIO.writeToFile(DIR_PATH+"keyExchangeResponse.dat", result);
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
			//if(mIsEncrypt)doSend();
			//else doSendNoEncrypt();
			doSend();	//TODO now we force send (but no encrypt)
			
		}else if(mState == 1){ // simulate Send command
			
		//processSendResponse(result);
			SendResponse responseObj = (SendResponse) Simulator.constructResponseObject(result, mAesKey);
			
			//display some info
			if(responseObj!=null){
				if(LOCAL_LOGV){
					Log.v(TAG, "STATUS_CODE: "+responseObj.getStatusCode());
					Log.v(TAG, "Message: "+responseObj.getMessage());
					Log.v(TAG, "Command Next Count: "+responseObj.getCommandNextCount());
					
					if(LOCAL_LOGV)showCmdNextDetail((ServerResponse) responseObj);
					
					mState = 2;	// send acknowledge back to server
					doSendAcknowledge();
				}
			}else{
				if(LOCAL_LOGV){
					Log.e(TAG, "DataCorrupted");
					try {
						FileUtil.writeToFile("/sdcard/RawSendResponse.dat", result);
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
				}
			}
		
		}else if(mState == 2){
			//1 write response to file
			try {
				FileIO.writeToFile(DIR_PATH+"acknowledgeResponse.dat", result);
			} catch (FileNotFoundException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			} catch (IOException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			} catch (SecurityException e){
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			}
			
			//2 initiate KeyExchageResponse
			AckResponse ackResponse = null;
			try {
				ackResponse = (AckResponse) UnstructParser.parseResponse(result);
			} catch (DataCorruptedException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			}
			if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+ackResponse.getCmdEcho()+"\nStatus Code: "+ackResponse.getStatusCode());
			

			return; //force stop (no next state anymore)
		}
	}

	private void showCmdNextDetail(ServerResponse response){
		int cmdNextCount = response.getCommandNextCount();
		
		CommandNext cmd;
		for(int i=0; i<cmdNextCount; i++){
			cmd = response.getCommandNext(i);
			Log.v(TAG, "Detail of command next no."+(i+1));
			Log.v(TAG, "ID: "+cmd.getCommandId());
			int argCount = cmd.getArgumentCount();
			Log.v(TAG, "Argument Count: "+argCount);
			if(argCount != 0){
				Log.v(TAG, "...Argument detail...");
			}
			for(int j=0; j<argCount; j++){
				Log.v(TAG, "Argument no."+j+1+": "+cmd.getArgument(j));
			}
		}
	}

	@Override
	public void onKeyExchangeError(Throwable err) {
		if(LOCAL_LOGE)Log.e(TAG, "onKeyExchangeError: "+err.getMessage());
		return;
	}

	@Override
	public void onKeyExchangeSuccess(KeyExchangeResponse keyExchangeResponse) {
		if(LOCAL_LOGE)Log.v(TAG, "onKeyExchangeSuccess");
		
		//2 initiate KeyExchageResponse
		mKeyExchangeResponse = keyExchangeResponse;
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+mKeyExchangeResponse.getCmdEcho()+"\nStatus Code: "+mKeyExchangeResponse.getStatusCode());
		
		doSend();
		
	}

	@Override
	public void onAcknowledgeError(Throwable err) {
		if(LOCAL_LOGE)Log.e(TAG, "onAcknowledgeError: "+err.getMessage());
		return;
		
	}

	@Override
	public void onAcknowledgeSuccess(AckResponse acknowledgeResponse) {
		if(LOCAL_LOGE)Log.v(TAG, "onAcknowledgeSuccess");
		
		AckResponse ackResponse = acknowledgeResponse;
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+ackResponse.getCmdEcho()+"\nStatus Code: "+ackResponse.getStatusCode());

	}

	

	

	

	
}
*/