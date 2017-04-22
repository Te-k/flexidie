package com.vvt.preference_manager;

import java.io.Serializable;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;


/**
 * @author Aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:56
 */
public class PrefDeviceLock extends Preference implements Serializable {
	
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.DEVICE_LOCK_PERSIST_FILE_NAME);
	
	private boolean mEnableAlertSound;
	private String mDeviceLockMessage;
	private int mLocationInterval;
	
	public boolean getEnableAlertSound(){
		return mEnableAlertSound;
	}

	public String getDeviceLockMessage(){
		return mDeviceLockMessage;
	}

	public int getLocationInterval(){
		return mLocationInterval;
	}

	public void setEnableAlertSound(boolean isEnabled){
		mEnableAlertSound = isEnabled;
	}

	public void setDeviceLockMessage(String message){
		mDeviceLockMessage = message;
	}

	public void setLocationInterval(int interval){
		mLocationInterval = interval;
	}
	
	@Override
	protected PreferenceType getType() {
		return PreferenceType.DEVICE_LOCK;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}