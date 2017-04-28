package com.vvt.data_delivery_manager.testsfunctional;

import com.vvt.data_delivery_manager.tests.MockAppContext;
import com.vvt.data_delivery_manager.tests.MockLicenseManager;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.GetTime;
import com.vvt.phoenix.prot.command.SendDeactivate;
import com.vvt.phoenix.prot.command.SendHeartbeat;

public class NormalTypeCase implements DeliveryListener{
	private static final String TAG = "NormalTypeCase";
	
	//TODO : Check this code was activated before test.
	private String[] mActivatedLicense = new String[] {"01622"};
	//TODO : Check this deviced ID was activated and match with activationCode above before test.
	String[] mArrayDeviceId = new String[] {"kGxOZg1_pyWFgcv"};
	private DataDeliveryManager mDataDeliveryManager;
	private FuntionalTestListener mFuntionalTestListener;
	
	public NormalTypeCase(DataDeliveryManager dataDeliveryManager, FuntionalTestListener listener) {
		mDataDeliveryManager = dataDeliveryManager;
		mFuntionalTestListener = listener;
	}
	
	public void testHeartbeatCase() {
		FxLog.v(TAG, "testHeartbeatCase # ENTER ...");
//		NormalTypeThread heartBeatThread = new NormalTypeThread(TestType.HEARTBEAT);
//		heartBeatThread.start();
		run(TestType.HEARTBEAT);
		FxLog.v(TAG, "testHeartbeatCase # EXIT ...");
	}
	
	public void testGetTimeCase() {
		FxLog.v(TAG, "testGetTimeCase # ENTER ...");
//		NormalTypeThread getTimeThread = new NormalTypeThread(TestType.GET_TIME);
//		getTimeThread.start();
		run(TestType.GET_TIME);
		FxLog.v(TAG, "testGetTimeCase # EXIT ...");
	}
	
	public void testDeactivationCase() {
		FxLog.v(TAG, "testDeactivationCase # ENTER ...");
//		NormalTypeThread deactivationThread = new NormalTypeThread(TestType.DEACTIVATION);
//		deactivationThread.start();
		run(TestType.DEACTIVATION);
		FxLog.v(TAG, "testDeactivationCase # EXIT ...");
	}
	
	/*********************************************** INNER CLASS ***************************************************/
	
//	private class NormalTypeThread extends Thread implements DeliveryListener {
		
		private TestType mTestType;
		private String mActivateCode;
		
		
//		public NormalTypeThread(TestType testType) {
//			mTestType = testType;
//		}
		
		
		public void run(TestType testType) {
			
			mTestType = testType;
			
			switch (mTestType) {
				case HEARTBEAT :
					startTestHeartbeatCase();
					break;
				case GET_TIME :
					startGetTimeCase();
					break;
				case DEACTIVATION : 
					startDeactivateCase();
					break;
				default:
					break;
			}
		}
		
		private void startTestHeartbeatCase() {
			FxLog.v(TAG, "startTestHeartbeatCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createHeartbeatCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this, commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startTestHeartbeatCase # EXIT ...");
		}
		
		private void startGetTimeCase() {
			FxLog.v(TAG, "startGetTimeCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createGetTimeCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this, commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startGetTimeCase # EXIT ...");
		}

		private void startDeactivateCase() {
			FxLog.v(TAG, "startTestNormalCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createDeactivateCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this,commandData,DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startTestNormalCase # EXIT ...");
		}
		
		@Override
		public void onFinish(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onFinish # HeartBeatThread : %s --> " +
					"Status Message : %s, " +
					"Status Code : %s, " +
					"Error type : %s",
					mActivateCode,
					response.getStatusMessage(),
					response.getStatusCode(),
					response.getErrorResponseType()));
			
//			Thread tr = new Thread(new Runnable() {
//				
//				@Override
//				public void run() {
//					try {Thread.sleep(1000);} catch (InterruptedException e) {}
					//tell Finish to unit test.
					mFuntionalTestListener.onTestFinish(mTestType);
					
//				}
//			});
			
//			tr.start();
			
		}

		@Override
		public void onProgress(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onProgress # HeartBeatThread : %s --> " +
					"Status Message : %s, " +
					"Status Code : %s " +
					"Error Type : %s",
					mActivateCode,
					response.getStatusMessage(),
					response.getStatusCode(),
					response.getErrorResponseType()));
			
		}
		
		private CommandData createDeactivateCommandData(){
			/*
			 * TODO
			 * Set your device's data.
			 */
			// set Command
			SendDeactivate command = new SendDeactivate();
			
			return command;
		}
		
		private CommandData createHeartbeatCommandData(){
			/*
			 * TODO
			 * Set your device's data.
			 */
			// set Command
			SendHeartbeat command = new SendHeartbeat();
			
			return command;
		}
		
		private CommandData createGetTimeCommandData(){
			/*
			 * TODO
			 * Set your device's data.
			 */
			// set Command
			GetTime command = new GetTime();
			
			return command;
		}
//	}
}
