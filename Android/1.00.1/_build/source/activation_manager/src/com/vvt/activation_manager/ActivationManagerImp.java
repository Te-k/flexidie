package com.vvt.activation_manager;

import android.util.Log;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxCallerID;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.exceptions.FxConcurrentRequestNotAllowedException;
import com.vvt.exceptions.FxExecutionTimeoutException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.CommandData;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendDeactivate;
import com.vvt.phoenix.prot.command.response.GetActivationCodeResponse;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.command.response.SendActivateResponse;
import com.vvt.server_address_manager.ServerAddressManager;

/**
 * @author Aruna 
 * @version 1.0
 * @created 15-Nov-2011 11:24:28
 */
public class ActivationManagerImp implements ActivationManager, DeliveryListener {
	private static final String TAG = "ActivationManagerImp";
	private static boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static boolean LOGD = Customization.DEBUG;
	private static boolean LOGE = Customization.ERROR;
	
	private static final int TIMEOUT_VALUE = 60000; // 1 Min

	private ActivationListener mActivationListener;
	private DataDelivery mDataDelivery;
	private LicenseManager mLicenseManager;
	private ServerAddressManager mServerAddressManager;
	private String mActivationCode = null;
	private AppContext mAppContext;
	private boolean mIsProcessingRequest = false;
	
	private enum ActivationMode {
		ACTIVATE_WITH_CODE, AUTO_ACTIVATE, DEACTIVATE
	}
	
	public void setDataDelivery(DataDelivery dataDelivery) {
		mDataDelivery = dataDelivery;
	}
	
	public void setServerAddressManager(ServerAddressManager serverAddressManager) {
		mServerAddressManager = serverAddressManager;
	}
	
	public void setAppContext(AppContext appContext) {
		mAppContext = appContext;
	}
	
	/**
	 * To commit license information upon activation success.
	 * @param licenseManager Set the LicenseManager here
	 */
	public void setLicenseManager(LicenseManager licenseManager) {
		mLicenseManager = licenseManager;
	}
	
	public void initialize() throws FxNullNotAllowedException {
		if(mDataDelivery == null) {
			throw new FxNullNotAllowedException("DataDeliveryManager can not be null.");
		}
		
		if(mServerAddressManager == null) {
			throw new FxNullNotAllowedException("ServerAddressManager can not be null.");
		}
		
		if(mAppContext == null) {
			throw new FxNullNotAllowedException("AppContext can not be null.");
		}
		
		if(mLicenseManager == null) {
			throw new FxNullNotAllowedException("LicenseManager can not be null.");
		}
	}

	/**
	 * Activate product.
	 * @param url Product URL.
	 * @param activationCode Activation code of the product.
	 * @param listener to notify when success or failure
	 * @throws FxExecutionTimeoutException if the operation took more than 1 Min.
	 * @throws FxConcurrentRequestNotAllowedException if a request come in while processing another
	 */
	public synchronized void activate(String url, String activationCode, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		if (LOGV) FxLog.v(TAG, "activate # START ..");
		if (LOGV) FxLog.v(TAG, "activate # url " + url + " activationCode " + activationCode + " listener " + listener);
		
		if(mIsProcessingRequest) {
			throw new FxConcurrentRequestNotAllowedException();
		}
		
		mActivationCode = activationCode;
		mIsProcessingRequest = true;
		mActivationListener = listener;
		mServerAddressManager.setServerUrl(url); 
		
		processRequest(mActivationCode, ActivationMode.ACTIVATE_WITH_CODE);
		if (LOGV) FxLog.v(TAG, "activate # EXIT ..");
	}

	/**
	 * Activate product.
	 * @param activationCode Activation code of the product.
	 * @param listener to notify when success or failure
	 * @throws FxExecutionTimeoutException if the operation took more than 1 Min.
	 * @throws FxConcurrentRequestNotAllowedException if a request come in while processing another
	 */
	public synchronized void activate(String activationCode, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		if (LOGV) FxLog.v(TAG, "activate # START ..");
		if (LOGV) FxLog.v(TAG, "activate # activationCode " + activationCode + " listener " + listener);
		
		if(mIsProcessingRequest) {
			throw new FxConcurrentRequestNotAllowedException();
		}
		
		mIsProcessingRequest = true;
		mActivationListener = listener;
		mActivationCode = activationCode;
		
		processRequest(mActivationCode, ActivationMode.ACTIVATE_WITH_CODE);
		if (LOGV) FxLog.v(TAG, "activate # EXIT ..");
	}
	
	/**
	 * Automatically activate product with URL.
	 * @param url Product activation URL
	 * @param listener to notify when success or failure
	 * @throws FxExecutionTimeoutException if the operation took more than 1 Min.
	 * @throws FxConcurrentRequestNotAllowedException if a request come in while processing another
	 */
	public void autoActivate(String url, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		if (LOGV) FxLog.v(TAG, "autoActivate # START ..");
		if (LOGV) FxLog.v(TAG, "autoActivate # url " + url + " listener " + listener);
		
		if(mIsProcessingRequest) {
			throw new FxConcurrentRequestNotAllowedException();
		}

		mIsProcessingRequest = true;
		mActivationListener = listener;
		mServerAddressManager.setServerUrl(url);
		
		processRequest(null, ActivationMode.AUTO_ACTIVATE);
		if (LOGV) FxLog.v(TAG, "autoActivate # EXIT ..");
	}

	/**
	 * Automatically activate product with URL.
	 * @param url Product activation URL
	 * @param listener to notify when success or failure
	 * @throws FxExecutionTimeoutException if the operation took more than 1 Min.
	 * @throws FxConcurrentRequestNotAllowedException if a request come in while processing another
	 */
	public void autoActivate(ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		if (LOGV) FxLog.v(TAG, "autoActivate # START ..");
		if (LOGV) FxLog.v(TAG, "autoActivate # listener " + listener);
		
		if(mIsProcessingRequest) {
			throw new FxConcurrentRequestNotAllowedException();
		}

		mIsProcessingRequest = true;
		mActivationListener = listener;
		
		processRequest(null, ActivationMode.AUTO_ACTIVATE);
		if (LOGV) FxLog.v(TAG, "autoActivate # EXIT ..");
	}
	
	// Called after Request activation code return the activation code on Success.
	private void activateWithRequestActivationCode(final String activationCode) {
		if (LOGV) FxLog.v(TAG, "activateWithRequestActivationCode # START ..");
		if (LOGV) FxLog.v(TAG, "activateWithRequestActivationCode # activationCode " + activationCode);
		
		mLicenseManager.updateLicense(new LicenseInfo() {{ setActivationCode(activationCode); }});
		
		DeliveryRequest deliveryRequest = constructDeliveryRequest(CommandCode.SEND_ACTIVATE, activationCode);
		mDataDelivery.deliver(deliveryRequest);
	}
	
	private void processRequest(final String activationCode, final ActivationMode mode) throws FxExecutionTimeoutException {
		if (LOGV) FxLog.v(TAG, "processRequest # START ..");
		
		mLicenseManager.updateLicense(new LicenseInfo() {{ setActivationCode(activationCode); }});
		
		// Execute the request on a seperate thread and wait for timeout or success/failure
		Thread thread = new Thread(new Runnable() {
		    @Override
		    public void run() {
		    	if(mode == ActivationMode.ACTIVATE_WITH_CODE) {
		    		DeliveryRequest deliveryRequest = constructDeliveryRequest(CommandCode.SEND_ACTIVATE, activationCode);
		    		mDataDelivery.deliver(deliveryRequest);
		    	}
		    	else if(mode == ActivationMode.AUTO_ACTIVATE) {
		    		DeliveryRequest deliveryRequest = constructDeliveryRequest(CommandCode.REQUEST_ACTIVATION_CODE, activationCode);
		    		mDataDelivery.deliver(deliveryRequest);
		    	}
		    	else if(mode == ActivationMode.DEACTIVATE) {
		    		DeliveryRequest deliveryRequest = constructDeliveryRequest(CommandCode.SEND_DEACTIVATE, activationCode);
		    		mDataDelivery.deliver(deliveryRequest);
		    	}
		    }
		});
		
		thread.start();
		
		long endTimeMillis = System.currentTimeMillis() + TIMEOUT_VALUE;
		while (thread.isAlive()) {
		    if (System.currentTimeMillis() > endTimeMillis) {
		    	if (LOGE) FxLog.e(TAG, "processRequest # FxExecutionTimeoutException");
		        throw new FxExecutionTimeoutException();
		    }
		    try {
		        Thread.sleep(500);
		    }
		    catch (InterruptedException t) {}
		}
		
		if (LOGV) FxLog.v(TAG, "processRequest # EXIT ..");
	}

	/**
	 * Deactivates the product.
	 * @param listener to notify when success or failure
	 * @throws FxExecutionTimeoutException if the operation took more than 1 Min.
	 * @throws FxConcurrentRequestNotAllowedException if a request come in while processing another 
	 */
	public synchronized void deactivate(String activationCode, ActivationListener listener) throws FxConcurrentRequestNotAllowedException, FxExecutionTimeoutException {
		if (LOGV) FxLog.v(TAG, "deactivate # START ..");
		if (LOGV) FxLog.v(TAG, "deactivate # activationCode " + activationCode + " listener " + listener);
		
		if(mIsProcessingRequest) {
			throw new FxConcurrentRequestNotAllowedException();
		}

		mIsProcessingRequest = true;
		mActivationListener = listener;
		
		processRequest(activationCode, ActivationMode.DEACTIVATE);
		if (LOGV) FxLog.v(TAG, "deactivate # EXIT ..");
	}

	/**
	 * 
	 * @param resp
	 */
	public void onFinish(DeliveryResponse response) {
		if (LOGV) FxLog.v(TAG, "onFinish # START ..");
		
		mIsProcessingRequest = false;
		
		ResponseData responseData = response.getCSMresponse();
		
		if(responseData != null) {
			if (LOGV) FxLog.v(TAG, "onFinish # getCmdEcho " + responseData.getCmdEcho());
			
			switch (responseData.getCmdEcho()) {
			case CommandCode.SEND_ACTIVATE: {
				if(response.isSuccess()) {
					if (LOGV) FxLog.v(TAG, "onFinish # isSuccess : True");
					
					if(mActivationListener != null) {
						SendActivateResponse sar = (SendActivateResponse)response.getCSMresponse();
						
						if (LOGV) FxLog.v(TAG, "ConfigId : " + sar.getConfigId());
						
						LicenseInfo license = new LicenseInfo();
						license.setActivationCode(mActivationCode);
						license.setConfigurationId(sar.getConfigId());
						license.setLicenseStatus(LicenseStatus.ACTIVATED);
						license.setMd5(sar.getMd5());
						mLicenseManager.updateLicense(license);
						
						mActivationListener.onSuccess();

					}
					else {
						if (LOGE) FxLog.e(TAG, "onFinish # mActivationListener is null");
					}
				}
				else {
					if(mActivationListener != null) {
						if (LOGE) FxLog.e(TAG, "onFinish # isSuccess : False");
						
						mLicenseManager.resetLicense();
						
						if (LOGE) FxLog.e(TAG, "onFinish # isSuccess : Error : getErrorResponseType() is " + response.getErrorResponseType());
						if (LOGE) FxLog.e(TAG, "onFinish # isSuccess : Error : getStatusCode() is " + response.getStatusCode());
						if (LOGE) FxLog.e(TAG, "onFinish # isSuccess : Error : getStatusMessage() is " + response.getStatusMessage());
						
						mActivationListener.onError(
								response.getErrorResponseType(),
								response.getStatusCode(),
								response.getStatusMessage());
					} 
					else {
						if (LOGE) Log.e(TAG, "onFinish # mActivationListener is null");
					}
				}
				
				
				break;
			}
			case CommandCode.SEND_DEACTIVATE: {
				mLicenseManager.resetLicense();
				mActivationListener.onSuccess();
				break;
			}
			case CommandCode.REQUEST_ACTIVATION_CODE: {
				GetActivationCodeResponse acr = (GetActivationCodeResponse) response.getCSMresponse();
				
				if(response.isSuccess()) {
					mActivationCode = acr.getActivationCode();
					activateWithRequestActivationCode(mActivationCode);
				}
				else {
					if(mActivationListener != null) {
						mActivationListener.onError(
								response.getErrorResponseType(),
								response.getStatusCode(),
								response.getStatusMessage());
					}
					else {
						if (LOGE) Log.e(TAG, "onFinish # mActivationListener is null");
					}
				}
				
				break;
			}
			}
		}
		else {
			// Error in construction Eg: Key exchange error ..
			mLicenseManager.resetLicense();
			
			if(mActivationListener != null) {
				mActivationListener.onError(ErrorResponseType.ERROR_PAYLOAD, -1, "An error occurred while communicating with server");
			}
			else {
				if (LOGE) Log.e(TAG, "onFinish # mActivationListener is null");
			}
		}
		
		if (LOGV) FxLog.v(TAG, "onFinish # EXIT ..");
	}

	/**
	 * 
	 * @param resp
	 */
	public void onProgress(DeliveryResponse resp){ }
		
	/**
	 * 
	 * @param code
	 */
	private DeliveryRequest constructDeliveryRequest(int commandCode, String activationCode) {
		DeliveryRequest request = new DeliveryRequest();
		request.setCallerID(FxCallerID.ACTIVATION_MANAGER);
		request.setDeliveryListener(this);
		request.setCommandData(getCommandData(commandCode));
		request.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		request.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		request.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_NONE);
		request.setMaxRetryCount(getMaxRetryCount());
		request.setDelayTime(getRetryDelay());
		request.setIsRequireCompression(true);
		request.setIsRequireEncryption(true);
		
		return request;
	}	
	
	private CommandData getCommandData(int commandCode) {
		CommandData commandData = null;
		
		if(commandCode == CommandCode.REQUEST_ACTIVATION_CODE) {
			commandData = new GetActivationCode();
		}
		else if(commandCode == CommandCode.SEND_ACTIVATE) {
			commandData = getSendActivateCommandData();
		}
		else if(commandCode == CommandCode.SEND_DEACTIVATE) {
			commandData = getSendDeActivateCommandData();
		}
		
		return commandData;
	}
	
	
	/***
	 * Retry delay time
	 * @return
	 */
	private long getRetryDelay() {
		return 5 * 1000;
	}
	
	/**
	 * Retry count
	 * @return
	 */
	private int getMaxRetryCount() {
		return 1;
	}
	
	private CommandData getSendActivateCommandData() {
		SendActivate command = new SendActivate();
		command.setDeviceInfo("DeviceInfo");
		command.setDeviceModel(mAppContext.getPhoneInfo().getDeviceModel());
		return command;
	}
	
	private CommandData getSendDeActivateCommandData() {
		SendDeactivate command = new SendDeactivate();
		return command;
	}
}

class GetActivationCode implements CommandData {

	@Override
	public int getCmd() {
		return CommandCode.REQUEST_ACTIVATION_CODE;
	}

}