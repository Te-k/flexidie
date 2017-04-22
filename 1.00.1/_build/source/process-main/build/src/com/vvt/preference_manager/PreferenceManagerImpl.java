package com.vvt.preference_manager;

import java.util.HashMap;
import java.util.Map;

import com.vvt.logger.FxLog;


/**
 * @author Aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:50
 */
public class PreferenceManagerImpl implements PreferenceManager  {
	private static final String TAG = "PreferenceManagerImpl";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;
	
	private Map<PreferenceType, Preference> mPreferences;
	private PreferenceChangeListener mPreferenceChangeListener;
	private PreferenceStore mPreferenceStore;
	
	public PreferenceManagerImpl(String writablePath){
		mPreferences = new HashMap<PreferenceType, Preference>();
		mPreferenceStore = new PreferenceStore(writablePath);
	}

	public void setPreferenceChangeListener(PreferenceChangeListener listener){
		mPreferenceChangeListener = listener;
	}

	public synchronized Preference getPreference(PreferenceType type) {
		if(LOGV) FxLog.v(TAG, "getPreference # ENTER ... ");
		Preference mPreference = null;
		if(LOGV) FxLog.v(TAG, String.format("getPreference # PreferenceType %s",type));
		if(mPreferences.containsKey(type)) {
			if(LOGV) FxLog.v(TAG, String.format("getPreference # containsKey this type : %s",type));
			mPreference = mPreferences.get(type);
		}
		else {
			if(LOGV) FxLog.v(TAG, String.format("getPreference # Not containsKey this type : %s",type));
			mPreference = mPreferenceStore.loadPreference(type);
			mPreferences.put(type, mPreference);
		}
		if(LOGV) FxLog.v(TAG, "getPreference # EXIT ... ");
		return mPreference;
	}

	public synchronized void savePreferenceAndNotifyChange(Preference preference){
		if(LOGV) FxLog.v(TAG, "savePreferenceAndNotifyChange # ENTER ... ");
		if(LOGV) FxLog.v(TAG, "getPreference # preference :  "+preference.getClass().getName());
		boolean isSuccess = mPreferenceStore.savePreference(preference);

		mPreferences.remove(preference.getType());
		mPreferences.put(preference.getType(), preference);
		if(LOGV) FxLog.v(TAG, "getPreference # is save Success ... "+isSuccess);
		if(isSuccess && mPreferenceChangeListener != null) {
			if(LOGV) FxLog.v(TAG, "getPreference # Notify ... ");
			mPreferenceChangeListener.onPreferenceChange(preference);
		}
		if(LOGV) FxLog.v(TAG, "savePreferenceAndNotifyChange # EXIT ... ");
	}

}