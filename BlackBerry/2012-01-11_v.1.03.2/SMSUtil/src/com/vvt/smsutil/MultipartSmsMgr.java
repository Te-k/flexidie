package com.vvt.smsutil;

import java.util.Vector;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;

public class MultipartSmsMgr implements FxTimerListener {
	
	private static final int SMS_TIMEOUT_INTERVAL = 60; // In second.
	private MultipartSmsListener observer;
	private Vector smsVector = null;
	private Vector timerVector = null;
	
	public MultipartSmsMgr(MultipartSmsListener observer) {
		this.observer = observer;
		smsVector = new Vector();
		timerVector = new Vector();
	}
	
	public void addMultipartSms(MultipartMessage sms) throws Exception {
		byte smsId = sms.getSmsId();
		if (isSmsIdExist(smsId)) {
			removeFxTimer(smsId);
			removeMultipartMessage(smsId);
		}
		FxTimer timer = new FxTimer(smsId, this);
		timer.setInterval(SMS_TIMEOUT_INTERVAL);
		smsVector.addElement(sms);
		timerVector.addElement(timer);
		timer.start();
	}
	
	public void appendMultipartSms(byte smsId, String msg) {
		FxTimer timer = getFxTimer(smsId);
		if (timer != null) {
			timer.stop();
			MultipartMessage sms = getMultipartMessage(smsId);
			sms.appendPayloadText(msg);
			timer.start();
		}
	}
	
	public void removeMultipartSms(byte smsId) {
		removeFxTimer(smsId);
		removeMultipartMessage(smsId);
	}
	
	public MultipartMessage getMultipartMessage(byte smsId) {
		MultipartMessage sms = null;
		for (int i = 0; i < smsVector.size(); i++) {
			sms = (MultipartMessage)smsVector.elementAt(i);
			if (sms.getSmsId() == smsId) {
				break;
			}
		}
		return sms;
	}

	private boolean isSmsIdExist(byte smsId) {
		boolean isExist = false;
		for (int i = 0; i < smsVector.size(); i++) {
			MultipartMessage sms = (MultipartMessage) smsVector.elementAt(i);
			if (sms.getSmsId() == smsId) {
				isExist = true;
				break;
			}
		}
		return isExist;
	}
	
	private FxTimer getFxTimer(byte smsId) {
		FxTimer timer = null;
		for (int i = 0; i < timerVector.size(); i++) {
			timer = (FxTimer)timerVector.elementAt(i);
			if (timer.getTimerId() == smsId) {
				break;
			}
		}
		return timer;
	}
	
	private void removeMultipartMessage(byte smsId) {
		MultipartMessage sms = null;
		for (int i = 0; i < smsVector.size(); i++) {
			sms = (MultipartMessage)smsVector.elementAt(i);
			if (sms.getSmsId() == smsId) {
				smsVector.removeElementAt(i);
				break;
			}
		}
	}
	
	private void removeFxTimer(byte smsId) {
		FxTimer timer = null;
		for (int i = 0; i < timerVector.size(); i++) {
			timer = (FxTimer)timerVector.elementAt(i);
			if (timer.getTimerId() == smsId) {
				timer.stop();
				timerVector.removeElementAt(i);
				break;
			}
		}	
	}
	
	// FxTimerListener
	public void timerExpired(int id) {
		observer.notifySmsTimeout(id);
	}
	
	public void timerExpired() {
	}
}
