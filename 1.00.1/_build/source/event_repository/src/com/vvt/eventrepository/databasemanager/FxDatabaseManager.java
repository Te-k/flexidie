package com.vvt.eventrepository.databasemanager;

import java.io.File;
import java.io.IOException;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.logger.FxLog;
 
/**
 * Exposes methods to manage a SQLite database. 
 * 
 * @author aruna
 * @version 1.0
 * @created 29-Aug-2011 04:19:34
 */
 
public class FxDatabaseManager {
	private final static String TAG = "FxDatabaseManager";
	
	private SQLiteDatabase m_SQLiteDatabase = null;
	private Context mContext;
	private String mWritablePath;
	
	public FxDatabaseManager(Context context, String writablePath) {
		mContext = context;
		mWritablePath = writablePath;
	}
	
	
	public SQLiteDatabase getDb() {
		return m_SQLiteDatabase;
	}
	
	/**
	 * Open the database. If the database does not exisit application will
	 * create new database with the structure in it.
	 * 
	 * @throws FxDbOpenException
	 *             If there are any errors while creating.
	 */
	public void openDb() throws FxDbOpenException, FxDbCorruptException {
		
		if(m_SQLiteDatabase == null) {
			try {
				String dbfile = FxDbSchema.getDbFullPath(mWritablePath);
				// Android will create the database for us and run onCreate in FxDatabaseHelper. Check the FxDatabaseHelper onCreate for table strure sql
				/*FxDatabaseHelper dbHelper = new FxDatabaseHelper(mContext, dbfile, null, FxDbSchema.DATABASE_VERSION);*/
				FxDatabaseHelper dbHelper = new FxDatabaseHelper(mContext, dbfile, FxDbSchema.DATABASE_VERSION);
				
				m_SQLiteDatabase = dbHelper.getWritableDatabase();
			}
			catch(SQLiteDatabaseCorruptException ex) {
				throw new FxDbCorruptException();
			} catch (Throwable ex) {
				FxLog.e(TAG, ex.toString());
				
				throw new FxDbOpenException("An error occured opening the database. Please check inner exception for details.", ex);
			}
		} else if(!m_SQLiteDatabase.isOpen()) {
			closeDb();
			openDb();
		}
	}

	/***
	 * Close the database
	 */
	public void closeDb() {
		if (m_SQLiteDatabase != null && m_SQLiteDatabase.isOpen()) {
			m_SQLiteDatabase.close();
			m_SQLiteDatabase = null;
		}
	}

	/**
	 * Deletes the underlying database.
	 * 
	 * @throws IOException
	 * @returns True if the database was successfully deleted; else false.
	 */
	public boolean dropDb() throws IOException {
		// Close the database
		closeDb();

		String dbfile = FxDbSchema.getDbFullPath(mWritablePath);
		return mContext.deleteDatabase(dbfile);
	}
	
	/***
	 * Check whether internal database is open
	 * @return
	 */
	public boolean isDbOpen() {
		if(m_SQLiteDatabase != null)
			return m_SQLiteDatabase.isOpen();
		else
			return false;
	}


	public long getDBSize() {
		try {
			String dbfile = FxDbSchema.getDbFullPath(mWritablePath);
			File db = new File(dbfile);
			return db.length();
		} catch (IOException e) {
			 return 0;
		}
	}


	public void cleanDb() {
		 
	}

}