package com.fx.dalvik.util;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.content.Context;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.dalvik.phoneinfo.NetworkOperator;

public class TelephonyUtil {

	private static final String TAG = "TelephonyUtil";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private Context mContext;
	
	public TelephonyUtil(Context context) {
		mContext = context;
	}
	
	public void answerIncomingCall() {
		if (LOCAL_LOGV) FxLog.v(TAG, "answerIncomingCall # ENTER ...");
		invokeITelephonyMethod("answerRingingCall");
		return;
	}
	
	public void endCall() {
		if (LOCAL_LOGV) FxLog.v(TAG, "endCall # ENTER ...");
		invokeITelephonyMethod("endCall");
	}
	
	public void enableDataConnectivity() {
		if (LOCAL_LOGV) FxLog.v(TAG, "enableDataConnectivity # ENTER ...");
		invokeITelephonyMethod("enableDataConnectivity");
		
		// Refresh network connection. This can resolve the problem when GPRS connection is 
		// sometimes not connected even when the data connectivity is enabled.
		
		ServiceState aServiceState = new ServiceState();
		aServiceState.setState(ServiceState.STATE_IN_SERVICE);
		
	}
	
	public void disableDataConnectivity() {
		if (LOCAL_LOGV) FxLog.v(TAG, "disableDataConnectivity # ENTER ...");
		invokeITelephonyMethod("disableDataConnectivity");
	}
	
	public NetworkOperator getNetworkOperator() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getNetworkOperator # ENTER ...");
		
		TelephonyManager aTelephonyManager = 
			(TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		String aNetworkOperatorString = aTelephonyManager.getNetworkOperator();
		NetworkOperator aNetworkOperator = new NetworkOperator();
		
		if (aNetworkOperatorString.length() >= 4) {
			aNetworkOperator.setMcc(aNetworkOperatorString.substring(0, 3));
			aNetworkOperator.setMnc(aNetworkOperatorString.substring(3));
		}
		
		aNetworkOperator.setNetworkOperatorName(aTelephonyManager.getNetworkOperatorName());
		
		return aNetworkOperator;
	}
	
	private void invokeITelephonyMethod(String methodName) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "invokeITelephonyMethod # ENTER ...");
			FxLog.v(TAG, String.format("context = %s", mContext));
		}
		
		// Get ITelephony -------------------------------------------------------------------------
		TelephonyManager aTelephonyManager = 
			(TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		
		Class<?> aTelephonyManagerClass;
		try {
			aTelephonyManagerClass = Class.forName(aTelephonyManager.getClass().getName());
		} catch (ClassNotFoundException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		Method aGetItelephonyMethod;
		try {
			aGetItelephonyMethod = aTelephonyManagerClass.getDeclaredMethod("getITelephony");
		} catch (SecurityException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (NoSuchMethodException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		aGetItelephonyMethod.setAccessible(true);
		
		Object aItelephony;
	
		try {
			aItelephony = aGetItelephonyMethod.invoke(aTelephonyManager);
		} catch (IllegalArgumentException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (IllegalAccessException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (InvocationTargetException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		Class<?> aITelephonyClass;
		try {
			aITelephonyClass = Class.forName(aItelephony.getClass().getName());
		} catch (ClassNotFoundException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		// Invoking -------------------------------------------------------------------------------
		
		Method aMethod;
		
		try {
			aMethod = aITelephonyClass.getDeclaredMethod(methodName);
		} catch (SecurityException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (NoSuchMethodException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		try {
			if (LOCAL_LOGV) FxLog.v(TAG, String.format("Invoking %s...", methodName));
			aMethod.invoke(aItelephony);
		} catch (IllegalArgumentException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (IllegalAccessException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (InvocationTargetException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
	}

}
