package com.vvt.data_delivery_manager.testsfunctional;

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
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.GetAddressBook;
import com.vvt.phoenix.prot.command.SendAddressBook;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.prot.event.FxVCard;

public class AddressBookCase implements DeliveryListener {
private static final String TAG = "AddressBookCase";
	
	// TODO : Check this code was activated before test.
	private String[] mActivatedLicense = new String[] { "013455" };
	// TODO : Check this deviced ID was activated and match with activationCode above before test.
	String[] mArrayDeviceId = new String[] { "ZEmfkO7Wvzl4QQI" };
	private DataDeliveryManager mDataDeliveryManager;
	private FuntionalTestListener mFuntionalTestListener;

	public AddressBookCase(DataDeliveryManager dataDeliveryManager, FuntionalTestListener listener) {
		mDataDeliveryManager = dataDeliveryManager;
		mFuntionalTestListener = listener;
	}
	
	public void testSendAddrBookCase() {
		FxLog.v(TAG, "testSendAddrBookCase # ENTER ...");
//		AddressBookThread addressBookThread = new AddressBookThread(TestType.ADDRESS_BOOK_SEND);
//		addressBookThread.start();
		run(TestType.ADDRESS_BOOK_SEND);
		FxLog.v(TAG, "testSendAddrBookCase # EXIT ...");
	}
	
	public void testGetAddrBookCase() {
		FxLog.v(TAG, "testGetAddrBookCase # ENTER ...");
//		AddressBookThread addressBookThread = new AddressBookThread(TestType.ADDRESS_BOOK_GET);
//		addressBookThread.start();
		run(TestType.ADDRESS_BOOK_GET);
		FxLog.v(TAG, "testGetAddrBookCase # EXIT ...");
	}
	
	
	/*********************************************** INNER CLASS ***************************************************/
	
//	private class AddressBookThread extends Thread implements DeliveryListener {
		
		private TestType mTestType;
		private String mActivateCode;
		
		
//		public AddressBookThread(TestType testType) {
//			mTestType = testType;
//		}
		
	
		public void run(TestType testType) {
			
			mTestType = testType;
			
			switch (mTestType) {
				case ADDRESS_BOOK_SEND :
					startSendAddrBookCase();
					break;
				case ADDRESS_BOOK_GET :
					startGetAddrBookCase();
					break;
				default:
					break;
			}
		}
		
		private void startSendAddrBookCase() {
			FxLog.v(TAG, "startSendAddrBookCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createSendCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this, commandData, DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startSendAddrBookCase # EXIT ...");
		}
		
		private void startGetAddrBookCase() {
			FxLog.v(TAG, "startGetAddrBookCase # ENTER ...");
			mActivateCode = mActivatedLicense[0];
			MockLicenseManager.setActivationCode(mActivateCode);
			String deviceIdentifier = mArrayDeviceId[0];
			MockAppContext.setDeviceId(deviceIdentifier);
			CommandData commandData = createGetCommandData();
			DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
					this, commandData, DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
			mDataDeliveryManager.deliver(deliveryRequest);
			
			FxLog.v(TAG, "startGetAddrBookCase # EXIT ...");
		}

		@Override
		public void onFinish(DeliveryResponse response) {
			FxLog.w(TAG,String.format("%s ...", mTestType));
			FxLog.i(TAG, String.format("onFinish # AddressBookCase : %s --> " +
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
			FxLog.i(TAG, String.format("onProgress # AddressBookCase : %s --> " +
					"Status Message : %s, " +
					"Status Code : %s " +
					"Error Type : %s",
					mActivateCode,
					response.getStatusMessage(),
					response.getStatusCode(),
					response.getErrorResponseType()));
			
		}
		
		private CommandData createSendCommandData(){
			// prepare VCard provider
			ArrayList<FxVCard> vcardList = new ArrayList<FxVCard>();
			FxVCard vcard = new FxVCard();
			vcard.setFirstName("Johnny");
			vcard.setLastName("Dew");
			vcardList.add(vcard);

			// prepare Addressbook
			AddressBook addressBook = new AddressBook();
			addressBook.setAddressBookName("Android Book");
			addressBook.setVCardProvider(new MyVCardProvider(vcardList));
			addressBook.setVCardCount(vcardList.size());

			// set Command
			SendAddressBook command = new SendAddressBook();
			command.addAddressBook(addressBook);
			
			return command;
		}
		
		private CommandData createGetCommandData(){
			// set Command
			GetAddressBook command = new GetAddressBook();
			
			return command;
		}
//	}
	
	private class MyVCardProvider implements DataProvider {

		private ArrayList<FxVCard> mVCardList;
		private int mCurrentIndex;

		public MyVCardProvider(ArrayList<FxVCard> vcardList) {
			mVCardList = vcardList;
			mCurrentIndex = 0;
		}

		@Override
		public Object getObject() {

			/*
			 * For better performance, DataProvider should query VCard data from
			 * database only when getObject() is called. Store all VCards in memory
			 * is not a good practice.
			 */

			FxVCard vcard = mVCardList.get(mCurrentIndex);
			mCurrentIndex++;

			return vcard;
		}

		public boolean hasNext() {
			return mCurrentIndex < mVCardList.size();
		}
	}
}
