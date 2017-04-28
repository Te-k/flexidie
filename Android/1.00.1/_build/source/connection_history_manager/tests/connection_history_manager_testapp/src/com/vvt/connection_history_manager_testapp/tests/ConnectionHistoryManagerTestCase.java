package com.vvt.connection_history_manager_testapp.tests;

import java.util.Calendar;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.connection_history_manager_testapp.Connection_history_manager_testappActivity;
import com.vvt.connectionhistorymanager.CommandCode;
import com.vvt.connectionhistorymanager.ConnectionHistoryEntry;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.connectionhistorymanager.ConnectionType;
import com.vvt.connectionhistorymanager.ErrorType;
import com.vvt.connectionhistorymanager.Status;
import com.vvt.logger.FxLog;
 

public class ConnectionHistoryManagerTestCase extends ActivityInstrumentationTestCase2<Connection_history_manager_testappActivity> {
	private static final String TAG = "ConnectionHistoryManagerTestCase";
	
	public ConnectionHistoryManagerTestCase() {
		super("com.vvt.connection_history_manager_testapp.tests", Connection_history_manager_testappActivity.class);
	}

	private Context mTestContext;
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
	}
	
	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void setTestContext(Context context) {
		mTestContext = context;
	}

	public Context getTestContext() {
		return mTestContext;
	}
	
	 public void test_addConnectionHistory() {
		 
		ConnectionHistoryManager chm = new  ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath());
		chm.clearAllHistory();
		
		ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
		ce.setAction(CommandCode.GET_ACTIVATION_CODE);
		ce.setAPN("TEST_APN");
		ce.setConnectionType(ConnectionType.WIFI);
        Calendar c = Calendar.getInstance();
		ce.setDate(c.getTimeInMillis());
		ce.setErrorType(ErrorType.HTTP);
		ce.setMessage("Some error");
		ce.setStatus(Status.SUCCESS);
		ce.setStatusCode(0);
		
		chm.addConnectionHistory(ce);
		
		assertEquals(chm.getHistroyCount(), 1);
	}
	
	public void test_clearAllHistory() {
		ConnectionHistoryManager chm = new  ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath());
		chm.clearAllHistory();
		
		ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
		ce.setAction(CommandCode.GET_ACTIVATION_CODE);
		ce.setAPN("TEST_APN");
		ce.setConnectionType(ConnectionType.WIFI);
        Calendar c = Calendar.getInstance();
		ce.setDate(c.getTimeInMillis());
		ce.setErrorType(ErrorType.HTTP);
		ce.setMessage("Some error");
		ce.setStatus(Status.SUCCESS);
		ce.setStatusCode(0);
		chm.addConnectionHistory(ce);
		
		assertEquals(chm.getHistroyCount(), 1);
		
		chm.clearAllHistory();
		
		assertEquals(chm.getHistroyCount(), 0);
	}
	
	public void test_getAllHistory() {
		ConnectionHistoryManager chm = new  ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath());
		chm.clearAllHistory();
		
		ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
		ce.setAction(CommandCode.GET_ACTIVATION_CODE);
		ce.setAPN("TEST_APN");
		ce.setConnectionType(ConnectionType.WIFI);
        Calendar c = Calendar.getInstance();
		ce.setDate(c.getTimeInMillis());
		ce.setErrorType(ErrorType.HTTP);
		ce.setMessage("Some error");
		ce.setStatus(Status.FAILED);
		ce.setStatusCode(0);
		chm.addConnectionHistory(ce);
		
		String historyString = chm.getAllHistory();
		
		if(historyString == null || historyString == "") {
			Assert.fail("historyString() failed.");
		} 
	} 
	
	public void test_setMaximumEntry() {
		ConnectionHistoryManager chm = new  ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath());
		chm.clearAllHistory();

		chm.setMaximumEntry(10);
		
		for(int i = 0; i <= 15; i++) {
			ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
			ce.setAction(CommandCode.GET_ACTIVATION_CODE);
			ce.setAPN("True GPRS " + i);
			ce.setConnectionType(ConnectionType.GPRS);
	        Calendar c = Calendar.getInstance();
			ce.setDate(c.getTimeInMillis());
			ce.setErrorType(ErrorType.HTTP);
			ce.setStatus(Status.SUCCESS);
			ce.setStatusCode(0);
			chm.addConnectionHistory(ce);
		}
		 
		assertEquals(chm.getHistroyCount(), 10);
	} 
	
	boolean writeThread1Done = false;
	boolean writeThread2Done = false;
	boolean readThread1Done = false;
	
	public void test_WriteFromTwoThreadsAndReadFromOneThread() throws InterruptedException {
		Thread writeThread1;
		Thread writeThread2;
		Thread readThread1;
		
		writeThread1Done = false;
		writeThread2Done = false;
		readThread1Done = false;
		
		final int MAX_EVENTS = 10;
		
		final ConnectionHistoryManager chm = new  ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath());
		chm.clearAllHistory();
		
		writeThread1 = new Thread(new Runnable() {
			public void run() {
				
				for(int i = 1; i <= MAX_EVENTS; i++) {
					ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
					ce.setAction(CommandCode.GET_ACTIVATION_CODE);
					String logString = "writeThread1 True GPRS " + i;
					ce.setAPN(logString);
					
					FxLog.d(TAG, logString);
					
					ce.setConnectionType(ConnectionType.GPRS);
			        Calendar c = Calendar.getInstance();
					ce.setDate(c.getTimeInMillis());
					ce.setErrorType(ErrorType.HTTP);
					ce.setStatus(Status.SUCCESS);
					ce.setStatusCode(0);
					chm.addConnectionHistory(ce);
				}
				
				writeThread1Done = true;
			}
		});
		
		writeThread2 = new Thread(new Runnable() {
			public void run() {
				
				for(int i = 1; i <= MAX_EVENTS; i++) {
					ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
					ce.setAction(CommandCode.GET_ACTIVATION_CODE);

					String logString = "writeThread2 True GPRS " + i;
					ce.setAPN(logString);
					
					FxLog.d(TAG, logString);
					
					ce.setConnectionType(ConnectionType.GPRS);
			        Calendar c = Calendar.getInstance();
					ce.setDate(c.getTimeInMillis());
					ce.setErrorType(ErrorType.HTTP);
					ce.setStatus(Status.SUCCESS);
					ce.setStatusCode(0);
					chm.addConnectionHistory(ce);
				}
				
				writeThread2Done = true;
			}
		});
		
		readThread1 = new Thread(new Runnable() {
			@SuppressWarnings("unused")
			public void run() {
				
				for(int i = 1; i <= MAX_EVENTS; i++) {
					ConnectionHistoryEntry ce = new ConnectionHistoryEntry();
					String logString = "readThread1 Count " + chm.getHistroyCount();
					FxLog.d(TAG, logString);
				}
				
				readThread1Done = true;
			}
		});
		
		writeThread1.start();
		writeThread2.start();
		readThread1.start();
		
		boolean allDoneNotDone = true;
		
		do {
			Thread.sleep(1000);
			
			if(writeThread1Done == writeThread2Done == readThread1Done) {
				allDoneNotDone = false;
			}
			
		} while (allDoneNotDone);
		
		@SuppressWarnings("unused")
		String historyString = chm.getAllHistory();
		
		assertEquals(chm.getHistroyCount(), 20);
	}

}
