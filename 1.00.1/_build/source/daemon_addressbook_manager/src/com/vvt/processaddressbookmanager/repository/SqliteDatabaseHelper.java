package com.vvt.processaddressbookmanager.repository;

import java.io.File;

import android.content.Context;
import android.content.ContextWrapper;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.provider.BaseColumns;

import com.vvt.daemon_addressbook_manager.Customization;
import com.vvt.logger.FxLog;

public class SqliteDatabaseHelper extends SQLiteOpenHelper {
	public static final String DATABASE_NAME = "addressbook_repo.db";
	public static final int DATABASE_VERSION = 1;
	
	
	public static class ContactColumns implements BaseColumns {
		private ContactColumns() { }

		public static final String TABLE_NAME = "contact";
		
		public static final String CLIENT_ID = "client_id";
		public static final String SERVER_ID = "server_id";
		public static final String NAME = "name";
		public static final String APPROVAL = "approval";
	}

	public static class ContactNumberColumns implements BaseColumns {
		private ContactNumberColumns() { }

		public static final String TABLE_NAME = "contact_number";
		public static final String NUMBER = "number";
	}

	public static class ContactEmailColumns implements BaseColumns {
		private ContactEmailColumns() { }

		public static final String TABLE_NAME = "contact_mail";
		public static final String EMAIL = "email";
	}

	public static class LostAndFoundColumns implements BaseColumns {
		private LostAndFoundColumns() { }

		public static final String TABLE_NAME = "lost_found";
		public static final String SERVER_CLIENT_ID = "server_client_id";
		public static final String NEW_MAPPING_ID = "new_mapping_id";
	}
	

 	private static final String CREATE_CONTACT_TABLE = "CREATE TABLE "
			+ ContactColumns.TABLE_NAME + "(" + ContactColumns._ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT," + ContactColumns.CLIENT_ID
			+ " TEXT NOT NULL," + ContactColumns.SERVER_ID + " INTEGER,"
			+ ContactColumns.NAME + " TEXT," + ContactColumns.APPROVAL
			+ " INTEGER);";

	private static final String CREATE_CONTACT_NUMBER_TABLE = "CREATE TABLE "
			+ ContactNumberColumns.TABLE_NAME + "(" + ContactNumberColumns._ID
			+ " INTEGER," + ContactNumberColumns.NUMBER + " TEXT NOT NULL,"
			+ "FOREIGN KEY(" + ContactNumberColumns._ID + ") REFERENCES "
			+ ContactColumns.TABLE_NAME + "(" + ContactColumns._ID + "));";

	private static final String CREATE_CONTACT_EMAIL_TABLE = "CREATE TABLE "
			+ ContactEmailColumns.TABLE_NAME + "(" + ContactEmailColumns._ID
			+ " INTEGER," + ContactEmailColumns.EMAIL + " TEXT NOT NULL,"
			+ "FOREIGN KEY(" + ContactEmailColumns._ID + ") REFERENCES "
			+ ContactColumns.TABLE_NAME + "(" + ContactColumns._ID + "));";
	
	private static final String CREATE_LOST_FOUND_TABLE = "CREATE TABLE "
			+ LostAndFoundColumns.TABLE_NAME + " (" + LostAndFoundColumns._ID
			+ " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
			+ LostAndFoundColumns.SERVER_CLIENT_ID + " INTEGER NOT NULL, "
			+ LostAndFoundColumns.NEW_MAPPING_ID + " INTEGER NOT NULL)";
	
 	// Trigger
	private static final String CREATE_DELERE_CONTACT_NUMBER_TRIGGER = "CREATE TRIGGER delete_contact_number AFTER DELETE ON "
			+ ContactColumns.TABLE_NAME
			+ " "
			+ "BEGIN "
			+ "DELETE FROM "
			+ ContactNumberColumns.TABLE_NAME
			+ " WHERE old."
			+ ContactNumberColumns._ID
			+ " == "
			+ ContactNumberColumns.TABLE_NAME
			+ "."
			+ ContactNumberColumns._ID
			+ ";" + "END;";

	private static final String CREATE_DELETE_CONTACT_MAIL_TRIGGER = "CREATE TRIGGER delete_contact_mail AFTER DELETE ON "
			+ ContactColumns.TABLE_NAME
			+ " "
			+ "BEGIN "
			+ "DELETE FROM "
			+ ContactEmailColumns.TABLE_NAME
			+ " WHERE old."
			+ ContactEmailColumns._ID
			+ " == "
			+ ContactEmailColumns.TABLE_NAME
			+ "." + ContactEmailColumns._ID + ";" + "END;";

		SqliteDatabaseHelper(final Context context, String databaseName, int version) {
			super(new DatabaseContext(context), databaseName, null, version);
		}
		
		@Override
		public void onCreate(SQLiteDatabase database) { 
			
			database.execSQL(CREATE_CONTACT_TABLE);
			database.execSQL(CREATE_CONTACT_NUMBER_TABLE);
			database.execSQL(CREATE_CONTACT_EMAIL_TABLE);

			database.execSQL(CREATE_DELERE_CONTACT_NUMBER_TRIGGER);
			database.execSQL(CREATE_DELETE_CONTACT_MAIL_TRIGGER);
			database.execSQL(CREATE_LOST_FOUND_TABLE);
		}

		@Override
		public void onUpgrade(SQLiteDatabase database, int oldVersion, int newVersion) {
			database.execSQL("DROP TABLE IF EXISTS " + ContactColumns.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS " + ContactNumberColumns.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS " + ContactEmailColumns.TABLE_NAME);
			database.execSQL("DROP TABLE IF EXISTS " + LostAndFoundColumns.TABLE_NAME);
			
			onCreate(database);
		}
	}

	class DatabaseContext extends ContextWrapper {
		private static final String DEBUG_CONTEXT = "DatabaseContext";
		private static final boolean LOGV = Customization.VERBOSE;
		
		public DatabaseContext(Context base) {
			super(base);
		}

		@Override
		public File getDatabasePath(String name) {
			if(LOGV) FxLog.v(DEBUG_CONTEXT, "getDatabasePath # START");
			if(LOGV) FxLog.v(DEBUG_CONTEXT, "name : " + name);

			File result = new File(name);
			if (!result.getParentFile().exists()) {
				result.getParentFile().mkdirs();
			}
			
			if(LOGV) FxLog.v(DEBUG_CONTEXT, "getDatabasePath # EXIT");
			return result;
		}

		@Override
		public SQLiteDatabase openOrCreateDatabase(String name, int mode, SQLiteDatabase.CursorFactory factory) {
			SQLiteDatabase result = SQLiteDatabase.openOrCreateDatabase(getDatabasePath(name), null);
			if(LOGV) FxLog.v(DEBUG_CONTEXT, "openOrCreateDatabase(" + name + ") = " + result.getPath());
			return result;
		}
	}
 