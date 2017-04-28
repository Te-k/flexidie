package com.vvt.datadeliverymanager.interfaces;



public interface RetryTimerListener {
	public void onTimerExpired(long csid);
}
