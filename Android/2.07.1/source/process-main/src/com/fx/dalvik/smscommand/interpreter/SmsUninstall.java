package com.fx.dalvik.smscommand.interpreter;

import android.content.Context;
import android.os.SystemClock;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.license.LicenseManager;
import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;

public class SmsUninstall {
	
	private static final String TAG = "SmsUninstall";
 	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#74";
	
	// Uninstall product
	// <*#74><FK> | <*#74>
	public static String processCommand(final Context context, String[] tokens) {
		if (LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				(tokens.length == 1 && !SmsCommandHelper.isEndWithDebugTag(tokens)) ||
				(tokens.length == 2 && SmsCommandHelper.isEndWithDebugTag(tokens)) ||
				(tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens)) ||
				(tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
		if (!debugTagValidation) {
			return String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		boolean isActivated = LicenseManager.getInstance(context).isActivated();
		
		// Only check Activation Code if the product is activated 
		if (isActivated) {
			String activationCodeValidation = 
				SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
			
			if (!activationCodeValidation.equals(
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
				return activationCodeValidation;
			}
		}
		
		Thread t = new Thread() {
			public void run() {
				int delay = 30000;
				if (LOGV) FxLog.v(TAG, String.format(
						"Uninstall product in %d sec ...", delay/1000));
				SystemClock.sleep(delay);
				ServiceManager.getInstance(context).uninstallAll();
			}
		};
		t.start();
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
	}

}
