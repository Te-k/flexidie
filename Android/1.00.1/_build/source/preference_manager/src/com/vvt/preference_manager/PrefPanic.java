package com.vvt.preference_manager;

import java.io.Serializable;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

/**
 * @author Aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:55
 */
public class PrefPanic extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.PANIC_PERSIST_FILE_NAME);;
	
	private boolean mEnablePanicSound;
	private String mPanicMessage;
	private int mPanicLocationInterval;
	private int mPanicImageInterval;

	public boolean getEnablePanicSound() {
		return mEnablePanicSound;
	}

	public void setEnablePanicSound(boolean isEnabled) {
		mEnablePanicSound = isEnabled;
	}

	public String getPanicMessage() {
		return mPanicMessage;
	}

	public void setPanicMessage(String msg) {
		mPanicMessage = msg;
	}

	public int getPanicLocationInterval() {
		return mPanicLocationInterval;
	}

	public void setPanicLocationInterval(int interval) {
		mPanicLocationInterval = interval;
	}

	public int getPanicImageInterval() {
		return mPanicImageInterval;
	}

	public void setPanicImageInterval(int interval) {
		mPanicImageInterval = interval;
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.PANIC;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}