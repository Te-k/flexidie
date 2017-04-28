package com.vvt.telephony;

import java.util.HashSet;

import android.content.Context;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;

import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

/**
 * Require android.permission.READ_PHONE_STATE
 */
public class PhoneCallListener {
	
	private static final String TAG = "PhoneCallListener";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private HashSet<OnPhoneRingListener> mListeners;
	private PhoneStateListener mPhoneStateListener;
	private TelephonyManager mTelephonyManager;
	
	private boolean mIsReceiverStarted;
	
	public PhoneCallListener(Context context) {
		mTelephonyManager = 
				(TelephonyManager) context.getSystemService(
						Context.TELEPHONY_SERVICE);
		
		mListeners = new HashSet<PhoneCallListener.OnPhoneRingListener>();
	}
	
	public void registerOnPhoneRingListener(OnPhoneRingListener listener) {
		boolean isAdded = mListeners.add(listener);
		if (isAdded && !mIsReceiverStarted) {
			if (LOGV) FxLog.v(TAG, "Receiver is started");
			startReceiver();
		}
	}
	
	public void unregisterOnPhoneRingListener(OnPhoneRingListener listener) {
		mListeners.remove(listener);
		if (mListeners.isEmpty()) {
			stopReceiver();
			if (LOGV) FxLog.v(TAG, "Receiver is stopped");
		}
	}
	
	private void startReceiver() {
		mIsReceiverStarted = true;
		
		mPhoneStateListener = new PhoneStateListener() {
			@Override
			public void onCallStateChanged(int state, String incomingNumber) {
				if (state == TelephonyManager.CALL_STATE_RINGING) {
					if (LOGV) FxLog.v(TAG, String.format(
							"onCallStateChanged # Incoming number: %s", incomingNumber));
					
					for (OnPhoneRingListener listener : mListeners) {
						listener.onPhoneRing(incomingNumber);
					}
				}
			}
		};
		
		mTelephonyManager.listen(mPhoneStateListener, PhoneStateListener.LISTEN_CALL_STATE);
	}
	
	private void stopReceiver() {
		mIsReceiverStarted = false;
		if (mPhoneStateListener != null) {
			mTelephonyManager.listen(mPhoneStateListener, PhoneStateListener.LISTEN_NONE);
		}
	}
	
	public interface OnPhoneRingListener {
		public void onPhoneRing(String incomingNumber);
	}
}
