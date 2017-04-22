package com.vvt.phoenix.prot.parser;

/**
 * @author tanakharn
 * @version 1.0
 * @updated 20-Oct-2010 5:51:56 PM
 * @refactor January 2012
 */
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.prot.unstruct.AckResponse;
import com.vvt.phoenix.prot.unstruct.AckSecResponse;
import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.PingResponse;
import com.vvt.phoenix.prot.unstruct.UnstructCmdCode;
import com.vvt.phoenix.util.ByteUtil;

public class UnstructProtParser {
	// Fields
	private static final String TAG = "UnstructProtParser";
	
	/*
	 * Constants
	 */
	private static final int KEY_EXCHANGE_REQUEST_LENGTH = 5;
	private static final int ACKNOWLEDGE_SECURE_REQUEST_LENGTH = 8;
	private static final int ACKNOWLEDGE_MINIMUM_REQUEST_LENGTH = 9;
	private static final int PING_REQUEST_LENGTH = 4;

	public static byte[] parseKeyExchangeRequest(int code, int encodingType)
	{
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream(KEY_EXCHANGE_REQUEST_LENGTH);
		
		//1 parse Command Code : 2 bytes
		byteStream.write(ByteUtil.toBytes((short) UnstructCmdCode.KEY_EXCHANGE), 0, 2);
		
		//2 parse code	: 2 bytes
		byteStream.write(ByteUtil.toBytes((short) code), 0, 2);
		
		//3 parse encoding type : 1 byte
		byteStream.write((byte) encodingType);
		
		//4 close stream
		closeByteArrayOutputStream(byteStream);
		
		return byteStream.toByteArray();
		
	}
	public static KeyExchangeResponse parseKeyExchangeResponse(byte[] rawResponse) throws DataCorruptedException{		
				
		if(rawResponse.length < 10){
			FxLog.w(TAG, "> parseKeyExchangeResponse # Response data is incomplete");
			throw new DataCorruptedException("Response data is incomplete");
		}
		
		ByteArrayInputStream byteStream = new ByteArrayInputStream(rawResponse);
		byte[] buffer;
		//1 check command echo : 2 bytes
		buffer = new byte[2];
		byteStream.read(buffer, 0, 2);
		short cmdEcho = ByteUtil.toShort(buffer);
		if(cmdEcho != UnstructCmdCode.KEY_EXCHANGE){
			FxLog.w(TAG, "> parseKeyExchangeResponse # Command echo is not KeyExchange command");
			closeByteArrayInputStream(byteStream);
			throw new DataCorruptedException("Command echo is not KeyExchange command");
		}
		
		KeyExchangeResponse keyExchangeResponse = new KeyExchangeResponse();

		//2 read status code : 2 bytes
		byteStream.read(buffer, 0, 2);
		short statusCode = ByteUtil.toShort(buffer);
		keyExchangeResponse.setStatusCode(statusCode);
		
		//3 read session ID : 4 bytes
		buffer = new byte[4];
		byteStream.read(buffer, 0, 4);
		int sessionId = ByteUtil.toInt(buffer);
		keyExchangeResponse.setSessionId(sessionId);
		
		//4 read PK
		//4.1 read PK length : 2 bytes
		buffer = new byte[2];
		byteStream.read(buffer, 0, 2);
		short pkLen = ByteUtil.toShort(buffer);
		
		//4.2 read PK
		if(pkLen != 0){			
			ByteArrayOutputStream keyBuffer = new ByteArrayOutputStream();
			buffer = new byte[32];
			try{
				int readCount = byteStream.read(buffer);
				while(readCount != -1){
					keyBuffer.write(buffer, 0, readCount);
					readCount = byteStream.read(buffer);
				}
				buffer = keyBuffer.toByteArray();
				if(pkLen == buffer.length){
					keyExchangeResponse.setServerPK(buffer);
				}else{
					FxLog.w(TAG, "> parseKeyExchangeResponse # Key length doesn't matched with the given length value");
					closeByteArrayInputStream(byteStream);
					throw new DataCorruptedException("Key length doesn't matched with the given length value");
				}
				// for testing
				//throw new IOException("Dummy");
			}catch(IOException e){
				FxLog.w(TAG, String.format("IOException while retrieving public key: %s", e.getMessage()));
				closeByteArrayInputStream(byteStream);
				throw new DataCorruptedException(String.format("IOException while retrieving public key: %s", e.getMessage()));
			}
			
		}else{
			FxLog.w(TAG, "> parseKeyExchangeResponse # Given Key Length = 0");
			closeByteArrayInputStream(byteStream);
			throw new DataCorruptedException("Given Key Length = 0");
		}
		
		//5 close stream
		closeByteArrayInputStream(byteStream);
		
		return keyExchangeResponse;
	}
	
	public static byte[] parseAckSecureRequest(int code, long sessionId){
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream(ACKNOWLEDGE_SECURE_REQUEST_LENGTH);
		
		//1 parse Command Code : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) UnstructCmdCode.ACKNOWLEDGE_SEC), 0, 2);
		
		//2 parse code : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) code), 0, 2);
		
		//3 parse session id : unsigned int 4 bytes
		byteStream.write(ByteUtil.toBytes((int) sessionId), 0, 4);
		
		byte[] result = byteStream.toByteArray();
		
		closeByteArrayOutputStream(byteStream);
		
		return result;	
		
	}
	
	public static AckSecResponse parseAckSecureResponse(byte[] rawResponse) throws DataCorruptedException{
		
		//1 check integrity of data
		if(rawResponse.length < 4){
			FxLog.w(TAG, "> parseAckSecureResponse # Response data is incomplete");
			throw new DataCorruptedException("Response data is incomplete");
		}
		
		ByteArrayInputStream byteStream = new ByteArrayInputStream(rawResponse);
		byte[] buffer  = new byte[2];
		
		//2 check command echo
		byteStream.read(buffer, 0, 2);
		short cmdEcho = ByteUtil.toShort(buffer);
		if(cmdEcho != UnstructCmdCode.ACKNOWLEDGE_SEC){
			FxLog.w(TAG, "> parseAckSecureResponse # Command echo is not Acknowledge Secure command");
			throw new DataCorruptedException("Command echo is not Acknowledge Secure command");
		}
		
		AckSecResponse acknowledgeSecureResponse = new AckSecResponse();
		
		//3 parse code : 2 bytes
		byteStream.read(buffer, 0, 2);
		short code = ByteUtil.toShort(buffer);
		acknowledgeSecureResponse.setStatusCode(code);
		
		//4 close stream
		closeByteArrayInputStream(byteStream);
		
		return acknowledgeSecureResponse;
	}


	public static byte[] parseAckRequest(int code, long sessionId, String deviceId){
		
		//1 calculate the bytes length of this request
		byte[] deviceIdBytes = deviceId.getBytes(); 
		int requestLength = ACKNOWLEDGE_MINIMUM_REQUEST_LENGTH + deviceIdBytes.length;
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream(requestLength);
		
		//2 parse Command Code : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) UnstructCmdCode.ACKNOWLEDGE), 0, 2);
		
		//3 parse code : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) code), 0, 2);
		
		//4 parse session id : unsigned int 4 bytes
		byteStream.write(ByteUtil.toBytes((int) sessionId), 0, 4);
		
		//5 parse Device ID (variable) and its length (1 byte)
		byteStream.write((byte) deviceIdBytes.length);
		byteStream.write(deviceIdBytes, 0, deviceIdBytes.length);
		
		byte[] result = byteStream.toByteArray();
		closeByteArrayOutputStream(byteStream);
		
		return result;	
		
	}
	
	public static AckResponse parseAckResponse(byte[] rawResponse) throws DataCorruptedException{
		
		//1 check integrity of data
		if(rawResponse.length < 4){
			FxLog.w(TAG, "> parseAckResponse # Response data is incomplete");
			throw new DataCorruptedException("Response data is incomplete");
		}
		
		ByteArrayInputStream byteStream = new ByteArrayInputStream(rawResponse);
		byte[] buffer  = new byte[2];
		
		//2 check command echo
		byteStream.read(buffer, 0, 2);
		short cmdEcho = ByteUtil.toShort(buffer);
		if(cmdEcho != UnstructCmdCode.ACKNOWLEDGE){
			FxLog.w(TAG, "> parseAckResponse # Command echo is not Acknowledge command");
			throw new DataCorruptedException("Command echo is not Acknowledge command");
		}
		
		AckResponse acknowledgeResponse = new AckResponse();
		
		//3 parse code : 2 bytes
		byteStream.read(buffer, 0, 2);
		short code = ByteUtil.toShort(buffer);
		acknowledgeResponse.setStatusCode(code);
		
		//4 close stream
		closeByteArrayInputStream(byteStream);
		
		return acknowledgeResponse;		
	}
	
	public static byte[] parsePingRequet(int code){
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream(PING_REQUEST_LENGTH);
		
		//1 parse Command Code : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) UnstructCmdCode.PING), 0, 2);
		
		//2 parse code : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) code), 0, 2);
		
		byte[] result = byteStream.toByteArray();
		
		closeByteArrayOutputStream(byteStream);
		
		return result;	
	}
	
	public static PingResponse parsePingResponse(byte[] rawResponse) throws DataCorruptedException{
		
		//1 check integrity of data
		if(rawResponse.length < 4){
			FxLog.w(TAG, "> parsePingResponse # Response data is incomplete");
			throw new DataCorruptedException("Response data is incomplete");
		}
		
		ByteArrayInputStream byteStream = new ByteArrayInputStream(rawResponse);
		byte[] buffer  = new byte[2];
		
		//2 check command echo
		byteStream.read(buffer, 0, 2);
		short cmdEcho = ByteUtil.toShort(buffer);
		if(cmdEcho != UnstructCmdCode.PING){
			FxLog.w(TAG, "> parsePingResponse # Command echo is not Ping command");
			throw new DataCorruptedException("Command echo is not Ping command");
		}
		
		PingResponse pingResponse = new PingResponse();
		
		//3 parse code : 2 bytes
		byteStream.read(buffer, 0, 2);
		short code = ByteUtil.toShort(buffer);
		pingResponse.setStatusCode(code);
		
		//4 close stream
		closeByteArrayInputStream(byteStream);
		
		return pingResponse;
	}

	// ************************************** Resources Utils *************************************** //
	private static void closeByteArrayInputStream(ByteArrayInputStream stream){
		try {
			stream.close();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("> closeByteArrayInputStream # Got IOException while closing ByteArrayInputStream: %s", e.getMessage()));
		}
	}
	
	private static void closeByteArrayOutputStream(ByteArrayOutputStream stream){
		try {
			stream.close();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("> closeByteArrayOutputStream # Got IOException while closing ByteArrayOutputStream: %s", e.getMessage()));
		}
	}
}
