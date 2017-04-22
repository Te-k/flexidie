package com.vvt.phoenix.prot.unstruct.test;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.unstruct.AckResponse;
import com.vvt.phoenix.prot.unstruct.AckSecResponse;
import com.vvt.phoenix.prot.unstruct.KeyExchangeResponse;
import com.vvt.phoenix.prot.unstruct.PingResponse;
import com.vvt.phoenix.prot.unstruct.UnstructuredManager;

public class UnstructuredManagerTest extends AndroidTestCase{
	
	private static final String TAG = "UnstructuredManagerTest";	
	private static final String UNSTRUCTURED_URL = "http://192.168.2.116/RainbowCore/gateway/unstructured";
	private static final String NONEXIST_URL = "http://192.168.2.116/RainbowCore/gateway/xx";
	private static final String DUMMY_SERVER = "http://192.168.2.60";
	
	private static final boolean TEST_KEY_EXCHANGE = true;
	private static final boolean TEST_KEY_EXCHANGE_HANDLE_HTTP_ERROR = false;
	private static final boolean TEST_KEY_EXCHANGE_THREAD_BLOCKING_TIME_OUT = false;
	private static final boolean TEST_KEY_EXCHANGE_PARSE_RESPONSE_ERROR = false;
	
	private static final boolean TEST_ACK_SECURE = true;
	private static final boolean TEST_ACK_SECURE_HANDLE_HTTP_ERROR = false;
	private static final boolean TEST_ACK_SECURE_THREAD_BLOCKING_TIME_OUT = false;
	private static final boolean TEST_ACK_SECURE_PARSE_RESPONSE_ERROR = false;
	
	private static final boolean TEST_ACK = true;
	private static final boolean TEST_ACK_HANDLE_HTTP_ERROR = false;
	private static final boolean TEST_ACK_THREAD_BLOCKING_TIME_OUT = false;
	private static final boolean TEST_ACK_PARSE_RESPONSE_ERROR = false;
	
	private static final boolean TEST_PING = true;
	private static final boolean TEST_PING_HANDLE_HTTP_ERROR = false;
	private static final boolean TEST_PING_THREAD_BLOCKING_TIME_OUT = false;
	private static final boolean TEST_PING_PARSE_RESPONSE_ERROR = false;
	
	public void testCases(){
		/*
		 * Key Exchange
		 */
		if(TEST_KEY_EXCHANGE){
			_testKeyExchange();
		}
		if(TEST_KEY_EXCHANGE_HANDLE_HTTP_ERROR){
			_testKeyExchangeHandleHttpError();
		}
		if(TEST_KEY_EXCHANGE_THREAD_BLOCKING_TIME_OUT){
			_testKeyExchangeThreadBlockingTimeOut();
		}
		if(TEST_KEY_EXCHANGE_PARSE_RESPONSE_ERROR){
			_testKeyExchangePareseResponseError();
		}
		
		/*
		 * Acknowledge Secure
		 */
		if(TEST_ACK_SECURE){
			_testAcknowledgeSecure();
		}
		if(TEST_ACK_SECURE_HANDLE_HTTP_ERROR){
			_testAcknowledgeSecureHandleHttpError();
		}
		if(TEST_ACK_SECURE_THREAD_BLOCKING_TIME_OUT){
			_testAckSecureThreadBlockingTimeOut();
		}
		if(TEST_ACK_SECURE_PARSE_RESPONSE_ERROR){
			_testAckSecurePareseResponseError();
		}
		
		/*
		 * Acknowledge
		 */
		if(TEST_ACK){
			_testAcknowledge();
		}
		if(TEST_ACK_HANDLE_HTTP_ERROR){
			_testAcknowledgeHandleHttpError();
		}
		if(TEST_ACK_THREAD_BLOCKING_TIME_OUT){
			_testAckThreadBlockingTimeOut();
		}
		if(TEST_ACK_PARSE_RESPONSE_ERROR){
			_testAckPareseResponseError();
		}
		
		/*
		 * Ping
		 */
		if(TEST_PING){
			_testPing();
		}
		if(TEST_PING_HANDLE_HTTP_ERROR){
			_testPingHandleHttpError();
		}
		if(TEST_PING_THREAD_BLOCKING_TIME_OUT){
			_testPingThreadBlockingTimeOut();
		}
		if(TEST_PING_PARSE_RESPONSE_ERROR){
			_testPingPareseResponseError();
		}
	}
	
	// ************************************************** Key Exchange Test Cases ***************************************** //

	private void _testKeyExchange(){
		Log.d(TAG, "_testKeyExchange");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		KeyExchangeResponse response = manager.doKeyExchange(101, 1);
		
		assertEquals(true, response.isResponseOk());
	}
	
	/*
	 * To test  UnstructuredManager.HttpCaller
	 * use _testKeyExchangeHandleHttpError and test each HTTP scenario the same way as
	 * HTTP Demo project in HTTP test folder.
	 * 
	 * 	- test handling connect error
	 * 		- connect to off-line host
	 * 		- connect with no Internet connection
	 * - test handling HTTP error
	 *  	- connect and request for resource that doesn't exist on the server.
	 *  - test handling transport error
	 *  	- connect to my server by send data but no response back from server
	 *  
	 * Also check this task (http://redmine.vervata.com/issues/2609) 
	 * for more info about how I test it.
	 */
	
	private void _testKeyExchangeHandleHttpError(){
		Log.d(TAG, "_testKeyExchangeHandleHttpError");
		
		//UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		UnstructuredManager manager = new UnstructuredManager(DUMMY_SERVER);
		//UnstructuredManager manager = new UnstructuredManager(NONEXIST_URL);
		KeyExchangeResponse response = manager.doKeyExchange(101, 1);
				
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testKeyExchangeHandleHttpError # %s", response.getErrorMessage()));
	}

	
	/**
	 * To test this case
	 * You will need to change Thread blocking time out value inside
	 * UnstructuredManager.doKeyExchange()
	 * at waiting for HTTP operation step to be less.
	 * 
	 */
	private void _testKeyExchangeThreadBlockingTimeOut(){
		Log.d(TAG, "_testKeyExchangeThreadBlockingTimeOut");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		KeyExchangeResponse response = manager.doKeyExchange(101, 1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testKeyExchangeThreadBlockingTimeOut # Error message: %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to throw dummy Exception inside
	 * UnstructuredManager.doKeyExchange()
	 * at parsing response step
	 */
	private void _testKeyExchangePareseResponseError(){
		Log.d(TAG, "_testKeyExchangePareseResponseError");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		KeyExchangeResponse response = manager.doKeyExchange(101, 1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testKeyExchangePareseResponseError # Error message: %s", response.getErrorMessage()));
	}


	// ************************************************** Acknowledge Secure Test Cases ***************************************** //
	
	private void _testAcknowledgeSecure(){
		Log.d(TAG, "_testAcknowledgeSecure");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		AckSecResponse response = manager.doAckSecure(1, 1);
		
		assertEquals(true, response.isResponseOk());
	}
	
	private void _testAcknowledgeSecureHandleHttpError(){
		Log.d(TAG, "_testAcknowledgeSecureHandleHttpError");
		
		UnstructuredManager manager = new UnstructuredManager(DUMMY_SERVER);
		//UnstructuredManager manager = new UnstructuredManager(NONEXIST_URL);
		AckSecResponse response = manager.doAckSecure(1, 1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testAcknowledgeSecureHandleHttpError # %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to change Thread blocking time out value inside
	 * UnstructuredManager.doAckSecure()
	 * at waiting for HTTP operation step to be less.
	 * 
	 */
	private void _testAckSecureThreadBlockingTimeOut(){
		Log.d(TAG, "_testAckSecureThreadBlockingTimeOut");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		AckSecResponse response = manager.doAckSecure(1, 1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testAckSecureThreadBlockingTimeOut # Error message: %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to throw dummy Exception inside
	 * UnstructuredManager.doAckSecure()
	 * at parsing response step
	 */
	private void _testAckSecurePareseResponseError(){
		Log.d(TAG, "_testAckSecurePareseResponseError");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		AckSecResponse response = manager.doAckSecure(1, 1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testAckSecurePareseResponseError # Error message: %s", response.getErrorMessage()));
	}
	
	// ************************************************** Acknowledge Test Cases ***************************************** //
	
	private void _testAcknowledge(){
		Log.d(TAG, "_testAcknowledge");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		AckResponse response = manager.doAck(1, 1, "123456790");
		
		assertEquals(true, response.isResponseOk());
	}
	
	private void _testAcknowledgeHandleHttpError(){
		Log.d(TAG, "_testAcknowledgeHandleHttpError");
		
		UnstructuredManager manager = new UnstructuredManager(DUMMY_SERVER);
		//UnstructuredManager manager = new UnstructuredManager(NONEXIST_URL);
		AckResponse response = manager.doAck(1, 1, "123456790");
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testAcknowledgeHandleHttpError # %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to change Thread blocking time out value inside
	 * UnstructuredManager.doAck()
	 * at waiting for HTTP operation step to be less.
	 * 
	 */
	private void _testAckThreadBlockingTimeOut(){
		Log.d(TAG, "_testAckThreadBlockingTimeOut");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		AckResponse response = manager.doAck(1, 1, "123456790");
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testAckThreadBlockingTimeOut # Error message: %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to throw dummy Exception inside
	 * UnstructuredManager.doAck()
	 * at parsing response step
	 */
	private void _testAckPareseResponseError(){
		Log.d(TAG, "_testAckPareseResponseError");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		AckResponse response = manager.doAck(1, 1, "123456790");
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testAckPareseResponseError # Error message: %s", response.getErrorMessage()));
	}
	
	// ************************************************** Ping Test Cases ***************************************** //
	
	private void _testPing(){
		Log.d(TAG, "_testPing");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		PingResponse response = manager.doPing(1);
		
		assertEquals(true, response.isResponseOk());
	}
	
	private void _testPingHandleHttpError(){
		Log.d(TAG, "_testPingHandleHttpError");
		
		UnstructuredManager manager = new UnstructuredManager(DUMMY_SERVER);
		//UnstructuredManager manager = new UnstructuredManager(NONEXIST_URL);
		PingResponse response = manager.doPing(1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testPingHandleHttpError # %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to change Thread blocking time out value inside
	 * UnstructuredManager.doPing()
	 * at waiting for HTTP operation step to be less.
	 * 
	 */
	private void _testPingThreadBlockingTimeOut(){
		Log.d(TAG, "_testPingThreadBlockingTimeOut");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		PingResponse response = manager.doPing(1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testPingThreadBlockingTimeOut # Error message: %s", response.getErrorMessage()));
	}
	
	/**
	 * To test this case
	 * You will need to throw dummy Exception inside
	 * UnstructuredManager.doPing()
	 * at parsing response step
	 */
	private void _testPingPareseResponseError(){
		Log.d(TAG, "_testPingPareseResponseError");
		
		UnstructuredManager manager = new UnstructuredManager(UNSTRUCTURED_URL);
		PingResponse response = manager.doPing(1);
		
		assertEquals(false, response.isResponseOk());
		Log.w(TAG, String.format("> _testPingPareseResponseError # Error message: %s", response.getErrorMessage()));
	}
}
