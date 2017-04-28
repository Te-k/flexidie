package com.vvt.phoenix.prot.test;

import com.vvt.crypto.AESKeyGenerator;
import com.vvt.crypto.RSAKeyGenerator;
import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.session.SessionInfo;
import com.vvt.phoenix.prot.session.SessionManager;

import android.os.ConditionVariable;
import android.os.Looper;
import android.os.SystemClock;
import android.test.AndroidTestCase;
import android.util.Log;

public class CSMResumeRequestTest extends AndroidTestCase implements CommandListener{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "CSMResumeRequestTest";
	
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
	
	/*
	 * Test cases switchers
	 * For CSMCommonTest, you must test only one case at a time.
	 */
	private static final boolean TEST_HANDLE_RETRIEVE_SESSION_ERROR = false;
	private static final boolean TEST_RETRIEVE_SESSION_WITH_INCOMPLETE_PAYLOAD = false;
	private static final boolean TEST_HANDLE_NULL_RASK_RESPONSE = false;
	private static final boolean TEST_HANDLE_RASK_ERROR = false;
	private static final boolean TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR = false;
	
	public void testCases(){
		mLock = new ConditionVariable();
		Thread callerThread = new Thread(){
			@Override
			public void run(){
				Looper.prepare();
			
				if(TEST_HANDLE_RETRIEVE_SESSION_ERROR){
					_testHandleRetrieveSessionError();
				}
				if(TEST_RETRIEVE_SESSION_WITH_INCOMPLETE_PAYLOAD){
					_testRetrieveSessionWithIncompletePayload();
				}
				if(TEST_HANDLE_NULL_RASK_RESPONSE){
					_testHandleNullRAskResponse();
				}
				if(TEST_HANDLE_RASK_ERROR){
					_testHandleRAskError();
				}
				if(TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR){
					_testHandleBuildProtocolPacketError();
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
	
	private void _testHandleRetrieveSessionError(){
		Log.d(TAG, "> _testHandleRetrieveSessionError");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		long csid = mCsm.resume(-1, this);
		assertEquals(-1, csid);
		mLock.open();
	}
	
	/**
	 * To test this case,
	 * You have to add dummy SessionInfo in resume()
	 */
	private void _testRetrieveSessionWithIncompletePayload(){
		Log.d(TAG, "> _testRetrieveSessionWithIncompletePayload");
		
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		long csid = mCsm.resume(-1, this);
		assertEquals(-1, csid);
		mLock.open();
	}
	
	/**
	 * Don't forget to remove Phoenix DB before test.
	 */
	private void _testHandleNullRAskResponse(){
		Log.d(TAG, "> _testHandleNullRAskResponse");
		long dummyCsid = 6996;
		//1 persist dummy session with ready flag = true
		SessionInfo dummySession = new SessionInfo();
		dummySession.setPayloadReady(true);
		dummySession.setCsid(dummyCsid);
		dummySession.setMetaData(new CommandMetaData());
		dummySession.setAesKey(new byte[]{0, 0, 0}); // we will crash RAskAgency by give it an invalid AES key.
		SessionManager sessionMan = new SessionManager(STORE_PATH, STORE_PATH);	//paths must be matched with CSM
		sessionMan.openOrCreateSessionDatabase();
		assertEquals(true, sessionMan.persistSession(dummySession));
		
		//2 resume it
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mCsm.resume(dummyCsid, this);
	}
	
	/**
	 * To test this case, 
	 * You have to add dummy SessionInfo with invalid response code
	 * in doRAsk()
	 * and remove Phoenix DB as well.
	 */
	private void _testHandleRAskError(){
		Log.d(TAG, "> _testHandleRAskError");
		
		long dummyCsid = 6996;
		long invalidSsid = -1;
		//1 persist dummy session with ready flag = true
		SessionInfo dummySession = new SessionInfo();
		dummySession.setPayloadReady(true);
		dummySession.setCsid(dummyCsid);
		dummySession.setMetaData(new CommandMetaData());
		dummySession.setAesKey(AESKeyGenerator.generate().getEncoded());
		RSAKeyGenerator rsaKeyGen = new RSAKeyGenerator();
		dummySession.setServerPublicKey(rsaKeyGen.getPublicKey().getEncoded());
		dummySession.setSsid(invalidSsid);
		dummySession.setPayloadPath("");
		SessionManager sessionMan = new SessionManager(STORE_PATH, STORE_PATH);	//paths must be matched with CSM
		sessionMan.openOrCreateSessionDatabase();
		assertEquals(true, sessionMan.persistSession(dummySession));
		
		//2 let's resume
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mCsm.resume(dummyCsid, this);
	}
	
	/**
	 * To test this case,
	 * You have to call doBuildResumeRequestProtocolPacket()
	 * instead of doRAsk() in processingNextRequest().
	 * And don't forget to remove Phoenix DB before test.
	 */
	private void _testHandleBuildProtocolPacketError(){
		Log.d(TAG, "> _testHandleBuildProtocolPacketError");
		
		long dummyCsid = 6996;
		//1 persist dummy session with ready flag = true
		SessionInfo dummySession = new SessionInfo();
		dummySession.setPayloadReady(true);
		dummySession.setCsid(dummyCsid);
		dummySession.setMetaData(new CommandMetaData());
		dummySession.setAesKey(new byte[]{0, 0, 0});	// we will crash ProtocolPacketBuilder by give it an invalid AES key.
		SessionManager sessionMan = new SessionManager(STORE_PATH, STORE_PATH);	//paths must be matched with CSM
		sessionMan.openOrCreateSessionDatabase();
		assertEquals(true, sessionMan.persistSession(dummySession));
		
		//2 resume it
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mCsm.resume(dummyCsid, this);
	}
	
	
	// ****************************************************** Phoenix Callback ****************************************************** //

		@Override
		public void onConstructError(long csid, Exception e) {
			Log.w(TAG, String.format("> onConstructError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
			

			mLock.open();
		}

		@Override
		public void onTransportError(long csid, Exception e) {
			Log.w(TAG, String.format("> onTransportError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
			
			if(TEST_HANDLE_NULL_RASK_RESPONSE){
				Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_NULL_RASK_RESPONSE, CSID %d - %s", csid, e.getMessage()));
			}else if(TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR){
				Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_BUILD_PROTOCOL_PACKET_ERROR, CSID %d - %s", csid, e.getMessage()));
			}else{
				fail("onTransportError");
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
			
			if(TEST_HANDLE_RASK_ERROR){
				Log.v(TAG, String.format("> onTransportError # TEST_HANDLE_RASK_ERROR, CSID %d - %s", response.getCsid(), response.getMessage()));
			}else{
				fail("onServerError");
			}

			
			mLock.open();
		}

}
