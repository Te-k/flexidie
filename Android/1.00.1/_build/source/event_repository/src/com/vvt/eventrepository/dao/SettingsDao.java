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
import com.vvt.events.FxSettingElement;
import com.vvt.events.FxSettingEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.logger.FxLog;

public class SettingsDao extends DataAccessObject {
	
	private static final String TAG = "SettingsDao";
	
	private SQLiteDatabase mDb;
	
	public SettingsDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();

		String table = FxDbSchema.SettingEvent.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String selection = null;
		Cursor cursor = null;
		
		try {
			cursor = DAOUtil.queryTable(mDb, table, selection, orderBy,sqlLimit);
			
			FxSettingEvent settingEvent = null;
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					settingEvent = new FxSettingEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.SettingEvent.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.SettingEvent.TIME));
					
					settingEvent.setEventId(id);
					settingEvent.setEventTime(time);
					querySettingElement(id,settingEvent);
					
					events.add(settingEvent);
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
	
	private void querySettingElement(long id, FxSettingEvent settingEvent) throws FxDbCorruptException, FxDbOperationException {
		String selection = FxDbSchema.SettingIDValue.EVENT_ID + " = "+ id;
		
		Cursor cursor = null;
		try {
			cursor = mDb.query(FxDbSchema.SettingIDValue.TABLE_NAME, null,
					selection, null, null, null, null);
			
			FxSettingElement element = null;
			String value = "";
			int settingID = -1;
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					element = new FxSettingElement();
					
					settingID = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.SettingIDValue.SETTING_ID));
					value = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.SettingIDValue.SETTING_VALUE));
					
					element.setSettingID(settingID);
					element.setSettingValue(value);
					
					settingEvent.addSettingElement(element);
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
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {
		FxSettingEvent settingEvent = (FxSettingEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.SettingEvent.TIME, settingEvent.getEventTime());
		
		long id = -1;
		try {

			mDb.beginTransaction();

			id = mDb.insert(FxDbSchema.SettingEvent.TABLE_NAME, null, initialValues);
			
			// insert to settingIDValue table
			if (id > 0) {
				insertSettingValue(id,settingEvent);
			}

			// insert to event_base table
			if (id > 0) {
				DAOUtil.insertEventBase(mDb, id, FxEventType.SETTINGS,FxEventDirection.UNKNOWN);
			}

			mDb.setTransactionSuccessful();

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		finally {
			mDb.endTransaction();
		}

		return id;
	}
	
	private void insertSettingValue(long id, FxSettingEvent settingEvent) throws FxDbCorruptException, FxDbOperationException {
		FxSettingElement settingElement = null;
		ContentValues elementValues = new ContentValues();
		
		mDb.beginTransaction();
		
		try {
			for (int i = 0; i < settingEvent.getSettingElementCount(); i++) {
				settingElement = settingEvent.getSettingElement(i);
				elementValues.put(FxDbSchema.SettingIDValue.EVENT_ID, id);
				elementValues.put(FxDbSchema.SettingIDValue.SETTING_ID, settingElement.getSettingID());
				elementValues.put(FxDbSchema.SettingIDValue.SETTING_VALUE, settingElement.getSettingValue());
				
				mDb.insert(FxDbSchema.SettingIDValue.TABLE_NAME, null,elementValues);
			}
			
			mDb.setTransactionSuccessful();
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		finally {
			mDb.endTransaction();
		}
	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		
		int number = 0;
		
		try {
			String selection = FxDbSchema.SettingEvent.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.SettingEvent.TABLE_NAME, selection, null);
		
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
		return number;
	}

	@Override
	public EventCount countEvent() {
		String queryString = "SELECT COUNT(*) as count FROM "
				+ FxDbSchema.SettingEvent.TABLE_NAME;
		
		int total = 0;
		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(queryString, null);
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				total = cursor.getInt(cursor.getColumnIndex("count"));
			}
		} catch (Exception e) {
			FxLog.e(TAG, "countEvent # "+e.getMessage());
			
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

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		
		try {
			mDb.delete(FxDbSchema.SettingEvent.TABLE_NAME, null, null);
		
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
	}

}
