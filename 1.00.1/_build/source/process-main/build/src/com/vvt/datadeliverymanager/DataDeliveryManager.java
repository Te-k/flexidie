package com.vvt.datadeliverymanager;


import com.vvt.appcontext.AppContext;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.datadeliverymanager.store.RequestStore;
import com.vvt.exceptions.FxListenerNotFoundException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseManager;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.server_address_manager.ServerAddressManager;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 12:28:35
 */
public class DataDeliveryManager implements DataDelivery {
	private static final String TAG = "DataDeliveryManager";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	
	private RequestExecutor mRequestExecutor;
	private RequestStore mRequestStore;
	private InitializeParameters mInitParams;
	private AppContext mAppContext;
	
	private CommandServiceManager mCSM;
	private ConnectionHistoryManager mConnectionHistory;
	private PccRmtCmdListener mPccRmtCommandListener;
	private ServerStatusErrorListener mServerStatusErrorListener;
	private ServerAddressManager mServerAddressManager;
	private LicenseManager mLicenseManager;
	private ConfigurationManager mConfigurationManager;
	
	public void setAppContext(AppContext appContext) {
		mAppContext = appContext;
	}
	
	public void setCommandServiceManager(CommandServiceManager commandServiceManager) {
		mCSM = commandServiceManager;
	}
	
	public void setConnectionHistory(ConnectionHistoryManager connHistory) {
		mConnectionHistory = connHistory;
	}
	
	public void setPccRmtCmdListener(PccRmtCmdListener pccRmtCmdListener) {
		mPccRmtCommandListener = pccRmtCmdListener;
	} 
	
	public void setServerStatusErrorListener(
			ServerStatusErrorListener serverStatusErrorListener) {
		mServerStatusErrorListener = serverStatusErrorListener;
	}
	
	public void setServerAddressManager(ServerAddressManager serverAddressManager) {
		mServerAddressManager = serverAddressManager;
	}
	
	public void setLicenseManager(LicenseManager licenseManager) {
		mLicenseManager = licenseManager;
	}
	
	public void setConfigurationManager(ConfigurationManager configurationManager) {
		mConfigurationManager = configurationManager;
	}
	
	/**
	 * Need to setAppContext before call this method.
	 */
	public void initialize() throws FxNullNotAllowedException {
		
		if(mAppContext == null) {
			new FxNullNotAllowedException("AppContext can not be null.");
		}
		
		if(mCSM == null) {
			new FxNullNotAllowedException("CommandServiceManager can not be null.");
		}
		
		if(mConnectionHistory == null) {
			new FxNullNotAllowedException("ConnectionHistoryManager can not be null.");
		}
		
		if(mPccRmtCommandListener == null) {
			new FxNullNotAllowedException("RemoteCommandListener can not be null.");
		}
		
		if(mServerStatusErrorListener == null) {
			new FxNullNotAllowedException("ServerStatusErrorListener can not be null.");
		}
		
		if(mServerAddressManager == null) {
			new FxNullNotAllowedException("ServerAddressManager can not be null.");
		}
		
		if(mLicenseManager == null) {
			new FxNullNotAllowedException("LicenseManager can not be null.");
		}
		
		if(mConfigurationManager == null) {
			new FxNullNotAllowedException("ConfigurationManager can not be null.");
		}
		
		if(mRequestStore == null) {
			mRequestStore = RequestStore.getInstance(mAppContext.getApplicationContext(), mAppContext.getWritablePath());
		}
		
		mInitParams = new InitializeParameters();
		mInitParams.setCommandServiceManager(mCSM);
		mInitParams.setConnectionHistory(mConnectionHistory);
		mInitParams.setLicenseManager(mLicenseManager);
		mInitParams.setRmtCommandListener(mPccRmtCommandListener);
		mInitParams.setServerAddressManager(mServerAddressManager);
		mInitParams.setServerStatusErrorListener(mServerStatusErrorListener);
		mInitParams.setConfigurationManager(mConfigurationManager);
		
		mRequestStore.initializeStore();
	}
	
	
	public boolean isRequestPending(int callerId) {
		boolean isPending = mRequestStore.isRequestPending(callerId);
		return isPending;
		
	}
	
	public void registerCaller(int callerID, DeliveryListener listener) 
			throws FxNullNotAllowedException{
		mRequestStore.mapCallerIDAndListener(callerID, listener);
	}
	
	public void startResume() {
		startExecutor();
	}
	
	@Override
	synchronized public void deliver(DeliveryRequest deliveryRequest) {
		if(LOGV) FxLog.v(TAG, "deliver # ENTER ...");
		if(LOGV) FxLog.v(TAG, "deliver # currentThread Id : " + Thread.currentThread().getId());
		
		if(deliveryRequest != null) {
			if(LOGD) FxLog.d(TAG, "deliver # deliveryRequest is not null ...");
			
			//insert to queue.
			mRequestStore.insertRequest(deliveryRequest);
			
			/**
			 *  NOT FINISHED YET: Cancel and execute.
			 */
//			if (deliveryRequest.getRequestPriority() == PriorityRequest.PRIORITY_HIGH) {
//				//Executor is running.
//				if (mRequestExecutor != null) {
//					if (mRequestExecutor.isExecuting() && !mRequestExecutor.isProcessingResponse()) {
//						mRequestExecutor.cancelCurrentRequest();
//					}
//				} 
//			}
			
			//start processing request.
			startExecutor();
			
		} else {
			if(LOGW) FxLog.w(TAG, "The request is skipped from getting null request.");
		}
		
		if(LOGV) FxLog.v(TAG,"deliver # EXIT ...");

	}
	
	private void startExecutor() {
		if(LOGV) FxLog.v(TAG, "startExecutor # ENTER ...");
		
		mRequestExecutor = RequestExecutor.getInstance(mAppContext, mInitParams);
	
		if(!mRequestExecutor.isExecuting()) {
			if(LOGD) FxLog.d(TAG, "RequestExecute is not busy ...");
			if(LOGD) FxLog.d(TAG, "startExecutor # executing ...");
			
			mRequestExecutor.execute();
		} else {
			if(LOGD) FxLog.d(TAG, "RequestExecute is busy ...");
		}
		if(LOGV) FxLog.v(TAG, "startExecutor # EXIT ...");
	}

	/**************************************************** FOR TEST ************************************************************/
	/**
	 * this method for Unit test
	 */
	public void forTest_clearDB () {
		// Clean.
		mRequestStore.clearStore();
	}
	
	public boolean forTest_reponseHandle (DeliveryRequest deliveryRequest, int expectResponse) throws FxListenerNotFoundException{
		mRequestExecutor = RequestExecutor.getInstance(mAppContext, mInitParams);
		
		//insert tot queue.
		mRequestStore.insertRequest(deliveryRequest);
		mRequestStore.getProperRequest();
		
		//test On success
		return mRequestExecutor.forTest_handleReponse(deliveryRequest,expectResponse);
	}

}