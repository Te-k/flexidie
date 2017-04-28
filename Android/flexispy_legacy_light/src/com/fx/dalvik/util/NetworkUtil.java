package com.fx.dalvik.util;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.telephony.TelephonyManager;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;


public class NetworkUtil {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
    
	private static final String TAG = "NetworkUtil";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static boolean hasInternetConnection(Context context) {
		if (context != null) {
			ConnectivityManager connectivityManager = (ConnectivityManager) 
					context.getSystemService(Context.CONNECTIVITY_SERVICE);
			
			NetworkInfo.State mobileState = 
				connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).getState();
			NetworkInfo.State wifiState = 
				connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState();
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("hasInternetConnection # MobileState: %s, WifiState: %s", 
						mobileState, wifiState));
			}
			
			return mobileState == NetworkInfo.State.CONNECTED || 
					wifiState == NetworkInfo.State.CONNECTED;
		} else {
			return false;
		}
	}
	
	/**
	 * @param context
	 * @return type of active network get from ConnectivityManager
	 */
	public static int getActiveNetworkType(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		if (connectivityManager.getActiveNetworkInfo() != null) {
			return connectivityManager.getActiveNetworkInfo().getType(); 
		}
		else {
			return -1;
		}
	}
	
	public static boolean isMobileNetworkConnected(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

		NetworkInfo.State mobileState = 
			connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_MOBILE).getState();
		
		return mobileState == NetworkInfo.State.CONNECTED;
	}
	
	public static boolean isWifiNetworkConnected(Context context) {
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		
		NetworkInfo.State wifiState = 
			connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI).getState();
		
		return wifiState == NetworkInfo.State.CONNECTED;
	}
	
	/**
	 * If there is no active network connection, this method will try to enable mobile network and 
	 * wait until network status is "connected". If the method failed to enable, it will return 
	 * <code>false</code>. Otherwise it will return <code>true</code>.  
	 *
	 * @param context  the context
	 * @return         true if there is already an active connection or connection can be enabled
	 *                      successfully.
	 *                 false if the method cannot enable the connection.  
	 */
	public static boolean enableDataConnectivityIfNecessary(Context context) {
		if (LOCAL_LOGV) FxLog.v(TAG, "enableDataConnectivityIfNecessary # ENTER ...");
		
		ConnectivityManager connectivityManager = 
			(ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("Active network info: %s", activeNetworkInfo));
		}
		
		if (activeNetworkInfo != null) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "There is already an active network, no need to turn on mobile network");
			}
			return true;
		}
		
		// if (LOCAL_LOGV) FxLog.v(TAG, "Trying to enable Wifi (if not enabled).");
		// TODO: Try to enable Wifi and check status.
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Trying to turn on mobile network");
		
		// Still doesn't work. SecurityException is thrown when calling this method.
		//asyncSelectNetworkAutomatic();
		
		TelephonyManager telephonyManager = 
				(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		
		for (int i = 0 ; i < 50 ; i++) {
			int dataState = telephonyManager.getDataState();
			
			switch (dataState) {
			case TelephonyManager.DATA_CONNECTED:
				if (LOCAL_LOGV) FxLog.v(TAG, "Data State: Connnected");
				break;
				
			case TelephonyManager.DATA_CONNECTING:
				if (LOCAL_LOGV) FxLog.v(TAG, "Data State: Connecting");
				break;
				
			case TelephonyManager.DATA_DISCONNECTED:
				if (LOCAL_LOGV) FxLog.v(TAG, "Data State: Disconnected");
				break;
				
			case TelephonyManager.DATA_SUSPENDED:
				if (LOCAL_LOGV) FxLog.v(TAG, "Data State: Suspended");
				break;
				
			default:
				if (LOCAL_LOGD) FxLog.d(TAG, "Invalid state");
				break;
			}
			
			if (dataState == TelephonyManager.DATA_CONNECTED) {
				if (LOCAL_LOGV) FxLog.v(TAG, "Network enabling success.");
				return true;
			} else if (dataState == TelephonyManager.DATA_DISCONNECTED) {
				
				if (LOCAL_LOGV) FxLog.v(TAG, "Trying to enable data state...");
				
				TelephonyUtil telephonyUtils = new TelephonyUtil(context);
				try {
					telephonyUtils.enableDataConnectivity();
				} catch (Exception e1) {
					if (LOCAL_LOGD) FxLog.d(TAG, "Cannot enable", e1);
				}
			}
			
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				if (LOCAL_LOGD) FxLog.d(TAG, "Cannot sleep", e);
			}
		}
		
		if (LOCAL_LOGD) FxLog.d(TAG, "Network enabling failed.");
		
		return false;
	}
}
