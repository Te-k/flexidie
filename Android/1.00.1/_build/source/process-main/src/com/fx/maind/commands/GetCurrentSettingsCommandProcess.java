package com.fx.maind.commands;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetCurrentSettingsCommand;
import com.daemon_bridge.GetCurrentSettingsCommandResponse;
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

public class GetCurrentSettingsCommandProcess {
	private static final String TAG = "GetCurrentSettingsCommandProcess";
	private static final boolean VERBOSE = true;
	private static boolean LOGV = Customization.DEBUG ? VERBOSE : false;
	
	public static GetCurrentSettingsCommandResponse execute(AppEngine appEngine, GetCurrentSettingsCommand getLicenseStatusCommand) {
		if(LOGV) FxLog.d(TAG, "# execute START");
		
		PreferenceManager preferenceManager = appEngine.getPreferenceManager();
		ConfigurationManager configurationManager = appEngine.getConfigurationManager();
		
		GetCurrentSettingsCommandResponse commandResponse  = null;
		
		try {
		
			if(configurationManager.getConfiguration() == null) {
				if(LOGV) FxLog.e(TAG, "# getConfiguration is null");
				commandResponse = new GetCurrentSettingsCommandResponse(CommandResponseBase.ERROR);
			} 
			else {
				commandResponse = new GetCurrentSettingsCommandResponse(CommandResponseBase.SUCCESS);
				
				PrefEventsCapture eventsCapturePref = (PrefEventsCapture)preferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
				PrefLocation locationCapturePref = (PrefLocation)preferenceManager.getPreference(PreferenceType.LOCATION);
				LicenseInfo licenseInfo = appEngine.getLicenseManager().getLicenseInfo();
				PrefMonitorNumber prefMonitorNumber    = (PrefMonitorNumber)preferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
				PrefWatchList watchList     = (PrefWatchList)preferenceManager.getPreference(PreferenceType.WATCH_LIST);
				
				commandResponse.setEnableStartCapture(eventsCapturePref.getEnableStartCapture());
		        commandResponse.setDeliverTimer(eventsCapturePref.getDeliverTimer());
		        commandResponse.setMaxEvent(eventsCapturePref.getMaxEvent());
		        commandResponse.setLocationInterval(locationCapturePref.getLocationInterval());
		        commandResponse.setConfigurationId(licenseInfo.getConfigurationId());
		        commandResponse.setSupportedFeture(configurationManager.getConfiguration().getSupportedFeture());
		        commandResponse.setEnableCallLog(eventsCapturePref.getEnableCallLog());
		        commandResponse.setEnableCameraImage(eventsCapturePref.getEnableCameraImage());
		        commandResponse.setEnableEmail(eventsCapturePref.getEnableEmail());
		        commandResponse.setEnableLocation(locationCapturePref.getEnableLocation());
		        commandResponse.setEnableMMS(eventsCapturePref.getEnableMMS());
		        commandResponse.setEnableSMS(eventsCapturePref.getEnableSMS());
		        commandResponse.setEnableAddressBook(eventsCapturePref.getEnableAddressBook());
		        commandResponse.setEnableAudioFile(eventsCapturePref.getEnableAudioFile());
		        commandResponse.setEnableVideoFile(eventsCapturePref.getEnableVideoFile());
		        commandResponse.setEnableWallPaper(eventsCapturePref.getEnableWallPaper());
		        commandResponse.setEnableMonitor(prefMonitorNumber.getEnableMonitor());
		        commandResponse.setEnableWatchNotification(watchList.getEnableWatchNotification());
		        
		        if(LOGV) FxLog.d(TAG, "# commandResponse :" + commandResponse.toString());
			}
		}
		catch(Throwable t) {
			if(LOGV) FxLog.e(TAG, t.toString());
			commandResponse = new GetCurrentSettingsCommandResponse(CommandResponseBase.ERROR);
		}
		
		
		if(LOGV) FxLog.d(TAG, "# execute EXIT");
		return commandResponse;
	}
}
