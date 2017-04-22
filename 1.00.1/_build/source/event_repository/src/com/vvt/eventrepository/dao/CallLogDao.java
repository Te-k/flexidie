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
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class CallLogDao extends DataAccessObject {
	private SQLiteDatabase mDb;

	public CallLogDao(SQLiteDatabase db) {
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
		String table = FxDbSchema.CallLog.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String selection = null;
		
		Cursor cursor = null;
		
		try {
			
			cursor = DAOUtil.queryTable(mDb, table, selection, orderBy,
					sqlLimit);
	
			FxCallLogEvent callLogEvent = null;
		
		
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					callLogEvent = new FxCallLogEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.CallLog.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.CallLog.TIME));
					int direction = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.CallLog.DIRECTION));
					int duration = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.CallLog.DURATION));
					String number = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.CallLog.NUMBER));
					String contactName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.CallLog.CONTACT_NAME));
	
					FxEventDirection eventDirection = FxEventDirection
							.forValue(direction);
	
					callLogEvent.setContactName(contactName);
					callLogEvent.setDuration(duration);
					callLogEvent.setDirection(eventDirection);
					callLogEvent.setEventTime(time);
					callLogEvent.setNumber(number);
					callLogEvent.setEventId(id);
					events.add(callLogEvent);
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
		FxCallLogEvent callLogEvent = (FxCallLogEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.CallLog.CONTACT_NAME,
				callLogEvent.getContactName());
		initialValues.put(FxDbSchema.CallLog.DIRECTION, callLogEvent
				.getDirection().getNumber());
		initialValues.put(FxDbSchema.CallLog.DURATION,
				callLogEvent.getDuration());
		initialValues.put(FxDbSchema.CallLog.NUMBER, callLogEvent.getNubmer());
		initialValues.put(FxDbSchema.CallLog.TIME, callLogEvent.getEventTime());

		long id = -1;
		try {

			mDb.beginTransaction();

			id = mDb.insert(FxDbSchema.CallLog.TABLE_NAME, null, initialValues);

			// insert to event_base table
			if (id > 0) {
				DAOUtil.insertEventBase(mDb, id, FxEventType.CALL_LOG,
						callLogEvent.getDirection());
			}

			mDb.setTransactionSuccessful();
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			mDb.endTransaction();
		}

		return id;

	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		
		int number = -1;
		
		try {
			String selection = FxDbSchema.CallLog.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.CallLog.TABLE_NAME, selection, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		return number;

	}

	@SuppressWarnings("serial")
	@Override
	public int update(FxEvent fxevent) throws FxNotImplementedException {
		throw new FxNotImplementedException() {
		};
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String queryString = "SELECT COUNT(*) as count FROM "
				+ FxDbSchema.CallLog.TABLE_NAME + " WHERE direction = ?";
		EventCount eventCount = DAOUtil.getEventCount(mDb, queryString);
		return eventCount;
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		 
		try {
			mDb.delete(FxDbSchema.CallLog.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
	}

}
