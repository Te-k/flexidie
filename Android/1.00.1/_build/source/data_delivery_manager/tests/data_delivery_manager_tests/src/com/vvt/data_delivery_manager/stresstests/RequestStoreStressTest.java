package com.vvt.data_delivery_manager.stresstests;

import android.content.Context;
import android.os.SystemClock;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.data_delivery_manager.tests.Data_delivery_manager_testsActivity;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.store.RequestStore;
import com.vvt.exceptions.FxListenerNotFoundException;
import com.vvt.logger.FxLog;

@SuppressWarnings("unused")
public class RequestStoreStressTest 
		extends ActivityInstrumentationTestCase2<Data_delivery_manager_testsActivity> 
		implements StressTestListener{
			
	private static final String TAG = "RequestStoreTestInsert";
	private Context mTestContext;
	
	private boolean mIsInsertFinish = false;
	private boolean mIsDeleteFinish = false;
	private boolean mIsUpdateFinish = false;
	
	public RequestStoreStressTest() {
		super("com.vvt.data_delivery_manager.tests", Data_delivery_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();

		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
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
	
//	 public void test_stressTest() {
//		 RSInsertThread insertThread = new RSInsertThread(this);
//		 insertThread.start();
//		 
//
//		 while(!(mIsInsertFinish && mIsDeleteFinish && mIsUpdateFinish)) {
//			 // wait for test
//		 }
//		 
//		 RequestStore requestStore = RequestStore.getInstance();
//		 try {
//			DeliveryRequest r = requestStore.getProperRequest();
//			if(r == null) {
//				Log.d(TAG,"Stress test Success!");
//				assertTrue(true);
//			}else {
//				Log.d(TAG,"Stress test Fail!");
//				assertTrue(false);
//			}
//		} catch (FxListenerNotFoundException e) {}
//		 
//	 }
	 
	 public void test_stressTest_updateAndDelete() {
		
		 RequestStore requestStore = RequestStore.getInstance(mTestContext);
		 
		 mIsInsertFinish = false;
		 RSInsertThread insertThread = new RSInsertThread(mTestContext,this);
		 insertThread.start();
		 
		//wait until finish inserting
		 while(!mIsInsertFinish) {
			 SystemClock.sleep(500);
		 }
		 
		 int count = 0;
		 boolean result = true;
		 
		 try {
				DeliveryRequest r = requestStore.getProperRequest();
				while(r != null) {
					r.setDelayTime(20);
					if(requestStore.updateRequest(r)) {
						requestStore.deleteRequest(r.getCsId());
						count++;
						FxLog.v(TAG,String.format("UpdateAndDelete CallerID = %s, Count : %s", r.getCallerID(),count));
					}
					r = requestStore.getProperRequest();
				}
			} catch (FxListenerNotFoundException e) {
				FxLog.v(TAG, "FxListenerNotFoundException ");
				e.printStackTrace();
			} catch (Exception ex) {
				FxLog.v(TAG, "Exception :" +ex.getMessage());
				result = false;
			}
		
		 DeliveryRequest r;
		try {
			r = requestStore.getProperRequest();
			if(r != null) {
				 result = false;
			 }
		} catch (FxListenerNotFoundException e) {}
		 
		 assertTrue(result);
	 }

	@Override
	public void onInsertFinish(int numberOfInsert) {
		FxLog.d(TAG,"Number of insert = " + numberOfInsert);
		mIsInsertFinish = true;
		
	}
	
}
