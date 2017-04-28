package com.vvt.location;

import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Looper;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;


public class LocationListenerManager extends Thread implements LocationListener {
	
	private static final String TAG = "LocationListenerManager";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	private LocationManager mLocationManager;
	
	private Callback mCallback;
	
	public LocationListenerManager(Context context, Callback callback) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "LocationListenerManager # ENTER ...");
		}
		
		mLocationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
		mCallback = callback;
	}
	
	public void register() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "register # ENTER ...");
		}
		if (!isAlive()) {
			start();
		}
	}
	
	public void unregister() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "unregister # ENTER ...");
		}
		unregisterLocationListener();
	}
	
	@Override
	public void run() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "run # ENTER ...");
		}
		
		Looper.prepare();
		
		registerLocationListener();
		
		Looper.loop();
	}
	
	private void registerLocationListener() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "registerLocationListener # ENTER ...");
		}
		
		mLocationManager.requestLocationUpdates(
				LocationManager.GPS_PROVIDER, 0, 0, this);
		
		mLocationManager.requestLocationUpdates(
				LocationManager.NETWORK_PROVIDER, 0, 0, this);
	}
	
	private void unregisterLocationListener() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "unregisterLocationListener # ENTER ...");
		}
		mLocationManager.removeUpdates(this);
	}

	@Override
	public void onLocationChanged(Location location) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onLocationChanged # ENTER ...");
		}
		if (mCallback != null) {
			mCallback.onLocationChanged(location);
		}
	}
	
	@Override
	public void onProviderDisabled(String provider) { }
	@Override
	public void onProviderEnabled(String provider) { }
	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) { }
	
	public interface Callback {
		void onLocationChanged(Location location);
	}
}


