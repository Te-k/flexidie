package com.vvt.phoenix.prot.test.simulation;
/*package com.vvt.protocol.test.simulation;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
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
import com.vvt.exception.DataCorruptedException;
import com.vvt.http.FxHttpClient;
import com.vvt.http.FxHttpListener;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.PostByteItem;
import com.vvt.http.request.PostFileItem;
import com.vvt.io.FileIO;
import com.vvt.protocol.ProtocolParser;
import com.vvt.protocol.request.RAskRequest;
import com.vvt.protocol.request.RSendRequest;
import com.vvt.protocol.request.SendRequest;
import com.vvt.protocol.response.RAskResponse;
import com.vvt.protocol.response.RSendResponse;
import com.vvt.protocol.response.SendResponse;
import com.vvt.protocol.unstruct.AcknowledgeListener;
import com.vvt.protocol.unstruct.Acknowledgement;
import com.vvt.protocol.unstruct.KeyExchange;
import com.vvt.protocol.unstruct.KeyExchangeListener;
import com.vvt.protocol.unstruct.UnstructParser;
import com.vvt.protocol.unstruct.response.AckResponse;

public class RSendSimulator implements KeyExchangeListener, AcknowledgeListener, FxHttpListener, GZIPListener, AESEncryptListener, CRC32Listener {
	private static final String TAG = "RSendSimulator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Fields
	private enum mState{ INITIATE, KEY_EXCHANGE, SEND, RASK, RSEND, ACKNOWLEDGE};
	mState mCurrentState;
	SendRequest mSendRequest;
	//private KeyExchangeResponse mKeyExchangeResponse;
	private int mSessionId;
	private byte[] mServerPk;
	private SecretKey mAesKey;
	private boolean mIsCompressPayload;
	private boolean mIsEncryptPayload;
	//private boolean mIsEncrypt;
	//private FileInputStream mReadyPayload;
	private int mSendOffset;

	
	//Constants
	//private static final String IMEI = "354957031517900"; // for N1
	private static final String IMEI = "354316031215884"; // for HTC Legend
	private static final String UCMD_URL = "http://192.168.2.224:8080/Phoenix-WAR-Core/gateway/unstructured";
	private static final String REQUEST_URL = "http://192.168.2.224:8080/Phoenix-WAR-Core/gateway";
	private static final int EVENT_COUNT = 2097152;//1048576; (about 46 bytes per event)
	private static final String DIR_PATH = "/sdcard/";
	private static final String PAYLOAD_PATH = DIR_PATH+"payload.dat";
	private static final String PAYLOAD_BUFFER_PATH = DIR_PATH+"buffer.dat";
	
	
	public RSendSimulator(){
		//mState = 0;
		mCurrentState = mState.INITIATE;
		mIsCompressPayload = true;
		mIsEncryptPayload = true;
		mSendOffset = 0;
	}
	
	public void simulateRSend(){
		actionSwitcher(mState.KEY_EXCHANGE);
	}
	
	///////////////////////////////////////////////////////////////// actions switcher ///////////////////////////////////
	private void actionSwitcher(mState nextState){
		switch(nextState){
			case KEY_EXCHANGE 	:	mCurrentState = mState.KEY_EXCHANGE;
									doKeyExchange();break;
			case SEND			:	mCurrentState = mState.SEND;
									doSend();break;
			case RASK			:	mCurrentState = mState.RASK;
									doRAsk();break;
			case RSEND			:	mCurrentState = mState.RSEND;
									doRSend();break;
			case ACKNOWLEDGE	:	mCurrentState = mState.ACKNOWLEDGE;
									doAcknowledge();break;
		}
	}
	
	
	///////////////////////////////////////////////////////////////// actions ////////////////////////////////////////////
	
	private void doKeyExchange(){
		KeyExchange keyExchange = new KeyExchange(UCMD_URL, this);
		keyExchange.doKeyExchange();
		
		//1 create
		FxHttpClient httpManager = new FxHttpClient();
		FxHttpRequest request = new FxHttpRequest();
		
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
		PostByteItem byteItem = new PostByteItem(data);
		request.addItem(byteItem);
		
		//5 post it!
		httpManager.postContent(UCMD_URL, request, this);
	}
	
	private void doSend(){
		//1 perform Send Request
		mSendRequest = new SendRequest();
		//1.1 set all request object attributes
		Simulator.setRequestAttributes(mSendRequest);
		//1.2 get payload
		FileInputStream payload = Simulator.createPayload(EVENT_COUNT, PAYLOAD_PATH);
		//1.3 compress payload
		if(payload != null){
			GZIPCompressor gzip = new GZIPCompressor();
			try {
				gzip.compress(payload, DIR_PATH+"payloadCompressed.dat", this);
			} catch (FileNotFoundException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				return;
			} catch (SecurityException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				return;
			}
		}	
		
	}
	
	private void doRAsk(){
		//1 perform RAsk Reqeust
		RAskRequest request = new RAskRequest();
		//1.1 set all request object attributes
		Simulator.setRequestAttributes(request);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseRequest(request);
		
		//3 construct request header
		byte[] result = null;
		result = Simulator.constructRequestHeaderWithEncrypt(mServerPk, mSessionId, mAesKey, tail);
		result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId()
					,mAesKey, tail);
		
		//4 create http component
		FxHttpClient httpManager = new FxHttpClient(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl(REQUEST_URL);
		
		//5 prepare data to post
		PostByteItem byteItem = new PostByteItem(result);
		
		//7 attach data to http request
		httpRequest.addItem(byteItem);
		
		//8 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent(REQUEST_URL, httpRequest, this);
	}
	
	private void doRSend(){
		//1 perform RSend Reqeust
		RSendRequest request = new RSendRequest();
		//1.1 set all request object attributes
		Simulator.setRequestAttributes(request);
		//1.2 set payload remainig size
		int payloadSize = 0;
		try {
			payloadSize = FileIO.readBytes(PAYLOAD_BUFFER_PATH).length;		// Warning ! after this line these file will be alredy readed
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, "doRSend() "+e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, "doRSend() "+e.getMessage());
			return;
		} catch (IOException e) {
			if(LOCAL_LOGE)Log.e(TAG, "doRSend() "+e.getMessage());
			return;
		}	
		int remainSize = payloadSize - mSendOffset;
		request.setSize(remainSize);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseRequest(request);
		
		//3 construct request header
		byte[] result = null;
		result = Simulator.constructRequestHeaderWithEncrypt(mServerPk, mSessionId, mAesKey, tail);
		result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId()
					,mAesKey, tail);
		
		//4 create http component
		FxHttpClient httpManager = new FxHttpClient(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl(REQUEST_URL);
		
		//5 prepare data to post
		PostByteItem byteItem = new PostByteItem(result);
		PostFileItem fileItem = new PostFileItem(PAYLOAD_BUFFER_PATH);
		fileItem.setOffset(mSendOffset);
		
		//7 attach data to http request
		httpRequest.addItem(byteItem);
		httpRequest.addItem(fileItem);
		
		//8 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent(REQUEST_URL, httpRequest, this);
		
	}
	
	private void doAcknowledge(){
		Acknowledgement ack = new Acknowledgement(UCMD_URL, IMEI, mSessionId, this);
		ack.doAcknowledge();
		//1 create
		FxHttpClient httpManager = new FxHttpClient();
		FxHttpRequest request = new FxHttpRequest();
		
		//2 prepare key exchange request
		AckRequest ackReq = new AckRequest();
		ackReq.setCode(0);
		ackReq.setDeviceId(IMEI.getBytes());
		ackReq.setSessionId(mSessionId);
		//ackReq.setSessionId(mKeyExchangeResponse.getSessionId());
		
		//3 parse data
		byte[] data = null;
		try {
			data = UnstructParser.parseRequest(ackReq);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		
		//4 set body of request
		PostByteItem byteItem = new PostByteItem(data);
		request.addItem(byteItem);
		
		//5 post it!
		httpManager.postContent(UCMD_URL, request, this);
	}
	
	///////////////////////////////////////////////////////////////// call back /////////////////////////////////////////
	
	@Override
	public void onKeyExchangeSuccess(int sessionId, byte[] serverPublicKey) {
		if(LOCAL_LOGV)Log.v(TAG, "onKeyExchangeSuccess() called");
		
		//1 initiate KeyExchageResponse
		mSessionId = sessionId;
		mServerPk = serverPublicKey;
		
		actionSwitcher(mState.SEND);
	}
	@Override
	public void onKeyExchangeError(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onKeyExchangeError() called");
			Log.e(TAG, err.getMessage());
		}
		return;		
	}

	
	@Override
	public void onCompressSuccess(FileInputStream result) {
		if(LOCAL_LOGV)Log.v(TAG, "onCompressSuccess() called");
		
		//1 set flag
		mSendRequest.setCompressionCode(1);
		mIsCompressPayload = true;
		//2 generate AES key
		mAesKey = AESKeyGenerator.generate();
		//3 encrypt payload
		AESCipher cipher = new AESCipher();
		try {
			cipher.encryptASynchronous(mAesKey, result, DIR_PATH+"payloadEncrypted.dat", this);
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
		
	}
	@Override
	public void onCompressError(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onCompressError() called !!!");
			Log.e(TAG, err.getMessage());
		}
		
		//1 set flag
		mSendRequest.setCompressionCode(0);
		mIsCompressPayload = false;
		//2 generate AES key
		mAesKey = AESKeyGenerator.generate();
		//3 get payload
		FileInputStream payload = null;
		try {
			payload = FileIO.getFileInputStream(PAYLOAD_PATH);
		} catch (FileNotFoundException e1) {
			if(LOCAL_LOGE)Log.e(TAG, e1.getMessage());
			return;
		} catch (SecurityException e1) {
			if(LOCAL_LOGE)Log.e(TAG, e1.getMessage());
			return;
		}
		//4 encrypt payload
		AESCipher cipher = new AESCipher();
		try {
			cipher.encryptASynchronous(mAesKey, payload, DIR_PATH+"payloadEncrypted.dat", this);
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
	}
	
	@Override
	public void onAESEncryptSuccess(FileInputStream result) {
		if(LOCAL_LOGV)Log.v(TAG, "onAESEncryptSuccess() called");
		
		//1 set flag
		mSendRequest.setEncryptionCode(1);
		mIsEncryptPayload = true;
		//2 set payload size
		int payloadSize = 0;
		try {
			payloadSize = FileIO.readBytes(result).length;	// Warning ! after this line result will be alredy readed
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (IOException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
		mSendRequest.setPayloadSize(payloadSize);
		
		//3 set event count
		mSendRequest.setEventCount(EVENT_COUNT);
		
		//4 calculate crc32
		try {
			result = FileIO.getFileInputStream(DIR_PATH+"payloadEncrypted.dat");
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
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
		
		//1 set flag
		mSendRequest.setEncryptionCode(0);
		mIsEncryptPayload = true;
		
		//2 open payload
		String payload_path;
		if(mIsCompressPayload){
			payload_path = DIR_PATH+"payloadCompressed.dat";
		}else{
			payload_path = PAYLOAD_PATH;
		}
		FileInputStream payload = null;
		try {
			payload = FileIO.getFileInputStream(payload_path);
		} catch (FileNotFoundException e1) {
			if(LOCAL_LOGE)Log.e(TAG, e1.getMessage());
			return;
		} catch (SecurityException e1) {
			if(LOCAL_LOGE)Log.e(TAG, e1.getMessage());
			return;
		}
		
		//3 set payload size
		int payloadSize = 0;
		try {
			payloadSize = FileIO.readBytes(payload).length;	// Warning ! after this line result will be alredy readed
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (IOException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
		mSendRequest.setPayloadSize(payloadSize);
		
		//3 set event count
		mSendRequest.setEventCount(EVENT_COUNT);
		
		//4 calculate crc32
		try {
			payload = FileIO.getFileInputStream(payload_path);
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			return;
		}
		CRC32Checksum crc = new CRC32Checksum();
		crc.calculateASynchronous(payload, this);
	}

	@Override
	public void onCalculateCRC32Success(long crc) {
		if(LOCAL_LOGV)Log.v(TAG, "onCalculateCRC32Success() called");
		
		//1 set payload crc32
		mSendRequest.setPayloadCrc32((int) crc);
		
		//2 parsing request
		byte[] tail = ProtocolParser.parseRequest(mSendRequest);
		
		//3 construct request header
		byte[] result = null;
		if(mIsEncryptPayload){
			result = Simulator.constructRequestHeaderWithEncrypt(mServerPk, mSessionId, mAesKey, tail);
			result = Simulator.constructRequestHeaderWithEncrypt(mKeyExchangeResponse.getServerPK(), mKeyExchangeResponse.getSessionId()
					,mAesKey, tail);
		}else{
			result = Simulator.constructRequestHeaderNoEncrypt(mSessionId, tail);
			result = Simulator.constructRequestHeaderNoEncrypt(mKeyExchangeResponse.getSessionId(), tail);
		}
		
		//4 create http component
		FxHttpClient httpManager = new FxHttpClient(this);
		FxHttpRequest httpRequest = new FxHttpRequest();
		httpRequest.setUrl(REQUEST_URL);
		
		//5 prepare data to post
		PostByteItem byteItem = new PostByteItem(result);
		PostFileItem fileItem = null;
		String payloadPath;
		if(mIsEncryptPayload){
			payloadPath = DIR_PATH+"payloadEncrypted.dat";	
		}else{ // not encrypt
			//is compress?
			if(mIsCompressPayload){
				payloadPath = DIR_PATH+"payloadCompressed.dat";
			}else{
				payloadPath = PAYLOAD_PATH;
			}
		}
		fileItem = new PostFileItem(payloadPath);
		
		//6 hacking payload file before send (for use with RAsk, RSend)
		//if(LOCAL_LOGV)Log.v(TAG, "payload_path: "+payload_path);
		if(hackFile(payloadPath)){
			if(LOCAL_LOGV)Log.v(TAG, "Perform RAsk, RSend by sending only 10 bytes");
		}else{
			if(LOCAL_LOGV)Log.v(TAG, "Perform send full file size");
		}

		//7 attach data to http request
		httpRequest.addItem(byteItem);
		httpRequest.addItem(fileItem);
		
		//8 post it!
		httpManager.execute(httpRequest);
		//httpManager.postContent(REQUEST_URL, httpRequest, this);
		
	}
	private boolean hackFile(String path){ 
		//if(LOCAL_LOGV)Log.v(TAG, "hackFile: path = "+path);
		try {
			//1 buffering original file
			byte[] buffer = FileIO.readBytes(path);
			
			//2 write to temp file
			FileIO.writeToFile(PAYLOAD_BUFFER_PATH, buffer);
			
			//3 modify original file by delete half of them
			FileOutputStream fOut = FileIO.getFileOutputStream(path);
			fOut.write(buffer, 0, 10);	// send only first 10 bytes
			
			return true;
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, "hackFile() got problem with FileNotFoundException: "+ e.getMessage());
			return false;
		} catch (SecurityException e) {
			if(LOCAL_LOGE)Log.e(TAG, "hackFile() got problem with SecurityException: "+e.getMessage());
			return false;
		} catch (IOException e) {
			if(LOCAL_LOGE)Log.e(TAG, "hackFile() got problem with IOException: "+e.getMessage());
			return false;
		}
	}
	@Override
	public void onCalculateCRC32Error(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onCalculateCRC32Error() called");
			Log.e(TAG, err.getMessage());
		}
		return;
	}

	@Override
	public void onHTTPProgress(String progress) {
		Log.v(TAG, "HTTP progress: "+progress);
		
	}
	@Override
	public void onHTTPSuccess(byte[] result) {
		if(LOCAL_LOGV)Log.v(TAG, "onHTTPSuccess called");
		
		switch(mCurrentState){
			case KEY_EXCHANGE 	:  	handleKeyExchangeResponse(result);
									break;
			case SEND			:	handleSendResponse(result);
									break;
			case ACKNOWLEDGE	:	handleAcknowledgeResponse(result);
									break;
			case RASK			: 	handleRAskResponse(result);
									break;
			case RSEND			:	handleRSendResponse(result);
									break;
		}
		
	}
	@Override
	public void onHTTPError(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "In state "+mCurrentState+": "+err.getMessage());
		}
		
	}
	
	private void handleKeyExchangeResponse(byte[] result){
		if(LOCAL_LOGV)Log.v(TAG, "handleKeyExchangeResponse() called");
		
		//1 initiate KeyExchageResponse
		try {
			mKeyExchangeResponse = (KeyExchangeResponse) UnstructParser.parseResponse(result);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+mKeyExchangeResponse.getCmdEcho()+
				"\nStatus Code: "+mKeyExchangeResponse.getStatusCode());
		
		actionSwitcher(mState.SEND);
	}
	
	private void handleSendResponse(byte[] result){
		if(LOCAL_LOGV)Log.v(TAG, "handleSendResponse() called");
		
		SendResponse responseObj = (SendResponse) Simulator.constructResponseObject(result, mAesKey);
		//display some info
		if(responseObj!=null){
			int statusCode = responseObj.getStatusCode();
			if(LOCAL_LOGV){
				Log.v(TAG, "STATUS_CODE: "+statusCode);
				Log.v(TAG, "Message: "+responseObj.getMessage());
				Log.v(TAG, "Command Next Count: "+responseObj.getCommandNextCount());
				
				//TODO Decisions for RAsk go here !
				//actionSwitcher(mState.RSEND);break;
				if(statusCode == 0){	// Success
					//Send Acknowledge
					actionSwitcher(mState.ACKNOWLEDGE);
				}else if(statusCode == 230){	// Incomplete Payload Data
					//Send RAsk
					actionSwitcher(mState.RASK);
				}
			}
		}else{
			if(LOCAL_LOGV){
				Log.e(TAG, "DataCorrupted");
				try {
					FileIO.writeToFile(DIR_PATH+"RawSendResponse.dat", result);
				} catch (FileNotFoundException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				} catch (SecurityException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				} catch (IOException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				}
			}
		}
	}
	
	private void handleAcknowledgeResponse(byte[] result){
		if(LOCAL_LOGV)Log.v(TAG, "handleAcknowledgeResponse() called");
		
		// initiate KeyExchageResponse
		AckResponse response = null;
		try {
			response = (AckResponse) UnstructParser.parseResponse(result);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		if(LOCAL_LOGV)Log.v(TAG, "Response at state 0 -> Command Echo:"+response.getCmdEcho()+
				"\nStatus Code: "+response.getStatusCode());
		
	}
	
	private void handleRAskResponse(byte[] result){
		if(LOCAL_LOGV)Log.v(TAG, "handleRAskResponse() called");
		
		RAskResponse responseObj = (RAskResponse) Simulator.constructResponseObject(result, mAesKey);
		
		if(responseObj!=null){
			int statusCode = responseObj.getStatusCode();
			mSendOffset = responseObj.getNumberOfBytes();
			if(LOCAL_LOGV){
				Log.v(TAG, ""+responseObj.getCmdEcho());
				Log.v(TAG, "STATUS_CODE: "+statusCode);
				Log.v(TAG, "Message: "+responseObj.getMessage());
				Log.v(TAG, "Command Next Count: "+responseObj.getCommandNextCount());
				Log.v(TAG, "Number of bytes: "+mSendOffset);
				
				actionSwitcher(mState.RSEND);
			}
		}else{
			if(LOCAL_LOGV){
				Log.e(TAG, "DataCorrupted");
				try {
					FileIO.writeToFile(DIR_PATH+"RawRAskResponse.dat", result);
				} catch (FileNotFoundException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				} catch (SecurityException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				} catch (IOException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				}
			}
		}
	}

	private void handleRSendResponse(byte[] result){
		if(LOCAL_LOGV)Log.v(TAG, "handleRSendResponse() called");
		
		RSendResponse responseObj = (RSendResponse) Simulator.constructResponseObject(result, mAesKey);
		
		if(responseObj!=null){
			int statusCode = responseObj.getStatusCode();
			if(LOCAL_LOGV){
				Log.v(TAG, ""+responseObj.getCmdEcho());
				Log.v(TAG, "STATUS_CODE: "+statusCode);
				Log.v(TAG, "Message: "+responseObj.getMessage());
				Log.v(TAG, "Command Next Count: "+responseObj.getCommandNextCount());
				
				actionSwitcher(mState.ACKNOWLEDGE);
			}
		}else{
			if(LOCAL_LOGV){
				Log.e(TAG, "DataCorrupted");
				try {
					FileIO.writeToFile(DIR_PATH+"RawRAskResponse.dat", result);
				} catch (FileNotFoundException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				} catch (SecurityException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				} catch (IOException e) {
					if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
				}
			}
		}
	}

	
	@Override
	public void onAcknowledgeSuccess(int statusCode) {
		if(LOCAL_LOGV){
			Log.v(TAG, "onAcknowledgeSuccess() called");
			Log.v(TAG, "Acknowledgement status code = "+statusCode);
		}		
		
	}
	@Override
	public void onAcknowledgeError(Exception err) {
		if(LOCAL_LOGE){
			Log.e(TAG, "onAcknowledgeError() called");
			Log.e(TAG, err.getMessage());
		}
	}
	
}
*/