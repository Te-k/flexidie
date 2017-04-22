package com.vvt.data_delivery_manager.tests;

import junit.framework.Assert;
import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.datadeliverymanager.store.RequestStore;
import com.vvt.exceptions.FxListenerNotFoundException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;

@SuppressWarnings("rawtypes")
public class RequestStoreTestCase extends  ActivityInstrumentationTestCase2 {
	 

	private static final String TAG = "RequestStoreTestCase";
	private Context mTestContext;
	
	@SuppressWarnings("unchecked")
	public RequestStoreTestCase() {
		super("com.vvt.data_delivery_manager.tests", Data_delivery_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
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

	 public void test_InsertAndDeleteRequestStore() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(100);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setDeliveryListener(deliveryListener);
		
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setMaxRetryCount(10);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		requestStore.insertRequest(deliveryRequest);
		requestStore.deleteRequest(100);
		
	} 
	
	 
	DeliveryListener deliveryListener = new DeliveryListener() {
		@Override
		public void onProgress(DeliveryResponse response) {
		}

		@Override
		public void onFinish(DeliveryResponse response) {
		}
	};
	 
	 public void test_InsertAndUpdateRequestStore() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(100);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setDeliveryListener(deliveryListener);
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setMaxRetryCount(10);
		deliveryRequest.setDelayTime(100);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		requestStore.insertRequest(deliveryRequest);

		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_PERSISTED);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setMaxRetryCount(9);
		deliveryRequest.setDelayTime(9);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		deliveryRequest.setRetryCount(9);
		requestStore.updateRequest(deliveryRequest);
				
		DeliveryRequest r = requestStore.getProperRequest();
		
		// Verify with the update ..
		Assert.assertEquals(deliveryRequest.getDeliveryRequestType(), r.getDeliveryRequestType()); 
		Assert.assertEquals(deliveryRequest.isReadyToResume(), r.isReadyToResume());
		Assert.assertEquals(deliveryRequest.getDelayTime(), r.getDelayTime());
		Assert.assertEquals(deliveryRequest.getMaxRetryCount(), r.getMaxRetryCount());
		Assert.assertEquals(deliveryRequest.getRequestPriority(), r.getRequestPriority());
		Assert.assertEquals(deliveryRequest.getRetryCount(), r.getRetryCount());
		
		requestStore.deleteRequest(deliveryRequest.getCsId());
		FxLog.d(TAG, r.toString());	
		
	}
	
	 public void test_updateCanRetry() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
	
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		deliveryRequest.setDelayTime(10);
		deliveryRequest.setDeliveryListener(deliveryListener);
		
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setMaxRetryCount(10);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		requestStore.insertRequest(deliveryRequest);
		
		DeliveryRequest r = requestStore.getProperRequest();
		FxLog.d(TAG, r.toString());
		
		r.setCSID(100);
		boolean isUpdateSuccess = requestStore.updateRequest(r);

		boolean isUpdateReadySuccess = requestStore.updateCanRetryWithCsid(r.getCsId());
		
		assertTrue(isUpdateSuccess && isUpdateReadySuccess);
		
		r = requestStore.getProperRequest();
		FxLog.d(TAG, 	r.toString());
		
		Assert.assertEquals(true, r.isReadyToResume());
		
		requestStore.deleteRequest(r.getCsId());
		
	} 
	
	 public void test_initalStore() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(100);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		deliveryRequest.setDelayTime(10);
		deliveryRequest.setDeliveryListener(deliveryListener);
		
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setMaxRetryCount(0);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		requestStore.insertRequest(deliveryRequest);
		DeliveryRequest r = requestStore.getProperRequest();
		
		requestStore.initializeStore();
		
		// Should return null
		r = requestStore.getProperRequest();
		
		if( r != null)
			Assert.fail("initialStore did not clear MaxRetryCount == 0 entries");
				
		deliveryRequest.setMaxRetryCount(5);
		requestStore.insertRequest(deliveryRequest);
		r = requestStore.getProperRequest();
		
		requestStore.initializeStore();
		
		r = requestStore.getProperRequest();
		if(!r.isReadyToResume()) {
			Assert.fail("initialStore did not set isReadyToResume to true");
		}
		
		
	} 
	
	
	public void test_isRequestPending() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(100);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		deliveryRequest.setDelayTime(10);
		deliveryRequest.setDeliveryListener(deliveryListener);
		
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setMaxRetryCount(0);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		requestStore.insertRequest(deliveryRequest);
		
		DeliveryRequest r = requestStore.getProperRequest();
		
		boolean hasPendingRequest = requestStore.isRequestPending(r.getCallerID());
		assertEquals(true, hasPendingRequest);
		
	}
	
	 public void test_deleteRequest() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(999);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(999);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(999);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_PANIC);
		deliveryRequest.setDelayTime(10);
		deliveryRequest.setDeliveryListener(deliveryListener);
		
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setMaxRetryCount(10);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
				
		requestStore.insertRequest(deliveryRequest);
		//should can not delete. because it is not in the persist store.
		requestStore.deleteRequest(999);
		
		DeliveryRequest r = requestStore.getProperRequest();
		if(r.getCallerID() != 999) {
			Assert.fail("Can't get request in Queue.");
		}
		
		requestStore.deleteRequest(r.getCsId());
		
		r = requestStore.getProperRequest();
		if(r != null) {
			Assert.fail("Can not delete from persist store");
		}
		
		
	}
	
	 public void test_getProperRequest() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		/*=============================== normal case =======================================*/
		DeliveryRequest panicRequest = new DeliveryRequest();
		panicRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		panicRequest.setCommandData(commandData);
		panicRequest.setCSID(100);
		panicRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_PANIC);
		panicRequest.setIsReadyToResume(false);
		panicRequest.setDeliveryListener(deliveryListener);
		
		panicRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		panicRequest.setMaxRetryCount(10);
		panicRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		panicRequest.setRetryCount(0);
		panicRequest.setIsRequireCompression(true);
		panicRequest.setIsRequireEncryption(true);
				
		requestStore.insertRequest(panicRequest);
		DeliveryRequest r = requestStore.getProperRequest();
		
		
		if(r.getCommandData().getCmd() != 100) {
			Assert.fail("Can't get request in Queue.");
		}
		
		requestStore.deleteRequest(r.getCsId());
		/*============================= End normal case ====================================*/
		
		/*=================== 3 new request with the same priority =========================*/
		requestStore.clearStore();
		
		//insert to Queue with CallerID = 1 and Cmd = 100.
		requestStore.insertRequest(panicRequest);
		
		//insert to Queue with CallerID = 2 and Cmd = 200.
		DeliveryRequest systemRequest = new DeliveryRequest();
		systemRequest.setCallerID(2);
		
		commandData = new MockCommandData();
		commandData.setCmd(200);
		
		systemRequest.setCommandData(commandData);
		systemRequest.setCSID(200);
		systemRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_SYSTEM);
		systemRequest.setIsReadyToResume(false);
		systemRequest.setDeliveryListener(deliveryListener);
		
		systemRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		systemRequest.setMaxRetryCount(10);
		systemRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		systemRequest.setRetryCount(0);
			requestStore.insertRequest(systemRequest);
		
		// insert to Queue with CallerID = 3 and Cmd = 300.
		DeliveryRequest settingRequest = new DeliveryRequest();
		settingRequest.setCallerID(3);
		
		commandData = new MockCommandData();
		commandData.setCmd(300);
		
		settingRequest.setCommandData(commandData);
		settingRequest.setCSID(300);
		settingRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_SETTINGS);
		settingRequest.setIsReadyToResume(false);
		settingRequest.setDeliveryListener(deliveryListener);
		
		settingRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		settingRequest.setMaxRetryCount(10);
		settingRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		settingRequest.setRetryCount(0);
		settingRequest.setIsRequireCompression(true);
		settingRequest.setIsRequireEncryption(true);
		
		requestStore.insertRequest(settingRequest);
		
		r = requestStore.getProperRequest();
		
		if(r.getCommandData().getCmd() != 100) {
			Assert.fail("Can't get FIRST request in Queue.");
		}
		
		requestStore.deleteRequest(r.getCsId());
		
		/*================= End 3 new request with the same priority =======================*/

		/*========= 2 new requests and 3 persisted requests,2 of them is ready to resume.=========*/
		requestStore.clearStore();
		
		// insert to persist store with CallerID = 1 and Cmd = 100.
		requestStore.insertRequest(panicRequest);
		r = requestStore.getProperRequest();
		requestStore.updateCanRetryWithCsid(r.getCsId());
		
		// insert to persist store with CallerID = 2 and Cmd = 200.
		requestStore.insertRequest(systemRequest);
		r = requestStore.getProperRequest();
		requestStore.updateCanRetryWithCsid(r.getCsId());
		
		// insert to persist store with CallerID = 3 and Cmd = 300.
		requestStore.insertRequest(settingRequest);
		r = requestStore.getProperRequest();
		
		// insert to Queue with CallerID = 4 and Cmd = 400.
		DeliveryRequest queueRequest_1 = new DeliveryRequest();
		queueRequest_1.setCallerID(4);

		commandData = new MockCommandData();
		commandData.setCmd(400);

		queueRequest_1.setCommandData(commandData);
		queueRequest_1.setCSID(400);
		queueRequest_1.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_PANIC);
		queueRequest_1.setIsReadyToResume(false);
		queueRequest_1.setDeliveryListener(deliveryListener);
		queueRequest_1.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		queueRequest_1.setMaxRetryCount(10);
		queueRequest_1.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		queueRequest_1.setRetryCount(0);
		queueRequest_1.setIsRequireCompression(true);
		queueRequest_1.setIsRequireEncryption(true);
		
		requestStore.insertRequest(queueRequest_1);
		
		// insert to Queue with CallerID = 5 and Cmd = 500.
		DeliveryRequest queueRequest_2 = new DeliveryRequest();
		queueRequest_2.setCallerID(5);

		commandData = new MockCommandData();
		commandData.setCmd(500);

		queueRequest_2.setCommandData(commandData);
		queueRequest_2.setCSID(500);
		queueRequest_2.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_SETTINGS);
		queueRequest_2.setIsReadyToResume(false);
		queueRequest_2.setDeliveryListener(deliveryListener);
		queueRequest_2.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		queueRequest_2.setMaxRetryCount(10);
		queueRequest_2.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		queueRequest_2.setRetryCount(0);
		queueRequest_2.setIsRequireCompression(true);
		queueRequest_2.setIsRequireEncryption(true);
		
		requestStore.insertRequest(queueRequest_2);
	
		r = requestStore.getProperRequest();
		
		FxLog.d(TAG, "r.getCommandData().getCmd() :" +r.getCommandData().getCmd() );
		if(r.getCommandData().getCmd() != 100) {
			Assert.fail("Can't get FIRST request in Queue.");
		}
		
		/*=======End 2 new requests and 3 persisted requests,2 of them is ready to resume.=========*/
		
		
		
	} 
	 
	public void test_resumeImediately() throws FxNullNotAllowedException, FxListenerNotFoundException  {
		RequestStore requestStore = RequestStore.getInstance(mTestContext);
		requestStore.clearStore();
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		
		MockCommandData commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(100);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_PANIC);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setDeliveryListener(deliveryListener);
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setMaxRetryCount(10);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		//add to queue.
		requestStore.insertRequest(deliveryRequest);
		//add to persist store
		DeliveryRequest r = requestStore.getProperRequest();
		
		//create new request.
		deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(2);
		
		//create same command code.
		commandData = new MockCommandData();
		commandData.setCmd(100);
		
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setCSID(200);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_SYSTEM);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setDeliveryListener(deliveryListener);
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setMaxRetryCount(10);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		
		
		//add to queue.
		requestStore.insertRequest(deliveryRequest);
		
		//should got request in persist 
		//because the logic should change status to ready to resume imediately.
		DeliveryRequest r2 = requestStore.getProperRequest();
		Assert.assertEquals(r.getCommandData().getCmd(), r2.getCommandData().getCmd());
		
	 }
	
}

class MockCommandData implements CommandData {

	private int m_CmdId;

	public void setCmd(int cmd_id) {
		m_CmdId = cmd_id;
	}

	@Override
	public int getCmd() {
		return m_CmdId;
	}
}