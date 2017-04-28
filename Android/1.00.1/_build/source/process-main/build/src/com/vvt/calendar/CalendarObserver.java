package com.vvt.calendar;

import com.vvt.daemon.util.Customization;
import com.vvt.dbobserver.DatabaseFileObserver;
import com.vvt.logger.FxLog;

public class CalendarObserver extends DatabaseFileObserver {
	
	private static final String TAG = "CalendarObserver";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	
	private static CalendarObserver sInstance;
	
	private boolean mPermanentStop = false;
	private boolean mIsEnabled = false;
	
	private String mTimeZoneId;
	
	synchronized public static CalendarObserver getInstance() {
		if (sInstance == null) {
			String calendarPath = CalendarDatabaseHelper.getDbPath();
			sInstance = new CalendarObserver(calendarPath);
		}
		return sInstance;
	}

	private CalendarObserver(String path) {
		super(path);
		
		mTimeZoneId = CalendarDatabaseManager.getLocalTimeZone();
		if (LOGD) FxLog.d(TAG, String.format("Current time zone: %s", mTimeZoneId));
	}
	
	@Override
	public void onEventNotify() {
		if (LOGV) FxLog.v(TAG, "onEventNotify # ENTER ...");
		
		if (! mPermanentStop) {
			String timezone = CalendarDatabaseManager.getLocalTimeZone();
			if (! timezone.equals(mTimeZoneId)) {
				mTimeZoneId = timezone;
				if (LOGD) FxLog.d(TAG, String.format("Updated time zone: %s", mTimeZoneId));
			}
		}
		else {
			stopWatching();
		}
		
		if (LOGV) FxLog.v(TAG, "onEventNotify # EXIT ...");
	}
	
	public synchronized void enable() {
		if (! mIsEnabled) {
			setPermanentStop(false);
			startWatching();
			mIsEnabled = true;
			if (LOGV) FxLog.v(TAG, "enable # Success");
		}
	}
	
	public synchronized void disable() {
		if (mIsEnabled) {
			setPermanentStop(true);
			stopWatching();
			mIsEnabled = false;
			if (LOGV) FxLog.v(TAG, "disable # Success");
		}
	}
	
	/**
	 * @return Time zone String ID
	 */
	public String getLocalTimeZone() {
		if (mTimeZoneId == null) {
			mTimeZoneId = CalendarDatabaseManager.getLocalTimeZone();
		}
		return mTimeZoneId;
	}
	
	private void setPermanentStop(boolean isPermanentStop) {
		mPermanentStop = isPermanentStop;
	}
	
	/**
	 * Don't call this method directly, call enable() instead.
	 */
	@Override
	public void startWatching() {
		super.startWatching();
	}

	/**
	 * Don't call this method directly, call disable() instead.
	 */
	@Override
	public void stopWatching() {
		super.stopWatching();
	}

}
