package com.vvt.android.syncmanager;

import java.text.SimpleDateFormat;
import java.util.Date;

import com.fx.dalvik.util.FxLog;
import com.vvt.security.Constant;
import com.vvt.security.FxSecurity;

public abstract class Customization {
	
	public static enum ProductServer { RETAIL, RESELLER, TEST };
	
    public static final ProductServer PRODUCT_SERVER = ProductServer.TEST;
    public static final String PRODUCT_ID = FxSecurity.getConstant(Constant.RETAIL_PRODUCT_ID);
    public static final String PRODUCT_NAME = FxSecurity.getConstant(Constant.RETAIL_PRODUCT_NAME);
	
	public static boolean DEBUG = true;
	public static boolean STRESS_TEST = false; 

    private static final String TAG = "Customization";
	private static final boolean LOGV = DEBUG ? true : false;
	
	public static boolean isMockServer() {
		return false;
	}
	
	public static Date getDefaultDeviceEventExpiryTime() {
		if (LOGV) FxLog.v(TAG, "getDefaultDeviceEventExpiryTime # ENTER ...");
		return new Date((System.currentTimeMillis() * 1000) + (60*60*24*7));	// One week
	}
	
	public static short getDefaultMaxSendAttempts() {
		if (LOGV) FxLog.v(TAG, "getDefaultMaxSendAttempts # ENTER ...");
		return 48;
	}
	
	public static short getDefaultMaxSendDeviceEventCount() {
		if (LOGV) FxLog.v(TAG, "getDefaultMaxSendDeviceEventCount # ENTER ...");
		return 50;
	}
	
	public static long getDefaultURLRequestTimeoutShort() {
		if (LOGV) FxLog.v(TAG, "getDefaultURLRequestTimeoutShort # ENTER ...");
		return 60;
	}
	
	public static long getDefaultURLRequestTimeoutLong() {
		if (LOGV) FxLog.v(TAG, "getDefaultURLRequestTimeoutLong # ENTER ...");
		return 300;
	}
	
	public static String getDefaultUnknownErrorMessage() {
		if (LOGV) FxLog.v(TAG, "getDefaultUnknownErrorMessage # ENTER ...");
		return "Unknown error";
	}
	
	public static String getIncorrectResponseLengthErrorMessage() {
		if (LOGV) FxLog.v(TAG, "getIncorrectResponseLengthErrorMessage # ENTER ...");
		return "Server response not recognized";
	}
	
	public static String getPleaseActivateMessage() {
		if (LOGV) FxLog.v(TAG, "getPleaseActivateMessage # ENTER ...");
		return "Please activate your device";
	}
	
	public static SimpleDateFormat getConnectionHistoryDateFormat() {
		return new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
	}

}
