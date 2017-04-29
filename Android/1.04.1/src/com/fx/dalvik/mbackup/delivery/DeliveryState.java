package com.fx.dalvik.mbackup.delivery;

import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;

public class DeliveryState {

	private static final String TAG = "EventsManager";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private boolean mDelivering = false;
	private long mDeliverStartTimestamp = 0;
	
	public void setDelivering(boolean delivering) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("setDelivering # ENTER ... : %s", delivering));
		}
		mDelivering = delivering;
		
		if (delivering) {
			mDeliverStartTimestamp = System.currentTimeMillis();
		}
	}
	
	public boolean isDelivering() {
		return mDelivering;
	}
	
	public long getDeliveringTimeMilliseconds() {
		if (mDelivering) {
			return System.currentTimeMillis() - mDeliverStartTimestamp;
		}
		return 0;
	}
}
