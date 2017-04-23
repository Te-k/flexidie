package com.fx.maind.command.processor;

import com.fx.maind.ref.WatchNotificationSettings;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.preference_manager.WatchFlag;

public class RemoteGetWatchListSettingsProcessor {

private AppEngine mAppEngine;
	
	public RemoteGetWatchListSettingsProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	public WatchNotificationSettings process() {
		WatchNotificationSettings watchNotificationSettings = new WatchNotificationSettings();
		PreferenceManager preferenceManager = mAppEngine.getPreferenceManager();
		
		PrefWatchList prefWatchList = (PrefWatchList)preferenceManager.getPreference(PreferenceType.WATCH_LIST);
		watchNotificationSettings.setEnableWatchNotification(prefWatchList.getEnableWatchNotification());
		watchNotificationSettings.AddWatchListNumber(prefWatchList.getWatchNumber());
		
		for(WatchFlag f: prefWatchList.getWatchFlag()) {
			
			if(f == WatchFlag.WATCH_IN_ADDRESSBOOK) {
				watchNotificationSettings.addWatchFlag(WatchNotificationSettings.WatchFlag.WATCH_IN_ADDRESSBOOK, true);
			}
			else if( f== WatchFlag.WATCH_IN_LIST) {
				watchNotificationSettings.addWatchFlag(WatchNotificationSettings.WatchFlag.WATCH_IN_LIST, true);
			}
			else if(f == WatchFlag.WATCH_NOT_IN_ADDRESSBOOK) {
				watchNotificationSettings.addWatchFlag(WatchNotificationSettings.WatchFlag.WATCH_NOT_IN_ADDRESSBOOK, true);
			}
			else if(f == WatchFlag.WATCH_PRIVATE_OR_UNKNOWN_NUMBER) {
				watchNotificationSettings.addWatchFlag(WatchNotificationSettings.WatchFlag.WATCH_PRIVATE_OR_UNKNOWN_NUMBER, true);
			}
			
		}
				
		return watchNotificationSettings;
	}
}
