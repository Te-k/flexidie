package com.vvt.preference_manager;

import java.io.Serializable;

import com.vvt.base.FxAddressbookMode;
import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

public class PrefAddressBook  extends Preference implements Serializable {
	
	private static final long serialVersionUID = 1L;
	private static final String ADDRESSBOOK_PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.ADDRESSBOOK_PERSIST_FILE_NAME);
	
	private FxAddressbookMode mMode;
	
	public PrefAddressBook() {
		// TODO: Comfirm and change later
		mMode = FxAddressbookMode.MONITOR;
	}
	
	public FxAddressbookMode getMode() {
		return mMode;
	}

	public void setMode(FxAddressbookMode mode) {
		mMode = mode;
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.ADDRESSBOOK;
	}

	@Override
	protected String getPersistFileName() {
		return ADDRESSBOOK_PERSIST_FILE_NAME;
	}

}