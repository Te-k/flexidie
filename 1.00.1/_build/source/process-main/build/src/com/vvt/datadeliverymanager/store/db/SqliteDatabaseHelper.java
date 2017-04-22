package com.vvt.datadeliverymanager.store.db;

import java.io.File;

import android.content.Context;
import android.content.ContextWrapper;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.logger.FxLog;

/*public class SqliteDatabaseHelper  extends SQLiteOpenHelper {



 public SqliteDatabaseHelper(Context context, String name,
 CursorFactory factory, int version) {
 super(context, name, factory, version);
 }


 }*/

public class SqliteDatabaseHelper extends SQLiteOpenHelper {
	public static final String DATABASE_NAME = "ddmmgr.db";
	public static final int DATABASE_VERSION = 1;
	
	// Database creation sql statement
	private static final String DATABASE_CREATE = "CREATE TABLE ddm (_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
			+ " caller_id INTEGER, "
			+ " cmd_id INTEGER, "
			+ " priority_request INTEGER, "
			+ " delivery_request_type INTEGER, "
			+ " csId INTEGER, "
			+ " ready_to_resume BOOLEAN, "
			+ " retry_count INTEGER, "
			+ " max_retry_count INTEGER, "
			+ " data_provider_type INTEGER, "
			+ " is_require_encryption INTEGER, "
			+ " is_require_compression INTEGER, " + " delay_time INTEGER);";

	SqliteDatabaseHelper(final Context context, String databaseName, int version) {
		super(new DatabaseContext(context), databaseName, null, version);
	}

	// Method is called during creation of the database
	@Override
	public void onCreate(SQLiteDatabase database) {
		database.execSQL(DATABASE_CREATE);
	}

	// Method is called during an upgrade of the database, e.g. if you increase
	// the database version
	@Override
	public void onUpgrade(SQLiteDatabase database, int oldVersion,
			int newVersion) {

		database.execSQL("DROP TABLE IF EXISTS ddm");
		onCreate(database);
	}
}

class DatabaseContext extends ContextWrapper {
	private static final String DEBUG_CONTEXT = "DatabaseContext";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;


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
	public SQLiteDatabase openOrCreateDatabase(String name, int mode,
			SQLiteDatabase.CursorFactory factory) {
		SQLiteDatabase result = SQLiteDatabase.openOrCreateDatabase(
				getDatabasePath(name), null);
		if(LOGV) FxLog.v(DEBUG_CONTEXT,
				"openOrCreateDatabase(" + name + ") = " + result.getPath());
		return result;
	}
}
