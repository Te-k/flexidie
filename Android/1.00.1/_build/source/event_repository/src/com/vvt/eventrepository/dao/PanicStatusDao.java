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
import com.vvt.events.FxPanicStatusEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class PanicStatusDao extends DataAccessObject {

	private static final String TAG = "PanicStatusDao";
	
	private SQLiteDatabase mDb;

	public PanicStatusDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) {
		List<FxEvent> events = new ArrayList<FxEvent>();
		String table = FxDbSchema.Panic.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);

		FxPanicStatusEvent panicStatusEvent = null;
		Cursor cursor = null;
		try {
			cursor = mDb.query(table, null, null, null, null, null, orderBy,
					sqlLimit);
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					panicStatusEvent = new FxPanicStatusEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Panic.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Panic.TIME));
					int status = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Panic.PANIC_STATUS));
	
					boolean panicStatus = (status == 1) ? true : false;
	
					panicStatusEvent.setEventId(id);
					panicStatusEvent.setEventTime(time);
					panicStatusEvent.setStatus(panicStatus);
					events.add(panicStatusEvent);
	
				}
			}

		} catch (Exception e) {
			FxLog.e(TAG, "select # "+e.getMessage());
			
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		return events;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {
		FxPanicStatusEvent panicStatusEvent = (FxPanicStatusEvent) fxevent;
		int panicStatus = (panicStatusEvent.getStatus()) ? 1 : 2;

		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.Panic.PANIC_STATUS, panicStatus);
		initialValues.put(FxDbSchema.Panic.TIME,
				panicStatusEvent.getEventTime());

		long id = -1;
		try {

			mDb.beginTransaction();

			id = mDb.insert(FxDbSchema.Panic.TABLE_NAME, null, initialValues);

			// insert to event_base table
			if (id > 0) {
				DAOUtil.insertEventBase(mDb, id, FxEventType.PANIC_STATUS,
						FxEventDirection.UNKNOWN);
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
		
		int number = 0;
		
		try { 
			String selection = FxDbSchema.CallLog.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.Panic.TABLE_NAME, selection, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}

		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String queryString = "SELECT COUNT(*) as count FROM "
				+ FxDbSchema.Panic.TABLE_NAME;
		int total = 0;
		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(queryString, null);
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				total = cursor.getInt(cursor.getColumnIndex("count"));
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

		EventCount eventCount = new EventCount();
		eventCount.setInCount(0);
		eventCount.setLocal_im(0);
		eventCount.setMissedCount(0);
		eventCount.setOutCount(0);
		eventCount.setUnknownCount(0);
		eventCount.setTotalCount(total);
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
			mDb.delete(FxDbSchema.Panic.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}

		 
	}

}
