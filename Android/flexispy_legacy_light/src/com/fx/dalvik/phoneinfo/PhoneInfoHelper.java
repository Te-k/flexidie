package com.fx.dalvik.phoneinfo;

import android.content.Context;
import android.os.Build;
import android.telephony.TelephonyManager;

public class PhoneInfoHelper {
	
	public static String getDeviceId(Context context) {
		TelephonyManager telephonyManager = 
			(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		
		return telephonyManager.getDeviceId();
	}

	public static String getModel() {
		return Build.MODEL;
	}

	public static String getDevice() {
		return Build.DEVICE;
	}
	
	public static NetworkOperator getNetworkOperator(Context context) {
		TelephonyManager telephonyManager = 
			(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		
		NetworkOperator networkOperator = new NetworkOperator();
		String networkOperatorString = telephonyManager.getNetworkOperator();
		
		if (networkOperatorString.length() >= 4) {
			networkOperator.setMcc(networkOperatorString.substring(0, 3));
			networkOperator.setMnc(networkOperatorString.substring(3));
		}
		
		networkOperator.setNetworkOperatorName(telephonyManager.getNetworkOperatorName());
		
		return networkOperator;
	}

}
