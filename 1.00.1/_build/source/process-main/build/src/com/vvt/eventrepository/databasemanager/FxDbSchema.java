package com.vvt.eventrepository.databasemanager;

import java.io.File;
import java.io.IOException;

import com.vvt.eventrepository.Customization;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

/**
 * @author aruna
 * @version 1.0
 * @created 29-Aug-2011 04:20:22
 */
public class FxDbSchema {
	private static final String TAG = "FxDbSchema";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
		
	public static final String DATABASE_NAME = "events.db";
	public static final int DATABASE_VERSION = 1;
	    
	public static String getDbFullPath(String writablePath) throws IOException {
		if(LOGV) FxLog.v(TAG, "getDbFullPath # START ...");
		if(LOGV) FxLog.v(TAG, "getDbFullPath # writablePath :" + writablePath);
		
		String appPath =  null;
		
		if(FxStringUtils.isEmptyOrNull(writablePath)) {
			appPath =  DATABASE_NAME;
		}
		else {
			final String repositoryFolder = "event_repository";
			String fullFolderPath = Path.combine(writablePath, repositoryFolder);
			File dbDirectory = new File(fullFolderPath);

			if (!dbDirectory.exists()) {
				if (!dbDirectory.mkdirs()) {
					throw new IOException(String.format("unable to create event_repository folder on %s. Is premission set ?", appPath));
				}
			}

			appPath = Path.combine(fullFolderPath, DATABASE_NAME);
		}
		
		if(LOGD) FxLog.d(TAG, "getDbFullPath # appPath :" + appPath);
		if(LOGV) FxLog.v(TAG, "getDbFullPath # EXIT ...");
		return appPath;
	}

	public static String getSqlCreateSequenceTable()
	{
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s INTEGER)", 
				EventBase.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, EventBase.EVENT_TYPE // 3
				, EventBase.EVENT_ID // 4
				, EventBase.DIRECTION); // 5

		return sql;
	}
	
	public static String getSqlCreateSystemTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s INTEGER, "
				+ "%6$s TEXT)", System.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, System.LOG_TYPE // 4
				, System.DIRECTION // 5
				, System.MESSAGE); // 6

		return sql;
	}

	public static String getSqlCreatePanicTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER);", Panic.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, Panic.PANIC_STATUS); // 4
		return sql;
	}

	public static String getSqlCreateCallLogTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s INTEGER, "
				+ "%6$s TEXT, " + "%7$s TEXT);", CallLog.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, CallLog.DIRECTION // 4
				, CallLog.DURATION // 5
				, CallLog.NUMBER // 6
				, CallLog.CONTACT_NAME); // 7

		return sql;
	}

	public static String getSqlCreateMmsTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s TEXT, "
				+ "%6$s TEXT, " + "%7$s TEXT, " + "%8$s TEXT);", Mms.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, Mms.DIRECTION // 4
				, Mms.SENDER_NUMBER // 5
				, Mms.CONTACT_NAME // 6
				, Mms.SUBJECT // 7
				, Mms.MESSAGE); // 8

		return sql;
	}

	public static String getSqlCreateSmsTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s TEXT, "
				+ "%6$s TEXT, " + "%7$s TEXT, " + "%8$s TEXT);", Sms.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, Sms.DIRECTION // 4
				, Sms.SENDER_NUMBER // 5
				, Sms.CONTACT_NAME // 6
				, Sms.SUBJECT // 7
				, Sms.MESSAGE); // 8

		return sql;
	}

	public static String getSqlCreateEmailTable() {
		final String sql = String.format(
				"CREATE TABLE %1$s "
						+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
						+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s TEXT, "
						+ "%6$s TEXT, " + "%7$s TEXT, " + "%8$s TEXT, "
						+ "%9$s TEXT);", Email.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, Email.DIRECTION // 4
				, Email.SENDER_EMAIL // 5
				, Email.CONTACT_NAME // 6
				, Email.SUBJECT // 7
				, Email.MESSAGE // 8
				, Email.HTML_TEXT); // 9

		return sql;
	}

	public static String getSqlCreateLocationTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s REAL, " + "%5$s REAL, "
				+ "%6$s REAL, " + "%7$s REAL, " + "%8$s REAL, " + "%9$s REAL, "
				+ "%10$s REAL, " + "%11$s INTEGER, " + "%12$s TEXT, "
				+ "%13$s TEXT, " + "%14$s INTEGER, " + "%15$s TEXT, "
				+ "%16$s TEXT, " + "%17$s TEXT, " + "%18$s INTEGER, "
				+ "%19$s INTEGER, "+ "%20$s INTEGER);", Location.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, Location.LATITUDE // 4
				, Location.LONGITUDE // 5
				, Location.ALTITUDE // 6
				, Location.HORIZONTAL_ACCURACY // 7
				, Location.VERTICAL_ACCURACY // 8
				, Location.SPEED // 9
				, Location.HEADING // 10
				, Location.DATUM_ID // 11
				, Location.NETWORKID // 12
				, Location.NETWORKNAME // 13
				, Location.CELLID // 14
				, Location.CELLNAME // 15
				, Location.AREACODE // 16
				, Location.COUNTRYCODE // 17
				, Location.CALLING_MODULE // 18
				, Location.METHOD // 19
				, Location.PROVIDER); // 20

		return sql;
	}

	public static String getSqlCreateMediaTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s TEXT, " + "%5$s INTEGER, "
				+ "%6$s INTEGER, " + "%7$s INTEGER);", Media.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, Media.FULL_PATH // 4
				, Media.MEDIA_EVENT_TYPE // 5
				, Media.THUMBNAIL_DELIVERED // 6
				, Media.HAS_THUMBNAIL); // 7
		return sql;
	}

	public static String getSqlCreateAttachmentTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, " + "%3$s TEXT, "
				+ "%4$s INTEGER, " + "%5$s INTEGER, " + "FOREIGN KEY("
				+ Attachment.MMS_ID + ") REFERENCES " + Mms.TABLE_NAME + "("
				+ BaseColumns.ROWID + "), " + "FOREIGN KEY(" + Attachment.EMAIL_ID
				+ ") REFERENCES " + Email.TABLE_NAME + "(" + BaseColumns.ROWID
				+ "));", Attachment.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, Attachment.FULL_PATH // 3
				, Attachment.MMS_ID // 4
				, Attachment.EMAIL_ID); // 5

		return sql;
	}

	public static String getSqlCreateRecipientTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, " + " %3$s TEXT, "
				+ "%4$s TEXT, " + "%5$s INTEGER, " + "%6$s INTEGER, "
				+ "%7$s INTEGER, " + "%8$s INTEGER, " 
				+ "FOREIGN KEY("+ Recipient.SMS_ID + ") REFERENCES " + Sms.TABLE_NAME + "(" + BaseColumns.ROWID + "), " 
				+ "FOREIGN KEY(" + Recipient.MMS_ID + ") REFERENCES " + Mms.TABLE_NAME + "(" + BaseColumns.ROWID + "), "
				+ "FOREIGN KEY(" + Recipient.EMAIL_ID + ") REFERENCES " + Email.TABLE_NAME + "(" + BaseColumns.ROWID + ")); ", 
				Recipient.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, Recipient.RECIPIENT // 3
				, Recipient.CONTACT_NAME // 4
				, Recipient.RECIPIENT_TYPE // 5
				, Recipient.SMS_ID // 6
				, Recipient.MMS_ID // 7
				, Recipient.EMAIL_ID); // 8

		return sql;
	}
	
	public static String getSqlCreateImTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s INTEGER, " + "%5$s INTEGER, "
				+ "%6$s INTEGER, " + "%7$s TEXT, " + "%8$s TEXT);", IM.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME // 3
				, IM.DIRECTION // 4
				, IM.USER_ID // 5
				, IM.IM_SERVICE_ID // 6
				, IM.MESSAGE // 7
				, IM.USER_DISPLAY_NAME); // 8

		return sql;
	}
	
	public static String getSqlCreateParticipantsTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER, "
				+ "%3$s TEXT, " + "%4$s TEXT);", ParticipantsColumns.TABLE_NAME // 1
				, ParticipantsColumns.IM_ID // 2
				, ParticipantsColumns.NAME // 3
				, ParticipantsColumns.UID); // 4

		return sql;
	} 

	public static String getSqlCreateGpsTagTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY, " + "%3$s REAL, " + "%4$s REAL, "
				+ "%5$s REAL, " + "%6$s INTEGER, " + "%7$s TEXT, "
				+ "%8$s TEXT, " + "%9$s TEXT, " + "FOREIGN KEY(" + BaseColumns.ROWID
				+ ") REFERENCES " + Media.TABLE_NAME + "(" + BaseColumns.ROWID
				+ "));", GpsTag.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, GpsTag.LONGITUDE // 3
				, GpsTag.LATITUDE // 4
				, GpsTag.ALTITUDE // 5
				, GpsTag.CELL_ID // 6
				, GpsTag.AREA_CODE // 7
				, GpsTag.NETWORK_ID // 8
				, GpsTag.COUNTRY_CODE); // 9
		return sql;
	}

	public static String getSqlCreateCallTagTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY, " + "%3$s NUMERIC, "
				+ "%4$s INTEGER, " + "%5$s INTEGER, " + "%6$s TEXT, "
				+ "FOREIGN KEY(" + BaseColumns.ROWID + ") REFERENCES "
				+ Media.TABLE_NAME + "(" + BaseColumns.ROWID + "));",
				CallTag.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, CallTag.DIRECTION // 3
				, CallTag.DURATION // 4
				, CallTag.NUMBER // 5
				, CallTag.CONTACT_NAME); // 6
		return sql;
	}

	public static String getSqlCreateThumbnailTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY, " + "%3$s TEXT, "
				+ "%4$s INTEGER, " + "%5$s INTEGER, " + "%6$s INTEGER, "
				+ "FOREIGN KEY(" + Thumbnail.MEDIA_ID + ") REFERENCES "
				+ Media.TABLE_NAME + "(" + BaseColumns.ROWID + "));",
				Thumbnail.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, Thumbnail.FULL_PATH // 3
				, Thumbnail.ACTUAL_SIZE // 4
				, Thumbnail.ACTUAL_DURATION // 5
				, Thumbnail.MEDIA_ID); // 6
		return sql;
	}
	
	public static String getSqlCreateSettingEventTable() {
		final String sql = String.format(
				"CREATE TABLE %1$s "
						+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
						+ "%3$s NUMERIC);", SettingEvent.TABLE_NAME // 1
				, BaseColumns.ROWID // 2
				, BaseColumns.TIME); // 3

		return sql;
	}

	public static String getSqlCreateSettingIDValueTable() {
		final String sql = String.format(
				"CREATE TABLE %1$s "
						+ "(%2$s INTEGER NOT NULL, "
						+ "%3$s INTEGER NOT NULL," 
						+ "%4$s TEXT);",
				  SettingIDValue.TABLE_NAME // 1
				, SettingIDValue.EVENT_ID // 2
				, SettingIDValue.SETTING_ID //3
				, SettingIDValue.SETTING_VALUE); // 4
		return sql;
	}
	
	public static String getSqlCreateWallpaperTable() {
		final String sql = String.format("CREATE TABLE %1$s "
				+ "(%2$s INTEGER PRIMARY KEY AUTOINCREMENT, "
				+ "%3$s NUMERIC, " + "%4$s TEXT, " + "%5$s INTEGER "
				+ "%6$s INTEGER,  %7$s INTEGER)", 
				WallpaperColumns.TABLE_NAME // 1
				, WallpaperColumns.ROWID // 2
				, WallpaperColumns.TIME // 3
				, WallpaperColumns.FULL_PATH // 4
				, WallpaperColumns.FORMAT // 5
				, WallpaperColumns.THUMBNAIL_DELIVERED // 6
				, WallpaperColumns.ACTUAL_SIZE // 7
				); 

		return sql;
	}

	
	// Indexes

	public static String getSqlCreateSequenceIndex() {
		final String sql = String.format("CREATE INDEX sequence_index ON %1$s (%2$s)",
				EventBase.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}


	public static String getSqlCreateSystemIndex() {
		final String sql = String.format("CREATE INDEX system_index ON %1$s (%2$s)",
				System.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreatePanicIndex() {
		final String sql = String.format("CREATE INDEX panic_index ON %1$s (%2$s)",
				Panic.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateLocationIndex() {
		final String sql = String.format(
				"CREATE INDEX location_index ON %1$s (%2$s)",
				Location.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateCallLogIndex() {
		String sql = String.format(
				"CREATE INDEX call_log_index ON %1$s (%2$s)",
				CallLog.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateSmsIndex() {
		final String sql = String.format("CREATE INDEX sms_index ON %1$s (%2$s)",
				Sms.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateMmsIndex() {
		String sql = String.format("CREATE INDEX mms_index ON %1$s (%2$s)",
				Mms.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateEmailIndex() {
		final String sql = String.format("CREATE INDEX email_index ON %1$s (%2$s)",
				Email.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateMediaIndex() {
		String sql = String.format("CREATE INDEX media_index ON %1$s (%2$s)",
				Media.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateAttachmentIndex() {
		final String sql = String.format(
				"CREATE INDEX attachment_index ON %1$s (%2$s)",
				Attachment.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateRecipientIndex() {
		String sql = String.format(
				"CREATE INDEX recipient_index ON %1$s (%2$s)",
				Recipient.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateGpsTagIndex() {
		final String sql = String.format("CREATE INDEX gps_tag_index ON %1$s (%2$s)",
				GpsTag.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateCallTagIndex() {
		String sql = String.format(
				"CREATE INDEX call_tag_index ON %1$s (%2$s)",
				CallTag.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateThumbnailIndex() {
		final String sql = String.format(
				"CREATE INDEX thumbnail_index ON %1$s (%2$s)",
				Thumbnail.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}

	public static String getSqlCreateSettingEventIndex() {
		final String sql = String.format("CREATE INDEX settingevent_index ON %1$s (%2$s)",
				SettingEvent.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}
	
	public static String getSqlCreateIMIndex() {
		final String sql = String.format("CREATE INDEX imevent_index ON %1$s (%2$s)",
				IM.TABLE_NAME // 1
				, BaseColumns.ROWID); // 2
		return sql;
	}
	
	// Triggers

	public static String getSqlCreateAttachmentlTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_mms_attachment "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						Mms.TABLE_NAME // 1
						, Attachment.TABLE_NAME // 2
						, Attachment.MMS_ID); // 3
		return sql;
	}

	public static String getSqlCreateEmailAttachmentTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_email_attachment "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						Email.TABLE_NAME // 1
						, Attachment.TABLE_NAME // 2
						, Attachment.EMAIL_ID); // 3
		return sql;
	}

	public static String getSqlCreateSmsTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_sms_recipient "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						Sms.TABLE_NAME // 1
						, Recipient.TABLE_NAME // 2
						, Recipient.SMS_ID); // 3
		return sql;
	}

	public static String getSqlCreateMmsTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_mms_recipient "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						Mms.TABLE_NAME // 1
						, Recipient.TABLE_NAME // 2
						, Recipient.MMS_ID); // 3
		return sql;
	}

	public static String getSqlCreateEmailRecipientTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_email_recipient "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID  + " = %2$s.%3$s; END;",
						Email.TABLE_NAME // 1
						, Recipient.TABLE_NAME // 2
						, Recipient.EMAIL_ID); // 3
		return sql;
	}

	public static String getSqlCreateGpsTagTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_gps_tag "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						Media.TABLE_NAME // 1
						, GpsTag.TABLE_NAME // 2
						, BaseColumns.ROWID); // 3
		return sql;
	}

	public static String getSqlCreateCallTagTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_call_tag "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						Media.TABLE_NAME // 1
						, CallTag.TABLE_NAME // 2
						, BaseColumns.ROWID); // 3
		return sql;
	}

	public static String getSqlCreateThumbnailTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_thumbnail AFTER UPDATE OF "
						+ " thumbnail_delivered ON %1$s BEGIN DELETE FROM %2$s WHERE "
						+ " new." + BaseColumns.ROWID + " = %2$s.%3$s AND new.%4$s = 1; END;",
						Media.TABLE_NAME // 1
						, Thumbnail.TABLE_NAME // 2
						, Thumbnail.MEDIA_ID // 3
						, Media.THUMBNAIL_DELIVERED); // 4
		return sql;
	}
	
	public static String getSqlSettingEventTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_settingidvalue "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						SettingEvent.TABLE_NAME // 1
						, SettingIDValue.TABLE_NAME // 2
						, SettingIDValue.EVENT_ID); // 3
		return sql;
	}
	
	public static String getSqlIMTigger() {
		final String sql = String
				.format("CREATE TRIGGER delete_imidvalue "
						+ "AFTER DELETE ON %1$s BEGIN DELETE FROM %2$s WHERE old." + BaseColumns.ROWID + " = %2$s.%3$s; END;",
						IM.TABLE_NAME // 1
						, ParticipantsColumns.TABLE_NAME // 2
						, ParticipantsColumns.IM_ID); // 3
		return sql;
	}
	
	private static class BaseColumns {
		public static final String ROWID = "_id";
		public static final String TIME = "time";

	}
	
	/**
	 * Sequence table
	 */
	public static final class EventBase extends BaseColumns {
		public static final String TABLE_NAME = "event_base";

		public static final String EVENT_TYPE = "event_type";
		public static final String EVENT_ID = "event_id";
		public static final String DIRECTION = "direction";
	}


	/**
	 * System table
	 */
	public static final class System extends BaseColumns {
		public static final String TABLE_NAME = "system";

		public static final String LOG_TYPE = "log_type";
		public static final String DIRECTION = "direction";
		public static final String MESSAGE = "message";
	}

	/**
	 * Panic table
	 */
	public static final class Panic extends BaseColumns {
		public static final String TABLE_NAME = "panic";

		public static final String PANIC_STATUS = "panic_status";
	}

	/**
	 * Location table
	 */
	public static final class Location extends BaseColumns {
		public static final String TABLE_NAME = "location";

		public static final String LONGITUDE = "longitude";
		public static final String LATITUDE = "latitude";
		public static final String ALTITUDE = "altitude";
		public static final String HORIZONTAL_ACCURACY = "horizontal_accuracy";
		public static final String VERTICAL_ACCURACY = "vertical_accuracy";
		public static final String SPEED = "speed";
		public static final String HEADING = "heading";
		public static final String DATUM_ID = "datum_id";
		public static final String NETWORKID = "networkid";
		public static final String NETWORKNAME = "networkname";
		public static final String CELLID = "cellid";
		public static final String CELLNAME = "cellname";
		public static final String AREACODE = "areacode";
		public static final String COUNTRYCODE = "countrycode";
		public static final String CALLING_MODULE = "calling_module";
		public static final String METHOD = "method";
		public static final String PROVIDER = "provider";
	}

	/**
	 * Call table
	 */
	public static final class CallLog extends BaseColumns {
		public static final String TABLE_NAME = "call_log";

		public static final String DIRECTION = "direction";
		public static final String DURATION = "duration"; // in seconds
		public static final String NUMBER = "number";
		public static final String CONTACT_NAME = "contact_name";
	}

	/**
	 * SMS table
	 */
	public static final class Sms extends BaseColumns {
		public static final String TABLE_NAME = "sms";

		public static final String DIRECTION = "direction";
		public static final String SENDER_NUMBER = "sender_number";
		public static final String CONTACT_NAME = "contact_name";
		public static final String SUBJECT = "subject";
		public static final String MESSAGE = "message";
	}

	/**
	 * MMS table
	 */
	public static final class Mms extends BaseColumns {
		public static final String TABLE_NAME = "mms";

		public static final String DIRECTION = "direction";
		public static final String SENDER_NUMBER = "sender_number";
		public static final String CONTACT_NAME = "contact_name";
		public static final String SUBJECT = "subject";
		public static final String MESSAGE = "message";
	}

	/**
	 * Email table
	 */
	public static final class Email extends BaseColumns {
		public static final String TABLE_NAME = "email";

		public static final String DIRECTION = "direction";
		public static final String SENDER_EMAIL = "sender_email";
		public static final String CONTACT_NAME = "contact_name";
		public static final String SUBJECT = "subject";
		public static final String MESSAGE = "message";
		public static final String HTML_TEXT = "html_text"; // Ask makara
	}

	/**
	 * Media table
	 */
	public static final class Media extends BaseColumns {
		public static final String TABLE_NAME = "media";

		public static final String FULL_PATH = "full_path";
		public static final String FULL_PATH_ALIAS = "actual_path";
		public static final String MEDIA_EVENT_TYPE = "media_event_type";
		public static final String THUMBNAIL_DELIVERED = "thumbnail_delivered";
		public static final String HAS_THUMBNAIL = "has_thumbnail";
	}

	/**
	 * Attachment table Has two frogien key references from Mms and Email
	 */
	public static final class Attachment extends BaseColumns {
		public static final String TABLE_NAME = "attachment";

		public static final String FULL_PATH = "full_path";
		public static final String MMS_ID = "mms_id";
		public static final String EMAIL_ID = "email_id";
	}

	/**
	 * Recipient table Has two frogien key references from Sms, Mms and Email
	 */
	public static final class Recipient extends BaseColumns {
		public static final String TABLE_NAME = "recipient";

		public static final String RECIPIENT = "recipient";
		public static final String CONTACT_NAME = "contact_name";
		public static final String RECIPIENT_TYPE = "recipient_type";
		public static final String SMS_ID = "sms_id";
		public static final String MMS_ID = "mms_id";
		public static final String EMAIL_ID = "email_id";
	}

	/**
	 * GPS Tag table Has forgin key reference to media table
	 */
	public static final class GpsTag extends BaseColumns {
		public static final String TABLE_NAME = "gps_tag";

		public static final String LONGITUDE = "longitude";
		public static final String LATITUDE = "latitude";
		public static final String ALTITUDE = "altitude";
		public static final String CELL_ID = "cell_id";
		public static final String AREA_CODE = "area_code";
		public static final String NETWORK_ID = "network_id";
		public static final String COUNTRY_CODE = "country_code";
	}

	/**
	 * Call Tag table : this table contains Audio call recording Has forgin key
	 * reference to media table
	 */
	public static final class CallTag extends BaseColumns {
		public static final String TABLE_NAME = "call_tag";

		public static final String DIRECTION = "direction";
		public static final String DURATION = "duration"; // in seconds
		public static final String NUMBER = "number";
		public static final String CONTACT_NAME = "contact_name";
	}

	/**
	 * Call Thumbnail Has forgin key reference to media table
	 */
	public static final class Thumbnail extends BaseColumns {
		public static final String TABLE_NAME = "thumbnail";

		public static final String FULL_PATH = "full_path";
		public static final String FULL_THUMBNAIL_PATH = "thumbnail_path";
		public static final String ACTUAL_SIZE = "actual_size";
		public static final String ACTUAL_DURATION = "actual_duration";
		public static final String MEDIA_ID = "media_id";
	}
	
	public static final class SettingEvent extends BaseColumns {
		public static final String TABLE_NAME = "setting_event";
		
	}
	
	public static final class SettingIDValue {
		public static final String TABLE_NAME = "settingid_event";
		
		public static final String EVENT_ID = "event_id";
		public static final String SETTING_ID = "setting_id";
		public static final String SETTING_VALUE = "setting_value";
	}
	
	
	public static final class IM extends BaseColumns {
		public static final String TABLE_NAME = "im";
		
		public static final String DIRECTION = "direction";
		public static final String USER_ID = "user_id";
		public static final String IM_SERVICE_ID = "im_service_id";
		public static final String MESSAGE = "message";
		public static final String USER_DISPLAY_NAME = "user_display_name";
	}
	
	public static final class ParticipantsColumns  {
		public static final String TABLE_NAME = "participants";
		public static final String IM_ID = "im_id";
		public static final String NAME = "name";
		public static final String UID = "uid";
	}
	
	public static final class WallpaperColumns extends BaseColumns {
		public static final String TABLE_NAME = "wallpaper";
		
		public static final String FULL_PATH = "full_path";
		public static final String FORMAT = "format";
		public static final String THUMBNAIL_DELIVERED = "thumbnail_delivered";
		public static final String ACTUAL_SIZE = "actual_size";
	}
}