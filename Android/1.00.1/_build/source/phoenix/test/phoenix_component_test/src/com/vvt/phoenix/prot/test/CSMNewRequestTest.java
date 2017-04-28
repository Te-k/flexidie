package com.vvt.phoenix.prot.test;

import android.database.sqlite.SQLiteException;
import android.os.ConditionVariable;
import android.os.Looper;
import android.os.SystemClock;
import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.response.ResponseData;

public class CSMNewRequestTest extends AndroidTestCase implements CommandListener{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "CSMNewRequestTest";
	
	/*
	 * Constants
	 */
	private static final String STORE_PATH = "/sdcard/csm/";
	//private static final String URL = "http://58.137.119.229/RainbowCore/";
	private static final String URL = "http://192.168.2.116/RainbowCore/";
	private static final String UNSTRUCUTRED_URL = URL + "gateway/unstructured";
	private static final String STRUCUTRED_URL = URL + "gateway";
	
	/*
	 * Members
	 */	 
	CommandServiceManager mCsm;
	private ConditionVariable mLock;
	private long mKeyExchangeTestCaseCsid;
	private long mBuildPayloadTestCaseCsid;
	private long mHttpTestCaseCsid;
	private long mReponseTestCaseCsid;
	
	/*
	 * Test cases switchers
	 * For CSMCommonTest, you must test only one case at a time.
	 */
	private static final boolean TEST_HANDLE_OPEN_SESSION_DB_ERROR = false;
	private static final boolean TEST_HANDLE_REQUEST_WITH_INVALID_COMMAND_CODE = false;
	private static final boolean TEST_HANDLE_PERSIST_SESSION_ERROR = false;
	private static final boolean TEST_HANDLE_ADD_NEW_REQUEST_TO_QUEUE_ERROR = false;
	private static final boolean TEST_HANDLE_DELETE_SESSION_ERROR_WHEN_ADD_QUEUE_ERROR = false;
	private static final boolean TEST_HANDLE_KEY_EXCHANGE_ERROR = false;
	private static final boolean TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR = false;
	private static final boolean TEST_HANDLE_UPDATE_SESSION_ERROR = false;
	private static final boolean TEST_HANDLE_HTTP_CONNECT_ERROR = false;
	private static final boolean TEST_HANDLE_HTTP_TRANSPORT_ERROR = false;
	private static final boolean TEST_HANDLE_HTTP_ERROR = false;
	private static final boolean TEST_HANDLE_DECRYPT_RESPONSE_ERROR = false;
	private static final boolean TEST_HANDLE_PLAINTEXT_RESPONSE = false;
	private static final boolean TEST_HANDLE_INVALID_CRC = false;
	private static final boolean TEST_HANDLE_PARSING_RESPONSE_ERROR = false;
	private static final boolean TEST_HANDLE_SERVER_ERROR = false;
		
	
	public void testCases(){
		mLock = new ConditionVariable();
		Thread callerThread = new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				
				if(TEST_HANDLE_OPEN_SESSION_DB_ERROR){
					_testHandleOpenSessionDbError();
				}
				if(TEST_HANDLE_REQUEST_WITH_INVALID_COMMAND_CODE){
					_testHandleRequestWithInvalidCommandCode();
				}
				if(TEST_HANDLE_PERSIST_SESSION_ERROR){
					_testHandlePersistSessionError();
				}
				if(TEST_HANDLE_ADD_NEW_REQUEST_TO_QUEUE_ERROR){
					_testHandleAddNewRequestToQueueError();
				}
				if(TEST_HANDLE_DELETE_SESSION_ERROR_WHEN_ADD_QUEUE_ERROR){
					_testHandleDeleteSessionErrorWhenAddQueueError();
				}
				if(TEST_HANDLE_KEY_EXCHANGE_ERROR){
					_testHandleKeyExchangeError();
				}
				if(TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR){
					_testHandleBuildProtocolPacketError();
				}
				if(TEST_HANDLE_UPDATE_SESSION_ERROR){
					_testHandleUpdateSessionError();
				}
				if(TEST_HANDLE_HTTP_CONNECT_ERROR){
					_testHandleHttpConnectError();
				}
				if(TEST_HANDLE_HTTP_TRANSPORT_ERROR){
					_testHandleHttpTransportError();
				}
				if(TEST_HANDLE_HTTP_ERROR){
					_testHandleHttpError();
				}
				if(TEST_HANDLE_DECRYPT_RESPONSE_ERROR){
					_testHandleDecryptResponseError();
				}
				if(TEST_HANDLE_PLAINTEXT_RESPONSE){
					_testHandlePlaintextResponse();
				}
				if(TEST_HANDLE_INVALID_CRC){
					_testHandleInvalidCrc();
				}
				if(TEST_HANDLE_PARSING_RESPONSE_ERROR){
					_testHandleParsingResponseError();
				}
				if(TEST_HANDLE_SERVER_ERROR){
					_testHandleServerError();
				}
				
				Looper.loop();
			}
		};
		callerThread.start();
		
		mLock.block();
		//wait for CSM to clear resources
		SystemClock.sleep(5000);
	}
	
	// ****************************************************** Test Cases ****************************************************** //
	
	/**
	 * To test this case,
	 * You have to add dummy Exception in getInstance()
	 * at session DB opening step.
	 */
	private void _testHandleOpenSessionDbError(){
		Log.d(TAG, "> _testHandleOpenSessionDbError");
		try{
			mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
			fail("Should have thrown SQLiteException");
		}catch(SQLiteException e){
			Log.e(TAG, String.format("> _testHandleOpenSessionDbError # %s", e.getMessage()));
		}
		mLock.open();
	}
	
	/**
	 * To test this case,
	 * You have to force set command code to -1 in execute()
	 */
	private void _testHandleRequestWithInvalidCommandCode(){
		Log.d(TAG, "> _testHandleRequestWithInvalidCommandCode");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		CommandRequest request = new CommandRequest();
		request.setMetaData(new CommandMetaData());
		request.setCommandData(new SendActivate());
		long csid = mCsm.execute(request);
		assertEquals(-1, csid);
		mLock.open();
	}
	
	/**
	 * To test this case,
	 * You have to let SessionManager to persist error in persistSession()
	 */
	private void _testHandlePersistSessionError(){
		Log.d(TAG, "> _testHandlePersistSessionError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		CommandRequest request = new CommandRequest();
		request.setMetaData(new CommandMetaData());
		request.setCommandData(new SendEvents());
		long csid = mCsm.execute(request);
		assertEquals(-1, csid);
		mLock.open();
	}
	
	/**
	 * To test this case,
	 * You have to force set return value at adding queue operation to false
	 * in execute()
	 */
	private void _testHandleAddNewRequestToQueueError(){
		Log.d(TAG, "> _testHandleAddNewRequestToQueueError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		CommandRequest request = new CommandRequest();
		request.setMetaData(new CommandMetaData());
		request.setCommandData(new SendEvents());
		long csid = mCsm.execute(request);
		assertEquals(-1, csid);
		mLock.open();
	}
	
	/**
	 * To test this case,
	 * You have to force set return value at adding queue operation to false
	 * in execute() and also add dummy Exception in SessionManager.deleteSession()
	 */
	private void _testHandleDeleteSessionErrorWhenAddQueueError(){
		Log.d(TAG, "> _testHandleDeleteSessionErrorWhenAddQueueError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		CommandRequest request = new CommandRequest();
		request.setMetaData(new CommandMetaData());
		request.setCommandData(new SendEvents());
		long csid = mCsm.execute(request);
		assertEquals(-1, csid);
		mLock.open();
	}
	
	/**
	 * To test this case,
	 * You have to return key exchange error from UnstructuredManager.doKeyExchange() 
	 */
	private void _testHandleKeyExchangeError(){
		Log.d(TAG, "> _testHandleKeyExchangeError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		CommandRequest request = new CommandRequest();
		request.setMetaData(new CommandMetaData());
		request.setCommandData(new SendEvents());
		request.setCommandListener(this);
		mKeyExchangeTestCaseCsid = mCsm.execute(request);

	}
	
	/**
	 * To test this case,
	 * You have to add dummy Exception in SendEventsPayloadBuilder.buildPayload()
	 */
	private void _testHandleBuildProtocolPacketError(){
		Log.d(TAG, "> _testHandleBuildProtocolPacketError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mBuildPayloadTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	/**
	 * To test this case,
	 * You have to add dummy Exception in SessionManager.updateSession()
	 */
	private void _testHandleUpdateSessionError(){
		Log.d(TAG, "> _testHandleUpdateSessionError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mBuildPayloadTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	private void _testHandleHttpConnectError(){
		Log.d(TAG, "> _testHandleHttpConnectError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, "");
		mHttpTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
		
	}
	
	/**
	 * To test this case,
	 * You have to cut off the internet connection while CSM is sending data to server.
	 */
	private void _testHandleHttpTransportError(){
		Log.d(TAG, "> _testHandleHttpTransportError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mHttpTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 5));
	}
	
	private void _testHandleHttpError(){
		Log.d(TAG, "> _testHandleHttpError");
		
		//make connection to non-exist resource
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL+"/xxx");
		mHttpTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	/**
	 * To test this case,
	 * You have to request decryption with NULL AES key
	 * in doProcessResponse() at decryp response step.
	 */
	private void _testHandleDecryptResponseError(){
		Log.d(TAG, "> _testHandleDecryptResponseError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mHttpTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	/**
	 * To test this case,
	 * You have to call _testParsingResponseAsPlainText() in onHttpSuccess()
	 * instead of call doProcessResponse()
	 */
	private void _testHandlePlaintextResponse(){
		Log.d(TAG, "> _testHandlePlaintextResponse");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mHttpTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	/**
	 * To test this case,
	 * You have to set calculated CRC value to -1 in doProcessResponse()
	 */
	private void _testHandleInvalidCrc(){
		Log.d(TAG, "> _testHandleInvalidCrc");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mReponseTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	/**
	 * To test this case,
	 * You have to add dummy Exception in ResponseParser.parseResponse()
	 */
	private void _testHandleParsingResponseError(){
		Log.d(TAG, "> _testHandleParsingResponseError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mReponseTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	/**
	 * To test this case,
	 * You have to force response code to be invalid value in doNotifySuccess()
	 */
	private void _testHandleServerError(){
		Log.d(TAG, "> _testHandleServerError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mReponseTestCaseCsid = mCsm.execute(PhoenixTestUtil.createSendEventRequest(getContext(), this, 1));
	}
	
	
	// ****************************************************** Phoenix Callback ****************************************************** //

	@Override
	public void onConstructError(long csid, Exception e) {
		Log.w(TAG, String.format("> onConstructError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
		
		if(TEST_HANDLE_KEY_EXCHANGE_ERROR){
			Log.v(TAG, "> onConstructError # TEST_HANDLE_KEY_EXCHANGE_ERROR");
			assertEquals(mKeyExchangeTestCaseCsid, csid);
		}else if(TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR){
			Log.v(TAG, "> onConstructError # TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR");
			assertEquals(mBuildPayloadTestCaseCsid, csid);
		}else if(TEST_HANDLE_UPDATE_SESSION_ERROR){
			Log.v(TAG, "> onConstructError # TEST_HANDLE_UPDATE_SESSION_ERROR");
			assertEquals(mBuildPayloadTestCaseCsid, csid);
		}else{
			fail();
		}
		
		mLock.open();
	}

	@Override
	public void onTransportError(long csid, Exception e) {
		Log.w(TAG, String.format("> onTransportError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
		
		if(TEST_HANDLE_HTTP_CONNECT_ERROR){
			Log.v(TAG, "> onTransportError # TEST_HANDLE_HTTP_CONNECT_ERROR");
			assertEquals(mHttpTestCaseCsid, csid);
		}else if(TEST_HANDLE_HTTP_TRANSPORT_ERROR){
			Log.v(TAG, "> onTransportError # TEST_HANDLE_HTTP_TRANSPORT_ERROR");
			assertEquals(mHttpTestCaseCsid, csid);
		}else if(TEST_HANDLE_HTTP_ERROR){
			Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_HTTP_ERROR: %s", e.getMessage()));
			assertEquals(mHttpTestCaseCsid, csid);
		}else if(TEST_HANDLE_DECRYPT_RESPONSE_ERROR){
			Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_DECRYPT_RESPONSE_ERROR: %s", e.getMessage()));
			assertEquals(mHttpTestCaseCsid, csid);
		}else if(TEST_HANDLE_INVALID_CRC){
			Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_INVALID_CRC: %s", e.getMessage()));
			assertEquals(mReponseTestCaseCsid, csid);
		}else if(TEST_HANDLE_PARSING_RESPONSE_ERROR){
			Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_PARSING_RESPONSE_ERROR: %s", e.getMessage()));
			assertEquals(mReponseTestCaseCsid, csid);
		}else{
			fail();
		}
		
		mLock.open();
	}

	@Override
	public void onSuccess(ResponseData response) {
		Log.i(TAG, String.format("> onSuccess # CSID: %d, - %s - Thread ID: %d", response.getCsid(), response.getMessage(), Thread.currentThread().getId()));
		
		
		mLock.open();
	}

	@Override
	public void onServerError(ResponseData response) {
		Log.w(TAG, String.format("> onServerError # CSID: %d, - %s - Thread ID: %d", response.getCsid(), response.getMessage(), Thread.currentThread().getId()));
		
		if(TEST_HANDLE_SERVER_ERROR){
			Log.v(TAG, String.format("> onServerError # TEST_HANDLE_SERVER_ERROR: %s", response.getMessage()));
			assertEquals(mReponseTestCaseCsid, response.getCsid());
		}else{
			fail();
		}
		
		mLock.open();
	}

}
