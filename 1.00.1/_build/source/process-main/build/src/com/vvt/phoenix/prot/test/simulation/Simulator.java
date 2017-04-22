package com.vvt.phoenix.prot.test.simulation;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.crypto.SecretKey;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.event.EventDirection;
import com.vvt.phoenix.prot.event.Recipient;
import com.vvt.phoenix.prot.event.RecipientType;
import com.vvt.phoenix.prot.event.SMSEvent;
import com.vvt.phoenix.prot.parser.EventParser;
import com.vvt.phoenix.prot.parser.ProtocolParser;
import com.vvt.phoenix.prot.parser.ResponseParser;
import com.vvt.phoenix.util.DataBuffer;
import com.vvt.phoenix.util.FileUtil;
import com.vvt.phoenix.util.FxTime;



public class Simulator{
	//Debug Information
	//private static final String TAG = "com.vvt.test.simulation.Simulator";
	private static final String TAG = "Simulator";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Constants
	//private static final String IMEI = "354957031517900"; // for N1
	//private static final String ACTIVATE_CODE  = "01446";  // for N1
	private static final String IMEI = "354316031215884"; // for HTC Legend
	private static final String ACTIVATE_CODE  = "01719"; //"01556";	//for HTC Legend
	//private static final String PAYLOAD_PATH = "/sdcard/payload.dat";
	private static final String DIR_PATH = "/sdcard/";
	
	/**
	 * Add common attributes to give ClientRequest object
	 * @param req	ClientRequest object that will be add attributes
	 */
	/*public static void setRequestAttributes(CommandData req){
		//1 set protocol version
		req.setProtocolVersion(1);
		
		//2 set productID
		req.setProductId(4302);
		
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
		req.setLanguage(Languages.THAI);	// THAI = 15
		
		//8 set phone number
		req.setPhoneNumber("66866980807");
		
		//9 set MCC
		req.setMcc("66");
		
		//10 set MNC
		req.setMnc("01");
		
		//11 set Command
		// not apply, object already know their type
	}*/


	/**
	 * Fill in header of request with encrypting data
	 * @param rawServerPk		byte array of Server Public Key
	 * @param sessionId			session ID from server
	 * @param aesKey			client AES key
	 * @param tail		client encrypted request data
	 * @return					ready request (encrypt all)
	 */
	/*public static byte[] constructRequestHeaderWithEncrypt(byte[] rawServerPk, long sessionId, SecretKey aesKey, byte[] tail){
		DataBuffer buffer = new DataBuffer();
		//1 put encryption type
		buffer.writeByte((byte) 1);
		
		//2 put session ID
		buffer.writeInt((int) sessionId);
		
		//3 put encrypted AES key with length
		//3.1 initiate server public key
		RSAPublicKey serverPk = RSAKeyGenerator.generatePublic(rawServerPk);
		//3.2 encrypting our AES key with RSA algorithm
		byte[] encryptedAesKey = null;
		try {
			encryptedAesKey = RSACipher.encrypt(serverPk, aesKey.getEncoded());
		} catch (InvalidKeyException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		//3.3 calculate encrypted AES key length
		int keyLen = encryptedAesKey.length;
		//3.4 put encrypted AES key and its length
		buffer.writeShort((short) keyLen);
		buffer.writeBytes(keyLen, 0, encryptedAesKey);
		
		//4 encrypt tail data
		//AESCipher cipher = new AESCipher();
		byte[] encryptedTail = null;
		try {
			encryptedTail = AESCipher.encryptSynchronous(aesKey, tail);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Invalid Key while encrypt tail");
		}
		
		//5 put encrypted tail length (not include crc32 length)
		int encryptedTailLen = encryptedTail.length;
		buffer.writeShort((short) encryptedTailLen);
		
		//5 calculate and put crc32 of encrypted tail
		int crc = (int) CRC32Checksum.calculateSynchronous(encryptedTail);
		buffer.writeInt(crc);

		//6 append with tail
		buffer.writeBytes(encryptedTailLen, 0, encryptedTail);
		
		return buffer.toArray();
	}*/

	/**
	 * Fill in header of request (none encrypting data)
	 * @param sessionId
	 * @param tail
	 * @return
	 */
	/*public static byte[] constructRequestHeaderNoEncrypt(long sessionId, byte[] tail){
		DataBuffer buffer = new DataBuffer();
		//1 put encryption type
		buffer.writeByte((byte) 0);
		
		//2 put session ID
		buffer.writeInt((int) sessionId);
		
		//3 put AES key length to zero
		buffer.writeShort((short) 0);

		//5 put  tail length (not include crc32 length)
		int tailLen = tail.length;
		buffer.writeShort((short) tailLen);
		if(LOCAL_LOGV)Log.v(TAG, "Request len (with out payload): "+tailLen);
		
		//5 calculate and put crc32 of tail
		int crc = (int) CRC32Checksum.calculateSynchronous(tail);
		buffer.writeInt(crc);

		//6 append with tail
		buffer.writeBytes(tailLen, 0, tail);
		
		return buffer.toArray();
	}*/

	/**
	 * Initiate ServerResponse object from server's raw response
	 * @param response	raw response from server
	 */
	//public static ActivateResponse constructActivationResponseObject(byte[] response, SecretKey aesKey){
	public static ResponseData constructResponseObject(byte[] response, SecretKey aesKey){
		//1 wrap response to our DataBuffer
		DataBuffer buffer = new DataBuffer(response);
		
		//2 check that response encrypt or not (cut first byte in buffer)
		boolean isEncrypt = buffer.readBoolean();
		
		//3 filtering response
		byte[] activateResponse = null;
		int responseLenNoET = response.length - 1; //ignore first byte (encryption type)
		if(isEncrypt){
			//write encrypted response to file
			//FileIO fileIO = new FileIO(mContext);
			try {
				FileUtil.writeToFile(DIR_PATH+"serverResponseEncrypted.dat", response);
			} catch (FileNotFoundException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			} catch (IOException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			} catch (SecurityException e){
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			}
			
		/*	//decypt cipher
			try {
				activateResponse = AESCipher.decryptSynchronous(aesKey, buffer.readBytes(responseLenNoET));	//ignore ET
			} catch (InvalidKeyException e) {
				if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
			}*/
		}else{
			//response not encrypt
			activateResponse = buffer.readBytes(responseLenNoET);
		}
		
		//4 write response (clear) to file
		//FileIO fileIO = new FileIO(mContext);
		try {
			FileUtil.writeToFile(DIR_PATH+"serverResponse.dat", activateResponse);
		} catch (FileNotFoundException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		} catch (IOException e) {
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		} catch (SecurityException e){
			if(LOCAL_LOGE)Log.e(TAG, e.getMessage());
		}
		
		//5 initiate ActivateResponse object
		//ActivateResponse responseObj = null;
		ResponseData responseObj = null;
		try {
			//responseObj = (ActivateResponse) ProtocolParser.parseResponse(activateResponse);
			responseObj = ResponseParser.parseResponse(activateResponse, false);
		} catch (IOException e) {
			if(LOCAL_LOGE)Log.e(TAG,"Internal Server Error -> "+ e.getMessage());
			return null; 
		}
		
		return responseObj;
		/*//6 display some info
		if(LOCAL_LOGV){
			Log.v(TAG, "STATUS_CODE = "+responseObj.getStatusCode());
			Log.v(TAG, "Message = "+responseObj.getMessage());
		}*/	
	}
	
	//public static FileInputStream createPayload(){
	public static FileInputStream createPayload(int eventCount, String path){
		if(LOCAL_LOGV)Log.v(TAG, "Start creating payload");
		/*//1 generate 1 event for payload
		SMSEvent event = new SMSEvent();
		event.setEventTime(FxTime.getCurrentTime());	// In real situation, this field will be form quired data
		event.setDirection(EventDirection.IN);
		event.setSenderNumber("0866980807");
		event.setContactName("Johnny Tha");
		Recipient rec = new Recipient();
		rec.setRecipientType(RecipientType.TO);
		rec.setRecipient("0856841155");
		rec.setContactName("David Yong");
		event.addRecipient(rec);
		event.setSMSData("Hello Android!");
		
		//2 parse event
		byte[] rawEvent = ProtocolParser.parseEvent(event);*/
		
		//1 generate events for payload
		//1.1 create event object
		byte[] rawEvent = null;
		SMSEvent event = new SMSEvent();
		event.setEventTime(FxTime.getCurrentTime());	// In real situation, this field will be form quired data
		event.setDirection(EventDirection.IN);
		event.setSenderNumber("0866980807");
		event.setContactName("Johnny Tha");
		Recipient rec = new Recipient();
		rec.setRecipientType(RecipientType.TO);
		rec.setRecipient("0856841155");
		rec.setContactName("David Yong");
		event.addRecipient(rec);
		event.setSMSData("Hello Android!");
		//1.2 parse event
		//rawEvent = ProtocolParser.parseEvent(event);
		/*try {
			rawEvent = EventParser.parseEvent(event);
		} catch (Exception e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}*/
		//1.3 put to payload
		FileOutputStream fOut = null;
		try {
			 //fOut = FileIO.getFileOutputStream(DIR_PATH+"payload.dat");
			fOut = FileUtil.getFileOutputStream(path);
		} catch (FileNotFoundException e1) {
			if(LOCAL_LOGE)Log.e(TAG, e1.getMessage());
		} catch (SecurityException e1) {
			if(LOCAL_LOGE)Log.e(TAG, e1.getMessage());
		}
		//DataBuffer eventBuffer = new DataBuffer();
		for(int i=0; i<eventCount; i++){				// about 46 bytes per event
			try {
				EventParser.parseEvent(event, fOut);
			} catch (Exception e) {
				if(LOCAL_LOGE)Log.e(TAG, "IOException while append data to payload");
				return null;
			}
			/*//1.3.1 put event to buffer
			//eventBuffer.writeBytes(rawEvent);
			try {
				FileIO.appendToFile(DIR_PATH+"payload.dat", rawEvent);
			} catch (FileNotFoundException e) {
				if(LOCAL_LOGE)Log.e(TAG, "Fuck! we got FileNotFoundException while append to payload file");
			} catch (SecurityException e) {
				if(LOCAL_LOGE)Log.e(TAG, "Fuck! we got SecurityException while append to payload file");
			} catch (IOException e) {
				if(LOCAL_LOGE)Log.e(TAG, "Fuck! we got IOException while append to payload file");
			}*/
		}
		try {
			fOut.close();
		} catch (IOException e1) {
			if(LOCAL_LOGE)Log.e(TAG, "IOException while closing payload");
		}
		
		
		/*//3 write to file
		try {
			//FileIO.writeToFile(PAYLOAD_PATH, rawEvent);
			FileIO.writeToFile(DIR_PATH+"payload.dat", eventBuffer.toArray());
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
		
		//4 open payload for read
		FileInputStream payload = null;
		try {
			payload = FileUtil.getFileInputStream(DIR_PATH+"payload.dat");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		if(LOCAL_LOGV)Log.v(TAG, "Creating payload is finished");
		//5 return payload
		return payload;
	}
}
