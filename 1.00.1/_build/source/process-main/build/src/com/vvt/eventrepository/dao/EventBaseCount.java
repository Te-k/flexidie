package com.vvt.eventrepository.dao;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.base.FxEventType;
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.databasemanager.FxDbSchema.EventBase;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOperationException;

public class EventBaseCount {
	private SQLiteDatabase mDb;

	public EventBaseCount(SQLiteDatabase db) {
		this.mDb = db;
	}

	public int getTotalEventCount() throws FxDbCorruptException, FxDbOperationException {
		// Total
		int totalCount = 0;
		String queryString = new StringBuilder()
				.append("SELECT COUNT(*) as count FROM ")
				.append(FxDbSchema.EventBase.TABLE_NAME)
				.append(" WHERE ")
				.append(FxDbSchema.EventBase.EVENT_TYPE)
				.append(" != ")
				.append(FxEventType.SYSTEM.getNumber()).toString();
				
		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(queryString, null);
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				totalCount = cursor.getInt(cursor.getColumnIndex("count"));
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

		return totalCount;
	}

	public EventCount countEvent(FxEventType eventType) throws FxDbCorruptException, FxDbOperationException {
		EventCount eventCount = new EventCount();
		int inCount = 0;
		int outCount = 0;
		int missedCount = 0;
		int unknownCount = 0;
		int totalCount = 0;
		int local_im = 0;

		// Total
		String queryString = new StringBuilder()
				.append("SELECT COUNT(*) as count FROM ")
				.append(FxDbSchema.EventBase.TABLE_NAME).append(" WHERE ")
				.append(EventBase.EVENT_TYPE).append(" = ?").toString();

		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(queryString,
					new String[] { Integer.toString(eventType.getNumber()) });
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				totalCount = cursor.getInt(cursor.getColumnIndex("count"));
			}

			if (cursor != null)
				cursor.close();

			// In
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME).append(" WHERE ")
					.append(EventBase.EVENT_TYPE).append(" = ?").append(" AND ")
					.append(EventBase.DIRECTION).append(" = ?").toString();
	
			cursor = mDb.rawQuery(
					queryString,
					new String[] { Integer.toString(eventType.getNumber()),
							Integer.toString(FxEventDirection.IN.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				inCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// Out
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME).append(" WHERE ")
					.append(EventBase.EVENT_TYPE).append(" = ?").append(" AND ")
					.append(EventBase.DIRECTION).append(" = ?").toString();
	
			cursor = mDb.rawQuery(
					queryString,
					new String[] { Integer.toString(eventType.getNumber()),
							Integer.toString(FxEventDirection.OUT.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				outCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// Missed
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME).append(" WHERE ")
					.append(EventBase.EVENT_TYPE).append(" = ?").append(" AND ")
					.append(EventBase.DIRECTION).append(" = ?").toString();
	
			cursor = mDb.rawQuery(
					queryString,
					new String[] {
							Integer.toString(eventType.getNumber()),
							Integer.toString(FxEventDirection.MISSED_CALL
									.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				missedCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// unknown
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME).append(" WHERE ")
					.append(EventBase.EVENT_TYPE).append(" = ?").append(" AND ")
					.append(EventBase.DIRECTION).append(" = ?").toString();
	
			cursor = mDb
					.rawQuery(
							queryString,
							new String[] {
									Integer.toString(eventType.getNumber()),
									Integer.toString(FxEventDirection.UNKNOWN
											.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				unknownCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// IM
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME).append(" WHERE ")
					.append(EventBase.EVENT_TYPE).append(" = ?").append(" AND ")
					.append(EventBase.DIRECTION).append(" = ?").toString();
	
			cursor = mDb
					.rawQuery(
							queryString,
							new String[] {
									Integer.toString(eventType.getNumber()),
									Integer.toString(FxEventDirection.LOCAL_IM
											.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				local_im = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		eventCount.setInCount(inCount);
		eventCount.setLocal_im(local_im);
		eventCount.setMissedCount(missedCount);
		eventCount.setOutCount(outCount);
		eventCount.setTotalCount(totalCount);
		eventCount.setUnknownCount(unknownCount);

		return eventCount;
	}

}
