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
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.events.FxPanicImageEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.ioutil.FileUtil;

public class PanicImageDao extends DataAccessObject {
	private SQLiteDatabase mDb;

	public PanicImageDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit)
			throws FxFileNotFoundException, FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();

		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String eventType = Integer.toString(FxEventType.PANIC_IMAGE.getNumber());
		String sqlString = new StringBuilder()
				.append(DAOSqlHelper.PANIC_IMAGE_SQL_STRING)
				.append(" ORDER BY media.").append(orderBy).append(" LIMIT ")
				.append(sqlLimit).toString();

		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(sqlString, new String[] { eventType });
	
			FxPanicImageEvent panicImageEvent = null;
			FxGeoTag geoTag = null;
	
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					panicImageEvent = new FxPanicImageEvent();
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
					String ac_fullPath = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Media.FULL_PATH_ALIAS));
					int actualSize = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_SIZE));
					int actualDuration = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Thumbnail.ACTUAL_DURATION));
					int cellId = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.GpsTag.CELL_ID));
					String areaCode = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.GpsTag.AREA_CODE));
					String networkId = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.GpsTag.NETWORK_ID));
					String countryCode = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.GpsTag.COUNTRY_CODE));
					// String tn_fullPath =
					// cursor.getString(cursor.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH_ALIAS));
	
					geoTag = new FxGeoTag();
					geoTag.setAltitude(altitude);
					geoTag.setLat(lat);
					geoTag.setLon(lon);
	
					byte fileContent[] = new byte[] {};
					if (ac_fullPath != null) {
						File file = new File(ac_fullPath);
						if (file.exists()) {
							fileContent = FileUtil.readFileData(ac_fullPath);
						} else {
							throw new FxFileNotFoundException(
									String.format(
											FxFileNotFoundException.UPLOAD_ACTUAL_MEDIA_FILE_NOT_FOUND,
											id));
						}
					}
	
					FxMediaType mediaType = FxMediaType.UNKNOWN;
					if (ac_fullPath != null && !(ac_fullPath.endsWith(""))) {
						File actualFile = new File(ac_fullPath);
						if (actualFile.exists()) {
							String ext = FileUtil.getFileExtension(ac_fullPath);
							mediaType = FxMimeTypeParser.parse(ext);
						}
					}
	
					geoTag = new FxGeoTag();
					geoTag.setAltitude(altitude);
					geoTag.setLat(lat);
					geoTag.setLon(lon);
	
					panicImageEvent.setGeoTag(geoTag);
					panicImageEvent.setActualFullPath(ac_fullPath);
					panicImageEvent.setAreaCode(areaCode);
					panicImageEvent.setCellId(cellId);
					panicImageEvent.setCountryCode(countryCode);
					panicImageEvent.setEventId(id);
					panicImageEvent.setEventTime(time);
					panicImageEvent.setFormat(mediaType);
					panicImageEvent.setImageData(fileContent);
					panicImageEvent.setNetworkId(networkId);
					panicImageEvent.setActualDuration(actualDuration);
					panicImageEvent.setActualSize(actualSize);
					panicImageEvent.setNetworkName("unknown");
					panicImageEvent.setCellName("unknown");
					events.add(panicImageEvent);
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
		FxPanicImageEvent panicImageEvent = (FxPanicImageEvent) fxevent;

		long mediaId = -1;
		try {
			mDb.beginTransaction();

			mediaId = insertMediaTable(panicImageEvent);
			insertThumbnailTable(mediaId, panicImageEvent);
			insertGpsTagTable(mediaId, panicImageEvent);

			// insert to event_base table
			if (mediaId > 0) {
				DAOUtil.insertEventBase(mDb, mediaId, FxEventType.PANIC_IMAGE,
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

	private long insertMediaTable(FxPanicImageEvent panicImageEvent) throws FxDbCorruptException, FxDbOperationException {

		ContentValues mediaValues = new ContentValues();
		mediaValues.put(FxDbSchema.Media.HAS_THUMBNAIL, 0);
		mediaValues.put(FxDbSchema.Media.THUMBNAIL_DELIVERED, 0);
		mediaValues.put(FxDbSchema.Media.TIME, panicImageEvent.getEventTime());
		mediaValues.put(FxDbSchema.Media.FULL_PATH,
				panicImageEvent.getActualFullPath());
		mediaValues.put(FxDbSchema.Media.MEDIA_EVENT_TYPE,
				FxEventType.PANIC_IMAGE.getNumber());

		long mediaId =  -1;
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
			FxPanicImageEvent panicImageEvent) throws FxDbCorruptException, FxDbOperationException {

		ContentValues thumbnailValues = new ContentValues();
		thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_SIZE,
				panicImageEvent.getActualSize());
		thumbnailValues.put(FxDbSchema.Thumbnail.MEDIA_ID, mediaId);
		thumbnailValues.put(FxDbSchema.Thumbnail.ACTUAL_DURATION, 0);

		long id = -1;
		try {
			id = mDb.insert(FxDbSchema.Thumbnail.TABLE_NAME, null,
					thumbnailValues);
		
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		return id;

	}

	private void insertGpsTagTable(long mediaId,
			FxPanicImageEvent panicImageEvent) throws FxDbCorruptException, FxDbOperationException {
		FxGeoTag geoTag = panicImageEvent.getGeoTag();
		if (geoTag != null) {
			ContentValues gpsTagValues = new ContentValues();
			gpsTagValues.put(FxDbSchema.GpsTag.ROWID, mediaId);
			gpsTagValues.put(FxDbSchema.GpsTag.ALTITUDE, geoTag.getAltitude());
			gpsTagValues.put(FxDbSchema.GpsTag.LATITUDE, geoTag.getLat());
			gpsTagValues.put(FxDbSchema.GpsTag.LONGITUDE, geoTag.getLon());
			gpsTagValues.put(FxDbSchema.GpsTag.NETWORK_ID,
					panicImageEvent.getNetworkId());
			gpsTagValues.put(FxDbSchema.GpsTag.AREA_CODE,
					panicImageEvent.getAreaCode());
			gpsTagValues.put(FxDbSchema.GpsTag.CELL_ID,
					panicImageEvent.getCellId());
			gpsTagValues.put(FxDbSchema.GpsTag.COUNTRY_CODE,
					panicImageEvent.getCountryCode());

			try {
				mDb.insert(FxDbSchema.GpsTag.TABLE_NAME, null, gpsTagValues);
			} catch (SQLiteDatabaseCorruptException cex) {
				throw new FxDbCorruptException(cex.getMessage()); 	
			} catch (Throwable t) {
				throw new FxDbOperationException(t.getMessage(), t);
			}
		}
	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		
		int number = 0;
		
		try {
			String selection = FxDbSchema.Media.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.Media.TABLE_NAME, selection, null);
	
			if (number < 1) {
				throw new FxDbIdNotFoundException(
						String.format(
								FxDbIdNotFoundException.UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND,
								id));
			}
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}

		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String eventType = Integer
				.toString(FxEventType.PANIC_IMAGE.getNumber());
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
		} 
		finally {
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
			mDb.delete(FxDbSchema.Media.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
	}

}
