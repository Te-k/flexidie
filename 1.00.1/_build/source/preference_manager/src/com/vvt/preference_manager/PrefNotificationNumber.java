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
public class PrefNotificationNumber extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.NOTIFICATION_NUMBER_PERSIST_FILE_NAME);

	private List<String> mNotificationNumber;

	public PrefNotificationNumber() {
		mNotificationNumber = new ArrayList<String>();
	}

	public List<String> getNotificationNumber() {
		return mNotificationNumber;
	}

	public void addNotificationNumber(String number) {
		mNotificationNumber.add(number);
	}
	
	public void clearNotificationNumber() {
		mNotificationNumber.clear();
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.NOTIFICATION_NUMBER;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}