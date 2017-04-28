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
import com.vvt.phoenix.prot.command.SendActivate;

public class ActivationCase implements DeliveryListener{

	private static final String TAG = "ActivationCase";
	
	private String[] mNotActivatedLicense = new String[] {"01622","01624"};
	private String[] mActivatedLicense = new String[] {"01623"};
	private String[] mLicenseExpired = new String[] {"012607","012608"};
	private String[] mLicenseDisable = new String[] {"013451"};
	private DataDeliveryManager mDataDeliveryManager;
	private FuntionalTestListener mFuntionalTestListener;
	
	public ActivationCase(DataDeliveryManager dataDeliveryManager, FuntionalTestListener listener) {
		mDataDeliveryManager = dataDeliveryManager;
		mFuntionalTestListener = listener;
	}
	
	public void testNormalCase() {
		FxLog.v(TAG, "testNormalCase # ENTER ...");
//		ActivationThread activationThread = new ActivationThread(TestType.SIMPLE_ACTIVATE);
//		activationThread.start();
		run(TestType.SIMPLE_ACTIVATE);
		FxLog.v(TAG, "testNormalCase # EXIT ...");
	}
	
	public void testLicenseExpiredCase() {
//		ActivationThread activationThread = new ActivationThread(TestType.LICENSE_EXPIRED);
//		activationThread.start();
		run(TestType.LICENSE_EXPIRED);
	}
	
	public void testLicenseNotFound() {
//		ActivationThread activationThread = new ActivationThread(TestType.LICENSE_NOT_FOUND);
//		activationThread.start();
		run(TestType.LICENSE_NOT_FOUND);
	}
	
	public void testLicenseDisable() {
//		ActivationThread activationThread = new ActivationThread(TestType.LICENSE_DISABLE);
//		activationThread.start();
		run(TestType.LICENSE_DISABLE);
	}
	
	public void testRepeatActivate() {
//		ActivationThread activationThread = new ActivationThread(TestType.REPEAT_ACTIVATE);
//		activationThread.start();
		run(TestType.REPEAT_ACTIVATE);
	}
	
	public void testDuplicateLicense() {
//		ActivationThread activationThread = new ActivationThread(TestType.LICENSE_DUPLICATE);
//		activationThread.start();
		run(TestType.LICENSE_DUPLICATE);
	}
	
	
	/*********************************************** INNER CLASS ***************************************************/
	
//	private class ActivationThread extends Thread implements DeliveryListener {

		private TestType mTestType;
		private String mActivateCode;
		
//		public ActivationThread(TestType runCase) {
//			mTestType = runCase;
//		}
		

		public void run(TestType testType) {
			
			mTestType = testType;
			
			FxLog.v(TAG, "run # ENTER ...");
			switch (mTestType) {
				case SIMPLE_ACTIVATE : 
					startTestNormalCase();
					break;
				case LICENSE_DISABLE :
					startTestLicenseDisable();
					break;
				case LICENSE_EXPIRED : 
					startTestLicenseExpired();
					break;
				case LICENSE_NOT_FOUND : 
					startTestLicenseNotFound();
					break;
				case REPEAT_ACTIVATE : 
					startTestRepeatActivate();
					break;
				case LICENSE_DUPLICATE : 
					startTestDuplicateLicense();
				default :
					break;
			}
			FxLog.v(TAG, "run # EXIT ...");
		}

		private void startTestNormalCase() {
			FxLog.v(TAG, "startTestNormalCase # ENTER ...");
			mActivateCode = randomActivationCodeFromPool(mNotActivatedLicense);
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = GenerateTestValue.getRandomString(15);
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					 this,commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
			FxLog.v(TAG, "startTestNormalCase # EXIT ...");
		}
		
		private void startTestLicenseExpired() {
			mActivateCode = randomActivationCodeFromPool(mLicenseExpired);
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = GenerateTestValue.getRandomString(15);
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this,commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
		}
		
		private void startTestLicenseDisable() {
			mActivateCode = randomActivationCodeFromPool(mLicenseDisable);
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = GenerateTestValue.getRandomString(15);
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this,commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
		}
		
		private void startTestLicenseNotFound() {
			mActivateCode = Integer.toString(GenerateTestValue.getRandomInteger(100000, 999999));
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = GenerateTestValue.getRandomString(15);
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this,commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
		}
		
		private void startTestDuplicateLicense() {
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = GenerateTestValue.getRandomString(15);
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this,commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
		}
		
		private void startTestRepeatActivate() {
			mActivateCode = mNotActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = "TestRepeatActivate";
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this,commandData, DataProviderType.DATA_PROVIDER_TYPE_NONE);
			mDataDeliveryManager.deliver(deliveryRequest);
		}

		@Override
		public void onFinish(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onFinish # ActivationCode : %s --> " +
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
//					//tell Finish to unit test.
					mFuntionalTestListener.onTestFinish(mTestType);
					
//				}
//			});
			
//			tr.start();
		}

		@Override
		public void onProgress(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onProgress # ActivationCode : %s --> " +
					"Status Message : %s, " +
					"Status Code : %s " +
					"Error Type : %s",
					mActivateCode,
					response.getStatusMessage(),
					response.getStatusCode(),
					response.getErrorResponseType()));
			
		}
		
		
		private String randomActivationCodeFromPool(String[] activationPool) {
			if(activationPool.length == 1) {
				return activationPool[0];
			}
			int index = GenerateTestValue.getRandomInteger(0,activationPool.length-1);
			return activationPool[index];
		}

		private CommandData createCommandData(){
			SendActivate command = new SendActivate();
			/*
			 * TODO
			 * Set your device's data.
			 */
			command.setDeviceInfo("DeviceInfo");
			command.setDeviceModel("Nexus S");
			
			return command;
		}

//	}

}
