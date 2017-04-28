package com.vvt.smsutil;

public interface SMSReceiverListener {
	public void onSMSReceived(FxSMSMessage smsMessage);
	public void onSMSReceivedFailed(FxSMSMessage smsMessage, Exception e, String message);
}
