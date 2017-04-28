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
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMediaType;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class AudioFileThumbnailDao extends DataAccessObject {
	
	private static final String TAG = "AudioFileThumbnailDao";
	private SQLiteDatabase mDb;

	public AudioFileThumbnailDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();

		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String eventType = Integer.toString(FxEventType.AUDIO_FILE.getNumber());
		String sqlString = new StringBuilder()
				.append(DAOSqlHelper.AUDIO_FILE_THUMBNAIL_SQL_STRING)
				.append(" ORDER BY media.").append(orderBy).append(" LIMIT ")
				.append(sqlLimit).toString();
		
		Cursor cursor = null;
		
		try {
			cursor = mDb.rawQuery(sqlString, new String[] { eventType });
	
			FxAudioFileThumnailEvent audioFileThumnailEvent = null;

			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					audioFileThumnailEvent = new FxAudioFileThumnailEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Media.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Media.TIME));
					String ac_fullPath = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Media.FULL_PATH_ALIAS));
					int actualSize = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_SIZE));
					int actualDuration = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_DURATION));
					// No thumbnail
					// String tn_fullPath =
					// cursor.getString(cursor.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH_ALIAS));
	
					// thumbnail media type
					FxMediaType mediaType = FxMediaType.UNKNOWN;
	
					audioFileThumnailEvent.setActualFullPath(ac_fullPath);
					audioFileThumnailEvent.setActualDuration(actualDuration);
					audioFileThumnailEvent.setActualFileSize(actualSize);
					audioFileThumnailEvent.setAudioData(new byte[] {});
					audioFileThumnailEvent.setEventId(id);
					audioFileThumnailEvent.setEventTime(time);
					audioFileThumnailEvent.setFormat(mediaType);
					audioFileThumnailEvent.setParingId(id);
					events.add(audioFileThumnailEvent);
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
		FxAudioFileThumnailEvent audioFileThumnailEvent = (FxAudioFileThumnailEvent) fxevent;

		long mediaId = -1;
		try {
			mDb.beginTransaction();

			mediaId = insertMediaTable(audioFileThumnailEvent);
			insertThumbnailTable(mediaId, audioFileThumnailEvent);

			// insert to event_base table
			if (mediaId > 0) {
				DAOUtil.insertEventBase(mDb, mediaId, FxEventType.AUDIO_FILE,
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

		return mediaId;
	}

	private long insertMediaTable(
			FxAudioFileThumnailEvent audioFileThumnailEvent)  throws FxDbCorruptException, FxDbOperationException {

		ContentValues mediaValues = new ContentValues();
		mediaValues.put(FxDbSchema.Media.HAS_THUMBNAIL, 0);
		mediaValues.put(FxDbSchema.Media.THUMBNAIL_DELIVERED, 0);
		mediaValues.put(FxDbSchema.Media.TIME,
				audioFileThumnailEvent.getEventTime());
		mediaValues.put(FxDbSchema.Media.FULL_PATH,
				audioFileThumnailEvent.getActualFullPath());
		mediaValues.put(FxDbSchema.Media.MEDIA_EVENT_TYPE,
				FxEventType.AUDIO_FILE.getNumber());

		long mediaId = -1;
		
		try {
			mediaId = mDb.insert(FxDbSchema.Media.TABLE_NAME, null,
					mediaValues);
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
		return mediaId;

	}

	private long insertThumbnailTable(long mediaId,
			FxAudioFileThumnailEvent audioFileThumnailEvent) throws FxDbCorruptException, FxDbOperationException {

		ContentValues thumbnailValues = new ContentValues();
		thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_SIZE,
				audioFileThumnailEvent.getActualFileSize());
		thumbnailValues.put(FxDbSchema.Thumbnail.MEDIA_ID, mediaId);
		thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_DURATION,
				audioFileThumnailEvent.getActualDuration());

		long id = -1;
		try {
			id= mDb.insert(FxDbSchema.Thumbnail.TABLE_NAME, null,
					thumbnailValues);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
		return id;
	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		
		String selection = FxDbSchema.Thumbnail.ROWID + "=" + id;
		
		int number = 0;
		Cursor cursor = null;
		
		try {
			cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME, selection, null, null);

			if(cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				String tn_fullPath = cursor.getString(cursor
						.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));
	
				if(tn_fullPath != null && !tn_fullPath.equals("")) {
					try {
						FileUtil.deleteFile(tn_fullPath);
					}catch (IllegalArgumentException ex) {
						FxLog.e(TAG, ex.getMessage());
					}
				}
			}
			
			number = mDb.delete(FxDbSchema.Thumbnail.TABLE_NAME, selection, null);
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}
		
		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String eventType = Integer.toString(FxEventType.AUDIO_FILE.getNumber());
		String queryString = new StringBuilder().append("SELECT COUNT(*) as count FROM ")
				.append(FxDbSchema.Media.TABLE_NAME)
				.append(" WHERE media_event_type = ")
				.append(eventType).toString();

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
	public void deleteAll() throws FxNotImplementedException, FxDbCorruptException, FxDbOperationException {
		Cursor cursor = null;
		
		try {
			cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME, null, null, null);

			if(cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				String tn_fullPath = cursor.getString(cursor
						.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));
	
				if(tn_fullPath != null && !tn_fullPath.equals("")) {
					try {
						FileUtil.deleteFile(tn_fullPath);
					}catch (IllegalArgumentException ex) {
						FxLog.e(TAG, ex.getMessage());
					}
				}
			}
			
			mDb.delete(FxDbSchema.Thumbnail.TABLE_NAME, null, null);
			
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

}
