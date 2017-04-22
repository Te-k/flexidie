package com.vvt.data_delivery_manager.testsfunctional;

import java.text.SimpleDateFormat;
import java.util.ArrayList;

import com.vvt.data_delivery_manager.tests.MockAppContext;
import com.vvt.data_delivery_manager.tests.MockLicenseManager;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.PanicStatus;

public class PanicStatusCase implements DeliveryListener {
	
	private static final String TAG = "PanicStatusCase";
	
	// TODO : Check this code was activated before test.
	private String[] mActivatedLicense = new String[] { "013455" };
	// TODO : Check this deviced ID was activated and match with activationCode above before test.
	String[] mArrayDeviceId = new String[] { "ZEmfkO7Wvzl4QQI" };
	private DataDeliveryManager mDataDeliveryManager;
	private FuntionalTestListener mFuntionalTestListener;

	public PanicStatusCase(DataDeliveryManager dataDeliveryManager, FuntionalTestListener listener) {
		mDataDeliveryManager = dataDeliveryManager;
		mFuntionalTestListener = listener;
	}
	
	public void testSuccessCase() {
		FxLog.v(TAG, "testSuccessCase # ENTER ...");
//		PanicStatusThread panicStatusThread = new PanicStatusThread(TestType.PANIC_STATUS_SUCCESS);
//		panicStatusThread.start();
		run(TestType.PANIC_STATUS_SUCCESS);
		FxLog.v(TAG, "testSuccessCase # EXIT ...");
	}
	
	public void testFailCase() {
		FxLog.v(TAG, "testFailCase # ENTER ...");
//		PanicStatusThread panicStatusThread = new PanicStatusThread(TestType.PANIC_STATUS_FAIL);
//		panicStatusThread.start();
		run(TestType.PANIC_STATUS_FAIL);
		FxLog.v(TAG, "testFailCase # EXIT ...");
	}
	
	/*********************************************** INNER CLASS ***************************************************/
	
//	private class PanicStatusThread extends Thread implements DeliveryListener {
		
		private TestType mTestType;
		private String mActivateCode;
		
		
//		public PanicStatusThread(TestType testType) {
//			mTestType = testType;
//		}
		

		public void run(TestType testType) {
			
			mTestType = testType;
			
			switch (mTestType) {
				case PANIC_STATUS_SUCCESS :
					startTestSuccessCase();
					break;
				case PANIC_STATUS_FAIL :
					startTestFailCase();
					break;
				default:
					break;
			}
		}
		
		private void startTestSuccessCase() {
			FxLog.v(TAG, "startTestSuccessCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createSuccessCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this, commandData, DataProviderType.DATA_PROVIDER_TYPE_PANIC);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startTestSuccessCase # EXIT ...");
		}
		
		private void startTestFailCase() {
			FxLog.v(TAG, "startTestFailCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createFailCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this, commandData, DataProviderType.DATA_PROVIDER_TYPE_PANIC);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startTestFailCase # EXIT ...");
		}

		@Override
		public void onFinish(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onFinish # testPanicStatusEvent : %s --> " +
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
//			
//			tr.start();
			
			
			
			
		}


		@Override
		public void onProgress(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onProgress # testPanicStatusEvent : %s --> " +
					"Status Message : %s, " +
					"Status Code : %s " +
					"Error Type : %s",
					mActivateCode,
					response.getStatusMessage(),
					response.getStatusCode(),
					response.getErrorResponseType()));
			
		}
		
		private CommandData createSuccessCommandData(){
			// prepare Event provider
			ArrayList<Event> eventList = new ArrayList<Event>();
			PanicStatus ps = new PanicStatus();
			String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(System.currentTimeMillis());
			ps.setEventTime(time);
			ps.setStartPanic();
			//ps.setEndPanic();
			eventList.add(ps);

			// set Command
			SendEvents command = new SendEvents();
			command.setEventProvider(new MyEventProvider(eventList));
			command.setEventCount(eventList.size());
			
			return command;
		}
		
		private CommandData createFailCommandData(){
			// prepare Event provider
			ArrayList<Event> eventList = new ArrayList<Event>();
			PanicStatus ps = new PanicStatus();
			ps.setEventTime(Long.toString(System.currentTimeMillis()));
			ps.setStartPanic();
			//ps.setEndPanic();
			eventList.add(ps);

			// set Command
			SendEvents command = new SendEvents();
			command.setEventProvider(new MyEventProvider(eventList));
			command.setEventCount(eventList.size());
			
			return command;
		}
//	}
}
