package com.vvt.eventdelivery.tests;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.content.Context;
import android.os.SystemClock;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.base.FxLicenseInfo;
import com.vvt.base.FxPreferenceInfo;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.eventdelivery.EventDelivery;
import com.vvt.eventdelivery.EventDeliveryConstant;
import com.vvt.eventdelivery.EventDeliveryManager;
import com.vvt.eventdelivery.InitializeParameters;
import com.vvt.eventrepository.DatabaseCorruptExceptionListener;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.RepositoryChangeListener;
import com.vvt.eventrepository.RepositoryChangePolicy;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.EventQueryPriority;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxCameraImageEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxPanicStatusEvent;
import com.vvt.events.FxSMSEvent;
import com.vvt.events.FxSettingElement;
import com.vvt.events.FxSettingEvent;
import com.vvt.events.FxSystemEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.productinfo.ProductInfo;


@SuppressWarnings({"rawtypes", "unused"})
public class EventDeliveryManagerTestCase extends  ActivityInstrumentationTestCase2 {
	 

	private static final String TAG = "EventDeliveryManagerTestCase";
	private Context mTestContext;
	private AppContext mAppContext;
	
	private int mNumberOfTest = 10;
	private int mCountRegularRequest = 0;
	private int mCountTwoTimeRegularRequest = 0;
	private int mTwoTimeDeliverCount = 0;
	private int mCountActualMediaRequest = 0;
	private int mCountPanicRequest = 0;
	private int mCountSystemRequest = 0;
	private int mCountSettingRequest = 0;
	private int mCountMutiMediaRequest = 0;
	private int mCountSameListenerRequest = 0;
	
	
	private boolean mIsGotRegularResponse = false;
	private boolean mIsGotActualMediaResponse = false;
	private boolean mIsGotPanicStatusResponse = false;
	private boolean mIsFinishPanicRequest = false;
	private boolean mIsFinishSystemRequest = false;
	private boolean mIsFinishSettingRequest = false;
	private boolean mIsFinishFistTimeRequest = false;
	private boolean mIsFinishSecondTimeRequest = false;
	private boolean mIsFinishNullReponse = false;
	private boolean mIsFinishSameListenerRequest = false;
	
	
	private boolean mIsProcessingTwoTime = false;
	private boolean mIsProcessingNullResponse = false;
	private boolean mIsProcessingRepoCannotAccess = false;
	private boolean mIsProcessingDederialinzeFail = false;
	
	
	
	
	
	@SuppressWarnings("unchecked")
	public EventDeliveryManagerTestCase() {
		super("com.vvt.eventdelivery.tests", Event_delivery_testsActivity.class);
	}
	
	@Override
	protected void setUp()  throws Exception {
		super.setUp();

		mTestContext = this.getInstrumentation().getContext();
		mAppContext = new AppContextImpl(mTestContext);
		
		// Create the FxAppContext..
		String applicationPath =  mTestContext.getFilesDir().getAbsolutePath();
		String dateFormat = "";
		FxLicenseInfo licenseInfo = null; 
		FxPreferenceInfo preferenceInfo = null;
		ProductInfo productInfo= mAppContext.getProductInfo();
		PhoneInfo phoneInfo = mAppContext.getPhoneInfo();

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
	
	/**====================================== Test Initialization Is Null ======================================**/
	
	public void test_InitializationIsNull() {
		
		boolean isSuccess = true;
		
		
		//should not catch.
		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
		} catch (FxNullNotAllowedException e) {
			isSuccess = false;
		}
				
		
		
		//should catch.
		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(null);
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
		} catch (FxNullNotAllowedException e) {
			isSuccess = true;
		}
		
		//should catch.
		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(null);
			eventDeliveryManager.initialize();
		} catch (FxNullNotAllowedException e) {
			isSuccess = true;
		}
		assertTrue(isSuccess);
	}
	
	/**========================== Test deliver RegularEvents With DeliveryListener ===================================**/
	
	/**
	 * the system should deliver non-demia before media events. 
	 * so the DeliveryListener should got notification, "Onprogress", equal number of test.
	 */
	public void test_deliverRegularEventsWithDeliveryListener() {

		mCountRegularRequest = 0;
		
		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));

		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i = 0 ; i < mNumberOfTest ; i++) {
				mIsGotRegularResponse = false;
				eventDeliveryManager.deliverRegularEvents(new DeliveryListener() {

					@Override
					public void onProgress(DeliveryResponse response) {
						mCountRegularRequest++;
						FxLog.d(TAG, "On progress...");
						
					}

					@Override
					public void onFinish(DeliveryResponse response) {
						mIsGotRegularResponse = true;
					}
				});
				
				while(!mIsGotRegularResponse){ /*wait response...*/};
				//for prepare next round.
				SystemClock.sleep(100);
				FxLog.w(TAG, String.format("deliverRegularEvent Round : %s/%s",mCountRegularRequest,mNumberOfTest));
			}
			

		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		assertTrue(mCountRegularRequest == mNumberOfTest ? true : false);
	}
	
	
	/**================================== Test deliver RegularEvents TwoTimes ===================================**/
	
	/**
	 * System should deliver one time but notify all listener.
	 */
	public void test_deliverRegularEventsTwoTimes() {
		
		mIsProcessingTwoTime = true;
		
		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));

		try {

			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i=0 ; i<mNumberOfTest ;i++) {
				
				//It should not more than 2 time deliver.
				if(mTwoTimeDeliverCount > 2) {
					assertTrue(false);
				}
				
				//reset value.
				mTwoTimeDeliverCount = 0;
				
				//first request
				DeliveryListener listener1 = new DeliveryListener() {
					
					@Override
					public void onProgress(DeliveryResponse response) {
						FxLog.d(TAG,"On Progress 1....");

					}
	
					@Override
					public void onFinish(DeliveryResponse response) {
						FxLog.d(TAG,"On Finish 1....");
						mIsFinishFistTimeRequest = true;
						
					}
				};
				
				eventDeliveryManager.deliverRegularEvents(listener1);
				
				//Second request
				DeliveryListener listener2 = new DeliveryListener() {
	
					@Override
					public void onProgress(DeliveryResponse response) {
						FxLog.d(TAG,"On Progress 2....");

					}
	
					@Override
					public void onFinish(DeliveryResponse response) {
						FxLog.d(TAG,"On Finish 2....");
						mIsFinishSecondTimeRequest = true;
						
					}
				};

				eventDeliveryManager.deliverRegularEvents(listener2);
				
				while(!mIsFinishFistTimeRequest && !mIsFinishSecondTimeRequest){ };
				//for prepare next round.
				SystemClock.sleep(100);
				mIsFinishFistTimeRequest =false;
				mIsFinishSecondTimeRequest = false;
				FxLog.w(TAG, String.format("deliverRegularTwoTimes i = %s Round : %s/%s",i+1,mCountTwoTimeRegularRequest/2,mNumberOfTest));
			}

		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		//Why it /2 because it deliver non-media and media.
		assertTrue(mCountTwoTimeRegularRequest/2 == mNumberOfTest ? true : false);
		mIsProcessingTwoTime = false;
	}
	
	/**================================ deliver Two Times With Same Listener ==================================**/
	
	/**
	 * test_deliverTwoTimesWithSameListener 
	 */
	private DeliveryListener mdeliverSameListener = new DeliveryListener() {

		@Override
		public void onProgress(DeliveryResponse response) {
			FxLog.d(TAG, "On progress...");
			mCountSameListenerRequest++;
		}

		@Override
		public void onFinish(DeliveryResponse response) {
			mIsFinishSameListenerRequest = true;
			
		}
	};
	
	public void test_deliverTwoTimesWithSameListener() {
		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
		
		try {

			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i=0 ; i<mNumberOfTest ;i++) {
				eventDeliveryManager.deliverRegularEvents(mdeliverSameListener);
				eventDeliveryManager.deliverRegularEvents(mdeliverSameListener);
				while(!mIsFinishSameListenerRequest){ };
				//for prepare next round.
				SystemClock.sleep(100);
				mIsFinishSameListenerRequest = false;
				FxLog.w(TAG, String.format("deliverTwoTimesWithSameListener NumberOfNotify : %s/%s",mCountSameListenerRequest,mNumberOfTest));
			}
		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		
		assertTrue(mCountSameListenerRequest/2 == mNumberOfTest ? true : false);
	}
	
	/**============================== End deliver Two Times With Same Listener ================================**/
	
	/**======================================= Test deliver MediaEvents ========================================**/
	
	/**
	 * test_deliverMediaEvents 
	 */
	private DeliveryListener mdeliverMediaListener = new DeliveryListener() {

		@Override
		public void onProgress(DeliveryResponse response) {
			FxLog.d(TAG, "On progress...");
		}

		@Override
		public void onFinish(DeliveryResponse response) {
			mIsGotActualMediaResponse = true;
			mCountActualMediaRequest++;
		}
	};
	
	
	/**
	 * System should not crach when the ID is not found.
	 */
	public void test_deliverMediaEvents() {
		
		final int callerId = 1;
		
		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA));
		params.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA));
		
		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			int paringId = 0;
			for(int i=0 ; i<mNumberOfTest ; i++) {
				mIsGotActualMediaResponse = false;
				paringId = GenerrateTestValue.getRandomInteger(1, 100);
				try {
					eventDeliveryManager.deliverActualMedia(paringId,mdeliverMediaListener);
				} catch (FxDbIdNotFoundException e) {
					FxLog.d(TAG,"paringID < 0");
				}
				while(!mIsGotActualMediaResponse){ /*wait response...*/};
				//for prepare next round.
				SystemClock.sleep(100);
				FxLog.w(TAG, String.format("deliverMediaEvents paringID = %s Round : %s/%s",paringId,mCountActualMediaRequest,mNumberOfTest));
			}
			
			
		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		
		assertTrue(mCountActualMediaRequest == mNumberOfTest ? true : false);
	}
	
	/**
	 * System should notify correct listener in each parig ID.
	 * 
	 * NOT UST THREAD when in DDM mock when test this case.
	 * 
	 */
//	public void test_deliverMultipleMediaEvent(){
//		
//		final int callerId = 1;
//		
//		InitializeParameters params = new InitializeParameters();
//		params.setCallerId(callerId);
//		params.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA));
//		params.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA));
//		
//		int number = 5;
//		
//		try {
//			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager(params);
//			int paringId = 0;
//			for(int i=1 ; i<=number ; i++) {
//				paringId = i;
//				try {
//					eventDeliveryManager.deliverActualMedia(paringId,new DeliveryListener() {
//						
//						@Override
//						public void onProgress(DeliveryResponse response) {}
//						
//						@Override
//						public void onFinish(DeliveryResponse response) {
//							mCountMutiMediaRequest++;
//						}
//					});
//				} catch (FxDbIdNotFoundException e) {
//					Log.d(TAG,"paringID < 0");
//				}
//			}
//			
//			while(mCountMutiMediaRequest < 5){ /*wait response...*/};
//			//for prepare next round.
//			SystemClock.sleep(100);
//			Log.w(TAG, String.format("test_deliverMultipleMediaEvent  TotalCount : %s/%s",mCountMutiMediaRequest,number));
//			
//			assertTrue(mCountMutiMediaRequest == 5 ? true : false);
//			
//			
//		} catch (FxNullNotAllowedException e) {
//			e.printStackTrace();
//		}
//	}
	
 
	/**================================== Test deliver Panic and Alert Event =====================================**/
	
	public void test_deliverPanicAndAlertEvent() {
		
		final int callerId = 1;
		
		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_PANIC));
		params.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_PANIC));
		
		try {
			
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i=0 ; i<mNumberOfTest ; i++) {
				mIsFinishPanicRequest = false;
				eventDeliveryManager.forTest_deliverEvents(EventDelivery.Type.TYPE_PANIC, new DeliveryListener() {
	
					@Override
					public void onProgress(DeliveryResponse response) {
						FxLog.d(TAG, "On progress...");
						FxLog.d(TAG,response.getStatusMessage()+":"+String.format("%s", FxEventType.PANIC_STATUS));
						if(response.getStatusMessage().equals(String.format("%s", FxEventType.PANIC_STATUS))){
							mIsGotPanicStatusResponse = true;
						}
						
					}
	
					@Override
					public void onFinish(DeliveryResponse response) {
						mIsFinishPanicRequest = true;
						if (mIsGotPanicStatusResponse) {
							mCountPanicRequest++;
						}
					}
				});
				
				while(!mIsFinishPanicRequest){ /*wait response...*/};
				//for prepare next round.
				SystemClock.sleep(100);
				FxLog.w(TAG, String.format("deliverPanicAndAlertEvent Round : %s/%s",mCountPanicRequest,mNumberOfTest));
			}
			
		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		assertTrue(mCountPanicRequest == mNumberOfTest ? true : false);
	}
	
	
	/**=================================== Test deliver System Events =======================================**/
	
	/**
	 * deliver should work.
	 */
	public void test_deliverSystemEvents() {

		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_SYSTEM));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_SYSTEM));

		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i=0 ; i<mNumberOfTest ; i++) {
				mIsFinishSystemRequest = false;
				eventDeliveryManager.forTest_deliverEvents(EventDelivery.Type.TYPE_SYSTEM, new DeliveryListener() {
	
					@Override
					public void onProgress(DeliveryResponse response) {
						FxLog.d(TAG, "On progress...");
						
					}
					
					@Override
					public void onFinish(DeliveryResponse response) {
						if(response.getStatusMessage().equals(String.format("%s", FxEventType.SYSTEM))){
							mCountSystemRequest++;
						}
						mIsFinishSystemRequest = true;
					}
				});
				while(!mIsFinishSystemRequest){ /*wait response...*/};
				//for prepare next round.
				SystemClock.sleep(100);
				FxLog.w(TAG, String.format("deliverSystemEvents Round : %s/%s",mCountSystemRequest,mNumberOfTest));
			}

		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		assertTrue(mCountSystemRequest == mNumberOfTest ? true : false);
	}
	
//	/**=================================== Test deliver Setting Events =======================================**/
//	
//	/**
//	 * CAN'T TEST because phoenix NOT SUPPORT now!. NO settings Event in phoenix.
//	 * 
//	 */
//	public void test_deliverSettingEvents() {
//
//		final int callerId = 1;
//
//		InitializeParameters params = new InitializeParameters();
//		params.setCallerId(callerId);
//		params.setDataDelivery(new DataDeliveryMock(
//				DataProviderType.DATA_PROVIDER_TYPE_SETTINGS));
//		params.setEventRepository(new EventRepositoryMock(
//				DataProviderType.DATA_PROVIDER_TYPE_SETTINGS));
//
//		try {
//			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager(mAppContext, params);
//			for(int i=0 ; i<mNumberOfTest ; i++) {
//				eventDeliveryManager.forTest_deliverEvents(EventDelivery.Type.TYPE_SETTINGS, new DeliveryListener() {
//	
//					@Override
//					public void onProgress(DeliveryResponse response) {
//						FxLog.d(TAG, "On progress...");
//						
//					}
//					
//					@Override
//					public void onFinish(DeliveryResponse response) {
//						mIsFinishSettingRequest = true;
//						if(response.getStatusMessage().equals(String.format("%s", FxEventType.SETTINGS))){
//							mCountSettingRequest++;
//						}
//					}
//				});
//				while(!mIsFinishSettingRequest){ /*wait response...*/};
//				FxLog.w(TAG, String.format("deliverSettingEvents Round : %s/%s",mCountSettingRequest,mNumberOfTest));
//			}
//
//		} catch (FxNullNotAllowedException e) {
//			e.printStackTrace();
//		}
//		assertTrue(mCountSettingRequest == mNumberOfTest ? true : false);
//	}
	
	/**=================================== Test get Null Response =======================================**/
	
	/**
	 * System should not crach and can continue when reponse is null.
	 */
	public void test_gotNullResponse() {
		mIsProcessingNullResponse = true;
		
		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_SYSTEM));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_SYSTEM));

		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			/*test 1 time enough because if you call deliver more than 1 it will deliver just one time*/
			mIsFinishNullReponse = false;
			eventDeliveryManager.deliverSystemEvents();
			FxLog.i(TAG, "deliverSystemEvents.....");
			while (!mIsFinishNullReponse) { /* wait triger from Deliver method... */}

		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		
		mIsProcessingNullResponse = false;
	}
	
	
	/**============================== Test got Null value from Repository ==================================**/
	
	/**
	 * system should not crash and not freeze, it shoud continue deliver event but actually it deliver notthing
	 * becase it always got empty resultset. 
	 */
	public void test_gotRepoReturnNull() {
		mIsProcessingRepoCannotAccess = true;
		mCountRegularRequest = 0;
		
		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));

		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i = 0 ; i < mNumberOfTest ; i++) {
				mIsGotRegularResponse = false;
				eventDeliveryManager.deliverRegularEvents(new DeliveryListener() {

					@Override
					public void onProgress(DeliveryResponse response) {
						FxLog.d(TAG, "On progress...");
						
					}

					@Override
					public void onFinish(DeliveryResponse response) {
						mCountRegularRequest++;
						mIsGotRegularResponse = true;
					}
				});
				
				while(!mIsGotRegularResponse){ /*wait response...*/};
				FxLog.w(TAG, String.format("gotRepoReturnNull Round : %s/%s",mCountRegularRequest,mNumberOfTest));
			}
			

		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		assertTrue(mCountRegularRequest == mNumberOfTest ? true : false);
		
		mIsProcessingRepoCannotAccess = false;
	}
	
	/**================================ Test Dederialinzing Failed ======================================**/
	public void test_deserialinzingFailed() {
		
		mIsProcessingDederialinzeFail = true;
		
		mCountRegularRequest = 0;
		
		final int callerId = 1;

		InitializeParameters params = new InitializeParameters();
		params.setCallerId(callerId);
		params.setDataDelivery(new DataDeliveryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
		params.setEventRepository(new EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));

		try {
			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager();
			eventDeliveryManager.setAppContext(mAppContext);
			eventDeliveryManager.setDataDelivery(new DataDeliveryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.setEventRepository(new EventRepositoryMock(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR));
			eventDeliveryManager.initialize();
			
			for(int i=0 ;i<mNumberOfTest ;i++) {
				mIsGotRegularResponse = false;
				eventDeliveryManager.deliverRegularEvents(new DeliveryListener() {
	
					@Override
					public void onProgress(DeliveryResponse response) {
						FxLog.d(TAG, "On progress...");
						
					}
	
					@Override
					public void onFinish(DeliveryResponse response) {
						mCountRegularRequest++;
						mIsGotRegularResponse = true;
					}
				});
	
				while (!mIsGotRegularResponse) { /* wait response... */}
				FxLog.w(TAG, String.format("deserialinzingFailed Round : %s/%s",mCountRegularRequest,mNumberOfTest));
			}

		} catch (FxNullNotAllowedException e) {
			e.printStackTrace();
		}
		assertTrue(mCountRegularRequest == mNumberOfTest ? true : false);
		
		mIsProcessingDederialinzeFail = false;
	
	}
	
	
	/**====================================== INNER CLASS ======================================**/
	
	class DataDeliveryMock implements DataDelivery
	{

		DataProviderType dataProviderType;
		
		
		public DataDeliveryMock(DataProviderType dataProviderType) {
			this.dataProviderType = dataProviderType;
		}
		
		@Override
		public void deliver(final DeliveryRequest deliveryRequest){

			//for check two time request, It should be 1 deliver.
			if(mIsProcessingTwoTime) {
				mCountTwoTimeRegularRequest++;
			}
			
			DeliveryRequestType type =  deliveryRequest.getDeliveryRequestType();
			
			Thread thd = new Thread(new Runnable() {
				
				@Override
				public void run() {
					try {Thread.sleep(100);} catch (InterruptedException e) {}
					
					DeliveryResponse response = new DeliveryResponse();
					
					SendEvents eventProvider  = (SendEvents)deliveryRequest.getCommandData();
					DataProvider p = eventProvider.getEventProvider();
					
					Event event = null;
					while(p.hasNext()) {
						event = (Event)p.getObject();
						event.toString();
					}
					
					response.setCanRetry(false);
					response.setCSMresponse(null);
					response.setDataProviderType(dataProviderType);
					response.setStatusCode(0);
					if(event != null) {
						String type = String.format("%s", FxEventType.forValue(event.getEventType()));
						response.setStatusMessage(type);
						FxLog.i(TAG,String.format("%s",type));
					}else {
						FxLog.i(TAG,"event is NULL");
						response.setStatusMessage("NULL");
					}

					response.setSuccess(true);
					
					/*================================ for test null response. =======================*/
					if(mIsProcessingNullResponse) {
						response = null;
						Thread notifyThread = new Thread(new Runnable() {
							
							@Override
							public void run() {
								FxLog.i(TAG,"Thread Start.....");
								try {Thread.sleep(1000);} catch (InterruptedException e) {}
								mIsFinishNullReponse = true;
								
							}
						});
						
						notifyThread.start();
					}
					/*================================ END test null response. =======================*/
					
					/*============================== for test Dederialinze Fail. =======================*/
					if(mIsProcessingDederialinzeFail) {
						String writtablePath = mTestContext.getFilesDir().getAbsolutePath();
						String pathToDelete = 
								EventDeliveryConstant.getSerializedObjectPath(
										writtablePath, EventDelivery.Type.TYPE_REGULAR);
						
						// This method doesn't throw IOException
						new File(pathToDelete).delete();
					}
					/*============================== END test Dederialinze Fail. =======================*/
					
					deliveryRequest.getDeliveryListener().onFinish(response);
					
				}
			});
			thd.start();
		}
	}

	class EventRepositoryMock implements FxEventRepository  {

		private static final String TAG = "EventRepositoryMock";
		DataProviderType dataProviderType;
		private int mRegularEventCountRound = 1;
		private int mPanicEventCountRound = 1;
		private int mSystemEventCountRound = 1;
		private int mSettingEventCountRound = 1;
		
		
		public EventRepositoryMock(DataProviderType dataProviderType) {
			this.dataProviderType = dataProviderType;
		}
		
		@Override
		public EventResultSet getRegularEvents(QueryCriteria criteria)
				throws FxNullNotAllowedException, FxNotImplementedException,
				FxDbNotOpenException, FxFileNotFoundException, FxDbOperationException {

			EventResultSet resultSet = new EventResultSet();
			List<FxEvent> myList = new ArrayList<FxEvent>();
			
			List<FxEventType> listType = criteria.getEventTypes();
			if (listType.size() < 1) {
				EventQueryPriority eventQueryPriority = new EventQueryPriority();
				listType = eventQueryPriority.getNormalPriorityEvents();
			}

			
			FxEvent event = null;
			
			if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR) {
				if(mRegularEventCountRound < 3) {
					for(FxEventType e : listType) { 	
						event = mockFxEvent(e);
						if(event != null) {
							myList.add(event);
						}
					}
					mRegularEventCountRound++;
				}  else {
					/*
					 * for test Dederialinze Fail, it should refresh value.
					 * if you not refresh it will it will sent switch between non-media and media and have a null value too. 
					*/
					if(mIsProcessingDederialinzeFail) {
						mRegularEventCountRound =1;
					}
				}
				
				resultSet.addEvents(myList);
			}
			
			if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_PANIC) {
				for (FxEventType e : listType) {
					event = mockFxEvent(e);
					if (event != null) {
						myList.add(event);
					}
				}
				resultSet.addEvents(myList);
			}
			
			if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_SYSTEM) {
				if(mSystemEventCountRound < 3) {
					for(FxEventType e : listType) { 
						event = mockFxEvent(e);
						if(event != null) {
							myList.add(event);
						}
					}
					mSystemEventCountRound++;
				} else {
					mSystemEventCountRound = 1;
				}
				resultSet.addEvents(myList);
			}
			
			if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_SETTINGS) {
				if(mSettingEventCountRound < 3) {
					for(FxEventType e : listType) { 
						event = mockFxEvent(e);
						if(event != null) {
							myList.add(event);
						}
					}
					mSettingEventCountRound++;
				} else {
					mSettingEventCountRound = 1;
				}
				resultSet.addEvents(myList);
			}

			//for test repository can't access before deliver to DDM.
			if(mIsProcessingRepoCannotAccess){
				resultSet = null;
			}
			
			return resultSet;
		}
		
		private FxEvent mockFxEvent(FxEventType type) {
			
			FxEvent event = null;
			
			switch (type) {
				case CALL_LOG : 
					List<FxEvent> callEvents  = GenerrateTestValue.getEvents(
							FxEventType.CALL_LOG, 1);
					FxCallLogEvent call = (FxCallLogEvent) callEvents.get(0);
					call.setDirection(FxEventDirection.IN);
					call.setEventId(1);
					event = call;
					break;
				case SMS :
					List<FxEvent> smsEvents  = GenerrateTestValue.getEvents(
							FxEventType.SMS, 1);
					FxLog.d(TAG,smsEvents.toString());
					FxSMSEvent sms = (FxSMSEvent) smsEvents.get(0);
					sms.setDirection(FxEventDirection.IN);
					sms.setEventId(2);
					event = sms;
					break;
				case CAMERA_IMAGE_THUMBNAIL :
					List<FxEvent> thumbEvents  = GenerrateTestValue.getEvents(
							FxEventType.CAMERA_IMAGE_THUMBNAIL, 1);
					FxCameraImageThumbnailEvent thumb = (FxCameraImageThumbnailEvent) thumbEvents.get(0);
					thumb.setActualFullPath("actualFullPath");
					thumb.setEventId(3);
					thumb.setThumbnailFullPath("/sdcard/data/xxx.png");
					event = thumb;
					break;
				case PANIC_STATUS : 
					if(mPanicEventCountRound < 3) {
						List<FxEvent> statusEvents = GenerrateTestValue.getEvents(
								FxEventType.PANIC_STATUS, 1);
						FxPanicStatusEvent statusEvent = (FxPanicStatusEvent) statusEvents.get(0);
						statusEvent.setEventId(4);
						event = statusEvent;
						mPanicEventCountRound++;
					}
					break;
				case ALERT_GPS : 
					if(mPanicEventCountRound < 6) {
						List<FxEvent> alertEvents = GenerrateTestValue.getEvents(
								FxEventType.ALERT_GPS, 1);
						FxAlertGpsEvent gpsEvent = (FxAlertGpsEvent) alertEvents.get(0);
						gpsEvent.setEventId(5);
						event = gpsEvent;
						mPanicEventCountRound++;
					} else {
						mPanicEventCountRound = 1;
					}
					break;
				case SYSTEM :
					List<FxEvent> systemGpsEvents = GenerrateTestValue.getEvents(
							FxEventType.SYSTEM, 1);
					FxSystemEvent systemEvent = (FxSystemEvent) systemGpsEvents.get(0);
					systemEvent.setEventId(5);
					event = systemEvent;
					break;
				case SETTINGS :
					FxSettingEvent settingsEvent = new FxSettingEvent();
					settingsEvent.setEventId(6);
					settingsEvent.setEventTime(System.currentTimeMillis());
					settingsEvent.addSettingElement(new FxSettingElement());
					event = settingsEvent;
					break;
				default :
					break;
			}
			return event;
		}

		@Override
		public EventResultSet getMediaEvents(QueryCriteria criteria)
				throws FxNullNotAllowedException, FxNotImplementedException,
				FxFileNotFoundException, FxDbNotOpenException, FxDbCorruptException, FxDbOperationException {
			
			List<FxEvent> myList = null;
			
			if(dataProviderType == DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR) {
				final FxCameraImageThumbnailEvent thumb = new FxCameraImageThumbnailEvent();
				thumb.setActualFullPath("actualFullPath");
				thumb.setActualSize(100);
				thumb.setData(null);
				thumb.setEventId(1);
				thumb.setEventTime(100);
				thumb.setFormat(FxMediaType.AAC);
				thumb.setGeo(null);
				thumb.setParingId(100);
				thumb.setThumbnailFullPath("sssss");
				
				myList = new ArrayList<FxEvent>(Arrays.asList(thumb));
			}
			
			EventResultSet resultSet = new EventResultSet();
			resultSet.addEvents(myList);
			
			mRegularEventCountRound++;
			//finish test regular media and non media.
			if(mRegularEventCountRound > 6){
				resultSet = new EventResultSet();
				mRegularEventCountRound = 1;
			} 
			return resultSet;
			
			
		}
		
		@Override
		public FxEvent getActualMedia(long paringId)
				throws FxNotImplementedException, FxDbOperationException {

			FxLog.d(TAG,"paringId = "+ paringId);
			
			if(paringId >= 1 && paringId <= 50) {
				FxCameraImageEvent e = new FxCameraImageEvent();
				e.setEventId(paringId);
				e.setEventTime(0);
				e.setFileName("fileName");
				e.setFormat(FxMediaType.AAC_PLUS);
				e.setGeo(null);
				e.setImageData(null);
				e.setParingId(paringId);
				return e;
			}
			
			return null;
		}

		@Override
		public void insert(FxEvent events) throws FxNullNotAllowedException,
		FxDbNotOpenException, FxNotImplementedException, FxDbOperationException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void insert(List<FxEvent> events) throws FxNullNotAllowedException,
		FxDbNotOpenException, FxNotImplementedException, FxDbOperationException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void delete(EventKeys evKeys) throws FxDbNotOpenException,
		FxNotImplementedException, FxNullNotAllowedException,
		FxDbIdNotFoundException, FxDbOperationException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public EventCountInfo getCount() throws FxNotImplementedException,
		FxDbNotOpenException, FxDbCorruptException, FxDbOperationException {
			return null;
		}

		@Override
		public int getTotalEventCount() throws FxDbNotOpenException, FxDbCorruptException, FxDbOperationException {
			// TODO Auto-generated method stub
			return 0;
		}

		@Override
		public void addRepositoryChangeListener(RepositoryChangeListener listener,
				RepositoryChangePolicy policy) throws FxNullNotAllowedException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void removeRepositoryChangeListener(RepositoryChangeListener listener) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void updateMediaThumbnailStatus(long id, boolean status)
				throws FxDbIdNotFoundException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void addDatabaseCorruptExceptionListener(
				DatabaseCorruptExceptionListener listener) {
			// TODO Auto-generated method stub
			
		}

		@Override
		public void deleteActualMedia(long paringId)
				throws FxDbIdNotFoundException {
			// TODO Auto-generated method stub
			
		}

		@Override
		public FxEvent validateMedia(long paringId)
				throws FxNotImplementedException, FxDbOperationException,
				FxFileNotFoundException, FxDbIdNotFoundException,
				FxFileSizeNotAllowedException {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public long getDBSize() {
			// TODO Auto-generated method stub
			return 0;
		}
			 
	}

}


