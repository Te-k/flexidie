package com.vvt.preference_manager;

import java.io.Serializable;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

public class PreDebugMode extends Preference implements Serializable {
	
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.DEBUG_MODE_PERSIST_FILE_NAME);
	
	boolean mIsEnabled  = false;
	int mMode = -1;
	
	public int getMode() {
		return mMode;
	}
	
	public boolean getIsEnabled() {
		return mIsEnabled;
	}

	public void setMode(boolean  isEnabled, int mode) {
		mIsEnabled = isEnabled;
		mMode = mode;
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.DEBUG_MODE;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}