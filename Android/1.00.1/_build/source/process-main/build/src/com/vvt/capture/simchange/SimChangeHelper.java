package com.vvt.capture.simchange;

import android.content.Context;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;

public class SimChangeHelper {

	public static String getSubscriberId(Context context) {
		// TelephonyManager
		final TelephonyManager telMgr = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

		// PhoneStateListener
		PhoneStateListener phoneStateListener = new PhoneStateListener() {
			@Override
			public void onCallStateChanged(final int state,
					final String incomingNumber) {
				getTelephonyOverview(telMgr);
			}
		};

		telMgr.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);

		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		return getTelephonyOverview(telMgr);
	}

	/**
	 * Parse TelephonyManager values into a human readable String.
	 * 
	 * @param telMgr
	 * @return
	 */
	private static String getTelephonyOverview(final TelephonyManager telMgr) {
		String subscriberId = telMgr.getSubscriberId();

		while (subscriberId == null) {
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) { /* do nothing */
			}
			subscriberId = telMgr.getSubscriberId();
		}

		return subscriberId;
	}
}
