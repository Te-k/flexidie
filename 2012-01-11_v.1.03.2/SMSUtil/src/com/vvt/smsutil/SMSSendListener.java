package com.vvt.smsutil;

public interface SMSSendListener {
	public void smsSendSuccess(FxSMSMessage smsMessage);
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message);
}
