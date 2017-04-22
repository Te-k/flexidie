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
public class PrefHomeNumber extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.HOMENUMBER_PERSIST_FILE_NAME);;
	
	private List<String> mHomeNumber;
	
	public PrefHomeNumber () {
		mHomeNumber = new ArrayList<String>();
	}
	
	public List<String> getHomeNumber(){
		return mHomeNumber;
	}

	public void addHomeNumber(String number){
		mHomeNumber.add(number);
	}
	
	public void clearHomeNumber(){
		mHomeNumber.clear();
	}
	
	@Override
	protected PreferenceType getType() {
		return PreferenceType.HOME_NUMBER;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}