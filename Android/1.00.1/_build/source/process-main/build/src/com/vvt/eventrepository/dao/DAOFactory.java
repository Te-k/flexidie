package com.vvt.eventrepository.dao;

import android.database.sqlite.SQLiteDatabase;

import com.vvt.base.FxEventType;
import com.vvt.events.FxCallingModuleType;

public class DAOFactory {

	private SQLiteDatabase mDb;

	public DAOFactory(SQLiteDatabase db) {
		mDb = db;
	}

	public DataAccessObject createDaoInstance(FxEventType eventType) {

		DataAccessObject dao = null;

		switch (eventType) {
		case CALL_LOG:
			dao = new CallLogDao(mDb);
			break;
		case SMS:
			dao = new SmsDao(mDb);
			break;
		case MMS:
			dao = new MmsDao(mDb);
			break;
		case MAIL:
			dao = new EmailDao(mDb);
			break;
		case LOCATION:
			dao = new LocationDao(mDb, FxCallingModuleType.CORE_TRIGGER);
			break;
		case CAMERA_IMAGE_THUMBNAIL:
			dao = new CameraImageThumbnailDao(mDb);
			break;
		case VIDEO_FILE_THUMBNAIL:
			dao = new VideoFileThumbnailDao(mDb);
			break;
		case ACTUAL_MEDIA_DAO:
			dao = new ActualMediaDao(mDb);
			break;
		case EVENT_BASE:
			dao = new EventBaseDao(mDb);
			break;
		case AUDIO_FILE_THUMBNAIL:
			dao = new AudioFileThumbnailDao(mDb);
			break;
		case PANIC_STATUS:
			dao = new PanicStatusDao(mDb);
			break;
		case PANIC_IMAGE:
			dao = new PanicImageDao(mDb);
			break;
		case PANIC_GPS:
			dao = new PanicGpsDao(mDb);
			break;
		case ALERT_GPS:
			dao = new AlertDao(mDb);
			break;
		case SYSTEM:
			dao = new SystemDao(mDb);
			break;
		case SETTINGS :
			dao = new SettingsDao(mDb);
			break;
		case IM :
			dao = new IMDao(mDb);
			break;
		case WALLPAPER_THUMBNAIL :
			dao = new WallpaperDao(mDb);
			break;
		default:
			// if the event type is not implement, use the mock to avoid null
			// exception.
			dao = new MockDao();
			break;
		}
		return dao;

	}
}
