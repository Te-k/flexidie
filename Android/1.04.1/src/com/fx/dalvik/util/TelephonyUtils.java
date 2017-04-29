package com.fx.dalvik.util;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import com.fx.android.common.Customization;

import android.content.Context;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;
import com.fx.dalvik.util.FxLog;


public class TelephonyUtils {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
    
	private static final String TAG = "TelephonyUtils";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private Context context;
	
	private void invokeITelephonyMethod(String aMethodName) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "invokeITelephonyMethod # ENTER ...");
			FxLog.v(TAG, String.format("context = %s", context));
		}
		
		// Get ITelephony -------------------------------------------------------------------------
		TelephonyManager aTelephonyManager = 
			(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		
		@SuppressWarnings("rawtypes")
		Class aTelephonyManagerClass;
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
		
		@SuppressWarnings("rawtypes")
		Class aITelephonyClass;
		try {
			aITelephonyClass = Class.forName(aItelephony.getClass().getName());
		} catch (ClassNotFoundException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		// Invoking -------------------------------------------------------------------------------
		
		Method aMethod;
		
		try {
			aMethod = aITelephonyClass.getDeclaredMethod(aMethodName);
		} catch (SecurityException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		} catch (NoSuchMethodException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
			return;
		}
		
		try {
			if (LOCAL_LOGV) FxLog.v(TAG, String.format("Invoking %s...", aMethodName));
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

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static class NetworkOperator {
		
		/**
		 * Mobile Country Code
		 */
		private String mcc;
		
		/**
		 * Mobile Network Code
		 */
		private String mnc;
		
		private String networkOperatorName;
		
		public String getMcc() {
			return mcc;
		}
		public void setMcc(String mcc) {
			this.mcc = mcc;
		}
		public String getMnc() {
			return mnc;
		}
		public void setMnc(String mnc) {
			this.mnc = mnc;
		}
		public String getNetworkOperatorName() {
			return networkOperatorName;
		}
		
		public void setNetworkOperatorName(String aNetworkOperatorName) {
			networkOperatorName = aNetworkOperatorName;
		}

	}
	
	/**
	 * @deprecated You can <code>new</code> this instance directly. The constructor is changed to
	 * be public.
	 */
	@Deprecated
	public static TelephonyUtils getInstance(Context aContext) {
		return new TelephonyUtils(aContext);
	}
	
	public TelephonyUtils(Context aContext) {
		if (LOCAL_LOGV) FxLog.v(TAG, "TelephonyUtils # ENTER ...");
		context = aContext;
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
			(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		String aNetworkOperatorString = aTelephonyManager.getNetworkOperator();
		NetworkOperator aNetworkOperator = new NetworkOperator();
		
		if (aNetworkOperatorString.length() >= 4) {
			aNetworkOperator.setMcc(aNetworkOperatorString.substring(0, 3));
			aNetworkOperator.setMnc(aNetworkOperatorString.substring(3));
		}
		
		aNetworkOperator.setNetworkOperatorName(aTelephonyManager.getNetworkOperatorName());
		
		return aNetworkOperator;
	}

}
