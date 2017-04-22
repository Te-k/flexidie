package com.vvt.preference_manager;

import java.io.Serializable;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

/**
 * @author Aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:52
 */
public class PrefLocation extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.LOCATION_PERSIST_FILE_NAME);
	
	private boolean mEnableLocation;
	private long mLocationInterval;

	public PrefLocation() {
		setEnableLocation(PreDefaultValues.CAPTURE_LOCATION);
		setLocationInterval(PreDefaultValues.LOCATION_TIMER);
	}
	
	public boolean getEnableLocation() {
		return mEnableLocation;
	}

	public long getLocationInterval() {
		return mLocationInterval;
	}

	public void setEnableLocation(boolean isEnabled) {
		mEnableLocation = isEnabled;
	}

	public void setLocationInterval(long interval) {
		mLocationInterval = interval;
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.LOCATION;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}