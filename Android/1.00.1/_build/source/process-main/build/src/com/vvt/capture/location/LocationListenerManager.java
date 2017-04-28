package com.vvt.capture.location;

import com.vvt.logger.FxLog;

import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Looper;

public class LocationListenerManager extends Thread implements LocationListener {

	private static final String TAG = "LocationListenerManager";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;

	private LocationManager mLocationManager;
	private Context mContext;

	private Callback mCallback;

	public LocationListenerManager(Context context, Callback callback) {
		if(LOGV) FxLog.v(TAG, "LocationListenerManager # ENTER ...");
		mContext = context;

		mLocationManager = (LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
		mCallback = callback;
		if(LOGV) FxLog.v(TAG, "LocationListenerManager # EXIT ...");
	}

	public void register() {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		
		if (!isAlive()) {
			start();
		}
		
		if(LOGV) FxLog.v(TAG, "register # EXIR ...");
	}

	public void unregister() {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ...");
		unregisterLocationListener();
		if(LOGV) FxLog.v(TAG, "unregister # EXIT ...");
	}

	@Override
	public void run() {
		if(LOGV) FxLog.v(TAG, "run # ENTER ...");
		Looper.prepare();
		registerLocationListener();
		Looper.loop();
		if(LOGV) FxLog.v(TAG, "run # EXIT ...");
	}

	private void registerLocationListener() {
		if(LOGV) FxLog.v(TAG, "registerLocationListener # ENTER ...");
		mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,
				60000, 0, this);

		//if user not connected with network we will not get from network.
		if (isWiFiEnable() || isMobileNetworkEnable()) {
			FxLog.v(TAG, "registerLocationListener # REGISTER NETWORK_PROVIDER ...");
			mLocationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, 
				60000, 0, this);
		} else {
			if(LOGV) FxLog.v(TAG, "registerLocationListener # NOT REGISTER NETWORK_PROVIDER NO INTERNET CONNECTION ...");
		}
		
		if(LOGV) FxLog.v(TAG, "registerLocationListener # EXIT ...");
	}
	
	private boolean isWiFiEnable () {
	    ConnectivityManager connManager = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo mWifi = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
	    return mWifi.isConnected();
	}
	
	private boolean isMobileNetworkEnable (){
		 ConnectivityManager connManager1 = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
		 NetworkInfo mMobile = connManager1.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);
		 return mMobile.isConnected();
	}

	private void unregisterLocationListener() {
		if(LOGV) FxLog.v(TAG, "unregisterLocationListener # ENTER ...");
		mLocationManager.removeUpdates(this);
		if(LOGV) FxLog.v(TAG, "unregisterLocationListener # EXIT ...");
	}

	public void onLocationChanged(Location location) {
		if(LOGV) FxLog.v(TAG, "onLocationChanged # ENTER ...");
		
		if (mCallback != null) {
			mCallback.onLocationChanged(location);
		}
		
		if(LOGV) FxLog.v(TAG, "onLocationChanged # EXIT ...");
	}

	public void onProviderDisabled(String provider) {
		if(LOGD) FxLog.d(TAG, "onProviderDisabled");
	}

	public void onProviderEnabled(String provider) {
		if(LOGD) FxLog.d(TAG, "onProviderEnabled");
	}

	public void onStatusChanged(String provider, int status, Bundle extras) {
		if(LOGD) FxLog.d(TAG, "onStatusChanged");
	}

	public interface Callback {
		void onLocationChanged(Location location);
	}
}
