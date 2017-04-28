package com.vvt.database;

import android.database.sqlite.SQLiteCursor;
import android.database.sqlite.SQLiteCursorDriver;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQuery;

public class VtCursor extends SQLiteCursor {

	private SQLiteDatabase mDatabase;
	
	public VtCursor(SQLiteDatabase db, SQLiteCursorDriver driver, String editTable, SQLiteQuery query) {
		super(db, driver, editTable, query);
		mDatabase = db;
	}
	
	@Override
	public void close() {
		super.close();
		if (mDatabase != null) {
			mDatabase.close();
		}
	}

}
