package com.vvt.phoenix.prot.test;

import android.os.ConditionVariable;
import android.os.Looper;
import android.os.SystemClock;
import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.response.ResponseData;

public class CSMCommonTest extends AndroidTestCase implements CommandListener{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "CSMCommonTest";
	
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
	private long mCurrentCsid;
	
	/*
	 * Test cases switchers
	 * For CSMCommonTest, you must test only one case at a time.
	 */
	private static final boolean TEST_SEND_NEW_REQUEST = false;
	private static final boolean TEST_SEND_RESUME_REQUEST = false;
	private static final boolean TEST_REMOVE_REQUEST_FROM_QUEUE = false;
	private static final boolean TEST_REMOVE_REQUEST_FROM_EXECUTOR_SESSION = false;
	private static final boolean TEST_HANDLE_INVALID_ARGUMENTS = false;

	public void testCases(){
		/*mCsm = CommandServiceManager2.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		mCsm.resume(5, this);*/
		
		mLock = new ConditionVariable();
		Thread callerThread = new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				FxLog.d(TAG, String.format("> testCases > run # Test case is running - Thread ID: %d", Thread.currentThread().getId()));
				if(TEST_SEND_NEW_REQUEST){
					_testSendNewRequest();
				}
				if(TEST_SEND_RESUME_REQUEST){
					_testSendResumeRequest();
				}
				if(TEST_REMOVE_REQUEST_FROM_QUEUE){
					_testRemoveRequestFromQueue();
				}
				if(TEST_REMOVE_REQUEST_FROM_EXECUTOR_SESSION){
					_testRemoveRequestFromExecutorSession();
				}
				if(TEST_HANDLE_INVALID_ARGUMENTS){
					_testHandleInvalidArguments();
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
	 * While CSM is sending data, cut off the internet to make onTransportError() then turn on internet again and wait for resume.
	 */
	private void _testSendNewRequest(){
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		if(mCsm != null){
			CommandRequest request = PhoenixTestUtil.createSendActivateRequest(getContext(), this);
			//CommandRequest request = PhoenixTestUtil.createSendEventRequest(getContext(), this, 1);
    		mCurrentCsid = mCsm.execute(request);
        	Log.v(TAG, String.format("> _testSendNewRequest # CSM has accepted our request and give us CSID: %d", mCurrentCsid));
    	}else{
    		fail("> _testSendNewRequest # Cannot initiate CSM");
    	}
	}
	
	private void _testSendResumeRequest(){
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		if(mCsm != null){
			CommandRequest request = PhoenixTestUtil.createSendEventRequest(getContext(), this, 10);
    		mCurrentCsid = mCsm.execute(request);
        	Log.v(TAG, String.format("> _testSendResumeRequest # CSM has accepted our request and give us CSID: %d", mCurrentCsid));
    	}else{
    		fail("> _testSendResumeRequest # Cannot initiate CSM");
    	}
	}
	
	private void _testRemoveRequestFromQueue(){
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		if(mCsm != null){
			//1 make first request
			CommandRequest request = PhoenixTestUtil.createSendEventRequest(getContext(), this, 1);
    		mCurrentCsid = mCsm.execute(request);
        	Log.v(TAG, String.format("> _testRemoveRequestFromQueue # CSM has accepted our first request and give us CSID: %d", mCurrentCsid));
        	//2 make second request
        	long secondCsid = mCsm.execute(request);
        	Log.v(TAG, String.format("> _testRemoveRequestFromQueue # CSM has accepted our second request and give us CSID: %d", secondCsid));
        	//3 remove second request
        	assertEquals(true, mCsm.cancelRequest(secondCsid));
    	}else{
    		fail("> _testRemoveRequestFromQueue # Cannot initiate CSM");
    	}
	}
	
	private void _testRemoveRequestFromExecutorSession(){
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		if(mCsm != null){
			CommandRequest request = PhoenixTestUtil.createSendEventRequest(getContext(), this, 1);
    		mCurrentCsid = mCsm.execute(request);
        	Log.v(TAG, String.format("> _testRemoveRequestFromExecutorSession # CSM has accepted our request and give us CSID: %d", mCurrentCsid));
        	//remove from CSM
        	SystemClock.sleep(100);
        	assertEquals(true, mCsm.cancelRequest(mCurrentCsid));
        	Log.v(TAG, String.format("> _testRemoveRequestFromExecutorSession # Ask CSM to cancel CSID %d already, sleep for awhile", mCurrentCsid));
        	//wait for Executor to finish his job (assume 30 seconds) then stop testing
        	SystemClock.sleep(9000);
        	Log.v(TAG, "> _testRemoveRequestFromExecutorSession # Wake up");
        	mLock.open();
    	}else{
    		fail("> _testRemoveRequestFromExecutorSession # Cannot initiate CSM");
    	}
	}
	
	private void _testHandleInvalidArguments(){
		//1 test getInstance()
		try{
			mCsm = CommandServiceManager.getInstance(null, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		try{
			mCsm = CommandServiceManager.getInstance(STORE_PATH, null, UNSTRUCUTRED_URL, STRUCUTRED_URL);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		try{
			mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, null, STRUCUTRED_URL);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		try{
			mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, null);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		
		//2 test execute()
		mCsm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		try{
			mCsm.execute(null);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		//null Meta data
		try{
			CommandRequest request = new CommandRequest();
			request.setCommandData(new SendEvents());
			mCsm.execute(request);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		//null command data
		try{
			CommandRequest request = new CommandRequest();
			request.setMetaData(new CommandMetaData());
			mCsm.execute(request);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> _testHandleInvalidArguments # %s", e.getMessage()));
		}
		
		//3 test resume()
		long csid = mCsm.resume(-1, this);
		assertEquals(-1, csid);
		
		mLock.open();
	}
	
	// ****************************************************** Phoenix Callback ****************************************************** //

	@Override
	public void onConstructError(long csid, Exception e) {
		Log.w(TAG, String.format("> onConstructError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
		if(TEST_SEND_NEW_REQUEST){
			fail(String.format("> onConstructError # CSID %d - %s", csid, e.getMessage()));
		}
		if(TEST_REMOVE_REQUEST_FROM_EXECUTOR_SESSION){
			if(csid == mCurrentCsid){
				fail("Should haven't got callback");
			}
		}
		
		mLock.open();
	}

	@Override
	public void onTransportError(final long csid, Exception e) {
		Log.w(TAG, String.format("> onTransportError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
		if(TEST_SEND_NEW_REQUEST){
			fail(String.format("> onTransportError # CSID %d - %s", csid, e.getMessage()));
		}
		if(TEST_SEND_RESUME_REQUEST){
			Log.v(TAG, "> onTransportError # Waiting 60 seconds before resume");
			new Thread(){
				@Override
				public void run(){
					Looper.prepare();
					SystemClock.sleep(60000);
					FxLog.v(TAG, String.format("> onTransportError # Resume CSID %d - Thread ID %d", csid, Thread.currentThread().getId()));
					mCsm.resume(csid, CSMCommonTest.this);
					Looper.loop();
				}
			}.start();
			//no need to unblock main Thread
			return;
		}
		if(TEST_REMOVE_REQUEST_FROM_EXECUTOR_SESSION){
			if(csid == mCurrentCsid){
				fail("Should haven't got callback");
			}
		}
		
		mLock.open();
	}

	@Override
	public void onSuccess(ResponseData response) {
		Log.i(TAG, String.format("> onSuccess # CSID: %d, - %s - Thread ID: %d", response.getCsid(), response.getMessage(), Thread.currentThread().getId()));
		if(TEST_SEND_NEW_REQUEST){
			assertEquals(mCurrentCsid, response.getCsid());
		}
		if(TEST_REMOVE_REQUEST_FROM_EXECUTOR_SESSION){
			if(response.getCsid() == mCurrentCsid){
				fail("Should haven't got callback");
			}
		}
		
		mLock.open();
	}

	@Override
	public void onServerError(ResponseData response) {
		Log.w(TAG, String.format("> onServerError # CSID: %d, - %s - Thread ID: %d", response.getCsid(), response.getMessage(), Thread.currentThread().getId()));
		if(TEST_SEND_NEW_REQUEST){
			fail(String.format("> onTransportError # CSID %d - %s", response.getCsid(), response.getMessage()));
		}
		if(TEST_REMOVE_REQUEST_FROM_EXECUTOR_SESSION){
			if(response.getCsid() == mCurrentCsid){
				fail("Should haven't got callback");
			}
		}
		
		mLock.open();
	}

}
