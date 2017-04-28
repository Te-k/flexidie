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
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.databuilder.test.EventProvider;
import com.vvt.phoenix.prot.event.PanicImage;

public class CSMTest extends AndroidTestCase implements CommandListener{
	
	private static final String TAG = "CommandServiceManagerTest";
	
	private static final String STORE_PATH = "/sdcard/csm/";
	private static final String URL = "http://58.137.119.229/RainbowCore/";
	private static final String UNSTRUCUTRED_URL = URL + "gateway/unstructured";
	private static final String STRUCUTRED_URL = URL + "gateway";
	private static final int CONFIG_ID = 104;
	private static final String ACTIVATION_CODE = "01329";
	private static final String IMAGE_PATH = "/sdcard/image.jpg";
	
	private static final boolean TEST_EXECUTE_NEW_REQUEST = true;
	private static final boolean TEST_HANDLE_OPEN_SESSION_DB_ERROR = false;
	private static final boolean TEST_HANDLE_ILLEGAL_INPUT = false;
	private static final boolean TEST_HANDLE_KEY_EXCHANGE_ERROR = false;
	private static final boolean TEST_HANDLE_BUILDING_PROTOCOL_ERROR = false;
	private static final boolean TEST_UPDATE_SESSION_ERROR = false;
	private static final boolean TEST_HANDLE_HTTP_OPERATION_TIME_OUT = false;
	private static final boolean TEST_HANDLE_HTTP_ERROR = false;
	private static final boolean TEST_DECRYPT_RESPONSE_ERROR = false;
	private static final boolean TEST_HANDLE_SERVER_ERROR = false;
	private static final boolean TEST_PROCESS_RESPONSE_ON_FILE = false;
	private static final boolean TEST_CANCEL_REQUEST = false;
	
	
	/*
	 * Member
	 */	 
	private ConditionVariable mLock;
	private long mCurrentCsid;
	
	public void testCases(){
		mLock = new ConditionVariable();
		Thread callerThread = new Thread(){
			@Override
			public void run(){
				Looper.prepare();
				FxLog.d(TAG, String.format("> testCases > run # Test case is running - Thread ID: %d", Thread.currentThread().getId()));
				
				if(TEST_EXECUTE_NEW_REQUEST){
					_testExecuteNewReqeust();
				}
				if(TEST_HANDLE_OPEN_SESSION_DB_ERROR){
					_testHandleOpenSessionDbError();
				}
				if(TEST_HANDLE_ILLEGAL_INPUT){
					_testHandleIllegalInput();
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
	
	private void _testExecuteNewReqeust(){
		Log.d(TAG, "_testExecuteNewReqeust");
		
		SendEvents commandData = new SendEvents();
    	EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(PhoenixTestUtil.getCurrentEventTimeStamp());
    	event.setImagePath(IMAGE_PATH);
    	provider.addEvent(event);
    	commandData.setEventProvider(provider);
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(PhoenixTestUtil.createMetaData(104, ACTIVATION_CODE, getContext()));
    	request.setCommandData(commandData);
    	request.setCommandListener(this);
		
		CommandServiceManager csm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
    	if(csm != null){
    		mCurrentCsid = csm.execute(request);
        	Log.v(TAG, String.format("> _testExecuteNewReqeust # CSM has accepted our request and give us CSID: %d", mCurrentCsid));
    	}else{
    		fail("> _testExecuteNewReqeust # Cannot initiate CSM");
    	}
	}
	
	/**
	 * To test this case, you have to add Dummy Exception
	 * in SessionManager at openOrCreateSessionDatabase() 
	 */
	private void _testHandleOpenSessionDbError(){
		Log.d(TAG, "_testHandleOpenSessionDbError");
		
		try{
			CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
			fail("Should have thrown RuntimeException");
		}catch(RuntimeException e){
			Log.e(TAG, String.format("> _testHandleOpenSessionDbError # %s", e.getMessage()));
		}
    	
    	mLock.open();
	}
	
	private void _testHandleIllegalInput(){
		Log.d(TAG, "_testHandleIllegalInput");
		
		// invalid argument at initialize time
		CommandServiceManager csm = null;
		try{
			csm = CommandServiceManager.getInstance(null, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		try{
			csm = CommandServiceManager.getInstance(STORE_PATH, null, UNSTRUCUTRED_URL, STRUCUTRED_URL);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		try{
			csm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, null, STRUCUTRED_URL);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		try{
			csm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, null);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		
		//invalid argument at execute
		csm = CommandServiceManager.getInstance(STORE_PATH, STORE_PATH, UNSTRUCUTRED_URL, STRUCUTRED_URL);
		try{
			csm.execute(null);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		CommandRequest request = new CommandRequest();
		request.setMetaData(null);
		try{
			csm.execute(request);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		
		request.setMetaData(PhoenixTestUtil.createMetaData(CONFIG_ID, ACTIVATION_CODE, getContext()));
		request.setCommandData(null);
		try{
			csm.execute(request);
			fail("Should have thrown IllegalArgumentException");
		}catch(IllegalArgumentException e){
			Log.e(TAG, String.format("> testHandleIllegalInput # %s", e.getMessage()));
		}
		
		mLock.open();
	}
	
	// ****************************************************** Phoenix Callback ****************************************************** //

	@Override
	public void onConstructError(long csid, Exception e) {
		Log.w(TAG, String.format("> onConstructError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
		if(TEST_EXECUTE_NEW_REQUEST){
			fail(String.format("> onConstructError # CSID: %d, - %s", csid, e.getMessage()));
		}
		
		mLock.open();
	}

	@Override
	public void onTransportError(long csid, Exception e) {
		Log.w(TAG, String.format("> onTransportError # CSID: %d, - %s - Thread ID: %d", csid, e.getMessage(), Thread.currentThread().getId()));
		if(TEST_EXECUTE_NEW_REQUEST){
			fail(String.format("> onTransportError # CSID: %d, - %s", csid, e.getMessage()));
		}
		
		mLock.open();
	}

	@Override
	public void onSuccess(ResponseData response) {
		Log.i(TAG, String.format("> onSuccess # CSID: %d, - %s - Thread ID: %d", response.getCsid(), response.getMessage(), Thread.currentThread().getId()));
		if(TEST_EXECUTE_NEW_REQUEST){
			Log.v(TAG, "> onSuccess # Check assertion");
			assertEquals(mCurrentCsid, response.getCsid());
		}
		
		mLock.open();
	}

	@Override
	public void onServerError(ResponseData response) {
		Log.w(TAG, String.format("> onServerError # CSID: %d, - %s - Thread ID: %d", response.getCsid(), response.getMessage(), Thread.currentThread().getId()));
		if(TEST_EXECUTE_NEW_REQUEST){
			fail(String.format("> onServerError # CSID: %d, - %s", response.getCsid(), response.getMessage()));
		}
		
		mLock.open();
	}

}
