package com.fx.license;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.activation.ActivationHelper;
import com.fx.maind.ref.Customization;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;

public class LicenseManager {
	
	private static LicenseManager sInstance;
	
	private static final String TAG = "LicenseManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private String clientHash;
	
	private Context mContext;
	private LicenseDatabaseHelper mLicenseHelper;
	
	private LicenseManager() { }
	
	private LicenseManager(Context context) {
		mContext = context;
		mLicenseHelper = LicenseDatabaseHelper.getInstance();
		
		// initialize license
		Cursor cursor = mLicenseHelper.query(
				Uri.parse(LicenseDatabaseMetadata.License.URI), null, null, null, null);
		
		if (cursor != null && cursor.getCount() < 1) {
			initLicense();
			cursor.close();
		}
		
		if (cursor != null) {
			cursor.close();
		}
	}
	
	public static LicenseManager getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new LicenseManager(context);
		}
		return sInstance;
	}
	
	public void setActivationStatus(int statusCode) {
		int rowAffected = updateValue(LicenseDatabaseMetadata.License.URI, 
				LicenseDatabaseMetadata.License.ACTIVATION_STATUS, statusCode);
		
		if (rowAffected > 0) {
			FxLog.d(TAG, String.format("Set activation status: %d", statusCode));
		}
		else {
			FxLog.d(TAG, "Fail to set activation status");
		}
	}
	
	public boolean isActivated() {
		if (LOGV) FxLog.v(TAG, "isActivated # ENTER ...");
		
    	boolean isActivated = false;
    	
    	// Calculate client hash
    	if (clientHash == null || clientHash.length() < 1) {
    		clientHash = ActivationHelper.getInstance(mContext).calculateHash();
    	}
    	if (LOGV) FxLog.v(TAG, String.format("isActivated # client hash: %s", clientHash));
    	
    	// Get server hash
    	String serverHash = getHashCode();
    	if (LOGV) FxLog.v(TAG, String.format("isActivated # server hash: %s", serverHash));
    	
    	if (serverHash != null && serverHash.equals(clientHash)) {
    		isActivated = true;
    	}
    	if (LOGV) FxLog.v(TAG, String.format("isActivated # result: %s", isActivated));
    	
    	return isActivated;
    }
	
	public void setActivationCode(String activationCode) {
		String insertData = null;
		
		if (activationCode == null || activationCode.length() < 1) {
			insertData = "";
		}
		else { 
			insertData = FxUtil.getEncryptedInsertData(activationCode, false);
		}
		
		int rowAffected = updateValue(LicenseDatabaseMetadata.License.URI, 
				LicenseDatabaseMetadata.License.ACTIVATION_CODE, insertData);
		
		if (LOGV) {
			if (rowAffected > 0) {
				FxLog.v(TAG, String.format(
						"Set Activation Code: %s, Encrypted Value: %s", 
						activationCode, insertData));
			}
			else {
				FxLog.v(TAG, "Fail to set Activation Code");
			}
		}
	}
	
	public String getActivationCode() {
    	String activationCode = "";
    	
    	Object value = queryValue(LicenseDatabaseMetadata.License.URI, 
    			LicenseDatabaseMetadata.License.ACTIVATION_CODE, String.class);
    	
    	if (value != null) {
    		activationCode = FxUtil.getDecryptedQueryData((String) value, false);
    	}
    	
    	return activationCode;
    }
	
	public void setHashCode(String hashCode) {
		String insertData = null;
			
		if (hashCode == null || hashCode.length() < 1) {
			insertData = "";
		}
		else {
			insertData = FxUtil.getEncryptedInsertData(hashCode, true);
		}
		
		int rowAffected = updateValue(LicenseDatabaseMetadata.License.URI, 
				LicenseDatabaseMetadata.License.SERVER_HASH, insertData);
		
		if (LOGV) {
			if (rowAffected > 0) {
				FxLog.v(TAG, String.format(
						"Set Hash Code: %s, Encrypted Value: %s", 
						hashCode, insertData));
			}
			else {
				FxLog.v(TAG, "Fail to set Hash Code");
			}
		}
	}
	
	public String getHashCode() {
		String hashCode = "";
    	
    	Object value = queryValue(LicenseDatabaseMetadata.License.URI, 
    			LicenseDatabaseMetadata.License.SERVER_HASH, String.class);
    	
    	if (value != null) {
    		hashCode = FxUtil.getDecryptedQueryData((String) value, true);
    	}
    	
    	return hashCode;
	}
	
	private void initLicense() {
		// Construct ContentValue object
		ContentValues values = new ContentValues();
		values.put(LicenseDatabaseMetadata.License.ACTIVATION_STATUS, -1);
		values.put(LicenseDatabaseMetadata.License.ACTIVATION_CODE, "");
		values.put(LicenseDatabaseMetadata.License.SERVER_HASH, "");
		values.put(LicenseDatabaseMetadata.License.CONFIGURATION_ID, "");
		
		// Insert new preference
		mLicenseHelper.insert(Uri.parse(LicenseDatabaseMetadata.License.URI), values);
		
		if (LOGV) {
			FxLog.v(TAG, String.format("License is initialized"));
		}
	}
	
	private Object queryValue(String uri, String column, Class<?> valueClass) {
    	
    	Object value = null;
    	
    	Cursor cursor = mLicenseHelper.query(Uri.parse(uri), null, null, null, null);
    	
    	if (cursor.moveToNext()) {
    		if (valueClass == String.class) {
    			value = cursor.getString(cursor.getColumnIndex(column));
    		}
    		else if (valueClass == Integer.class) {
    			value = Integer.valueOf(cursor.getInt(cursor.getColumnIndex(column)));
    		}
    		else if (valueClass == Double.class) {
    			value = Double.valueOf(cursor.getDouble(cursor.getColumnIndex(column)));
    		}
    	}
    	
    	if (cursor != null) {
    		cursor.close();
    	}
    	
    	return value;
    }
	
	private int updateValue(String uri, String key, Object value) {
		ContentValues values = new ContentValues();
		
		if (value instanceof String) {
			values.put(key, (String) value);
		}
		else if (value instanceof Boolean) {
			Integer intValue = (Boolean) value ? 1 : 0;
			values.put(key, (Integer) intValue);
		}
		else if (value instanceof Integer) {
			values.put(key, (Integer) value);
		}
		else if (value instanceof Double) {
			values.put(key, (Double) value);
		}
		
		return mLicenseHelper.update(Uri.parse(uri), values, null, null);
	}
}
