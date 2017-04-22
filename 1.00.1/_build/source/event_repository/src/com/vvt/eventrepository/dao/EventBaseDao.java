package com.vvt.eventrepository.dao;

import java.util.List;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOperationException;

public class EventBaseDao extends DataAccessObject {
	private SQLiteDatabase mDb;

	public EventBaseDao(SQLiteDatabase db) {
		this.mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) {
		return null;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public int delete(long id) throws FxDbCorruptException, FxDbOperationException {
		/*throw new FxNotImplementedException();*/
		
		int number = 0;
		try {
			number = mDb.delete(FxDbSchema.EventBase.TABLE_NAME,
				FxDbSchema.EventBase.EVENT_ID + "=" + id, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
 
		return number;
		
	}

	public int getTotalEventCount() throws FxDbCorruptException, FxDbOperationException {
		// Total
		int totalCount = 0;
		String queryString = new StringBuilder()
				.append("SELECT COUNT(*) as count FROM ")
				.append(FxDbSchema.EventBase.TABLE_NAME).toString();

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

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {

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
				.append(FxDbSchema.EventBase.TABLE_NAME).toString();

		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(queryString, null);
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				totalCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// In
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME)
					.append(" WHERE direction = ?").toString();
	
			cursor = mDb.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.IN.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				inCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// Out
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME)
					.append(" WHERE direction = ?").toString();
	
			cursor = mDb.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.OUT.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				outCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// Missed
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME)
					.append(" WHERE direction = ?").toString();
	
			cursor = mDb.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.MISSED_CALL.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				missedCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// unknown
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME)
					.append(" WHERE direction = ?").toString();
	
			cursor = mDb.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.UNKNOWN.getNumber()) });
	
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				unknownCount = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			if (cursor != null)
				cursor.close();
	
			// IM
			queryString = new StringBuilder()
					.append("SELECT COUNT(*) as count FROM ")
					.append(FxDbSchema.EventBase.TABLE_NAME)
					.append(" WHERE direction = ?").toString();
	
			cursor = mDb.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.LOCAL_IM.getNumber()) });
	
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

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
	
		try {
			mDb.delete(FxDbSchema.EventBase.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
	}

}
