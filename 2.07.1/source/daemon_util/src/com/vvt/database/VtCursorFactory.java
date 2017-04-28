package com.vvt.database;

import android.database.Cursor;
import android.database.sqlite.SQLiteCursorDriver;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteQuery;
import android.database.sqlite.SQLiteDatabase.CursorFactory;

public class VtCursorFactory implements CursorFactory {

	public Cursor newCursor(SQLiteDatabase db, SQLiteCursorDriver masterQuery, 
			String editTable, SQLiteQuery query) {
		
		return new VtCursor(db, masterQuery, editTable, query);
	}

}
