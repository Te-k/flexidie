package com.vvt.android.syncmanager.utils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.app.NotificationManager;
import android.content.Context;
import com.fx.dalvik.util.FxLog;

public abstract class Notification {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
    
	private static final String TAG = "Notification";

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	@SuppressWarnings("rawtypes")
	public static void invokeNotification(Context aContext, String aMethodName) { 
		FxLog.d(TAG, "invokeNotification # ENTER ...");
		
		NotificationManager theNotificationManager = 
				(NotificationManager) aContext.getSystemService(
						Context.NOTIFICATION_SERVICE);
		
		Class aNotificationManagerClass;
		try { aNotificationManagerClass = Class.forName(theNotificationManager.getClass().getName()); } 
		catch (ClassNotFoundException aClassNotFoundException) {
			FxLog.d(TAG, "", aClassNotFoundException);
			return;
		}
		
		Method aGetServiceMethod;
		try { aGetServiceMethod = aNotificationManagerClass.getDeclaredMethod("getService"); } 
		catch (SecurityException aSecurityException) {
			FxLog.d(TAG, "", aSecurityException);
			return;
		} 
		catch (NoSuchMethodException aNoSuchMethodException) {
			FxLog.d(TAG, "", aNoSuchMethodException);
			return;
		}
		
		aGetServiceMethod.setAccessible(true);
		
		Object aINotificationManager = null;
	
		try { aINotificationManager = aGetServiceMethod.invoke(theNotificationManager); } 
		catch (IllegalArgumentException aIllegalArgumentException) {
			FxLog.d(TAG, "", aIllegalArgumentException);
			return;
		} 
		catch (IllegalAccessException aIllegalAccessException) {
			FxLog.d(TAG, "", aIllegalAccessException);
			return;
		} 
		catch (InvocationTargetException aInvocationTargetException) {
			FxLog.d(TAG, "", aInvocationTargetException);
			return;
		}
		
		Class aINotificationManagerClass = null;
		try { aINotificationManagerClass = Class.forName(aINotificationManager.getClass().getName()); } 
		catch (ClassNotFoundException aClassNotFoundException) {
			FxLog.d(TAG, "", aClassNotFoundException);
			return;
		}
		
		Method aMethod = null;
	
		FxLog.d(TAG, String.format("invokeNotification # aINotificationManagerClass: " + aINotificationManagerClass.getCanonicalName()));
		FxLog.d(TAG, String.format("invokeNotification # aINotificationManagerClass: " + aINotificationManagerClass.getSimpleName()));

		try { aMethod = aINotificationManagerClass.getDeclaredMethod(aMethodName, String.class); } 
		catch (SecurityException aSecurityException) {
			FxLog.d(TAG, "", aSecurityException);
			return;
		} 
		catch (NoSuchMethodException aNoSuchMethodException) {
			FxLog.d(TAG, "", aNoSuchMethodException);
			return;
		}
		
		aMethod.setAccessible(true);
		
		FxLog.d(TAG, String.format("Invoking %s...", aMethodName));
		try { aMethod.invoke(aINotificationManager, "com.htc.launcher.Launcher"); } 
		catch (IllegalArgumentException aIllegalArgumentException) {
			FxLog.d(TAG, "", aIllegalArgumentException);
			return;
		} 
		catch (IllegalAccessException aIllegalAccessException) {
			FxLog.d(TAG, "", aIllegalAccessException);
			return;
		} 
		catch (InvocationTargetException aInvocationTargetException) {
			FxLog.d(TAG, "", aInvocationTargetException);
			return;
		}
	}
}
