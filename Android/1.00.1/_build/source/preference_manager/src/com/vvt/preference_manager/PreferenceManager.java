package com.vvt.preference_manager;


/**
 * @author aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:48
 */
public interface PreferenceManager {

	/**
	 * 
	 * @param type
	 */
	public Preference getPreference(PreferenceType type);

	/**
	 * 
	 * @param preference
	 */
	public void savePreferenceAndNotifyChange(Preference preference);

}