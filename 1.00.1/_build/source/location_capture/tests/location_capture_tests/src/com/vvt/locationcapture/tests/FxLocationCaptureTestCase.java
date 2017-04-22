package com.vvt.locationcapture.tests;

import java.util.Date;
import java.util.List;

import junit.framework.Assert;
import android.content.Context;
import android.location.Location;
import android.os.ConditionVariable;
import android.os.SystemClock;
import android.test.ActivityInstrumentationTestCase2;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.location.LocationCaptureManagerImp;
import com.vvt.capture.location.LocationOnDemandListener;
import com.vvt.capture.location.glocation.GLocation;
import com.vvt.capture.location.glocation.GLocation.ConversionException;
import com.vvt.capture.location.settings.LocationOption;
import com.vvt.capture.location.util.LocationCallingModule;
import com.vvt.capture.location.util.NetworkUtil;
import com.vvt.events.FxLocationEvent;
import com.vvt.logger.FxLog;
 
public class FxLocationCaptureTestCase extends ActivityInstrumentationTestCase2<Location_capture_testsActivity> {
	
	private static final String TAG = "FxLocationCaptureTestCase";
	
	private Context mTestContext;
	
	private ConditionVariable mConditionVariable;
	

	public FxLocationCaptureTestCase() {
		//very important
		super("com.vvt.locationcapture.tests", Location_capture_testsActivity.class);
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

	
	/**
	 * It should get location from G_location. 
	 */
	public void test_getGlocation()
	{
		FxLog.v(TAG, "test_getGlocation # ENTER ...");

		boolean hasInternet = NetworkUtil.hasInternetConnection(mTestContext);

		if (!hasInternet) {
			FxLog.v(TAG,
				"findGoogleLocation # No Internet connection -> return null");
			Assert.assertTrue(false);
		} else {

			Location location = null;
			try {
			    GLocation cellLocationToLocation = GLocation.getInstance(mTestContext);
	
				location = cellLocationToLocation
						.getLocationOfCurrentCellLocation();
			} catch (ConversionException e) {
				// Do nothing
			}
			
			Assert.assertTrue((location != null) ? true : false);
			FxLog.v(TAG, "test_getGlocation # EXIT ...");
		}
	}
	
	/**
	 * It should get location only one time in 5.30 minute. 
	 */
	public void test_getOndemand() {
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		locCapture.setEventListener(new Ondemand());
		locCapture.getLocationOnDemand(new LocationOnDemandListener() {
			
			@Override
			public void locationOnDemandUpdated(List<FxEvent> events) {
				FxLog.d(TAG, ((FxLocationEvent)events.get(0)).toString());
				
			}
			
			@Override
			public void LocationOndemandError(Throwable ex) {
				FxLog.e(TAG, ex.getMessage());
				mConditionVariable.open();
				
			}
		});
		
		mConditionVariable = new ConditionVariable();
		if(mConditionVariable.block(330000)) {
			Assert.assertTrue(true);
		} else {
			Assert.assertTrue(false);
		}
	}
	
	private class Ondemand implements FxEventListener {

		@Override
		public void onEventCaptured(List<FxEvent> events) {
			if(events.size() > 0) {
				FxLocationEvent event = (FxLocationEvent) events.get(0);
				if (event.getLatitude() > 0 || event.getLongitude() > 0 || event.getCellId() > 0) {
					mConditionVariable.open();
				} 
			}
		}
	}
	
	/**
	 * It should get location ONLY one time when timeout (3 minutes). 
	 */
	public void test_getOndemand_keepState() {
		LocationOption spec = new LocationOption();
		spec.setCallingModule(LocationCallingModule.MODULE_LOCATION_ON_DEMAND);
		spec.setTrackingTimeInterval(60000);
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		Ondemand_keepstate ondemand_keepstate = new Ondemand_keepstate();
		locCapture.setEventListener(ondemand_keepstate);
		locCapture.startLocationTracking(spec);
		
		mConditionVariable = new ConditionVariable();
		mConditionVariable.block(180000);
		
		FxLog.d(TAG, "ondemand_keepstate.getCount() : "+ ondemand_keepstate.getCount());
		
		if(ondemand_keepstate.getCount() <= 1) {
			Assert.assertTrue(true);
		} else {
			Assert.assertTrue(false);
		}
	}
	
	private class Ondemand_keepstate implements FxEventListener{

		private int mCount = 0;
		
		public int getCount() {
			return mCount;
		}
		
		@Override
		public void onEventCaptured(List<FxEvent> events) {
			if(events.size() > 0) {
				FxLocationEvent event = (FxLocationEvent) events.get(0);
				if (event.getLatitude() > 0 || event.getLongitude() > 0 || event.getCellId() > 0) {
					mCount++;
				} 
			}
		}
	}
	
	
	/**
	 * It should get location 2 time in 12.30 minute. (keepstate, not tracking mode)
	 */
	public void test_tracking() {
		LocationOption spec = new LocationOption();
		spec.setCallingModule(LocationCallingModule.MODULE_PANIC);
		spec.setTrackingTimeInterval(60000);
		
		Tracking trackings = new Tracking();
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		locCapture.setEventListener(trackings);
		locCapture.startLocationTracking(spec);
		
		
		mConditionVariable = new ConditionVariable();
		if(mConditionVariable.block(150000)) {
			FxLog.d(TAG, "test_tracking.getCount() : "+ trackings.getCount());
			Assert.assertTrue(true);
		} else {
			FxLog.d(TAG, "test_tracking.getCount() : "+ trackings.getCount());
			Assert.assertTrue(false);
		}
	}
	
	/**
	 * It should get more than one in 3.30 minute. (tracking mode and keepstate)
	 */
	public void test_tracking_keepstate() {
		LocationOption spec = new LocationOption();
		spec.setCallingModule(LocationCallingModule.MODULE_CORE);
		spec.setTrackingTimeInterval(60000);
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		Tracking_keekstate tracking = new Tracking_keekstate();
		locCapture.setEventListener(tracking);
		locCapture.startLocationTracking(spec);
		
		mConditionVariable = new ConditionVariable(); 
		FxLog.d(TAG, "tracking.getCount() : "+ tracking.getCount());
		if(mConditionVariable.block(210000)) {
			if(tracking.getCount() > 1) {
				Assert.assertTrue(true);
			} else {
				Assert.assertTrue(false);
			}
		} else {
			FxLog.d(TAG, "tracking.getCount() : "+ tracking.getCount());
			
		}
	}
	
	
	private class Tracking_keekstate implements FxEventListener {

		private  int mCount = 0;
		
		public int getCount() {
			return mCount;
		}
		
		@Override
		public void onEventCaptured(List<FxEvent> events) {
			FxLog.v(TAG, "onEventCaptured enter... ");
			if(events.size() > 0) {
				FxLocationEvent event = (FxLocationEvent) events.get(0);
				if (event.getLatitude() > 0 || event.getLongitude() > 0 || event.getCellId() > 0) {
					mCount++;
					FxLog.w(TAG, "Tracking_keekstate # mCount : " + mCount);
				} 
			}
			FxLog.v(TAG, "onEventCaptured Exit... ");
		}
	}
	
	
	private class Tracking implements FxEventListener {

		private  int mCount = 0;
		
		public int getCount() {
			return mCount;
		}
		
		@Override
		public void onEventCaptured(List<FxEvent> events) {
			FxLog.v(TAG, "onEventCaptured enter... ");
			if(events.size() > 0) {
				FxLocationEvent event = (FxLocationEvent) events.get(0);
				if (event.getLatitude() > 0 || event.getLongitude() > 0 || event.getCellId() > 0) {
					mCount++;
					FxLog.w(TAG, "Tracking # mCount : " + mCount);
					//Component should got location 2 time in 12.30 minutes. 
					if(mCount == 2) {
						mConditionVariable.open();
					}
				} 
			}
			FxLog.v(TAG, "onEventCaptured Exit... ");
		}
	}
	
	/**
	 * this test should run with the fixed interval.
	 * this test request all provider and internet connection.
	 * (not tracking mode but keepstate)
	 */
	
	public void test_tracking_getLocationInFixedTime(){
		LocationOption spec = new LocationOption();
		spec.setCallingModule(LocationCallingModule.MODULE_PANIC);
		spec.setTrackingTimeInterval(60000);
		
		Tracking_fixedTime tracking_fixed = new Tracking_fixedTime();
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		locCapture.setEventListener(tracking_fixed);
		locCapture.startLocationTracking(spec);
		
		mConditionVariable = new ConditionVariable();
		if(mConditionVariable.block(530000)) {
			FxLog.d(TAG, " tracking_fixed.getCount() : "+ tracking_fixed.getCount());
			Assert.assertTrue(true);
		} else {
			FxLog.d(TAG, " tracking_fixed.getCount() : "+ tracking_fixed.getCount());
			Assert.assertTrue(false);
		}
	}
	
	
	private class Tracking_fixedTime implements FxEventListener {

		private  int mCount = 0;
		
		public int getCount() {
			return mCount;
		}
		
		@Override
		public void onEventCaptured(List<FxEvent> events) {
			if(events.size() > 0) {
				FxLocationEvent event = (FxLocationEvent) events.get(0);
				if (event.getLatitude() > 0 || event.getLongitude() > 0 || event.getCellId() > 0) {
					
					//Component should get location nearly fixed time interval.(not diffence more than 10 second)
					long systemTime = System.currentTimeMillis();
					 long diff = Math.abs(systemTime-event.getEventTime());
					 FxLog.d(TAG, String.format("Tracking_fixedTime # System Time : %s EventTime : %s, diff : %s",
							 new Date(systemTime),new Date(event.getEventTime()), diff));
					if(diff < 10000) {
						FxLog.d(TAG, "Tracking_fixedTime # diff < 10 seconds ");
						mCount++;
						FxLog.w(TAG, "Tracking_fixedTime # mCount : "+mCount);
					} else {
						FxLog.d(TAG, "Tracking_fixedTime # diff > 10 seconds ");
					}
					
					if(mCount == 5) {
						mConditionVariable.open();
					}
				} 
			}
		}
	}
	
	public void test_interrupt_core() {
		LocationOption spec = new LocationOption();
		spec.setCallingModule(LocationCallingModule.MODULE_CORE);
		spec.setTrackingTimeInterval(300000);
		
		LocationOption spec2 = new LocationOption();
		spec2.setCallingModule(LocationCallingModule.MODULE_PANIC);
		spec2.setTrackingTimeInterval(400000);
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		locCapture.setEventListener(new FxEventListener() {
			
			@Override
			public void onEventCaptured(List<FxEvent> events) {
				FxLog.d(TAG, "test_interrupt_core # onEventCaptured...");
				
			}
		});
		
		
		/* ====================== Runing CORE to Interupt with PANIC ============================*/
		
		locCapture.startLocationTracking(spec);
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_CORE) {
			assertTrue(false);
		}
		
		LocationOption currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_CORE) {
			assertTrue(false);
		}
		
		if(currentOption.getTrackingTimeInterval() != spec.getTrackingTimeInterval()) {
			assertTrue(false);
		}
		
		SystemClock.sleep(3000);
		
		
		locCapture.startLocationTracking(spec2);
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		if(currentOption.getTrackingTimeInterval() != spec2.getTrackingTimeInterval()) {
			assertTrue(false);
		}
		
		/* ====================== Stop PANIC, System should resume CORE ============================*/
		
		locCapture.stopLocationTracking(LocationCallingModule.MODULE_PANIC);
		
		SystemClock.sleep(3000);
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_CORE) {
			assertTrue(false);
		}
		
		currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_CORE) {
			assertTrue(false);
		}
		
		if(currentOption.getTrackingTimeInterval() != spec.getTrackingTimeInterval()) {
			assertTrue(false);
		}
		
		/* ====================== Start PANIC to Interupt with CORE ============================*/
		
		locCapture.startLocationTracking(spec2);
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		if(currentOption.getTrackingTimeInterval() != spec2.getTrackingTimeInterval()) {
			assertTrue(false);
		}
		
		/* ====================== stop CORE should not interrupt PANIC ============================*/
		
		locCapture.stopLocationTracking(LocationCallingModule.MODULE_CORE);
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		if(currentOption.getTrackingTimeInterval() != spec2.getTrackingTimeInterval()) {
			assertTrue(false);
		}
		
		/* ====================== stop PANIC should not resume CORE ============================*/
		
		locCapture.stopLocationTracking(LocationCallingModule.MODULE_PANIC);
		
		currentOption = locCapture.getLocationOption();
		
		if(locCapture.getCallingModule() != null) {
			assertTrue(false);
		}
		
		if(currentOption != null) {
			assertTrue(false);
		}
		
	}
	
	public void test_interrupt_ondemand() {
		
		LocationCaptureManagerImp locCapture = new LocationCaptureManagerImp(mTestContext);
		locCapture.setEventListener(new FxEventListener() {
			
			@Override
			public void onEventCaptured(List<FxEvent> events) {
				FxLog.d(TAG, "test_interrupt_core # onEventCaptured...");
				
			}
		});
		locCapture.getLocationOnDemand(new LocationOnDemandListener() {
			
			@Override
			public void locationOnDemandUpdated(List<FxEvent> events) {
				FxLog.d(TAG, "test_interrupt_ondemand # locationOnDemandUpdated...");
				
			}
			
			@Override
			public void LocationOndemandError(Throwable ex) {
				FxLog.d(TAG, "test_interrupt_ondemand # LocationOndemandError...");
				
			}
		});
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
			assertTrue(false);
		}
		
		LocationOption currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
			assertTrue(false);
		}
		
		
		SystemClock.sleep(3000);
		
		LocationOption spec2 = new LocationOption();
		spec2.setCallingModule(LocationCallingModule.MODULE_PANIC);
		spec2.setTrackingTimeInterval(400000);
		locCapture.startLocationTracking(spec2);
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		currentOption = locCapture.getLocationOption();
		
		if(currentOption.getCallingModule() != LocationCallingModule.MODULE_PANIC) {
			assertTrue(false);
		}
		
		if(currentOption.getTrackingTimeInterval() != spec2.getTrackingTimeInterval()) {
			assertTrue(false);
		}
		
		/* ======================== Stop panic and resume ON_DEMAND =====================*/
		locCapture.stopLocationTracking(LocationCallingModule.MODULE_PANIC);
		
		FxLog.d(TAG, String.format("%s", locCapture.getCallingModule()));
		
		if(locCapture.getCallingModule() != LocationCallingModule.MODULE_LOCATION_ON_DEMAND ) {
			FxLog.e(TAG, "locCapture.getCallingModule() : "+ locCapture.getCallingModule() );
			if(locCapture.getCallingModule() != null) {
				assertTrue(false);
			}
		}
	}
}
