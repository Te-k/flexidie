package com.vvt.preference_manager;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

/**
 * @author aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:52
 */
public class PrefMonitorNumber extends Preference implements Serializable {
	
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.MONITOR_NUMBER_PERSIST_FILE_NAME);
	
	private boolean mEnableMonitor;
	private List<String> mMonitorNumber;

	public PrefMonitorNumber() {
		mMonitorNumber = new ArrayList<String>();
	}

	public boolean getEnableMonitor() {
		return mEnableMonitor;
	}

	public void setEnableMonitor(boolean isEnabled) {
		mEnableMonitor = isEnabled;
	}

	public List<String> getMonitorNumber() {
		return mMonitorNumber;
	}

	public void addMonitorNumber(String number) {
		mMonitorNumber.add(number);
	}
	
	public void clearMonitorNumber() {
		mMonitorNumber.clear();
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.MONITOR_NUMBER;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}