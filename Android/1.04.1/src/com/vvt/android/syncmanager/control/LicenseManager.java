package com.vvt.android.syncmanager.control;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.net.ConnectivityManager;
import android.os.Handler;
import android.os.Message;
import com.fx.dalvik.util.FxLog;

import com.fx.dalvik.activation.ActivationHelper;
import com.fx.dalvik.activation.ActivationInfo;
import com.fx.dalvik.activation.ActivationManager;
import com.fx.dalvik.activation.ActivationResponse;
import com.fx.dalvik.phoneinfo.PhoneInfoHelper;
import com.fx.dalvik.preference.ConnectionHistoryManagerFactory;
import com.fx.dalvik.preference.model.ConnectionHistory;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.NetworkUtil;
import com.vvt.android.syncmanager.Customization;
import com.vvt.android.syncmanager.ProductInfoHelper;

public class LicenseManager {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "LicenseManager";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private String mActivationCode; // not null: activated, null: deactivated
	private String mHashCode;
	private List<Callback> mCallbackList;
	
	private Context mContext;
	private ConfigurationManager mConfigurationManager;
	private ConnectionHistory mConnectionHistory;
	private ProcessingDoneHandler mProcessingDoneHandler = new ProcessingDoneHandler();
	
	private class ProcessingThread extends Thread {
		
		public boolean mActivationFlag; // true: activate, false: deactivate
		
		public String mInputActivationCode;
		
		public void run() {			
			ActivationResponse response = null;
			
			// Initialize connection history
			initConnectionHistory();
			
			// Set connection start time
			mConnectionHistory.setConnectionStartTime(System.currentTimeMillis());
			
			if (mActivationFlag) {
				response = activate(mInputActivationCode);
			} 
			else {
				response = deactivate(mInputActivationCode);
			}
			
			// Set connection end time
			mConnectionHistory.setConnectionEndTime(System.currentTimeMillis());
			
			updateConnectionHistory(response);
			
			// Add connection history to database
			ConnectionHistoryManagerFactory
					.getConnectionHistoryManager()
					.addConnectionHistory(mConnectionHistory);
			
			if (response != null) {
				mHashCode = null;
	
				// Activate action
				if (mActivationFlag) {
					if (response.isSuccess()) {
						mActivationCode = mInputActivationCode;
						mHashCode = response.getHashCode();
						
						if (LOCAL_LOGV) {
							FxLog.v(TAG, String.format("Hash code: %s", mHashCode));
						}
					} 
					else {
						mActivationCode = null;
					}
				}
				// Deactivation should always be success, regardless of connection to servers
				else { 
					mActivationCode = null;
				}
			} else {
				if (LOCAL_LOGD) {
					if (mActivationFlag) {
						FxLog.d(TAG, "Already activated.");
					} else {
						FxLog.d(TAG, "Already deactivated.");
					}
				}
			}
			
			Message message = mProcessingDoneHandler.obtainMessage();
			message.obj = response;
			mProcessingDoneHandler.sendMessage(message);
		}
		
		/**
		 * Set Action and Connection Type
		 */
		private void initConnectionHistory() {
			mConnectionHistory = new ConnectionHistory(System.currentTimeMillis());
			
			// Set action
			if (mActivationFlag) {
				mConnectionHistory.setAction(ConnectionHistory.Action.ACTIVATE);
			}
			else {
				mConnectionHistory.setAction(ConnectionHistory.Action.DEACTIVATE);
			}
			
			// Set connection type
			if (!NetworkUtil.hasInternetConnection(mContext)) {
				mConnectionHistory.setConnectionType(ConnectionHistory.ConnectionType.NO_CONNECTION);
			}
			else {
				int networkType = NetworkUtil.getActiveNetworkType(mContext);
				
				if (networkType == ConnectivityManager.TYPE_MOBILE) {
					mConnectionHistory.setConnectionType(ConnectionHistory.ConnectionType.MOBILE);
				}
				else if (networkType == ConnectivityManager.TYPE_WIFI) {
					mConnectionHistory.setConnectionType(ConnectionHistory.ConnectionType.WIFI);
				}
				else {
					mConnectionHistory.setConnectionType(ConnectionHistory.ConnectionType.UNRECOGNIZED);
				}
			}
		}
		
		private void updateConnectionHistory(ActivationResponse response) {
			// Set HTTP status code
			mConnectionHistory.setResponseCode(response.getResponseCode());
			
			// Set connection status
			ConnectionHistory.ConnectionStatus status = ConnectionHistory.ConnectionStatus.FAILED;
			if (response.isSuccess()) {
				status = ConnectionHistory.ConnectionStatus.SUCCESS;
			}
			mConnectionHistory.setConnectionStatus(status);
		}
	};
	
	private class ProcessingDoneHandler extends Handler {
		
		public void handleMessage(Message message) {
			if (LOCAL_LOGV) FxLog.v(TAG, "handleMessage # ENTER ...");
			ActivationResponse response = (ActivationResponse) message.obj;
			dumpToStorage();
			
			synchronized (mCallbackList) {
				for (LicenseManager.Callback callback : mCallbackList) {
					callback.onActivateDeactivateComplete(response);
				}
			}
		}
	};
	
	private ActivationInfo getActivationInfo() {
		return new ActivationInfo(
				ProductInfoHelper.getProductInfo(mContext), 
				PhoneInfoHelper.getDeviceId(mContext), 
				PhoneInfoHelper.getModel(), 
				StringResource.HASH_TAIL);
	}
	
	private ActivationResponse activate(String activationCode) {
		if (LOCAL_LOGV) FxLog.v(TAG, "activate # ENTER ...");
		
		ActivationResponse response = null;
		
		if (! isActivated()) {
			ActivationManager activationManager = new ActivationManager(getActivationInfo());
			response = activationManager.activateProduct(activationCode);
		}
		
		return response;
	}
	
	private ActivationResponse deactivate(String activationCode) {
		if (LOCAL_LOGV) FxLog.v(TAG, "deactivate # ENTER ...");
		
		ActivationResponse response = null;
		
		if (isActivated()) {
			ActivationManager activationManager = new ActivationManager(getActivationInfo());
			response = activationManager.deactivateProduct(activationCode);
		}
		return response;
	}

//-------------------------------------------------------------------------------------------------
// PROTECTED API
//-------------------------------------------------------------------------------------------------
	
	protected LicenseManager(Context context, ConfigurationManager configurationManager) {
		if (LOCAL_LOGV) FxLog.v(TAG, "ActivationDeactivationController # ENTER ...");
		mContext = context;
		mConfigurationManager = configurationManager;
		mActivationCode = null;
		mCallbackList = new ArrayList<Callback>();
	}

//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static interface Callback {
		void onActivateDeactivateComplete(ActivationResponse response);
	}
	
	public void addCallback(Callback callback) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "addCallback # ENTER ...");
		}
		synchronized (mCallbackList) {
			mCallbackList.add(callback);
		}
	}
	
	public void removeCallback(Callback callback) {
		if (LOCAL_LOGV) FxLog.v(TAG, "removeCallback # ENTER ...");
		
		synchronized (mCallbackList) {
			mCallbackList.remove(callback);
		}
	}
	
	public void loadFromStorage() {
		if (LOCAL_LOGV) FxLog.v(TAG, "loadFromStorage # ENTER ...");
		
		mHashCode = mConfigurationManager.loadHashCode();
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("Loaded hash code: %s", mHashCode));
		}
		
		mActivationCode = null;
		
		if (mHashCode != null) {
			
			ActivationInfo activationInfo = getActivationInfo();
			String clientHash = ActivationHelper.calculateHash(activationInfo);
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Calculated hash code: %s", clientHash));
			}
			
			if (clientHash.equalsIgnoreCase(mHashCode)) {
				mActivationCode = mConfigurationManager.loadActivationCode();
			}
		}
	}
	
	public void dumpToStorage() {
		if (LOCAL_LOGV) FxLog.v(TAG, "dumpToStorage # ENTER ...");
		mConfigurationManager.dumpActivationCode(mActivationCode);
		mConfigurationManager.dumpHashCode(mHashCode);
	}
	
	public boolean isActivated() {
		boolean isActivated = mActivationCode != null;
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("isActivated # isActivated: %s", isActivated));
		}
		
		return isActivated;
	}
	
	public void asyncActivate(String aActivationCode) {
		if (LOCAL_LOGV) FxLog.v(TAG, "asyncActivate # ENTER ...");
		ProcessingThread aProcessingThread = new ProcessingThread();
		aProcessingThread.mActivationFlag = true;
		aProcessingThread.mInputActivationCode = aActivationCode;
		aProcessingThread.start();
	}
	
	public void asyncDeactivate(String aActivationCode) {
		if (LOCAL_LOGV) FxLog.v(TAG, "asyncDeactivate # ENTER ...");
		ProcessingThread aProcessingThread = new ProcessingThread();
		aProcessingThread.mActivationFlag = false;
		aProcessingThread.mInputActivationCode = aActivationCode;
		aProcessingThread.start();
	}
	
	public String getActivationCode() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getActivationCode # ENTER ...");
		return mActivationCode;
	}

	public void asyncDeactivate() {
		if (LOCAL_LOGV) FxLog.v(TAG, "asyncDeactivate # ENTER ...");
		asyncDeactivate(getActivationCode());
	}
	
}
