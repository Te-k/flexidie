package com.vvt.eventrepository.dao;

import java.io.File;
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
import com.vvt.events.FxAudioConversationEvent;
import com.vvt.events.FxAudioFileEvent;
import com.vvt.events.FxCameraImageEvent;
import com.vvt.events.FxEmbededCallInfo;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.events.FxVideoFileEvent;
import com.vvt.events.FxWallpaperEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class ActualMediaDao extends DataAccessObject {
	
	private static final String TAG = "ActualMediaDao";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int THUMBNAIL_DELIVERED = 1;
	
	private SQLiteDatabase mDb;

	public ActualMediaDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit)
			throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	public FxEvent select(long id) throws FxFileNotFoundException,
			FxDbIdNotFoundException, FxFileSizeNotAllowedException, FxDbCorruptException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG, "select # ENTER");
		
		FxEvent fxEvent = null;

		String mediaId = Long.toString(id);
		String sqlMedia = String.format("SELECT * FROM %s WHERE %s._id = ? ", FxDbSchema.Media.TABLE_NAME, FxDbSchema.Media.TABLE_NAME);

		if(LOGV) FxLog.v(TAG, "select # sqlMedia is " + sqlMedia);
		if(LOGV) FxLog.v(TAG, "select # id mediaId " + mediaId);
		
		Cursor cursor = null;
		
		try {
			cursor = mDb.rawQuery(sqlMedia, new String[] { mediaId });
		
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				String fullPath = cursor.getString(cursor
						.getColumnIndex(FxDbSchema.Media.FULL_PATH));
				long time = cursor.getLong(cursor
						.getColumnIndex(FxDbSchema.Media.TIME));
				int mediaEventType = cursor.getInt(cursor
						.getColumnIndex(FxDbSchema.Media.MEDIA_EVENT_TYPE));
				int tn_delivered = cursor.getInt(cursor
						.getColumnIndex(FxDbSchema.Media.THUMBNAIL_DELIVERED));
				
				if( tn_delivered == THUMBNAIL_DELIVERED) { // Has to be delivered already ..
					FxEventType eventType = FxEventType.forValue(mediaEventType);
					fxEvent = getFxEventInstance(id, fullPath, time, eventType);	
				}

			} else {
				throw new FxDbIdNotFoundException(String.format(FxDbIdNotFoundException.UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND, id));
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
		
		if(fxEvent == null) {
			if(LOGD) FxLog.d(TAG, "select # fxEvent is null");
		} else {
			if(LOGV) FxLog.v(TAG, "select # fxEvent is " + fxEvent.toString());
		}

		if(LOGV) FxLog.v(TAG, "select # EXIT");
		return fxEvent;
	}

	private FxEvent getFxEventInstance(long id, String actualFliePath,
			long time, FxEventType eventType) throws FxFileNotFoundException,
			FxFileSizeNotAllowedException, FxDbCorruptException, FxDbOperationException {

		FxEvent fxEvent = null;
		byte fileContent[] = new byte[] {};
		FxMediaType mediaType = FxMediaType.UNKNOWN;

		if (actualFliePath != null) {
			File file = new File(actualFliePath);
			
			if (file.exists()) {
				long fileSize = FileUtil.getFileSize(actualFliePath);
				if(LOGV) FxLog.v(TAG, "getFxEventInstance # fileSize is " + fileSize);
				
				if (FileUtil.isFileSizeAllowed(fileSize)) {
					String ext = FileUtil.getFileExtension(actualFliePath);
					mediaType = FxMimeTypeParser.parse(ext);
					// Let the phoenix do this..
					//fileContent = FileUtil.readFileData(actualFliePath);
				} else {
					throw new FxFileSizeNotAllowedException(
							String.format(
									FxFileSizeNotAllowedException.UPLOAD_ACTUAL_MEDIA_FILE_SIZE_NOT_ALLOWED,
									id));
				}

			} else {
				throw new FxFileNotFoundException(
						String.format(
								FxFileNotFoundException.UPLOAD_ACTUAL_MEDIA_FILE_NOT_FOUND,
								id));
			}
			
			if(LOGV) FxLog.v(TAG, "getFxEventInstance # mediaType is " + mediaType);
			
			if(LOGV) FxLog.v(TAG, "getFxEventInstance # actualFliePath is " + actualFliePath);
		}

		switch (eventType) {
		case CAMERA_IMAGE:
			FxGeoTag geoTag = getGeoTag(id);
			FxCameraImageEvent cameraImageEvent = new FxCameraImageEvent();
			cameraImageEvent.setEventId(id);
			cameraImageEvent.setEventTime(time);
			cameraImageEvent.setFileName(actualFliePath);
			cameraImageEvent.setFormat(mediaType);
			cameraImageEvent.setParingId(id);
			cameraImageEvent.setImageData(fileContent);
			cameraImageEvent.setGeo(geoTag);
			fxEvent = cameraImageEvent;
			break;

		case AUDIO_CONVERSATION:
			FxEmbededCallInfo embededCallInfo = getCallTag(id);
			FxAudioConversationEvent audioConversationEvent = new FxAudioConversationEvent();
			audioConversationEvent.setAudioData(fileContent);
			audioConversationEvent.setEmbededCallInfo(embededCallInfo);
			audioConversationEvent.setEventId(id);
			audioConversationEvent.setEventTime(time);
			audioConversationEvent.setFileName(actualFliePath);
			audioConversationEvent.setFormat(mediaType);
			audioConversationEvent.setParingId(id);
			fxEvent = audioConversationEvent;
			break;
		case AUDIO_FILE:
			FxAudioFileEvent audioFileEvent = new FxAudioFileEvent();
			audioFileEvent.setAudioData(fileContent);
			audioFileEvent.setEventId(id);
			audioFileEvent.setEventTime(time);
			audioFileEvent.setFileName(actualFliePath);
			audioFileEvent.setFormat(mediaType);
			audioFileEvent.setParingId(id);
			fxEvent = audioFileEvent;
			break;
		case VIDEO_FILE:
			FxVideoFileEvent videoFileEvent = new FxVideoFileEvent();
			videoFileEvent.setEventId(id);
			videoFileEvent.setEventTime(time);
			videoFileEvent.setFileName(actualFliePath);
			videoFileEvent.setMediaType(mediaType);
			videoFileEvent.setParingId(id);
			videoFileEvent.setVideoData(fileContent);
			fxEvent = videoFileEvent;
			break;
		case WALLPAPER :
			FxWallpaperEvent wallpaperEvent = new FxWallpaperEvent();
			wallpaperEvent.setEventId(id);
			wallpaperEvent.setEventTime(time);
			wallpaperEvent.setParingId(id);
			wallpaperEvent.setActualFullPath(actualFliePath);
			
			fxEvent = wallpaperEvent;
			break;
		default:
			break;
		}

		return fxEvent;
	}

	private FxGeoTag getGeoTag(long id) throws FxDbCorruptException, FxDbOperationException {
		String sqlGpsTag = String.format("SELECT * FROM %s WHERE %s._id = ? ", 
				FxDbSchema.GpsTag.TABLE_NAME,FxDbSchema.GpsTag.TABLE_NAME);
		String mediaId = Long.toString(id);

		FxGeoTag geoTag = new FxGeoTag();
		
		Cursor gpsCursor = null;
		
		try {
			gpsCursor = mDb.rawQuery(sqlGpsTag, new String[] { mediaId });

			if (gpsCursor != null && gpsCursor.getCount() > 0) {
				gpsCursor.moveToFirst();
				float altitude = gpsCursor.getFloat(gpsCursor
						.getColumnIndex(FxDbSchema.GpsTag.ALTITUDE));
				float lat = gpsCursor.getFloat(gpsCursor
						.getColumnIndex(FxDbSchema.GpsTag.LATITUDE));
				float lon = gpsCursor.getFloat(gpsCursor
						.getColumnIndex(FxDbSchema.GpsTag.LONGITUDE));
	
				geoTag.setAltitude(altitude);
				geoTag.setLat(lat);
				geoTag.setLon(lon);
			}
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (gpsCursor != null) {
				gpsCursor.close();
			}
		}
		
		return geoTag;
	}

	private FxEmbededCallInfo getCallTag(long id) throws FxDbCorruptException, FxDbOperationException {
		String sqlCallTag = String.format("SELECT * FROM %s WHERE %s._id = ? ", 
				FxDbSchema.CallTag.TABLE_NAME,FxDbSchema.CallTag.TABLE_NAME);
		String mediaId = Long.toString(id);

		FxEmbededCallInfo callInfo = new FxEmbededCallInfo();

		Cursor callTagCursor = null;
		
		try {
			callTagCursor = mDb.rawQuery(sqlCallTag,new String[] { mediaId });

			if (callTagCursor != null && callTagCursor.getCount() > 0) {
				String contactName = callTagCursor.getString(callTagCursor
						.getColumnIndex(FxDbSchema.CallTag.CONTACT_NAME));
				String number = callTagCursor.getString(callTagCursor
						.getColumnIndex(FxDbSchema.CallTag.NUMBER));
				int direction = callTagCursor.getInt(callTagCursor
						.getColumnIndex(FxDbSchema.CallTag.DIRECTION));
				int duration = callTagCursor.getInt(callTagCursor
						.getColumnIndex(FxDbSchema.CallTag.DURATION));
	
				FxEventDirection eventDirection = FxEventDirection
						.forValue(direction);
	
				callInfo.setContactName(contactName);
				callInfo.setDirection(eventDirection);
				callInfo.setDuration(duration);
				callInfo.setNumber(number);
			}
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (callTagCursor != null) {
				callTagCursor.close();
			}
		}

		return callInfo;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException {
		String selection = FxDbSchema.Media.ROWID + "=" + id;
		
		int number = 0;
		
		try {
			number = mDb.delete(FxDbSchema.Media.TABLE_NAME, selection, null);
			if (number < 1) {
				throw new FxDbIdNotFoundException(
						String.format(
								FxDbIdNotFoundException.UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND,
								id));
			}
		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, "delete # "+e.getMessage());
			
		}

		return number;
	}

	@Override
	public EventCount countEvent() throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	public int update(long id, boolean isDelivered)
			throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		if(LOGV) FxLog.v(TAG,"update # ENTER ... ");
		if(isDelivered) {
			String ac_selection = FxDbSchema.Media.ROWID + "=" + id;
			String tn_selection = FxDbSchema.Thumbnail.MEDIA_ID + "=" + id;
			
			Cursor acCursor = null;
			Cursor cursor = null;
			
			int mediatype = -1;
			
			try {
				/*get media type for check is video or not? if it is a video we will not delete it
				 * because  that thumb nail is generate by system not by us.
				 */
				acCursor = DAOUtil.queryTable(mDb, FxDbSchema.Media.TABLE_NAME, ac_selection, null, null);
				if(acCursor != null && acCursor.getCount() > 0) {
					acCursor.moveToFirst();
					mediatype = acCursor.getInt(acCursor
							.getColumnIndex(FxDbSchema.Media.MEDIA_EVENT_TYPE));
				}
				
				if (acCursor != null) {
					acCursor.close();
				}
				
				//12 is a video
				if(mediatype > -1 && mediatype != 12) {
					if(LOGD) FxLog.d(TAG,"update # this is NOT video, delete thunbnail ...");
					//delete thumbnail file.
					cursor = DAOUtil.queryTable(mDb, FxDbSchema.Thumbnail.TABLE_NAME, tn_selection, null, null);
				
					if(LOGV) FxLog.v(TAG,String.format("cursor.getCount() = %s",cursor.getCount()));
		
					if(cursor != null && cursor.getCount() > 0) {
						cursor.moveToFirst();
						String tn_fullPath = cursor.getString(cursor
								.getColumnIndex(FxDbSchema.Thumbnail.FULL_PATH));
						
						if(tn_fullPath != null && !tn_fullPath.equals("")) {
							try {
								FileUtil.deleteFile(tn_fullPath);
							}catch (IllegalArgumentException ex) {
								if(LOGE) FxLog.e(TAG, ex.getMessage());
							}
						}
					}
				} else {
					if(LOGD) FxLog.d(TAG,"update # this is video, not delete thunbnail ...");
				}
			} catch (Exception e) {
				if(LOGE) FxLog.e(TAG, "update # " + e.toString());
				
			} finally {
				if (acCursor != null) {
					acCursor.close();
				}
				if (cursor != null) {
					cursor.close();
				}
			}
		}
		
		ContentValues contentValues = new ContentValues();
		if (isDelivered) {
			contentValues.put(FxDbSchema.Media.THUMBNAIL_DELIVERED, 1);
		} else {
			contentValues.put(FxDbSchema.Media.THUMBNAIL_DELIVERED, 0);
		}
		

		int numberUpdate = 0;
		
		try {
			String md_selection = FxDbSchema.Media.ROWID + "=" + id;
			numberUpdate = mDb.update(FxDbSchema.Media.TABLE_NAME,
					contentValues, md_selection, null);
	
			if (numberUpdate < 1) {
				throw new FxDbIdNotFoundException(
						String.format(
								FxDbIdNotFoundException.UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND,
								id));
			}
		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, "update # " + e.toString());
		}
		
		if(LOGV) FxLog.v(TAG,"update # EXIT ... ");
		return numberUpdate;
	}

	@Override
	public void deleteAll() {

		try {
			mDb.delete(FxDbSchema.Media.TABLE_NAME, null, null);

		} catch (Exception e) {
			FxLog.e(TAG, "deleteAll # " + e.getMessage());

		}
	}
}
