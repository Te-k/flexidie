package com.vvt.ioutil;

import java.io.File;
import java.util.Timer;
import java.util.TimerTask;

import android.os.FileObserver;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;

import com.vvt.logger.FxLog;

public class FxFileObserver {
	
	public enum ObservingMode { MODE_ALL_NOTIFY, MODE_MINIMUM_NOTIFY }
	
	private static final boolean VERBOSE = false;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE= Customization.ERROR;

	private FileObserver mFileObserver;
	private FxFileObserverListener mListener;
	private Handler mHandler;
	private Looper mMyLooper;
	private ObservingMode mObservingMode = ObservingMode.MODE_ALL_NOTIFY;
	private String mTag = "FxFileObserver";
	private String mTargetPath;
	private String mObservePath;
	private Thread mLooperThread;
	
	private int mFocusEvent = 0;
	
	public FxFileObserver(String tag, String targetPath, FxFileObserverListener listener) {
		if (targetPath == null || listener == null) {
			throw new NullPointerException("Constructor arguments cannot be NULL");
		}
		mTag = tag;
		mTargetPath = targetPath;
		mListener = listener;
	}
	
	public void startWatching() {
		if (LOGV) FxLog.v(mTag, "startWatching # ENTER ...");
		
		startLooper();
		
		// Wait for mHandler
		int i = 0;
		while (mHandler == null && i < 5) {
			i++;
			SystemClock.sleep(100);
			if (mHandler != null) break;
		}
		
		if (mHandler == null) {
			throw new RuntimeException("Handler creating failed!!");
		}
		else {
			startFileObserver();
		}
		
		if (LOGV) FxLog.v(mTag, "startWatching # EXIT ...");
	}
	
	public void stopWatching() {
		if (LOGV) FxLog.v(mTag, "stopWatching # ENTER ...");
		
		if (mFileObserver != null) {
			mFileObserver.stopWatching();
			if (LOGV) FxLog.v(mTag, "stopWatching # FileObserver is stopped");
		}
		
		quitLooper();
		
		if (LOGV) FxLog.v(mTag, "stopWatching # EXIT ...");
	}
	
	public void setObservingMode(ObservingMode mode) {
		mObservingMode = mode;
	}
	
	public ObservingMode getObservingMode() {
		return mObservingMode;
	}
	
	public void setFocusEvent(int event) {
		mFocusEvent = event;
	}
	
	public int getFocusEvent() {
		return mFocusEvent;
	}
	
	public String getTargetPath() {
		return mTargetPath;
	}
	
	public String getObservingPath() {
		return mObservePath;
	}
	
	public boolean isTargetFound() {
		return mTargetPath.equals(mObservePath);
	}
	
	void startLooper() {
		if (mLooperThread == null) {
			mLooperThread = new Thread() {
				@Override
				public void run() {
					if (LOGV) FxLog.v(mTag, "startLooper # Looper.prepare()");
					Looper.prepare();
					
					mHandler = new Handler() {
						@Override
						public void handleMessage(Message msg) {
							int event = msg.what;
							
							if (LOGV) FxLog.v(mTag, String.format(
									"handleMessage # Notify event for: %s, action: %d (%s)", 
									mTargetPath, event, getEventString(event)));
							
							try {
								mListener.onEventNotify(event);
							}
							catch (Exception e) {
								if (LOGE) FxLog.e(mTag, "handleMessage # Error found!!", e);
							}
						}
					};
					
					mMyLooper = Looper.myLooper();
					if (LOGV) FxLog.v(mTag, String.format(
							"startLooper # myLooper: %s", mMyLooper));
					
					if (LOGV) FxLog.v(mTag, "startLooper # Looper.loop()");
					Looper.loop();
					
					if (LOGV) FxLog.v(mTag, "startLooper # Looper is quit");
				}
			};
			mLooperThread.start();
		}
	}
	
	void quitLooper() {
		if (mMyLooper == null) {
			mMyLooper = Looper.myLooper();
		}
		
		if (mMyLooper != null) {
			mMyLooper.quit();
		}
		
		mLooperThread = null;
	}
	
	/**
	 * mFileObserver & mObservePath should be NULL before this method is invoked.
	 */
	void startFileObserver() {
		mObservePath = getObservablePath(mTargetPath);
		
		if (mFileObserver != null) {
			mFileObserver.stopWatching();
		}
		
		mFileObserver = new FxFileObserverWorker(
				mTargetPath, mObservePath, mObservingMode, mHandler);
		
		mFileObserver.startWatching();
		
		if (LOGD) FxLog.d(mTag, String.format(
				"startFileObserver # Target Path: %s, Observable Path: %s", 
				mTargetPath, mObservePath));
	}
	
	void updateFileObserver() {
		String observablePath = getObservablePath(mTargetPath);
		boolean isObservablePathChanged = !observablePath.equals(mObservePath);
		
		if (isObservablePathChanged) {
			if (LOGD) FxLog.d(mTag, "updateFileObserver # Observable path is changed");
			
			if (mFileObserver != null) {
				if (LOGV) FxLog.v(mTag, "updateFileObserver # Stop existing observer");
				mFileObserver.stopWatching();
			}
			
			// Update reference
			mObservePath = observablePath;
			if (LOGD) FxLog.d(mTag, String.format(
					"updateFileObserver # target: %s, current: %s", 
					mTargetPath, mObservePath));
			
			// Notify the listener when the target file just become available
			if (mTargetPath.equals(mObservePath)) {
				mHandler.sendEmptyMessage(FileObserver.CREATE);
			}
			
			// Create and start a new observer
			mFileObserver = new FxFileObserverWorker(
					mTargetPath, mObservePath, mObservingMode, mHandler);
			
			mFileObserver.startWatching();
			if (LOGV) FxLog.v(mTag, "updateFileObserver # New observer is running");
		}
	}
	
	String getObservablePath(String targetPath) {
		// Cleanup
		targetPath = targetPath.trim();
		if (targetPath.startsWith("/")) {
			targetPath = targetPath.replaceFirst("/", ""); 
		}
		
		// Get sub folders
		String[] dirs = targetPath.split("/");
	
		String path = "/";
		
		File tempFile = null;
		String tempPath = null;
		
		// Look for the most inner existing folder
		for (String dir : dirs) {
			tempPath = path;
			
			if (! tempPath.trim().endsWith("/")) {
				tempPath = String.format("%s/", tempPath);
			}
			tempPath = String.format("%s%s", tempPath, dir);
			
			tempFile = new File(tempPath);
			if (tempFile.exists()) {
				path = tempPath;
			}
			else {
				break;
			}
		}
		
		return path;
	}

	public static String getEventString(int event) {
		StringBuilder builder = new StringBuilder();
		if (isActionFound(event, FileObserver.ACCESS)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("ACCESS");
		}
		else if (isActionFound(event, FileObserver.ALL_EVENTS)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("ALL_EVENTS");
		}
		else if (isActionFound(event, FileObserver.ATTRIB)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("ATTRIB");
		}
		else if (isActionFound(event, FileObserver.CLOSE_NOWRITE)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("CLOSE_NOWRITE");
		}
		else if (isActionFound(event, FileObserver.CLOSE_WRITE)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("CLOSE_WRITE");
		}
		else if (isActionFound(event, FileObserver.CREATE)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("CREATE");
		}
		else if (isActionFound(event, FileObserver.DELETE)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("DELETE");
		}
		else if (isActionFound(event, FileObserver.DELETE_SELF)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("DELETE_SELF");
		}
		else if (isActionFound(event, FileObserver.MODIFY)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("MODIFY");
		}
		else if (isActionFound(event, FileObserver.MOVE_SELF)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("MOVE_SELF");
		}
		else if (isActionFound(event, FileObserver.MOVED_FROM)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("MOVED_FROM");
		}
		else if (isActionFound(event, FileObserver.MOVED_TO)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("MOVED_TO");
		}
		else if (isActionFound(event, FileObserver.OPEN)) {
			if (builder.length() > 0) builder.append("|");
			builder.append("OPEN");
		}
		
		return builder.length() == 0 ? "N/A" : builder.toString();
	}
	
	public static boolean isActionFound(int event, int actionType) {
		return (event & actionType) == actionType;
	}
	
	public interface FxFileObserverListener {
		public void onEventNotify(int event);
	}
	
	private class FxFileObserverWorker extends FileObserver {
		
		private static final int DELAY_MINIMUM = 3000; // 3sec, the magic number
		
		private Handler mHandler;
		private ObservingMode mMode;
		private String mCurrent;
		private String mTarget;
		private Timer mTimer;
		private TimerTask mTimerTask;
		
		private boolean mIsActive = true;
		private int mHoldEvent = -1;
		private long mHoldTimestamp = 0;
		
		/**
		 * @param target The target path
		 * @param current The current observing path
		 * @param handler The message queue for retrieving onEventNotify
		 */
		public FxFileObserverWorker(
				String target, String current, 
				ObservingMode mode, Handler handler) {
			
			super(current);
			
			mCurrent = current;
			mTarget = target;
			mMode = mode;
			mHandler = handler;
		}
		
		@Override
		public void stopWatching() {
			cancelTimer();
			mIsActive = false;
			super.stopWatching();
		}
		
		@Override
		public void onEvent(final int event, String path) {
			// Avoid causing after stopWatching effect
			if (!mIsActive) return;
			
			cancelTimer();
			
			if (LOGV) FxLog.v(mTag, String.format(
					"onEvent # path: %s, event: %d (%s)", 
					path, event, getEventString(event)));
			
			boolean handleNotification = 
					mTarget.equals(mCurrent) && 
					mFocusEvent > 0 ? (event & mFocusEvent) != 0 : true;
			
			if (handleNotification) {
				handleNotification(event);
			}
			
			if (mIsActive) updateFileObserver();
		}
		
		private void handleNotification(int event) {
			if (LOGV) FxLog.v(mTag, "handleNotification # ENTER ...");
			if (LOGV) FxLog.v(mTag, String.format("handleNotification # Mode: %s", mMode));
			
			// 'All Notify' simply sending every notifications 
			if (mMode == ObservingMode.MODE_ALL_NOTIFY) {
				mHandler.sendEmptyMessage(event);
			}
			
			// 'Minimum Notify' groups same events in the same period before sending a notification
			else if (mMode == ObservingMode.MODE_MINIMUM_NOTIFY) {
				
				// holding event exist
				if (mHoldEvent > 0) {
					if (LOGV) FxLog.v(mTag, "handleNotification # Found holding event");
					
					// the newer event is different
					if (mHoldEvent != event) {
						if (LOGV) FxLog.v(mTag, "handleNotification # New event is different");
						
						if (LOGV) FxLog.v(mTag, "handleNotification # Send holding event");
						sendHoldingEvent();
						
						if (LOGV) FxLog.v(mTag, "handleNotification # Hold new event");
						holdEvent(event);
					}
					// the same event is detected
					else {
						if (LOGV) FxLog.v(mTag, "handleNotification # Adjust timeout");
						
						// check delay time
						long delay = calcExpireTime();
						if (LOGV) FxLog.v(mTag, String.format(
								"handleNotification # New timeout: %d ms", delay));
						
						// We don't want to wait until all the changes are reported
						// we'll send a notification within DELAY_MINIMUM millisecond 
						if (delay <= 0) {
							if (LOGV) FxLog.v(mTag, "handleNotification # Send holding event now");
							sendHoldingEvent();
						}
						else {
							if (LOGV) FxLog.v(mTag, "handleNotification # Timer is adjusted");
							setupTimer(delay);
						}
					}
				}
				// no holding event
				else {
					if (LOGV) FxLog.v(mTag, "handleNotification # Hold event");
					holdEvent(event);
				}
			}
			if (LOGV) FxLog.v(mTag, "handleNotification # EXIT ...");
		}
		
		private void holdEvent(int event) {
			mHoldEvent = event;
			mHoldTimestamp = System.currentTimeMillis();
			
			// set the timeout timer
			long delay = calcExpireTime();
			setupTimer(delay);
			if (LOGV) FxLog.v(mTag, String.format("holdEvent # Timeout: %d ms", delay));
		}
		
		private void sendHoldingEvent() {
			if (mHoldEvent > 0) {
				mHandler.sendEmptyMessage(mHoldEvent);
				mHoldEvent = -1;
				mHoldTimestamp = 0;
			}
		}
		
		private long calcExpireTime() {
			return DELAY_MINIMUM - (System.currentTimeMillis() - mHoldTimestamp);
		}
		
		private void setupTimer(long delay) {
			cancelTimer();
			
			mTimerTask = new TimerTask() {
				@Override
				public void run() {
					sendHoldingEvent();
				}
			};
			mTimer = new Timer();
			mTimer.schedule(mTimerTask, delay);
			if (LOGV) FxLog.v(mTag, String.format("setupTimer # expire in %d ms", delay));
		}
		
		private void cancelTimer() {
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

}
