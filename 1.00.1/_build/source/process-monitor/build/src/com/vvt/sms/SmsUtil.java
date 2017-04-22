package com.vvt.sms;

import java.util.ArrayList;

import android.telephony.SmsManager;

public class SmsUtil {
	
	public static void sendSms (String recipientNumber,String message) {
		SmsManager smsManager = SmsManager.getDefault();
		 ArrayList<String> parts = smsManager.divideMessage(message);
		smsManager.sendMultipartTextMessage(recipientNumber, null, parts, null, null);
	}
}
