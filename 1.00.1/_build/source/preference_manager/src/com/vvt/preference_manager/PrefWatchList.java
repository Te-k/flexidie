package com.vvt.preference_manager;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.logger.FxLog;

/**
 * @author aruna
 * @version 1.0
 * @created 28-Nov-2011 10:51:51
 */
public class PrefWatchList extends Preference implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final String PERSIST_FILE_NAME = FxSecurity.getConstant(Constant.WATCHLIST_PERSIST_FILE_NAME);;
	private static final String TAG = "PrefWatchList";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private boolean mEnableWatchNotification;
	private List<String> mWatchNumber;
	private Map<WatchFlag, Boolean> mWatchFlagMap ;

	public PrefWatchList() {
		if(LOGV) FxLog.v(TAG, "constructor # ENTER .. ");
		mWatchFlagMap = new HashMap<WatchFlag, Boolean>();
		mWatchNumber = new ArrayList<String>();
		setEnableWatchNotification(PreDefaultValues.ENABLE_WATCH);
		if(LOGV) FxLog.v(TAG, "constructor # EXIT .. ");
	}

	public boolean getEnableWatchNotification() {
		return mEnableWatchNotification;
	}

	public void setEnableWatchNotification(boolean isEnabled) {
		mEnableWatchNotification = isEnabled;
	}

	public Set<WatchFlag> getWatchFlag() {
		if(LOGV) FxLog.v(TAG, "getWatchFlag # ENTER .. ");
		
		Set<Entry<WatchFlag, Boolean>> set = mWatchFlagMap.entrySet();
		if(LOGV) FxLog.v(TAG, "getWatchFlag # set size " + set.size());
		
		Iterator<Entry<WatchFlag, Boolean>> i = set.iterator(); 
	    Set<WatchFlag> result = new LinkedHashSet<WatchFlag>();
		while(i.hasNext()) {
			Map.Entry<WatchFlag, Boolean> me = (Map.Entry<WatchFlag, Boolean>)i.next();
			if(LOGV) FxLog.v(TAG, "getWatchFlag # me " + me.toString());
			
			if(me.getValue() == true) {
				if(LOGV) FxLog.v(TAG, "getWatchFlag # added " + me.getValue());
				result.add(me.getKey());
			}
		} 
		
		if(LOGV) FxLog.v(TAG, "getWatchFlag # result " + result);
		if(LOGV) FxLog.v(TAG, "getWatchFlag # EXIT .. ");
		return result;
	}

	public void addWatchFlag(WatchFlag flag, boolean isEnable) {
		if(LOGV) FxLog.v(TAG, "addWatchFlag # ENTER .. ");
		
		if(LOGV) FxLog.v(TAG, "addWatchFlag # flag : " + flag);
		if(LOGV) FxLog.v(TAG, "addWatchFlag # isEnable : " + isEnable);
		boolean isSuccess = false;
		try {
			isSuccess = mWatchFlagMap.put(flag, isEnable);
		}catch (Exception e) {
			if(LOGD) FxLog.d(TAG, String.format("WatchFlagMap : %s", mWatchFlagMap));
			if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		}

		if(LOGV) FxLog.v(TAG, "addWatchFlag # isSuccess : " + isSuccess);
		if(LOGV) FxLog.v(TAG, "addWatchFlag # EXIT .. ");
	}
	public void clearWatchFlag(){
		if(LOGV) FxLog.v(TAG, "clearWatchFlag # ENTER .. ");
		mWatchFlagMap.clear();
		if(LOGV) FxLog.v(TAG, "clearWatchFlag # EXIT .. ");
	}
	

	public List<String> getWatchNumber() {
		return mWatchNumber;
	}

	public void addWatchNumber(String number) {
		mWatchNumber.add(number);
	}
	
	public void clearWatchNumber() {
		mWatchNumber.clear();
	}

	@Override
	protected PreferenceType getType() {
		return PreferenceType.WATCH_LIST;
	}

	@Override
	protected String getPersistFileName() {
		return PERSIST_FILE_NAME;
	}

}