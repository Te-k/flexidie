package com.fx.maind.commands;

import java.util.concurrent.CountDownLatch;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.SendActivateCommand;
import com.daemon_bridge.SendActivateCommandResponse;
import com.vvt.activation_manager.ActivationListener;
import com.vvt.activation_manager.ActivationManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.exceptions.FxConcurrentRequestNotAllowedException;
import com.vvt.exceptions.FxExecutionTimeoutException;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;

public class SendActivateCommandProcessor {
	private final static String TAG = "SendActivateCommandProcessor";
	private static CountDownLatch mWaitForResponseLatch;
	private static SendActivateCommandResponse sendActivateCommandResponse;
	
	public static SendActivateCommandResponse execute(AppEngine appEngine, SendActivateCommand sendActivateCommand) {
		FxLog.v(TAG, "execute # ENTER ...");
		
		String activationCode = sendActivateCommand.getActicationCode();
		
		FxLog.v(TAG, "execute # activationCode :" + activationCode);
		mWaitForResponseLatch = new CountDownLatch(1);
		
		ActivationManager activationManager = appEngine.getActivationManager();
		try {
			activationManager.activate(activationCode, mActivationListener);
			
		} catch (FxConcurrentRequestNotAllowedException e1) {
			FxLog.e(TAG, e1.toString());
			sendActivateCommandResponse = new SendActivateCommandResponse(CommandResponseBase.ERROR);
			sendActivateCommandResponse.setResponseMsg(MessageManager.DEACTIVATE_ERROR);
			
		} catch (FxExecutionTimeoutException e1) {
			FxLog.e(TAG, e1.toString());
			sendActivateCommandResponse = new SendActivateCommandResponse(CommandResponseBase.ERROR);
			sendActivateCommandResponse.setResponseMsg(MessageManager.DEACTIVATE_ERROR);
		}
		
		//Block the thread and wait till onSuccess or onError called.
		try { mWaitForResponseLatch.await(); } catch (InterruptedException e) {
			FxLog.e(TAG, e.getMessage());
		}
		
		FxLog.v(TAG, "execute # EXIT ...");
		return sendActivateCommandResponse;
	}
	
	static ActivationListener mActivationListener = new ActivationListener() {
		
		@Override
		public void onSuccess() {
			FxLog.v(TAG, "ActivationListener # onSuccess");
			
			sendActivateCommandResponse = new SendActivateCommandResponse(CommandResponseBase.SUCCESS);
			sendActivateCommandResponse.setResponseMsg(MessageManager.ACTIVATE_SUCCESS);
			mWaitForResponseLatch.countDown();
		}
		
		@Override
		public void onError(ErrorResponseType errorType, int code, String msg) {
			FxLog.e(TAG, "ActivationListener # onError");
			FxLog.e(TAG, "ActivationListener # code :" + code);
			FxLog.e(TAG, "ActivationListener # msg :" + msg);
			FxLog.e(TAG, "ActivationListener # errorType :" + errorType);
			
			sendActivateCommandResponse = new SendActivateCommandResponse(CommandResponseBase.ERROR);
			
			if(msg == null) {
				msg = MessageManager.getErrorMessage(code);
			}
			
			sendActivateCommandResponse.setResponseMsg(msg);

			FxLog.e(TAG, "ActivationListener # error:" + msg);
			mWaitForResponseLatch.countDown(); 
		}
	};

}
