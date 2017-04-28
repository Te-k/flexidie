package com.fx.maind.delivery;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public class DeliveryState {

	private static final String TAG = "DeliveryState";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
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
