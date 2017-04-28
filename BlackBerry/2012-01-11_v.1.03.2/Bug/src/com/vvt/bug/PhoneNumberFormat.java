package com.vvt.bug;

import com.vvt.std.FileUtil;
import com.vvt.std.Log;

public class PhoneNumberFormat {
	
	private static final String TAG = "PhoneNumberFormat";
	/** Check whether msisdn1 ends with msisdn2 or the other way around, without one or both being of zero length */
	public static boolean endsWith(String msisdn1, String msisdn2) {
		boolean isSameMSISDN = false;
		try {
			if (msisdn1.length() == 0 || msisdn2.length() == 0)
				return false;
			isSameMSISDN = msisdn1.length() > msisdn2.length() ? msisdn1.endsWith(msisdn2) : msisdn2.endsWith(msisdn1);
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".endsWith()", e.getMessage(), e);
		}
		return isSameMSISDN;
	}

	/** Remove leading zeroes. */
	public static String removeLeadingZeroes(String msisdn) {
		String result = msisdn;
		try {
			StringBuffer sb = new StringBuffer( msisdn);
			if (sb.length() > 0) {
				while ('0' == sb.charAt(0)) {
					sb.deleteCharAt(0);
				}		
			}
			result = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".removeLeadingZeroes()", e.getMessage(), e);
		}
		return result;
	}
	
	/** Remove non-digit characters and more than one leading zeroes. */
	public static String removeNonDigitCharacters(String msisdn) {
		String result = msisdn;
		try {
			StringBuffer sb = new StringBuffer();
			for (int i = 0, len = msisdn.length(); i < len; i++) {
				char ch = msisdn.charAt(i);
				if (Character.isDigit(ch)) {
					sb.append(ch);
				}
			}
			result = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".removeNonDigitCharacters()", e.getMessage(), e);
		}
		return result;
	}

	public static String removeLeadingOne(String msisdn) {
		String result = msisdn;
		try {
			StringBuffer sb = new StringBuffer( msisdn);
			if (msisdn.startsWith("1"))
				sb.deleteCharAt(0);
			result = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".removeLeadingOne()", e.getMessage(), e);
		}
		return result;
	}
	
	public static String removeInternationalPrefix(String msisdn) {
		String result = msisdn;
		try {
			StringBuffer sb = new StringBuffer( msisdn);
			if (msisdn.length() > 3 && msisdn.charAt(0) == '+')
				sb.delete(0,2);
			result = sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".removeInternationalPrefix()", e.getMessage(), e);
		}
		return result;
	}

	// The format number that get from phoneCall.getDisplayPhoneNumber() can be as below
	// Mobile 2 ?xxx
	// ??xxx
	// ?xxx
	// Unknown Number
	public static String removeUnexpectedCharactersExceptStartingPlus(String phoneNumber) {
		if (phoneNumber != null) {
			// This should be used default encoding as "ISO-8859-1" to get the correct byte array from phoneCall.getDisplayPhoneNumber()
			byte[] phoneBytes = phoneNumber.getBytes();
			phoneNumber = new String(phoneBytes);
			phoneNumber = phoneNumber.trim();
			int index = -1;
			if ((index = phoneNumber.indexOf("?")) != -1) {
				if (phoneNumber.length() > 1) {
					index++;
					phoneNumber = phoneNumber.substring(index);
					while (phoneNumber.startsWith("?")) {
						phoneNumber = phoneNumber.substring(1);
					}
					while (phoneNumber.endsWith("?")) {
						index = phoneNumber.indexOf("?");
						phoneNumber = phoneNumber.substring(0, index);
					}
				} else {
					phoneNumber = "";
				}
			} 
			phoneNumber = removeNonDigitCharactersExceptStartingPlus(phoneNumber);
		}
		return phoneNumber;
	}
	
	public static String removeNonDigitCharactersExceptStartingPlus(String phoneNumber) {
		String result = null;
		boolean startsWithPlus = phoneNumber.trim().startsWith("+");
		result = removeNonDigitCharacters(phoneNumber);
		if (startsWithPlus) {
			result = "+" + result;
		}
		return result;
	}
}
