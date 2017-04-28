package com.vvt.eventrepository.dao;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.Customization;
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileThumbnailEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class VideoFileThumbnailDao extends DataAccessObject {
	private static final String TAG = "VideoFileThumbnailDao";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	
	private SQLiteDatabase mDb;

	public VideoFileThumbnailDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit)
			throws FxDbOperationException, SQLiteDatabaseCorruptException,
			FxDbCorruptException {
		if(LOGV) FxLog.d(TAG, "select # ENTER ...");
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		
		Cursor cursor = null;
		
		try {
			cursor = selectMediaTable(orderBy, sqlLimit);
	
			FxVideoFileThumbnailEvent videoFileThumbnailEvent = null;
			
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Media.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Media.TIME));
					String ac_fullPath = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Media.FULL_PATH));
					videoFileThumbnailEvent = getEvent(id, time, ac_fullPath);
	
					if(LOGV) FxLog.v(TAG, "select # FxVideoFileThumbnailEvent " + videoFileThumbnailEvent.toString());
					events.add(videoFileThumbnailEvent);
	
				}
				
				if(LOGV) FxLog.v(TAG, "select # count " + cursor.getCount());
			}
			else {
				if(LOGD) FxLog.d(TAG, "select # count 0");
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

		if(LOGV) FxLog.v(TAG, "select # EXIT ...");
		return events;
	}

	private Cursor selectMediaTable(String orderBy, String sqlLimit)
			throws FxDbCorruptException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "selectMediaTable # ENTER ...");
		
		String eventType = Integer.toString(FxEventType.VIDEO_FILE.getNumber());
		String selection = "media_event_type = " + eventType + " AND thumbnail_delivered = 0";
		Cursor cursor = null;
			
		if(LOGV) FxLog.v(TAG, "selectMediaTable # eventType " + eventType);
		if(LOGV) FxLog.v(TAG, "selectMediaTable # selection " + selection);
		
		try {
			cursor = mDb.query(FxDbSchema.Media.TABLE_NAME, null, selection,
					null, null, null, orderBy, sqlLimit);
						
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
		if(LOGV) FxLog.v(TAG, "selectMediaTable # EXIT ...");
		return cursor;
	}

	private FxVideoFileThumbnailEvent getEvent(long id, long time,
			String ac_fullPath) throws FxDbCorruptException,
			FxDbOperationException {

		if(LOGV) FxLog.v(TAG, "getEvent # ENTER ...");
		
		FxVideoFileThumbnailEvent videoFileThumbnailEvent = new FxVideoFileThumbnailEvent();
		List<FxThumbnail> thumbnails = new ArrayList<FxThumbnail>();
		int actualDuration = 0;
		int actualFileSize = 0;

		// if it has thumbnail.
		String selection = "media_id = " + id;
		
		Cursor cursor = null;
		try {
			cursor = mDb.query(FxDbSchema.Thumbnail.TABLE_NAME, null,
					selection, null, null, null, null);
			if (cursor != null && cursor.getCount() > 0) {
				// get thumbnails
				thumbnails = getThumbnails(cursor);
				cursor.moveToFirst();
				actualDuration = cursor.getInt(cursor
						.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_DURATION));
				actualFileSize = cursor.getInt(cursor
						.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_SIZE));
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

		// get extension actual file.
		FxMediaType mediaType = FxMediaType.UNKNOWN;
		
		if (!FxStringUtils.isEmptyOrNull(ac_fullPath)) {
			File actualFile = new File(ac_fullPath);
			if (actualFile.exists()) {
				if(LOGV) FxLog.v(TAG, "actualFile exists");
				
				String ext = FileUtil.getFileExtension(ac_fullPath);
				if(LOGV) FxLog.v(TAG, "ext is" + ext);
				
				mediaType = FxMimeTypeParser.parse(ext);
				if(LOGV) FxLog.v(TAG, "mediaType is" + mediaType);
			}
		} else {
			if(LOGD) FxLog.d(TAG, "ac_fullPath is null or empty");
		}

		videoFileThumbnailEvent.setActualDuration(actualDuration);
		videoFileThumbnailEvent.setActualFullPath(ac_fullPath);
		videoFileThumbnailEvent.setActualFileSize(actualFileSize);
		videoFileThumbnailEvent.setEventId(id);
		videoFileThumbnailEvent.setEventTime(time);
		videoFileThumbnailEvent.setFormat(mediaType);
		videoFileThumbnailEvent.setParingId(id);
		videoFileThumbnailEvent.setVideoData(new byte[] {});

		for (int i = 0; i < thumbnails.size(); i++) {
			videoFileThumbnailEvent.addThumbnail(thumbnails.get(i));
		}
		
		if(LOGV) FxLog.v(TAG, "getEvent # actualDuration :" + actualDuration);
		if(LOGV) FxLog.v(TAG, "getEvent # ac_fullPath :" + ac_fullPath);
		if(LOGV) FxLog.v(TAG, "getEvent # actualFileSize :" + actualFileSize);
		if(LOGV) FxLog.v(TAG, "getEvent # id :" + id);
		if(LOGV) FxLog.v(TAG, "getEvent # time :" + time);
		if(LOGV) FxLog.v(TAG, "getEvent # mediaType :" + mediaType);
		if(LOGV) FxLog.v(TAG, "getEvent # paringId :" + id);
		if(LOGV) FxLog.v(TAG, "getEvent # videoFileThumbnailEvent :" + videoFileThumbnailEvent.toString());
		
		if(LOGV) FxLog.v(TAG, "getEvent # EXIT ...");
		return videoFileThumbnailEvent;
	}

	private List<FxThumbnail> getThumbnails(Cursor cursor) {

		List<FxThumbnail> thumbnails = new ArrayList<FxThumbnail>();
		FxThumbnail thumbnail = new FxThumbnail();
		while (cursor.moveToNext()) {
			String tn_fullPath = cursor.getString(cursor
					.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));

			// get thumbnail data.
			byte fileContent[] = new byte[] {};
			if (tn_fullPath != null) {
				File file = new File(tn_fullPath);
				if (file.exists()) {
					fileContent = FileUtil.readFileData(tn_fullPath);
				}
			}

			thumbnail = new FxThumbnail();
			thumbnail.setImageData(fileContent);
			thumbnail.setThumbnailPath(tn_fullPath);

			thumbnails.add(thumbnail);
		}

		return thumbnails;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {
		FxVideoFileThumbnailEvent videoFileThumbnailEvent = (FxVideoFileThumbnailEvent) fxevent;

		long mediaId = -1;
		try {
			mDb.beginTransaction();

			mediaId = insertMediaTable(videoFileThumbnailEvent);
			insertThumbnailTable(mediaId, videoFileThumbnailEvent);

			// insert to event_base table
			if (mediaId > 0) {
				DAOUtil.insertEventBase(mDb, mediaId, FxEventType.VIDEO_FILE,
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
			FxVideoFileThumbnailEvent videoFileThumbnailEvent) throws FxDbCorruptException, FxDbOperationException {

		ArrayList<FxThumbnail> thumbnailList = videoFileThumbnailEvent
				.getListOfThumbnail();

		ContentValues mediaValues = new ContentValues();
		mediaValues.put(FxDbSchema.Media.THUMBNAIL_DELIVERED, 0);
		mediaValues.put(FxDbSchema.Media.TIME,
				videoFileThumbnailEvent.getEventTime());
		mediaValues.put(FxDbSchema.Media.FULL_PATH,
				videoFileThumbnailEvent.getActualFullPath());
		mediaValues.put(FxDbSchema.Media.MEDIA_EVENT_TYPE,
				FxEventType.VIDEO_FILE.getNumber());
		if (thumbnailList.size() > 0) {
			mediaValues.put(FxDbSchema.Media.HAS_THUMBNAIL, 1);
		} else {
			mediaValues.put(FxDbSchema.Media.HAS_THUMBNAIL, 0);
		}

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

	private void insertThumbnailTable(long mediaId,
			FxVideoFileThumbnailEvent videoFileThumbnailEvent) throws FxDbCorruptException, FxDbOperationException {

		ArrayList<FxThumbnail> thumbnails = videoFileThumbnailEvent
				.getListOfThumbnail();
		for (int i = 0; i < thumbnails.size(); i++) {
			String tn_path = thumbnails.get(i).getThumbnailPath();
			ContentValues thumbnailValues = new ContentValues();
			thumbnailValues.put(FxDbSchema.Thumbnail.FULL_PATH, tn_path);
			thumbnailValues.put(FxDbSchema.Thumbnail.MEDIA_ID, mediaId);
			thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_SIZE,
					videoFileThumbnailEvent.getActualFileSize());
			thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_DURATION,
					videoFileThumbnailEvent.getActualDuration());
			
			try {
				mDb.insert(FxDbSchema.Thumbnail.TABLE_NAME, null,
						thumbnailValues);
			} catch (SQLiteDatabaseCorruptException cex) {
				throw new FxDbCorruptException(cex.getMessage());
			} catch (Throwable t) {
				throw new FxDbOperationException(t.getMessage(), t);
			}
		}

	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "delete # ENTER ...");
		
		int number = 0;
		Cursor cursor = null;
		try {
			String selection = FxDbSchema.Thumbnail.ROWID + "=" + id;
			
			/**no need to delete because we use the android system thumbnail.**/
//			cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME, selection, null, null);
//			
//			if(cursor != null && cursor.getCount() > 0) {
//				cursor.moveToFirst();
//				String tn_fullPath = cursor.getString(cursor
//						.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));
//	
//				if(tn_fullPath != null && !tn_fullPath.equals("")) {
//					try {
//						FileUtil.deleteFile(tn_fullPath);
//					}catch (IllegalArgumentException ex) {
//						if(LOGE) FxLog.e(TAG, ex.getMessage());
//					}
//				}
//			}
		
			number = mDb.delete(FxDbSchema.Thumbnail.TABLE_NAME, selection, null);
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		if(LOGD) FxLog.d(TAG, "delete # count " + number);
		if(LOGV) FxLog.v(TAG, "delete # EXIT ...");
		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String eventType = Integer.toString(FxEventType.VIDEO_FILE.getNumber());
		String queryString = "SELECT COUNT(*) as count FROM "
				+ FxDbSchema.Media.TABLE_NAME + " WHERE media_event_type = "
				+ eventType;

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

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		 
		Cursor cursor = null;
		try {
			
			/**no need to delete because we use the android system thumbnail.**/
//			cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME, null, null, null);
//			
//			if(cursor != null && cursor.getCount() > 0) {
//				cursor.moveToFirst();
//				String tn_fullPath = cursor.getString(cursor
//						.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));
//	
//				if(tn_fullPath != null && !tn_fullPath.equals("")) {
//					try {
//						FileUtil.deleteFile(tn_fullPath);
//					}catch (IllegalArgumentException ex) {
//						FxLog.e(TAG, ex.getMessage());
//					}
//				}
//			}
		
			mDb.delete(FxDbSchema.Thumbnail.TABLE_NAME, null, null);
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		finally {
			if (cursor != null) {
				cursor.close();
			}
		}
		
	}

}
