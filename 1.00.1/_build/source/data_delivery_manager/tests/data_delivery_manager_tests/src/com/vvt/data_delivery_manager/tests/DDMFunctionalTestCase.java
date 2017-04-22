package com.vvt.data_delivery_manager.tests;

import java.util.List;
import java.util.Random;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.configurationmanager.ConfigurationManagerMock;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.data_delivery_manager.testsfunctional.ActivationCase;
import com.vvt.data_delivery_manager.testsfunctional.AddressBookCase;
import com.vvt.data_delivery_manager.testsfunctional.FuntionalTestListener;
import com.vvt.data_delivery_manager.testsfunctional.NormalTypeCase;
import com.vvt.data_delivery_manager.testsfunctional.PanicStatusCase;
import com.vvt.data_delivery_manager.testsfunctional.TestType;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

@SuppressWarnings("unused")
public class DDMFunctionalTestCase extends ActivityInstrumentationTestCase2<Data_delivery_manager_testsActivity> implements PccRmtCmdListener, ServerStatusErrorListener,FuntionalTestListener {

	private static final String TAG = "DDMFunctionalTestCase";
	private Context mTestContext;
	private DataDeliveryManager mDataDeliveryManager;
	private ServerAddressManager mMockServerAddressManager;
	private String mTestType;
	
	private int mDuplicateLicenseCount = 0;
	private int mSimpleActivationCount = 0;
	private int mLicenseNotFoundCount = 0;
	private int mLicenseDisableCount = 0;
	private int mLicenseExpiredCount = 0;
	private int mRepeatActivateCount = 0;
	private int mDeactivationCount = 0;
	private int mHeartbeatCount = 0;
	private int mPanicStatusCount = 0;
	private int mAddressBookSendCount = 0;
	private int mAddressBookGetCount = 0;
	private int mGetTimeCaseCount = 0;
	private int mThumbnailCaseCount = 0;
	private int mActualCaseCount = 0;
	
	private int mDuplicateLicense_Count = 0;
	private int mSimpleActivation_Count = 0;
	private int mLicenseNotFound_Count = 0;
	private int mLicenseDisable_Count = 0;
	private int mLicenseExpired_Count = 0;
	private int mRepeatActivate_Count = 0;
	private int mDeactivation_Count = 0;
	private int mHeartbeat_Count = 0;
	private int mPanicStatus_Count = 0;
	private int mAddressBookSend_Count = 0;
	private int mAddressBookGet_Count = 0;
	private int mGetTimeCase_Count = 0;
	private int mThumbnailCase_Count = 0;
	private int mActualCase_Count = 0;
	
	private int mStressTestNumber = 100;
	
	
	
	public DDMFunctionalTestCase() {
		super("com.vvt.data_delivery_manager.tests", Data_delivery_manager_testsActivity.class);
	}
	
	@Override
	protected void setUp() throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		
		try {
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
			mDataDeliveryManager.initialize();
		} catch (FxNullNotAllowedException e) {}
		
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
	
	private CommandServiceManager createCommandServiceManager() {
		String dbPath = "/sdcard/";
		String payloadPath = "/sdcard/";
		
		CommandServiceManager manager = CommandServiceManager.getInstance(dbPath, payloadPath);  
		manager.setStructuredUrl("http://58.137.119.229/RainbowCore/gateway");
		manager.setUnStructuredUrl("http://58.137.119.229/RainbowCore/gateway/unstructured");
		return manager;
	}
	
	/***************************************** BEGIN TEST Activation *********************************************/
	
//	public void test_simpleActivation () {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "TestNormalCase";
//		mSimpleActivationCount++;
//		mSimpleActivation_Count++;
//		ActivationCase activationCase = new ActivationCase(mDataDeliveryManager,this);
//		activationCase.testNormalCase();
//		while(mSimpleActivationCount > 0){}
//		
//	}
	
//	public void test_LicenseNotFound() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testLicenseNotFound";
//		
//		/**
//		 * set Number of test
//		 */
//		int round = 5000;
//		
//		ActivationCase activationCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mLicenseNotFoundCount++;
//			mLicenseNotFound_Count++;
//			activationCase = new ActivationCase(mDataDeliveryManager,this);
//			activationCase.testLicenseNotFound();
//			while(mLicenseNotFoundCount-1 >= 0){}
//		}
//	}
//	
//	public void test_LicenseDisable() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testLicenseDisable";
//		
//		/**
//		 * set Number of test
//		 */
//		int round = 5000;
//		
//		ActivationCase activationCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mLicenseDisableCount++;
//			mLicenseDisable_Count++;
//			activationCase = new ActivationCase(mDataDeliveryManager,this);
//			activationCase.testLicenseDisable();
//			
//			while(mLicenseDisableCount-1 >= 0){}
//		}
//	}
//	
//	public void test_LicenseExpired() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testLicenseExpired";
//		
//		/**
//		 * set Number of test
//		 */
//		int round = 5000;
//		
//		ActivationCase activationCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mLicenseExpiredCount++;
//			mLicenseExpired_Count++;
//			activationCase = new ActivationCase(mDataDeliveryManager,this);
//			activationCase.testLicenseExpiredCase();
//			while(mLicenseExpiredCount-1 >= 0){}
//		}
//	}
//	
////	public void test_RepeatActivate() {
////		mDataDeliveryManager.forTest_clearDB();
////		mTestType = "testRepeatActivate";
////		
////		/**
////		 * set Number of test
////		 */
////		int round = 5000;
////		
////		ActivationCase activationCase = null;
////		for(int i = 0 ; i<round ; i++) {
////			mRepeatActivateCount++;
////			mRepeatActivate_Count++;
////			activationCase = new ActivationCase(mDataDeliveryManager,this);
////			activationCase.testRepeatActivate();
////			while(mRepeatActivateCount-1 >= 0){}
////		}
////	}
//	
//	public void test_DuplicateLicense() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testDuplicateLicense";
//		
//		/**
//		 * set Number of test
//		 */
//		int round = 5000;
//		
//		ActivationCase activationCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mDuplicateLicenseCount++;
//			mDuplicateLicense_Count++;
//			activationCase = new ActivationCase(mDataDeliveryManager,this);
//			activationCase.testDuplicateLicense();
//			
//			while(mDuplicateLicenseCount-1 >= 0){}
//		}
//	}
//
//	/****************************************** END TEST Activation **********************************************/
//	
//	/*************************************** BIGIN TEST deactivation *********************************************/
////	public void test_deactivation() {
////		mDataDeliveryManager.forTest_clearDB();
////		mTestType = "testDeactivation";
////		mDeactivationCount++;
////		mDeactivation_Count++;
////		NormalTypeCase normalTypeCase = new NormalTypeCase(mDataDeliveryManager, this);
////		normalTypeCase.testDeactivationCase();
////		
////		while (mDeactivationCount > 0) {}
////	}
//	
//	/**************************************** END TEST deactivation *********************************************/
//	
//	/*************************************** BIGIN TEST HEARTBEAT *********************************************/
//	public void test_Heartbeat() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testHeartbeat";
//		
//		int round = 5000;
//		
//		NormalTypeCase normalTypeCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mHeartbeatCount++;
//			mHeartbeat_Count++;
//			normalTypeCase = new NormalTypeCase(mDataDeliveryManager, this);
//			normalTypeCase.testHeartbeatCase();
//			while(mHeartbeatCount-1 >= 0){}
//		}
//	}
//	
//	/**************************************** END TEST HEARTBEAT *********************************************/
//
//	/*********************************** BIGIN TEST PanicStatusEvent *****************************************/
//	public void testa_PanicStatusEvent() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testPanicStatusEvent";
//		
//		int round = 10000;
//		
//		PanicStatusCase panicStatusCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mPanicStatusCount++;
//			mPanicStatus_Count++;
//			panicStatusCase = new PanicStatusCase(mDataDeliveryManager, this);
////			if(i%2 == 0) {
//				panicStatusCase.testSuccessCase();
////			} else {
////				panicStatusCase.testFailCase();
////			}
//				
//			while(mPanicStatusCount-1 >= 0){}
//		}
//	}
//
//	/*********************************** END TEST PanicStatusEvent *****************************************/
//	
//	/*********************************** BIGIN TEST AddressBookEvent *****************************************/
//	public void test_sendAddressBookEvent() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testSendAddressBookEvent";
//		
//		int round = 5000;
//		
//		AddressBookCase addressBookCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mAddressBookSendCount++;
//			mAddressBookSend_Count++;
//			addressBookCase = new AddressBookCase(mDataDeliveryManager, this);
//			addressBookCase.testSendAddrBookCase();
//			
//			while (mAddressBookSendCount-1 >= 0) {}
//		}
//		
//		
//	}
//	
//	public void test_getAddressBookEvent() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testGetAddressBookEvent";
//		
//		int round = 5000;
//		
//		AddressBookCase addressBookCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mAddressBookGetCount++;
//			mAddressBookGet_Count++;
//			addressBookCase = new AddressBookCase(mDataDeliveryManager, this);
//			addressBookCase.testGetAddrBookCase();
//			
//			while (mAddressBookGetCount-1 >= 0) {}
//		}
//	}
//
//	/*********************************** END TEST AddressBookEvent *****************************************/
//	
//	/*********************************** BIGIN TEST GetTimeEvent *****************************************/
	
//	public void test_thumbmailEvent() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "test_thumbmailEvent";
//
//		int round = 1;
//
//		ActualMediaCase actualMediaCase = null;
//		for (int i = 0; i < mStressTestNumber; i++) {
//			mThumbnailCaseCount++;
//			mThumbnailCase_Count++;
//			actualMediaCase = new ActualMediaCase(mDataDeliveryManager, this);
//			actualMediaCase.testDeliverThumbnail();
//
//			while (mThumbnailCaseCount - 1 >= 0) {
//			}
//			SystemClock.sleep(10000);
//		}
//	}
	
//	public void test_GetTimeEvent() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "testGetTimeEvent";
//		
//		int round = 5000;
//		
//		NormalTypeCase normalTypeCase = null;
//		for(int i = 0 ; i<mStressTestNumber ; i++) {
//			mGetTimeCaseCount++;
//			mGetTimeCase_Count++;
//			normalTypeCase = new NormalTypeCase(mDataDeliveryManager, this);
//			normalTypeCase.testGetTimeCase();
//			
//			while (mGetTimeCaseCount-1 >= 0) {}
//			
//			SystemClock.sleep(10000);
//		}
//	}
	
//	public void test_actualMediaEvent() {
//		mDataDeliveryManager.forTest_clearDB();
//		mTestType = "test_thumbmailEvent";
//
//		ActualMediaCase actualMediaCase = null;
//		for (int i = 0; i < mStressTestNumber; i++) {
//			mActualCaseCount++;
//			mActualCase_Count++;
//			actualMediaCase = new ActualMediaCase(mDataDeliveryManager, this);
//			actualMediaCase.testDeliverActualMedia();
//
//			while (mActualCaseCount - 1 >= 0) {
//			}
//			
//			SystemClock.sleep(10000);
//		}
//	}

	
	public void test_all() {
		mDataDeliveryManager.forTest_clearDB();
		ActivationCase activationCase = new ActivationCase(mDataDeliveryManager,this);
		NormalTypeCase normalTypeCase = new NormalTypeCase(mDataDeliveryManager, this);
		AddressBookCase addressBookCase = new AddressBookCase(mDataDeliveryManager, this);
		PanicStatusCase panicStatusCase = new PanicStatusCase(mDataDeliveryManager, this);
		int rand =0;
		Random r = new Random();
		for(int i = 0 ; i<mStressTestNumber ; i++) {
			System.gc();
			rand = r.nextInt(10);
			switch(rand) {
				case 0 : 
					mLicenseNotFoundCount++;
					mLicenseNotFound_Count++;
			 
					activationCase.testLicenseNotFound();
					while(mLicenseNotFoundCount-1 >= 0){}
					break;
				case 1 :
					mLicenseDisableCount++;
					mLicenseDisable_Count++;
					
					activationCase.testLicenseDisable();
					while(mLicenseDisableCount-1 >= 0){}
					break;
				case 2 :
					mLicenseExpiredCount++;
					mLicenseExpired_Count++;
					
					activationCase.testLicenseExpiredCase();
					while(mLicenseExpiredCount-1 >= 0){}
					break;
				case 3 : 
					mDuplicateLicenseCount++;
					mDuplicateLicense_Count++;
					
					activationCase.testDuplicateLicense();
					while(mDuplicateLicenseCount-1 >= 0){}
					break;
				case 4 :
					mHeartbeatCount++;
					mHeartbeat_Count++;
					
					normalTypeCase.testHeartbeatCase();
					while(mHeartbeatCount-1 >= 0){}
					break;
				case 5 :
					mGetTimeCaseCount++;
					mGetTimeCase_Count++;
					
					normalTypeCase.testGetTimeCase();
					while (mGetTimeCaseCount-1 >= 0) {}
					break;
				case 6 :
					mAddressBookSendCount++;
					mAddressBookSend_Count++;
					
					addressBookCase.testSendAddrBookCase();
					while (mAddressBookSendCount-1 >= 0) {}
					break;
				case 7 : 
					mAddressBookGetCount++;
					mAddressBookGet_Count++;
					
					addressBookCase.testGetAddrBookCase();
					while (mAddressBookGetCount-1 >= 0) {}
					break;
				case 8 :
				case 9 : 
				default :
					mPanicStatusCount++;
					mPanicStatus_Count++;
									
					panicStatusCase.testSuccessCase();
					while(mPanicStatusCount-1 >= 0){}
					break;
					
			}
			
			try {Thread.sleep(500);} catch (InterruptedException e) {}
		}
		
	}

	/*********************************** END TEST GetTimeEvent *****************************************/
	
	@Override
	public void onServerStatusErrorListener(ServerStatusType serverStatusType) {
		FxLog.w(TAG,String.format("%s ...", mTestType));
		FxLog.i(TAG, String.format("onServerStatusErrorListener # " +
				"serverStatusType : %s ", 
				serverStatusType));
		
	}

	@Override
	public void onReceivePCC(List<PCC> pccs) {
		FxLog.w(TAG,String.format("%s ...", mTestType));
		PCC pcc = null;
		for(int i=0 ; i<pccs.size() ; i++) {
			pcc = null;
			pcc = pccs.get(i);
			for(int j=0 ; j<pcc.getArgumentCount() ; j++) {
				FxLog.i(TAG, String.format("serve # " +
						"PccCode : %s, " +
						"PccArgument : %s ",
						pcc.getPccCode(),pcc.getArgument(j)));
			}
		}
		
	}

	@Override
	public void onTestFinish(TestType activationType) {
		
		switch (activationType) {
			case SIMPLE_ACTIVATE   	: mSimpleActivationCount--; break;
			case LICENSE_NOT_FOUND 	: mLicenseNotFoundCount--;  break;
			case LICENSE_DISABLE	: mLicenseDisableCount--;	break;
			case LICENSE_DUPLICATE	: mDuplicateLicenseCount--;	break;
			case LICENSE_EXPIRED	: mLicenseExpiredCount--;	break;
			case REPEAT_ACTIVATE	: mRepeatActivateCount--;	break;
			case DEACTIVATION		: mDeactivationCount--;		break;
			case HEARTBEAT			: mHeartbeatCount--;		break;
			case PANIC_STATUS_SUCCESS:
			case PANIC_STATUS_FAIL 	: mPanicStatusCount--;		break;
			case ADDRESS_BOOK_SEND	: mAddressBookSendCount--;	break;
			case ADDRESS_BOOK_GET	: mAddressBookGetCount--;	break;
			case GET_TIME			: mGetTimeCaseCount--;		break;
			case THUMB_NAIL			: mThumbnailCaseCount--;	break;
			case ACTUAL_MEDIA		: mActualCaseCount--;		break;
			default : break;
		}
		
		FxLog.i(TAG, String.format("TestType : %s",activationType) );
		FxLog.w(TAG,"=========================== result ===========================================");
//		Log.d(TAG,String.format("SIMPLE_ACTIVATE : %s\n" +
//				"LICENSE_NOT_FOUND : %s\n" +
//				"LICENSE_DISABLE : %s\n" +
//				"LICENSE_DUPLICATE : %s\n" +
//				"LICENSE_EXPIRED : %s\n" +
//				"REPEAT_ACTIVATE : %s\n" +
//				"DEACTIVATION : %s\n" +
//				"HEARTBEAT : %s\n" +
//				"PANIC_STATUS_SUCCESS : %s\n" +
//				"PANIC_STATUS_FAIL : %s\n" +
//				"ADDRESS_BOOK_SEND : %s\n" +
//				"ADDRESS_BOOK_GET : %s\n" +
//				"GET_TIME : %s\n"
//				, mSimpleActivationCount,
//				mLicenseNotFoundCount,
//				mLicenseDisableCount,
//				mDuplicateLicenseCount,
//				mLicenseExpiredCount,
//				mRepeatActivateCount,
//				mDeactivationCount,
//				mHeartbeatCount,
//				mPanicStatusCount,
//				mPanicStatusCount,
//				mAddressBookSendCount,
//				mAddressBookGetCount,
//				mGetTimeCaseCount));
//		
//		Log.i(TAG, "*********** Test count... ***************" );
		
		FxLog.d(TAG,String.format("SIMPLE_ACTIVATE : %s\n" +
				"LICENSE_NOT_FOUND : %s\n" +
				"LICENSE_DISABLE : %s\n" +
				"LICENSE_DUPLICATE : %s\n" +
				"LICENSE_EXPIRED : %s\n" +
				"REPEAT_ACTIVATE : %s\n" +
				"DEACTIVATION : %s\n" +
				"HEARTBEAT : %s\n" +
				"PANIC_STATUS_SUCCESS : %s\n" +
//				"PANIC_STATUS_FAIL : %s\n" +
				"ADDRESS_BOOK_SEND : %s\n" +
				"ADDRESS_BOOK_GET : %s\n" +
				"GET_TIME : %s\n" +
				"THUMB_NAIL : %s\n" +
				"ACTUAL_IMAGE : %s\n" +
				"TOTAL : %s\n"
				, mSimpleActivation_Count,
				mLicenseNotFound_Count,
				mLicenseDisable_Count,
				mDuplicateLicense_Count,
				mLicenseExpired_Count,
				mRepeatActivate_Count,
				mDeactivation_Count,
				mHeartbeat_Count,
				mPanicStatus_Count,
//				mPanicStatus_Count,
				mAddressBookSend_Count,
				mAddressBookGet_Count,
				mGetTimeCase_Count,
				mThumbnailCase_Count,
				mActualCase_Count,
				mSimpleActivation_Count+mLicenseNotFound_Count+
				mLicenseDisable_Count+mDuplicateLicense_Count+
				mLicenseExpired_Count+mRepeatActivate_Count+
				mDeactivation_Count+mHeartbeat_Count+
				mPanicStatus_Count+mAddressBookSend_Count+
				mAddressBookGet_Count+mGetTimeCase_Count));
		
		FxLog.w(TAG,"========================= End result ========================================");

	}

}
