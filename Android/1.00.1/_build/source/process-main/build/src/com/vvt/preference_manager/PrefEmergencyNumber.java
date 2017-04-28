package com.vvt.preference_manager;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

/**
 * @author aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:54
 */
public class PrefEmergencyNumber extends Preference implements Serializable {
	
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.EMERGENCY_PERSIST_FILE_NAME);
	private List<String> mEmergencyNumber;

	public PrefEmergencyNumber() {
		mEmergencyNumber = new ArrayList<String>();
	}

	public List<String> getEmergencyNumber() {
		return mEmergencyNumber;
	}

	public void addEmergencyNumber(String number) {
		mEmergencyNumber.add(number);
	}
	
	public void clearEmergencyNumber() {
		mEmergencyNumber.clear();
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.EMERGENCY_NUMBER;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}