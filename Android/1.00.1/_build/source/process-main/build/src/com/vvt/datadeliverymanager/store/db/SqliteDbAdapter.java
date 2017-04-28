package com.vvt.datadeliverymanager.store.db;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.ioutil.Path;
import com.vvt.logger.FxLog;

public class SqliteDbAdapter {
	
	private static final String TAG = "SqliteDbAdapter";
	private static final boolean LOGE = Customization.ERROR;
	private static final boolean LOGD = Customization.DEBUG;

	// Database fields
	public static final String KEY_ROWID = "_id";
	public static final String KEY_CALLER_ID = "caller_id";
	public static final String KEY_CMD_ID = "cmd_id";
	public static final String KEY_PRIORITY_REQUEST = "priority_request";
	public static final String KEY_DELIVERY_REQUEST_TYPE = "delivery_request_type";
	public static final String KEY_CSID = "csId";
	
	public static final String KEY_RETRY_COUNT = "retry_count";
	public static final String KEY_MAX_RETRY_COUNT = "max_retry_count";
	public static final String KEY_DATA_PROVIDER_TYPE = "data_provider_type";
	public static final String KEY_DELAY_TIME =  "delay_time";
	public static final String KEY_IS_READY_TO_RESUME = "ready_to_resume";
	public static final String KEY_IS_REQUIRE_ENCRYPTION = "is_require_encryption";
	public static final String KEY_IS_REQUIRE_COMPRESSION = "is_require_compression";
	
	
	private static final String DATABASE_TABLE = "ddm";
	
	private Context mContext;
	private SQLiteDatabase mDatabase;
	private SqliteDatabaseHelper mDbHelper;
	private String mWritablePath;
	
	public SqliteDbAdapter(Context context, String path) {
		mContext = context;
		mWritablePath = path;
		
		String dbfile = Path.combine(mWritablePath, SqliteDatabaseHelper.DATABASE_NAME);
		mDbHelper = new SqliteDatabaseHelper(mContext, dbfile, SqliteDatabaseHelper.DATABASE_VERSION);
	}

	public SqliteDbAdapter open() throws SQLException {
		mDatabase = mDbHelper.getWritableDatabase();
		return this;
	}

	public void close() {
		mDbHelper.close();
	}

	public Cursor fetchAllDeliveryRequest() {

		// Higher priority requests then by older requests
		String orderBy = KEY_PRIORITY_REQUEST + " DESC, " + KEY_ROWID;
		
		boolean isOpenFail = true;
		int tryCount = 0;
		Cursor result = null;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"fetchAllDeliveryRequest # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				result = mDatabase.query(DATABASE_TABLE, new String[] { KEY_ROWID,
						KEY_CALLER_ID, KEY_CMD_ID, KEY_PRIORITY_REQUEST, KEY_DELIVERY_REQUEST_TYPE,
						KEY_CSID, KEY_IS_READY_TO_RESUME, KEY_RETRY_COUNT, KEY_MAX_RETRY_COUNT, KEY_DATA_PROVIDER_TYPE, KEY_DELAY_TIME,
						KEY_IS_REQUIRE_ENCRYPTION, KEY_IS_REQUIRE_COMPRESSION}, null, null, null,
						null, orderBy);
				
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result;
	}
	
	public boolean delete(long csid) {
		String where = KEY_CSID + "=" + csid;
		
		boolean isOpenFail = true;
		int tryCount = 0;
		int result = 0;
		do {
			try{
				
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"delete # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				result = mDatabase.delete(DATABASE_TABLE, where, null);
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return  result > 0;
	}
	
	public long insert(DeliveryRequest request) {
		ContentValues initialValues = createContentValues(request);
		boolean isOpenFail = true;
		int tryCount = 0;
		long id = -1;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGD) FxLog.d(TAG,"insert # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				id = mDatabase.insert(DATABASE_TABLE, null, initialValues);
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		return id;
	}
	
	private ContentValues createContentValues(DeliveryRequest request) {
		
		ContentValues values = new ContentValues();
		values.put(KEY_CALLER_ID, request.getCallerID());
		values.put(KEY_CMD_ID, request.getCommandData().getCmd());
		values.put(KEY_PRIORITY_REQUEST, request.getRequestPriority().getNumber());
		values.put(KEY_DELIVERY_REQUEST_TYPE, request.getDeliveryRequestType().getNumber());
		values.put(KEY_CSID, request.getCsId());
		values.put(KEY_IS_READY_TO_RESUME, request.isReadyToResume());
		values.put(KEY_RETRY_COUNT, request.getRetryCount());
		values.put(KEY_DATA_PROVIDER_TYPE, request.getDataProviderType().getNumber());
		values.put(KEY_MAX_RETRY_COUNT, request.getMaxRetryCount());
		values.put(KEY_DELAY_TIME, request.getDelayTime());
		values.put(KEY_IS_REQUIRE_ENCRYPTION , (request.isRequireEncryption() ? 1 : 0 ));
		values.put(KEY_IS_REQUIRE_COMPRESSION , (request.isRequireCompression() ? 1 : 0 ));
		
		return values;
	}
	
	private ContentValues createContentValues(
			PriorityRequest priorityRequest,
			DeliveryRequestType deliveryRequestType,
			long csId,
			boolean canRetry,
			int retryCount,
			int maxRetryCount,
			DataProviderType dataProviderType,
			long maxDelayTime,
			boolean isRequireEncryption,
			boolean isRequireCompression) {
		
		ContentValues values = new ContentValues();
		values.put(KEY_PRIORITY_REQUEST, priorityRequest.getNumber());
		values.put(KEY_DELIVERY_REQUEST_TYPE, deliveryRequestType.getNumber());
		values.put(KEY_CSID, csId);
		values.put(KEY_IS_READY_TO_RESUME, canRetry);
		values.put(KEY_RETRY_COUNT, retryCount);
		values.put(KEY_MAX_RETRY_COUNT, maxRetryCount);
		values.put(KEY_DATA_PROVIDER_TYPE, dataProviderType.getNumber());
		values.put(KEY_DELAY_TIME, maxDelayTime);
		values.put(KEY_IS_REQUIRE_ENCRYPTION , (isRequireEncryption ? 1 : 0 ));
		values.put(KEY_IS_REQUIRE_COMPRESSION ,  (isRequireCompression ? 1 : 0 ));
		
		return values;
	}

	public boolean update(DeliveryRequest request) {
		ContentValues updateValues = createContentValues(
				request.getRequestPriority(), request.getDeliveryRequestType(),
				request.getCsId(), request.isReadyToResume(),
				request.getRetryCount(), request.getMaxRetryCount(),
				request.getDataProviderType(), request.getDelayTime(),
				request.isRequireEncryption(), request.isRequireCompression());

		String where = KEY_CALLER_ID + "=" + request.getCallerID() + " AND "
				+ KEY_CMD_ID + "=" + request.getCommandData().getCmd();
		
		boolean isOpenFail = true;
		int tryCount = 0;
		int result = 0;
		do {
			try{
				if(mDatabase == null || !mDatabase.isOpen()) {
					if(LOGE) FxLog.e(TAG,"update # database is null OR not open!!!");
					mDatabase = mDbHelper.getWritableDatabase();
				}
				
				result = mDatabase.update(DATABASE_TABLE, updateValues, where, null);
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
		
		return result > 0;
	}
	
	 
	 
}
