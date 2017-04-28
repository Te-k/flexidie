package com.vvt.android.syncmanager.utils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import android.content.Context;
import android.media.AudioManager;
import android.telephony.TelephonyManager;
import com.fx.dalvik.util.FxLog;

public final class Telephony {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
    
	private static final String TAG = "Telephony";
	
	private Context context;
	
	private static class SingletonHolder { private static final Telephony INSTANCE = new Telephony(); }
	
	private Telephony() { }
	
	@SuppressWarnings("rawtypes")
	private void invokeITelephonyMethod(String aMethodName) { FxLog.d(TAG, "invokeITelephonyMethod # ENTER ...");
		
		FxLog.d(TAG, String.format("Current context = %s", context));
		
		// Get ITelephony -------------------------------------------------------------------------
		TelephonyManager aTelephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		
		Class aTelephonyManagerClass;
		try { aTelephonyManagerClass = Class.forName(aTelephonyManager.getClass().getName()); } 
		catch (ClassNotFoundException aClassNotFoundException) {
			FxLog.d(TAG, "", aClassNotFoundException);
			return;
		}
		
		Method aGetItelephonyMethod;
		try { aGetItelephonyMethod = aTelephonyManagerClass.getDeclaredMethod("getITelephony"); } 
		catch (SecurityException aSecurityException) {
			FxLog.d(TAG, "", aSecurityException);
			return;
		} 
		catch (NoSuchMethodException aNoSuchMethodException) {
			FxLog.d(TAG, "", aNoSuchMethodException);
			return;
		}
		
		aGetItelephonyMethod.setAccessible(true);
		
		Object aItelephony = null;
	
		try { aItelephony = aGetItelephonyMethod.invoke(aTelephonyManager); } 
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
		
		Class aITelephonyClass = null;
		try { aITelephonyClass = Class.forName(aItelephony.getClass().getName()); } 
		catch (ClassNotFoundException aClassNotFoundException) {
			FxLog.d(TAG, "", aClassNotFoundException);
			return;
		}
		
		// Invoking -------------------------------------------------------------------------------
		
		Method aMethod = null;
		
		try { aMethod = aITelephonyClass.getDeclaredMethod(aMethodName); } 
		catch (SecurityException aSecurityException) {
			FxLog.d(TAG, "", aSecurityException);
			return;
		} 
		catch (NoSuchMethodException aNoSuchMethodException) {
			FxLog.d(TAG, "", aNoSuchMethodException);
			return;
		}
		
		FxLog.d(TAG, String.format("Invoking %s...", aMethodName));
		try { aMethod.invoke(aItelephony); } 
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

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
		 
	public static Telephony getInstance(Context aContext) { FxLog.d(TAG, "getInstance # ENTER ...");
		
		FxLog.d(TAG, String.format("Current context = %s", aContext));
	
		SingletonHolder.INSTANCE.context = aContext;
		return SingletonHolder.INSTANCE; 
	}
	
	public void answerIncomingCall() { FxLog.d(TAG, "answerIncomingCall # ENTER ...");
		
		AudioManager aAudioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);

		// Store the original ringer state and change it to be silent -----------------------------
		int aOriginalRingerMode = aAudioManager.getRingerMode();
		aAudioManager.setRingerMode(AudioManager.RINGER_MODE_SILENT);
		this.invokeITelephonyMethod("silenceRinger");
		
		try { Thread.sleep(1000); } 
		catch (InterruptedException aInterruptedException) { FxLog.d(TAG, "", aInterruptedException); }
				
		// Answer ringing call --------------------------------------------------------------------
		this.invokeITelephonyMethod("answerRingingCall");

		// Set ringer mode to original ------------------------------------------------------------
		aAudioManager.setRingerMode(aOriginalRingerMode);
		return;
	}
	
	public void enableDataConnectivity() { FxLog.d(TAG, "enableDataConnectivity # ENTER ...");
		
		this.invokeITelephonyMethod("enableDataConnectivity");
	}
	
	public void disableDataConnectivity() { FxLog.d(TAG, "disableDataConnectivity # ENTER ...");
		
		this.invokeITelephonyMethod("disableDataConnectivity");
	}
}
