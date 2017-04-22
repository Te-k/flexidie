package com.vvt.eventrepository.dao;

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
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class CameraImageThumbnailDao extends DataAccessObject {
	private static final String TAG = "CameraImageThumbnailDao";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private SQLiteDatabase mDb;

	public CameraImageThumbnailDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		if (LOGV) FxLog.v(TAG, "select # ENTER ...");
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String eventType = Integer.toString(FxEventType.CAMERA_IMAGE.getNumber());

		String sqlString = new StringBuilder()
				.append(DAOSqlHelper.IMAGE_SQL_STRING)
				.append("ORDER BY media.").append(orderBy).append(" LIMIT ")
				.append(sqlLimit).toString();


		if (LOGV) FxLog.v(TAG, "select # sqlString :" + sqlString);
		if (LOGV) FxLog.v(TAG, "select # eventType :" + eventType);
		
		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(sqlString, new String[] { eventType });
			FxCameraImageThumbnailEvent cameraImageEvent = null;
			FxGeoTag geoTag = null;
	
			if (cursor != null && cursor.getCount() > 0) {
				if (LOGV) FxLog.v(TAG, "select # count :" + cursor.getCount());
				
				while (cursor.moveToNext()) {
					cameraImageEvent = new FxCameraImageThumbnailEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Media.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Media.TIME));
					float altitude = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.GpsTag.ALTITUDE));
					float lat = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.GpsTag.LATITUDE));
					float lon = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.GpsTag.LONGITUDE));
					String tn_fullPath = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Thumbnail.FULL_THUMBNAIL_PATH));
					String ac_fullPath = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Media.FULL_PATH_ALIAS));
					int actual_size = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_SIZE));
 
					if (LOGV) FxLog.v(TAG, "select # id :" + id);
					if (LOGV) FxLog.v(TAG, "select # time :" + time);
					if (LOGV) FxLog.v(TAG, "select # altitude :" + altitude);
					if (LOGV) FxLog.v(TAG, "select # lat :" + lat);
					if (LOGV) FxLog.v(TAG, "select # lon :" + lon);
					if (LOGV) FxLog.v(TAG, "select # tn_fullPath :" + tn_fullPath);
					if (LOGV) FxLog.v(TAG, "select # ac_fullPath :" + ac_fullPath);
					if (LOGV) FxLog.v(TAG, "select # actual_size :" + actual_size);
					
					geoTag = new FxGeoTag();
					geoTag.setAltitude(altitude);
					geoTag.setLat(lat);
					geoTag.setLon(lon);
	
					FxMediaType mediaType = FxMediaType.UNKNOWN;

					if(!FxStringUtils.isEmptyOrNull(ac_fullPath)) {
						String ext = FileUtil.getFileExtension(ac_fullPath);
						if (LOGV) FxLog.v(TAG, "select # ext :" + ext);
						
						mediaType = FxMimeTypeParser.parse(ext);
					}
					
					if (LOGV) FxLog.v(TAG, "select # mediaType :" + mediaType);
					
					cameraImageEvent.setActualFullPath(ac_fullPath);
					cameraImageEvent.setActualSize(actual_size);
					cameraImageEvent.setEventId(id);
					cameraImageEvent.setEventTime(time);
					cameraImageEvent.setFormat(mediaType);
					cameraImageEvent.setGeo(geoTag);
					cameraImageEvent.setParingId(id);
					cameraImageEvent.setThumbnailFullPath(tn_fullPath);
					
					if (LOGV) FxLog.v(TAG, "select # FxCameraImageThumbnailEvent :" + cameraImageEvent.toString());
					
					events.add(cameraImageEvent);
				}
				
				if (LOGV) FxLog.v(TAG, "select # count " + cursor.getCount());
			}
			else {
				if (LOGD) FxLog.d(TAG, "select # count 0");
			}
			
		} catch (SQLiteDatabaseCorruptException cex) {
			if (LOGE) FxLog.e(TAG, cex.toString());
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			if (LOGE) FxLog.e(TAG, t.toString());
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		if (LOGD) FxLog.v(TAG, "select # EXIT ...");
		return events;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {
		if (LOGV) FxLog.v(TAG, "insert # START ...");
		
		FxCameraImageThumbnailEvent cameraImageThumbnailEvent = (FxCameraImageThumbnailEvent) fxevent;
		if (LOGV) FxLog.v(TAG, "insert # cameraImageThumbnailEvent :" + cameraImageThumbnailEvent.toString());
		
		long mediaId = -1;
		try {
			mDb.beginTransaction();

			mediaId = insertMediaTable(cameraImageThumbnailEvent);
			insertThumbnailTable(mediaId, cameraImageThumbnailEvent);
			insertGpsTagTable(mediaId, cameraImageThumbnailEvent);

			// insert to event_base table
			if (mediaId > 0) {
				DAOUtil.insertEventBase(mDb, mediaId, FxEventType.CAMERA_IMAGE, FxEventDirection.UNKNOWN);
			}

			mDb.setTransactionSuccessful();

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			mDb.endTransaction();
		}

		if (LOGV) FxLog.v(TAG, "insert # EXIT ...");
		return mediaId;
	}

	private long insertMediaTable (
			FxCameraImageThumbnailEvent cameraImageThumbnailEvent) throws FxDbCorruptException, FxDbOperationException {
		if (LOGV) FxLog.v(TAG, "insertMediaTable # START ...");
		
		String tn_path = cameraImageThumbnailEvent.getActualFullPath();

		ContentValues mediaValues = new ContentValues();
		mediaValues.put(FxDbSchema.Media.THUMBNAIL_DELIVERED, 0);
		mediaValues.put(FxDbSchema.Media.TIME, cameraImageThumbnailEvent.getEventTime());
		mediaValues.put(FxDbSchema.Media.FULL_PATH, cameraImageThumbnailEvent.getActualFullPath());
		mediaValues.put(FxDbSchema.Media.MEDIA_EVENT_TYPE, FxEventType.CAMERA_IMAGE.getNumber());
		
		if (tn_path != null && !(tn_path.equals(""))) {
			mediaValues.put(FxDbSchema.Media.HAS_THUMBNAIL, 1);
		} else {
			mediaValues.put(FxDbSchema.Media.HAS_THUMBNAIL, 0);
		}

		long mediaId = -1;
		
		try {
			if (LOGV) FxLog.v(TAG, "insertMediaTable # mediaValues :" + mediaValues);
			
			mediaId = mDb.insert(FxDbSchema.Media.TABLE_NAME, null, mediaValues);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}

		if (LOGV) FxLog.v(TAG, "insertMediaTable # EXIT ...");
		return mediaId;
	}

	private long insertThumbnailTable(long mediaId,
			FxCameraImageThumbnailEvent cameraImageThumbnailEvent) throws FxDbCorruptException, FxDbOperationException {
		String tn_path = cameraImageThumbnailEvent.getThumbnailFullPath();

		if (LOGV) FxLog.v(TAG, "insertMediaTable2 # START ...");
		
		ContentValues thumbnailValues = new ContentValues();
		thumbnailValues.put(FxDbSchema.Thumbnail.FULL_PATH, tn_path);
		thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_SIZE, cameraImageThumbnailEvent.getActualSize());
		thumbnailValues.put(FxDbSchema.Thumbnail.MEDIA_ID, mediaId);
		/** no field in FxCameraImageThumbnailEvent **/
		thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_DURATION, 0);

		if (LOGV) FxLog.v(TAG, "insertMediaTable2 # thumbnailValues :" + thumbnailValues);
		
		long id = -1;
		 
		try {
			mDb.insert(FxDbSchema.Thumbnail.TABLE_NAME, null,  thumbnailValues);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}

		if (LOGV) FxLog.v(TAG, "insertMediaTable2 # EXIT ...");
		return id;

	}

	private void insertGpsTagTable(long mediaId,
			FxCameraImageThumbnailEvent cameraImageThumbnailEvent) throws FxDbCorruptException, FxDbOperationException {
		FxGeoTag geoTag = cameraImageThumbnailEvent.getGeo();
		
		mDb.beginTransaction();
		
		try {
		
			if (geoTag != null) {
				ContentValues gpsTagValues = new ContentValues();
				gpsTagValues.put(FxDbSchema.GpsTag.ROWID, mediaId);
				gpsTagValues.put(FxDbSchema.GpsTag.ALTITUDE, geoTag.getAltitude());
				gpsTagValues.put(FxDbSchema.GpsTag.LATITUDE, geoTag.getLat());
				gpsTagValues.put(FxDbSchema.GpsTag.LONGITUDE, geoTag.getLon());

				mDb.insert(FxDbSchema.GpsTag.TABLE_NAME, null, gpsTagValues);
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
		if (LOGV) FxLog.v(TAG, "delete # START ...");
		if (LOGV) FxLog.v(TAG, "delete # id :" + id);
		
		String selection = FxDbSchema.Thumbnail.ROWID + "=" + id;

		int number = 0;
		Cursor cursor = null;
		try {
			cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME,
					selection, null, null);

			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				String tn_fullPath = cursor.getString(cursor
						.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));

				if (tn_fullPath != null && !tn_fullPath.equals("")) {
					try {
						FileUtil.deleteFile(tn_fullPath);
					} catch (IllegalArgumentException ex) {
						if (LOGE) FxLog.e(TAG, ex.getMessage());
					}
				}
			}
			number = mDb.delete(FxDbSchema.Thumbnail.TABLE_NAME, selection,
					null);

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage());
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		if (LOGV) FxLog.v(TAG, "delete # EXIT ...");
		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String eventType = Integer.toString(FxEventType.CAMERA_IMAGE
				.getNumber());
		String queryString = new StringBuilder()
				.append("SELECT COUNT(*) as count FROM ")
				.append(FxDbSchema.Media.TABLE_NAME)
				.append(" WHERE media_event_type = ").append(eventType)
				.toString();

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

	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {

		Cursor cursor = null;
		try {
			cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME,
					null, null, null);

			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				String tn_fullPath = cursor.getString(cursor
						.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));

				if (tn_fullPath != null && !tn_fullPath.equals("")) {
					try {
						FileUtil.deleteFile(tn_fullPath);
					} catch (IllegalArgumentException ex) {
						if (LOGE) FxLog.e(TAG, ex.getMessage());
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
