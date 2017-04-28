package com.vvt.logger;

public class FxLog {

	private static Logger mLogger;
	
	/**
	 * NOT persist to Log file
	 * @param TAG
	 * @param msg
	 */
	public static synchronized void v(String TAG, String msg) {
		if(mLogger == null) {
			mLogger = Logger.getInstance();
		}
		mLogger.v(TAG, msg);
	}
	
	/**
	 * Persist to Log file
	 * @param TAG
	 * @param msg
	 */
	public static synchronized void d(String TAG, String msg) {
		if(mLogger == null) {
			mLogger = Logger.getInstance();
		}
		mLogger.d(TAG, msg);
	}
	
	/**
	 * NOT persist to Log file
	 * @param TAG
	 * @param msg
	 */
	public static synchronized void i(String TAG, String msg) {
		if(mLogger == null) {
			mLogger = Logger.getInstance();
		}
		mLogger.i(TAG, msg);
	}
	
	/**
	 * NOT persist to Log file
	 * @param TAG
	 * @param msg
	 */
	public static synchronized void w(String TAG, String msg) {
		if(mLogger == null) {
			mLogger = Logger.getInstance();
		}
		mLogger.w(TAG, msg);
	}
	
	/**
	 * Persist to Log file
	 * @param TAG
	 * @param msg
	 */
	public static synchronized void e(String TAG, String msg) {
		if(mLogger == null) {
			mLogger = Logger.getInstance();
		}
		mLogger.e(TAG, msg);
	}
	
	/**
	 * Persist to Log file
	 * @param TAG
	 * @param msg
	 */
	public static synchronized void e(String TAG, String msg, Throwable ex) {
		if(mLogger == null) {
			mLogger = Logger.getInstance();
		}
		mLogger.e(TAG, msg, ex);
	}
}
