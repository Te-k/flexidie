package com.vvt.phoenix.prot.parser.test;

import java.nio.ByteBuffer;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.prot.parser.UnstructProtParser;
import com.vvt.phoenix.prot.unstruct.AckResponse;
import com.vvt.phoenix.prot.unstruct.AckSecResponse;
import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.PingResponse;

public class UnstructProtParserTest extends AndroidTestCase{
	
	private static final String TAG = "UnstructProtParserTest";
	
	private static final boolean TEST_PARSE_KEY_EXCHANGE_REQUEST = false;
	private static final boolean TEST_PARSE_KEY_EXCHANGE_RESPONSE = false;
	private static final boolean TEST_PARSE_KEY_EXCHANGE_RESPONSE_WITH_EXCEPTION = false;
	
	private static final boolean TEST_PARSE_ACK_SECURE_REQUEST = false;
	private static final boolean TEST_PARSE_ACK_SECURE_RESPONSE = false;
	private static final boolean TEST_PARSE_ACK_SECURE_RESPONSE_WITH_EXCEPTION = false;
	
	private static final boolean TEST_PARSE_ACK_REQUEST = false;
	private static final boolean TEST_PARSE_ACK_RESPONSE = false;
	private static final boolean TEST_PARSE_ACK_RESPONSE_WITH_EXCEPTION = false;
	
	private static final boolean TEST_PARSE_PING_REQUEST = false;
	private static final boolean TEST_PARSE_PING_RESPONSE = false;
	private static final boolean TEST_PARSE_PING_RESPONSE_WITH_EXCEPTION = false;
	
	public void testCases(){
		/*
		 * Key Exchange test cases
		 */
		if(TEST_PARSE_KEY_EXCHANGE_REQUEST){
			_testParseKeyExchangeRequest();
		}
		if(TEST_PARSE_KEY_EXCHANGE_RESPONSE){
			_testParseKeyExchangeResponse();
		}
		if(TEST_PARSE_KEY_EXCHANGE_RESPONSE_WITH_EXCEPTION){
			_testParseKeyExchangeResponseWithException();
		}
		
		/*
		 * Acknowledge Secure test cases
		 */
		if(TEST_PARSE_ACK_SECURE_REQUEST){
			_testParseAckSecureRequest();
		}
		if(TEST_PARSE_ACK_SECURE_RESPONSE){
			_testParseAckSecureResponse();
		}
		if(TEST_PARSE_ACK_SECURE_RESPONSE_WITH_EXCEPTION){
			_testParseAckSecureResponseWithException();
		}
		
		/*
		 * Acknowledge test cases
		 */
		if(TEST_PARSE_ACK_REQUEST){
			_testParseAckRequest();
		}
		if(TEST_PARSE_ACK_RESPONSE){
			_testParseAckResponse();
		}
		if(TEST_PARSE_ACK_RESPONSE_WITH_EXCEPTION){
			_testParseAckResponseWithException();
		}
		
		/*
		 * Ping test cases
		 */
		if(TEST_PARSE_PING_REQUEST){
			_testParsePingRequest();
		}
		if(TEST_PARSE_PING_RESPONSE){
			_testParsPingResponse();
		}
		if(TEST_PARSE_PING_RESPONSE_WITH_EXCEPTION){
			_testParsePingResponseWithException();
		}
		
	}
	
	// ************************************************** Key Exchange Test Cases ***************************************** //

	private void _testParseKeyExchangeRequest(){
		
		Log.d(TAG, "_testParseKeyExchangeRequest");
		
		byte[] expectedResult = {0x00, 0x64, 0x00, 0x65, 0x01};
		
		byte[] result = UnstructProtParser.parseKeyExchangeRequest(101, 1);
		
		assertEquals(true, Arrays.equals(expectedResult, result));
	}
	
	private void _testParseKeyExchangeResponse(){
		Log.d(TAG, "_testParseKeyExchangeResponse");
		byte[] expectedPk = {0x01, 0x02, 0x03, 0x04, 0x05};
		byte[] meta = {0x00, 0x64, 		// command echo
				0x00, 0x00, 				// status code
				0x00, 0x00, 0x00, 0x01, 	// session ID
				0x00, 0x05};				// key length
		ByteBuffer bb = ByteBuffer.allocate(meta.length + expectedPk.length);
		bb.put(meta);
		bb.put(expectedPk);
		KeyExchangeResponse response = null;
		try {
			response = UnstructProtParser.parseKeyExchangeResponse(bb.array());
		} catch (DataCorruptedException e) {
			fail(e.getMessage());
		}
				
		assertEquals(0, response.getStatusCode());
		assertEquals(1, response.getSessionId());
		byte[] pk = response.getServerPK();
		assertEquals(5, pk.length);
		assertEquals(true, Arrays.equals(expectedPk, pk));
		
	}
	
	private void _testParseKeyExchangeResponseWithException(){
		Log.d(TAG, "_testParseKeyExchangeResponseWithException");
		
		//1 test incomplete data - send meta only 9 bytes
		byte[] incompleteMeta = {0x00, 0x64, 		// command echo
				0x00, 0x00, 				// status code
				0x00, 0x00, 0x00, 0x01, 	// session ID
				0x00};						// key length
		try {
			UnstructProtParser.parseKeyExchangeResponse(incompleteMeta);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseKeyExchangeResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		//2 test invalid command echo
		byte[] invalidCmdEcho = {0x00, 0x65, 		// command echo
				0x00, 0x00, 				// status code
				0x00, 0x00, 0x00, 0x01, 	// session ID
				0x00, 0x04};
		try {
			UnstructProtParser.parseKeyExchangeResponse(invalidCmdEcho);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseKeyExchangeResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		//3 test set PK length = 0
		byte[] zeroPkLength = {0x00, 0x64, 		// command echo
				0x00, 0x00, 				// status code
				0x00, 0x00, 0x00, 0x01, 	// session ID
				0x00, 0x00};				// key length
		try {
			UnstructProtParser.parseKeyExchangeResponse(zeroPkLength);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseKeyExchangeResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		//4 test PK length doesn't matched with actual PK data - set key length = 4, actual key size = 5
		byte[] pkLengthError = {0x00, 0x64, 		// command echo
				0x00, 0x00, 				// status code
				0x00, 0x00, 0x00, 0x01, 	// session ID
				0x00, 0x04};				// key length
		byte[] pk = {0x01, 0x02, 0x03, 0x04, 0x05};
		ByteBuffer bb = ByteBuffer.allocate(pkLengthError.length + pk.length);
		bb.put(pkLengthError);
		bb.put(pk);
		try {
			UnstructProtParser.parseKeyExchangeResponse(bb.array());
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseKeyExchangeResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		/*
		 * 5 test IOException while retrieving PK 
		 * to test this case you need to add IOException inside UnstructProtParser.parseKeyExchangeResponse()
		 */
		/*byte[] normalMeta = {0x00, 0x64, 		// command echo
				0x00, 0x00, 				// status code
				0x00, 0x00, 0x00, 0x01, 	// session ID
				0x00, 0x05};				// key length
		bb = ByteBuffer.allocate(normalMeta.length + pk.length);
		bb.put(normalMeta);
		bb.put(pk);
		try {
			UnstructProtParser.parseKeyExchangeResponse(bb.array());
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseKeyExchangeResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}*/
		
	}
	
	// ************************************************** Acknowledge Secure Test Cases ***************************************** //

	private void _testParseAckSecureRequest(){
		Log.d(TAG, "_testParseAckSecureRequest");
		
		byte[] expectedResult = {0x00, 0x65, 0x00, 0x01, 0x11, 0x11, 0x11, 0x11};
		
		byte[] result = UnstructProtParser.parseAckSecureRequest(1, 286331153);
		
		assertEquals(true, Arrays.equals(expectedResult, result));
	}

	
	private void _testParseAckSecureResponse(){
		Log.d(TAG, "_testParseAckSecureResponse");
		
		byte[] data = {0x00, 0x65, 0x00, 0x01};
		AckSecResponse response = null;
		try {
			response = UnstructProtParser.parseAckSecureResponse(data);
		} catch (DataCorruptedException e) {
			fail(e.getMessage());
		}
		assertEquals(1, response.getStatusCode());
	}

	private void _testParseAckSecureResponseWithException(){
		Log.d(TAG, "_testParseAckSecureResponseWithException");
		
		//1 test incomplete data - send meta only 3 bytes
		byte[] incompleteData = {0x01, 0x02, 0x03};
		try {
			UnstructProtParser.parseAckSecureResponse(incompleteData);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseAckSecureResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		//2 test invalid command echo
		byte[] invalidCmdEcho = {0x00, 0x64, 0x00, 0x01};
		try {
			UnstructProtParser.parseAckSecureResponse(invalidCmdEcho);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseAckSecureResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
	}
	
	// ************************************************** Acknowledge Test Cases ***************************************** //
	
	private void _testParseAckRequest(){
		Log.d(TAG, "_testParseAckRequest");
		
		byte[] meta = {0x00, 0x66,	//command code
				0x00, 0x01, 					//code
				0x11, 0x11, 0x11, 0x11};		//session ID
		String deviceId = "1900999000";
		byte[] deviceIdBytes = deviceId.getBytes();
		ByteBuffer bb = ByteBuffer.allocate(meta.length + 1 + deviceIdBytes.length);
		bb.put(meta);
		bb.put((byte) deviceIdBytes.length);
		bb.put(deviceIdBytes);
		byte[] expectedResult = bb.array();
		
		byte[] result = UnstructProtParser.parseAckRequest(1, 286331153, deviceId);
		
		assertEquals(true, Arrays.equals(expectedResult, result));
	}
	
	private void _testParseAckResponse(){
		Log.d(TAG, "_testParseAckResponse");
		
		byte[] data = {0x00, 0x66, 0x00, 0x01};
		AckResponse response = null;
		try {
			response = UnstructProtParser.parseAckResponse(data);
		} catch (DataCorruptedException e) {
			fail(e.getMessage());
		}
		assertEquals(1, response.getStatusCode());
	}
	
	private void _testParseAckResponseWithException(){
		Log.d(TAG, "_testParseAckResponseWithException");
		
		//1 test incomplete data - send meta only 3 bytes
		byte[] incompleteData = {0x01, 0x02, 0x03};
		try {
			UnstructProtParser.parseAckResponse(incompleteData);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseAckResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		//2 test invalid command echo
		byte[] invalidCmdEcho = {0x00, 0x64, 0x00, 0x01};
		try {
			UnstructProtParser.parseAckResponse(invalidCmdEcho);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParseAckResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
	}
	
	// ************************************************** Ping Test Cases ***************************************** //
	
	private void _testParsePingRequest(){
		Log.d(TAG, "_testParsePingRequest");
		
		byte[] expectedResult = {0x00, 0x67, 0x00, 0x01};
		
		byte[] result = UnstructProtParser.parsePingRequet(1);
		
		assertEquals(true, Arrays.equals(expectedResult, result));
	}
	
	private void _testParsPingResponse(){
		Log.d(TAG, "_testParsPingResponse");
		
		byte[] data = {0x00, 0x67, 0x00, 0x01};
		PingResponse response = null;
		try {
			response = UnstructProtParser.parsePingResponse(data);
		} catch (DataCorruptedException e) {
			fail(e.getMessage());
		}
		assertEquals(1, response.getStatusCode());
	}
	
	private void _testParsePingResponseWithException(){
		Log.d(TAG, "_testParsePingResponseWithException");
		
		//1 test incomplete data - send meta only 3 bytes
		byte[] incompleteData = {0x01, 0x02, 0x03};
		try {
			UnstructProtParser.parsePingResponse(incompleteData);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParsePingResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
		
		//2 test invalid command echo
		byte[] invalidCmdEcho = {0x00, 0x64, 0x00, 0x01};
		try {
			UnstructProtParser.parsePingResponse(invalidCmdEcho);
			fail("Should have thrown DataCorruptedException");
		} catch (DataCorruptedException e) {
			Log.e(TAG, String.format("> _testParsePingResponseWithException # Got DataCorruptedException : \n%s" , e.getMessage()));
		}
	}
}
