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
import com.vvt.events.FxIMEvent;
import com.vvt.events.FxParticipant;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class IMDao extends DataAccessObject {
	
	@SuppressWarnings("unused")
	private static final String TAG = "IMDao";
	private SQLiteDatabase mDb;
	
	public IMDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();
		Cursor cursor = null;
		String table = FxDbSchema.IM.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String selection = null;
		
		try {
			cursor = DAOUtil.queryTable(mDb, table, selection, orderBy, sqlLimit);
			
			FxIMEvent imEvent = null;
			
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					imEvent = new FxIMEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.IM.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.IM.TIME));
					int direction = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.IM.DIRECTION));
					String im_service_id = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.IM.IM_SERVICE_ID));
					String user_display_name = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.IM.USER_DISPLAY_NAME));
					String user_id = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.IM.USER_ID));
					String message = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.IM.MESSAGE));
					
					String selectParticipant = FxDbSchema.ParticipantsColumns.IM_ID + " = " + id;
					List<FxParticipant> participants = DAOUtil.queryPaticipant(mDb,
							selectParticipant);
	
					for (int i = 0; i < participants.size(); i++) {
						imEvent.addParticipant(participants.get(i));
					}
					
					FxEventDirection eventDirection = FxEventDirection
							.forValue(direction);
	
					imEvent.setEventDirection(eventDirection);
					imEvent.setUserDisplayName(user_display_name);
					imEvent.setEventTime(time);
					imEvent.setImServiceId(im_service_id);
					imEvent.setEventId(id);
					imEvent.setUserId(user_id);
					imEvent.setMessage(message);
					events.add(imEvent);
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
		FxIMEvent imEvent = (FxIMEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.IM.IM_SERVICE_ID, imEvent.getImServiceId());
		initialValues.put(FxDbSchema.IM.MESSAGE, imEvent.getMessage());
		initialValues.put(FxDbSchema.IM.DIRECTION, imEvent.getEventDirection().getNumber());
		initialValues.put(FxDbSchema.IM.TIME, imEvent.getEventTime());
		initialValues.put(FxDbSchema.IM.USER_DISPLAY_NAME, imEvent.getUserDisplayName());
		initialValues.put(FxDbSchema.IM.USER_ID, imEvent.getUserId());
		
		long rowId = -1;
		try {
			mDb.beginTransaction();

			rowId = mDb.insert(FxDbSchema.IM.TABLE_NAME, null, initialValues);
			
			FxParticipant participant = null;
			ContentValues participantValues = new ContentValues();
			for (int i = 0; i < imEvent.getParticipantCount(); i++) {
				participant = imEvent.getParticipant(i);
				participantValues.put(FxDbSchema.ParticipantsColumns.IM_ID, rowId);
				participantValues.put(FxDbSchema.ParticipantsColumns.NAME, participant.getName());
				participantValues.put(FxDbSchema.ParticipantsColumns.UID, participant.getUid());
				mDb.insert(FxDbSchema.ParticipantsColumns.TABLE_NAME, null,
						participantValues);

			}

			// insert to event_base table
			if (rowId > 0) {
				DAOUtil.insertEventBase(mDb, rowId, FxEventType.IM,
						imEvent.getEventDirection());
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
	public int delete(long id) throws FxDbIdNotFoundException, FxDbOperationException,FxDbCorruptException {
		int number = -1; 
		try {
			String selection = FxDbSchema.IM.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.IM.TABLE_NAME,selection, null);
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
				+ FxDbSchema.IM.TABLE_NAME + " WHERE direction = ?";
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
	public void deleteAll() throws FxDbCorruptException, FxDbOperationException {
		try {
			mDb.delete(FxDbSchema.IM.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
	}

}
