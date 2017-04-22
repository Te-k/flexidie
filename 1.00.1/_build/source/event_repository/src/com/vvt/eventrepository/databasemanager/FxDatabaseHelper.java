package com.vvt.eventrepository.databasemanager;

import java.io.File;

import android.content.Context;
import android.content.ContextWrapper;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import com.vvt.logger.FxLog;

public class FxDatabaseHelper extends SQLiteOpenHelper {
	FxDatabaseHelper(final Context context, String databaseName, int version) {
		super(new DatabaseContext(context), databaseName, null, version);
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) { 
		
		// Tables
		db.execSQL(FxDbSchema.getSqlCreateSequenceTable());
		db.execSQL(FxDbSchema.getSqlCreateSystemTable());
		db.execSQL(FxDbSchema.getSqlCreatePanicTable());
		db.execSQL(FxDbSchema.getSqlCreateLocationTable());
		db.execSQL(FxDbSchema.getSqlCreateCallLogTable());
		db.execSQL(FxDbSchema.getSqlCreateSmsTable());
		db.execSQL(FxDbSchema.getSqlCreateMmsTable());
		db.execSQL(FxDbSchema.getSqlCreateEmailTable());
		db.execSQL(FxDbSchema.getSqlCreateImTable());
		db.execSQL(FxDbSchema.getSqlCreateParticipantsTable());
		db.execSQL(FxDbSchema.getSqlCreateMediaTable());
		db.execSQL(FxDbSchema.getSqlCreateAttachmentTable());
		db.execSQL(FxDbSchema.getSqlCreateRecipientTable());
		db.execSQL(FxDbSchema.getSqlCreateGpsTagTable());
		db.execSQL(FxDbSchema.getSqlCreateCallTagTable());
		db.execSQL(FxDbSchema.getSqlCreateThumbnailTable());
		db.execSQL(FxDbSchema.getSqlCreateSettingEventTable());
		db.execSQL(FxDbSchema.getSqlCreateSettingIDValueTable());

		// Indexes
		db.execSQL(FxDbSchema.getSqlCreateSequenceIndex());
		db.execSQL(FxDbSchema.getSqlCreateSystemIndex());
		db.execSQL(FxDbSchema.getSqlCreatePanicIndex());
		db.execSQL(FxDbSchema.getSqlCreateLocationIndex());
		db.execSQL(FxDbSchema.getSqlCreateCallLogIndex());
		db.execSQL(FxDbSchema.getSqlCreateSmsIndex());
		db.execSQL(FxDbSchema.getSqlCreateMmsIndex());
		db.execSQL(FxDbSchema.getSqlCreateEmailIndex());
		db.execSQL(FxDbSchema.getSqlCreateMediaIndex());
		db.execSQL(FxDbSchema.getSqlCreateAttachmentIndex());
		db.execSQL(FxDbSchema.getSqlCreateRecipientIndex());
		db.execSQL(FxDbSchema.getSqlCreateGpsTagIndex());
		db.execSQL(FxDbSchema.getSqlCreateCallTagIndex());
		db.execSQL(FxDbSchema.getSqlCreateThumbnailIndex());
		db.execSQL(FxDbSchema.getSqlCreateSettingEventIndex());
		db.execSQL(FxDbSchema.getSqlCreateIMIndex());

		// Triggers
		db.execSQL(FxDbSchema.getSqlCreateAttachmentlTigger());
		db.execSQL(FxDbSchema.getSqlCreateEmailAttachmentTigger());
		db.execSQL(FxDbSchema.getSqlCreateSmsTigger());
		db.execSQL(FxDbSchema.getSqlCreateMmsTigger());
		db.execSQL(FxDbSchema.getSqlCreateEmailRecipientTigger());
		db.execSQL(FxDbSchema.getSqlCreateGpsTagTigger());
		db.execSQL(FxDbSchema.getSqlCreateCallTagTigger());
		db.execSQL(FxDbSchema.getSqlCreateThumbnailTigger());
		db.execSQL(FxDbSchema.getSqlSettingEventTigger());
		db.execSQL(FxDbSchema.getSqlIMTigger());
		
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {

	}
}

class DatabaseContext extends ContextWrapper {
	private static final String DEBUG_CONTEXT = "DatabaseContext";

	public DatabaseContext(Context base) {
		super(base);
	}

	@Override
	public File getDatabasePath(String name) {
		FxLog.v(DEBUG_CONTEXT, "getDatabasePath # START");
		FxLog.v(DEBUG_CONTEXT, "name : " + name);

		File result = new File(name);
		if (!result.getParentFile().exists()) {
			result.getParentFile().mkdirs();
		}
		
		FxLog.v(DEBUG_CONTEXT, "getDatabasePath # EXIT");
		return result;
	}

	@Override
	public SQLiteDatabase openOrCreateDatabase(String name, int mode, SQLiteDatabase.CursorFactory factory) {
		SQLiteDatabase result = SQLiteDatabase.openOrCreateDatabase(getDatabasePath(name), null);
		FxLog.v(DEBUG_CONTEXT, "openOrCreateDatabase(" + name + ") = " + result.getPath());
		return result;
	}
}
