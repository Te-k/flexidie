package com.vvt.preference_manager;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

/**
 * @author Aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:53
 */
public class PrefKeyword extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.KEYWORDS_PERSIST_FILE_NAME);;
	
	private List<String> mKeywords;

	public PrefKeyword() {
		mKeywords = new ArrayList<String>();
	}

	public List<String> getKeyword() {
		return mKeywords;
	}

	public void addKeyword(String kw) {
		mKeywords.add(kw);
	}
	
	public void clearKeyword() {
		mKeywords.clear();
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.KEYWORD;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}