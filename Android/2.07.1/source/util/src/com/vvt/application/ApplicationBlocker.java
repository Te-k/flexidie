package com.vvt.application;

import java.util.HashSet;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;

import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

public final class ApplicationBlocker {
	
	private static final String TAG = "ApplicationBlocker"; 
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final int DEFAULT_DELAY = 100;
	private static final int DEFAULT_PERIOD = 500;

	private Context mContext;
	private HashSet<String> mBlockingPackages;
	private Timer mTimer;
	private TimerTask mTimerTask;
	
	public ApplicationBlocker(Context context) {
		mContext = context;
		mBlockingPackages = new HashSet<String>();
	}
	
	public boolean addPackage(String packageName) {
		boolean isSuccess = false;
		
		synchronized (mBlockingPackages) {
			isSuccess = mBlockingPackages.add(packageName);
			if (LOGV) FxLog.v(TAG, String.format(
					"Current blocking packages: %s", mBlockingPackages));
		}
		
		return isSuccess;
	}
	
	public boolean removeBlockingPackage(String packageName) {
		boolean isSuccess = false;
		
		synchronized (mBlockingPackages) {
			isSuccess = mBlockingPackages.remove(packageName);
			if (LOGV) FxLog.v(TAG, String.format(
					"Current blocking packages: %s", mBlockingPackages));
		}
		
		return isSuccess;
	}
	
	public void startBlocking() {
		stopBlocking();
		
		mTimerTask = new TimerTask() {
			@Override
			public void run() {
				List<String> foregroundApps = 
						ApplicationUtil.getForegroundPackages(mContext);
				
				synchronized (mBlockingPackages) {
					for (String pkgName : mBlockingPackages) {
						if (foregroundApps.contains(pkgName)) {
							ApplicationUtil.switchToHome(mContext);
							break;
						}
					}
				}
			}
		};
		mTimer = new Timer();
		mTimer.schedule(mTimerTask, DEFAULT_DELAY, DEFAULT_PERIOD);
	}
	
	public void stopBlocking() {
		if (mTimerTask != null) {
			mTimerTask.cancel();
			mTimerTask = null;
		}
		if (mTimer != null) {
			mTimer.cancel();
			mTimer = null;
		}
	}
}
