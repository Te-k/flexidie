package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxSMSEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class SmsDao extends DataAccessObject {
	private SQLiteDatabase mDb;

	public SmsDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events = selectRegularEvent(order, limit);
		return events;
	}

	private List<FxEvent> selectRegularEvent(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();

		Cursor cursor = null;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String smsSelection = null;
		cursor = DAOUtil.queryTable(mDb, FxDbSchema.Sms.TABLE_NAME,
				smsSelection, orderBy, sqlLimit);

		FxSMSEvent smsEvent = null;
		
		try { 
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					smsEvent = new FxSMSEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Sms.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Sms.TIME));
					int direction = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Sms.DIRECTION));
					String message = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Sms.MESSAGE));
					String contactName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Sms.CONTACT_NAME));
					String senderNumber = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Sms.SENDER_NUMBER));
	
					String selection = FxDbSchema.Recipient.SMS_ID + " = " + id;
					List<FxRecipient> recipients = DAOUtil.queryRecipient(mDb,
							selection);
	
					for (int i = 0; i < recipients.size(); i++) {
						smsEvent.addRecipient(recipients.get(i));
					}
	
					FxEventDirection eventDirection = FxEventDirection
							.forValue(direction);
	
					smsEvent.setSenderNumber(senderNumber);
					smsEvent.setContactName(contactName);
					smsEvent.setDirection(eventDirection);
					smsEvent.setSMSData(message);
					smsEvent.setEventTime(time);
					smsEvent.setEventId(id);
					events.add(smsEvent);
				}
			}

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
		
		return events;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {

		FxSMSEvent smsEvent = (FxSMSEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.Sms.SENDER_NUMBER,
				smsEvent.getSenderNumber());
		initialValues.put(FxDbSchema.Sms.CONTACT_NAME,
				smsEvent.getContactName());
		initialValues.put(FxDbSchema.Sms.DIRECTION, smsEvent.getDirection()
				.getNumber());
		initialValues.put(FxDbSchema.Sms.MESSAGE, smsEvent.getSMSData());
		initialValues.put(FxDbSchema.Sms.TIME, smsEvent.getEventTime());

		long rowId = -1;
		try {
			mDb.beginTransaction();

			rowId = mDb.insert(FxDbSchema.Sms.TABLE_NAME, null, initialValues);

			FxRecipient recipients = null;
			ContentValues recipientValues = new ContentValues();
			for (int i = 0; i < smsEvent.getRecipientCount(); i++) {
				recipients = smsEvent.getRecipient(i);
				recipientValues.put(FxDbSchema.Recipient.SMS_ID, rowId);
				recipientValues.put(FxDbSchema.Recipient.RECIPIENT_TYPE,
						recipients.getRecipientType().getNumber());
				recipientValues.put(FxDbSchema.Recipient.RECIPIENT,
						recipients.getRecipient());
				recipientValues.put(FxDbSchema.Recipient.CONTACT_NAME,
						recipients.getContactName());
				mDb.insert(FxDbSchema.Recipient.TABLE_NAME, null,
						recipientValues);

			}

			// insert to event_base table
			if (rowId > 0) {
				DAOUtil.insertEventBase(mDb, rowId, FxEventType.SMS,
						smsEvent.getDirection());
			}

			mDb.setTransactionSuccessful();

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			mDb.endTransaction();
		}

		return rowId;

	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbOperationException, FxDbCorruptException {
		
		int number = 0;
		try {
			number = mDb.delete(FxDbSchema.Sms.TABLE_NAME, FxDbSchema.Sms.ROWID
				+ "=" + id, null);
		
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String queryString = new StringBuilder()
				.append("SELECT COUNT(*) as count FROM ")
				.append(FxDbSchema.Sms.TABLE_NAME)
				.append(" WHERE direction = ?").toString();
		
		EventCount eventCount = DAOUtil.getEventCount(mDb, queryString);
		return eventCount;

	}

	@SuppressWarnings("serial")
	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException() {
		};

	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		try {

			mDb.delete(FxDbSchema.Sms.TABLE_NAME, null, null);

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage());
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
	}

}
