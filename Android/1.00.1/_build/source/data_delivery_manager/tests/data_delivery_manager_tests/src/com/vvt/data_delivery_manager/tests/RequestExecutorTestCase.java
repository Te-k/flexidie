package com.vvt.data_delivery_manager.tests;

import java.util.List;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.configurationmanager.ConfigurationManagerMock;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.exceptions.FxListenerNotFoundException;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

public class RequestExecutorTestCase 
		extends ActivityInstrumentationTestCase2<Data_delivery_manager_testsActivity> 
		implements DeliveryListener,PccRmtCmdListener, ServerStatusErrorListener {
	
	private static final String TAG = "RequestExecutorTestCase";
	private Context mTestContext;
	private ServerAddressManager mMockServerAddressManager;
	private DataDeliveryManager mDataDeliveryManager;
	private boolean mIsFinish;
	
	public RequestExecutorTestCase() {
		super("com.vvt.data_delivery_manager.tests", Data_delivery_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		
		mMockServerAddressManager = new ServerAddressManagerImpl(new AppContextImpl(mTestContext));
		mMockServerAddressManager.setServerUrl("http://58.137.119.229/RainbowCore");
		AppContext appContext = new AppContextImpl(mTestContext);
			
		mDataDeliveryManager = new DataDeliveryManager();
		mDataDeliveryManager.setAppContext(appContext);
		mDataDeliveryManager.setCommandServiceManager(createCommandServiceManager());
		mDataDeliveryManager.setConnectionHistory(new ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath()) {});
		mDataDeliveryManager.setLicenseManager(new MockLicenseManager());
		mDataDeliveryManager.setPccRmtCmdListener(this);
		mDataDeliveryManager.setServerAddressManager(mMockServerAddressManager);
		mDataDeliveryManager.setServerStatusErrorListener(this);
		mDataDeliveryManager.setConfigurationManager(new ConfigurationManagerMock());
		
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
	
	
	public void test_activation() {
		
		DeliveryRequest deliveryRequest = createDeliveryRequest();

		mDataDeliveryManager.forTest_clearDB();
		mDataDeliveryManager.deliver(deliveryRequest);

		mIsFinish = true;
		
		FxLog.d(TAG,"sleep wait response from CSM");
		while(mIsFinish) {
			
		} 
		
	}
	
	public void test_onSuccessFromCSM () {
		DeliveryRequest deliveryRequest = createDeliveryRequest();

		/**
		 * 1 : OnSuccess
		 * 2 : onConstructError
		 * 3 : onServerError
		 * 4 : onTransportError
		 */
		
		try {
			mDataDeliveryManager.forTest_clearDB();
			assertTrue(mDataDeliveryManager.forTest_reponseHandle(deliveryRequest, 1));
		
		} catch (FxListenerNotFoundException e) {
			FxLog.e(TAG, e.toString());
		}
	} 
	
	public void test_onConstructErrorFromCSM () {
		DeliveryRequest deliveryRequest = createDeliveryRequest();

		/**
		 * 1 : OnSuccess
		 * 2 : onConstructError
		 * 3 : onServerError
		 * 4 : onTransportError
		 */
		
		try {
			mDataDeliveryManager.forTest_clearDB();
			assertTrue(mDataDeliveryManager.forTest_reponseHandle(deliveryRequest, 2));
		
		} catch (FxListenerNotFoundException e) {
			FxLog.e(TAG, e.toString());
		}
	}
	
	public void test_onServerErrorFromCSM () {
		DeliveryRequest deliveryRequest = createDeliveryRequest();
		

		boolean result = false;
		
		/**
		 * 1 : OnSuccess
		 * 2 : onConstructError
		 * 3 : onServerError
		 * 4 : onTransportError
		 */

		try {
			deliveryRequest.setMaxRetryCount(0);
			
			mDataDeliveryManager.forTest_clearDB();
			result = mDataDeliveryManager.forTest_reponseHandle(deliveryRequest, 3);
			
			deliveryRequest.setMaxRetryCount(3);
			
			mDataDeliveryManager.forTest_clearDB();
			result = result && mDataDeliveryManager.forTest_reponseHandle(deliveryRequest, 3);
		
		} catch (FxListenerNotFoundException e) {
			FxLog.e(TAG, e.toString());
		}

		assertTrue(result);
		
	}
	
	
	public void test_onTransportErrorFromCSM () {
		DeliveryRequest deliveryRequest = createDeliveryRequest();
		

		boolean result = false;
		
		/**
		 * 1 : OnSuccess
		 * 2 : onConstructError
		 * 3 : onServerError
		 * 4 : onTransportError
		 */

		try {
			
			// Cannot set max retry to 0 since we can't create mock csid. 
			deliveryRequest.setMaxRetryCount(3);
			
			mDataDeliveryManager.forTest_clearDB();
			result = mDataDeliveryManager.forTest_reponseHandle(deliveryRequest, 4);
		
		} catch (FxListenerNotFoundException e) {
			FxLog.e(TAG, e.toString());
		}

		assertTrue(result);
		
	}
	
	
	
	public void test_TimmerResume() {
		boolean result = false;
		DeliveryRequest deliveryRequest = createDeliveryRequest();

		/**
		 * 1 : OnSuccess
		 * 2 : onConstructError
		 * 3 : onServerError
		 * 4 : onTransportError
		 */

		try {
			deliveryRequest.setMaxRetryCount(2);
			deliveryRequest.setDelayTime(10000);
			
			mDataDeliveryManager.forTest_clearDB();
			result = mDataDeliveryManager.forTest_reponseHandle(deliveryRequest, 5);
			
		} catch (FxListenerNotFoundException e) {
			FxLog.e(TAG, e.toString());
		}
		
		while(!result){
			
		}

		assertTrue(result);
		
	}
	
	/****************************************** prepare method ***********************************************/
	
	private CommandServiceManager createCommandServiceManager() {
		String dbPath = "/sdcard/";
		String payloadPath = "/sdcard/";
		
		CommandServiceManager manager = CommandServiceManager.getInstance(dbPath, payloadPath);  
		manager.setStructuredUrl("http://58.137.119.229/RainbowCore/gateway");
		manager.setUnStructuredUrl("http://58.137.119.229/RainbowCore/gateway/unstructured");
		return manager;
	}
	
	private DeliveryRequest createDeliveryRequest() {
		CommandData commandData = createCommandData();
		
		
		DeliveryRequest deliveryRequest = new DeliveryRequest();
		deliveryRequest.setCallerID(1);
		deliveryRequest.setCommandData(commandData);
		deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_PANIC);
		deliveryRequest.setDelayTime(300000);
		deliveryRequest.setDeliveryListener(this);
		deliveryRequest.setIsReadyToResume(false);
		deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		deliveryRequest.setMaxRetryCount(5);
		deliveryRequest.setRetryCount(0);
		deliveryRequest.setRequestPriority(PriorityRequest.PRIORITY_HIGH);
		deliveryRequest.setIsRequireCompression(true);
		deliveryRequest.setIsRequireEncryption(true);
		return deliveryRequest;
		
	}
	
	@Override
	public void onServerStatusErrorListener(ServerStatusType serverStatusType) {
		FxLog.d(TAG, "onServerStatusErrorListener");
		
	}
	
	@Override
	public void onReceivePCC(List<PCC> pcc) {
		FxLog.d(TAG, "serve");
		
	}
	
	@Override
	public void onFinish(DeliveryResponse response) {
		FxLog.d(TAG, "onFinish");
		mIsFinish = false;

	}

	@Override
	public void onProgress(DeliveryResponse response) {
		FxLog.d(TAG, "onProgress");
		mIsFinish = false;

	}

	/**
	 * Set specific metadata e.g. device ID, product Version
	 * @param activationCode
	 * @return
	 */
//	private CommandMetaData createMetaDataForActivation(String activationCode){
//		int productId = 4202; 
//		int configId = 0;	
//		String deviceId = "355031040328607";		//Nexus S
//		String phoneNumber = "";
//		String mcc = "54";
//		String mnc = "55";
//		String imsi = "444";
//		String productVersion = "-1.00.23";
//		
//		CommandMetaData metaData = new CommandMetaData();
//		metaData.setProtocolVersion(1);
//		metaData.setProductId(productId);
//		metaData.setProductVersion(productVersion);
//		metaData.setConfId(configId);
//		metaData.setDeviceId(deviceId);
//		metaData.setActivationCode(activationCode);
//		metaData.setLanguage(Languages.ENGLISH);
//		metaData.setPhoneNumber(phoneNumber);
//		metaData.setMcc(mcc);
//		metaData.setMnc(mnc);
//		metaData.setImsi(imsi);	
//		metaData.setHostUrl("");
//		/*metaData.setEncryptionCode(0);
//		metaData.setCompressionCode(0);*/
//		metaData.setEncryptionCode(1);
//		metaData.setCompressionCode(1);
//		
//		return metaData;
//	}
	
	/**
	 * Setup specific information e.g. device info, device model.
	 * @return
	 */
	private CommandData createCommandData(){
		SendActivate command = new SendActivate();
		command.setDeviceInfo("DeviceInfo");
		command.setDeviceModel("Nexus S");
		return command;
	}

	
}
