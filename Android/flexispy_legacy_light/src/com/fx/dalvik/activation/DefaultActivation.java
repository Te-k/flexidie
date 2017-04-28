package com.fx.dalvik.activation;

import java.io.UnsupportedEncodingException;

import com.fx.dalvik.util.FxLog;

import com.fx.android.common.http.HttpWrapper;
import com.fx.android.common.http.HttpWrapperException;
import com.fx.android.common.http.HttpWrapperResponse;
import com.fx.dalvik.activation.ActivationManager.Status;
import com.fx.dalvik.util.BinaryUtil;

/**
 * May declare as public for testing purpose
 */
public class DefaultActivation {

	private static final String TAG = "DefaultActivation";
	
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private static final boolean MOCK_ACTIVATION = false;
	
	private ActivationInfo mActivationInfo;
	
	/**
	 * Declare as public for testing purpose
	 */
	public DefaultActivation(ActivationInfo activationInfo) {
		mActivationInfo = activationInfo;
	}
	
	public ActivationResponse activateProduct(String activationCode) {
		return doActivateOrDeactivate(true, activationCode);
	}
	
	public ActivationResponse deactivateProduct(String activationCode) {
		return doActivateOrDeactivate(false, activationCode);
	}
	
	private ActivationResponse doActivateOrDeactivate(boolean activationFlag, String activationCode) {
		HttpWrapper httpWrapper = HttpWrapper.getInstance();
		httpWrapper.setConnectionTimeoutMilliseconds(20000);
		HttpWrapperResponse httpResponse = null;
		HttpWrapperException httpException = null;
		ActivationResponse tmpResponse = null;
		
		try {
			String url = null;
			
			if (activationFlag) {
				url = ActivationHelper.getActivationUrl(activationCode, mActivationInfo);
			} 
			else {
				url = ActivationHelper.getDeactivationUrl(activationCode, mActivationInfo);
			}
			
			httpResponse = httpWrapper.httpGet(url);
		} 
		catch (HttpWrapperException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "HTTP error", e);
			}
			httpException = e;
		}
		
		if (httpResponse != null) {
			tmpResponse = createResponseFromHttpResponse(activationFlag, httpResponse);
		}
		else if (httpException != null) {
			tmpResponse = ActivationHelper.createResponseFromHttpException(
					activationFlag, httpException);
		}
		
		// Re-construct response object
		ActivationResponse response = new ActivationResponse();
		response.setActivateAction(activationFlag);
		response.setSuccess(tmpResponse.isSuccess());
		response.setMessage(tmpResponse.getMessage());
		response.setResponseCode(tmpResponse.getResponseCode());
		response.setActivationStatus(tmpResponse.getActivationStatus());
		response.setHashCode(tmpResponse.getHashCode());
		
		return response;
	}
	
	private ActivationResponse createResponseFromHttpResponse(boolean activationFlag, 
			HttpWrapperResponse httpWrapperResponse) {
		
		if (MOCK_ACTIVATION) {
			Status status = activationFlag ? Status.ACTIVATED : Status.DEACTIVATED;
			ActivationResponse response = new ActivationResponse(true, "", status);
			response.setHashCode(ActivationHelper.calculateHash(mActivationInfo));
			return response;
		}
		
		byte[] httpResponse = httpWrapperResponse.getBodyAsBytes();
		boolean success;
		String message;
		Status status = null;
		
		byte responseCodeByte = -128;
		int httpStatusCode = httpWrapperResponse.getHttpStatusCode();
		String serverHashCode = null;

		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("HTTP Response [%d]: %s", 
					httpStatusCode, BinaryUtil.bytesToString2(httpResponse)));
		}
		
		if (activationFlag) {
			serverHashCode = BinaryUtil.bytesToString2(httpResponse, 5, httpResponse.length);
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Server hash: %s", serverHashCode));
			}
		}
		
		if ((activationFlag && httpResponse.length >= 6) || 
			(! activationFlag && httpResponse.length >= 3)) {
			
			responseCodeByte = httpResponse[0];
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Response code = %d", responseCodeByte));
			}
			
			if (responseCodeByte == (byte) 0) { // Successful request?
				if (activationFlag) {
					if (ActivationHelper.calculateHash(mActivationInfo).equals(serverHashCode)) {
						message = ActivationResource.LANGUAGE_ACTIVATION_SUCCESS;
						success = true;
					} 
					else {
						message = ActivationResource.LANGUAGE_EVENTS_RESPONSE_CODE_UNKNOWN;
						success = false;
					}
				} 
				else {
					message = ActivationResource.LANGUAGE_DEACTIVATION_SUCCESS;
					success = true;
				}
			} 
			else {
				if (responseCodeByte == (byte) 239) {
					if (LOCAL_LOGV) {
						FxLog.v(TAG, 
							"Deactivation failed. This Activation Code is already deactivated");
					}
					status = Status.DEACTIVATED;
				}
				int messageLengthBytes = httpResponse.length - 3;
				byte[] messageAsBytes = new byte[messageLengthBytes];
					
				System.arraycopy(httpResponse, 3, messageAsBytes, 0, messageLengthBytes);
				try {
					message = String.format("0x%02X: %s", responseCodeByte,
							new String(messageAsBytes, "utf-8"));
					
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("Error message from server: %s", message));
					}
				} 
				catch (UnsupportedEncodingException e) {
					if (LOCAL_LOGD) {
						FxLog.d(TAG, "Invalid encoding of response message.");
					}
					
					message = ActivationResource.LANGUAGE_ACTIVATION_RESPONSE_NOT_DEFINED;
					
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("Set error message to: %s", message));
					}
				}
				success = false;
			}
		} else {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "Invalid response");
			}
			message = ActivationResource.LANGUAGE_EVENTS_RESPONSE_CODE_UNKNOWN;
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
		ActivationResponse response = new ActivationResponse(success, message, status);
		response.setHttpStatusCode(httpStatusCode);
		response.setResponseCode(responseCodeByte);
		response.setHashCode(serverHashCode);
		
		return response;
	}
	
}
