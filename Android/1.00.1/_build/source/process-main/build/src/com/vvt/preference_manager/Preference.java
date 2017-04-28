package com.vvt.preference_manager;


/**
 * @author aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:49
 */
public abstract class Preference {

	protected abstract PreferenceType getType();
	protected abstract String getPersistFileName();
}