package com.fx.dalvik.activation;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;

import com.fx.android.common.http.HttpWrapper;
import com.fx.android.common.http.HttpWrapperException;
import com.fx.android.common.http.HttpWrapperResponse;
import com.fx.dalvik.activation.ActivationManager.Status;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.util.BinaryUtil;
import com.fx.dalvik.util.FxLog;

class AutoActivation {
	
	private static final String TAG = "AutoActivation";
	
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private ActivationInfo mActivationInfo;
	private ProductInfo mProductInfo;
	
	AutoActivation(ActivationInfo activationInfo) {
		mActivationInfo = activationInfo;
		mProductInfo = mActivationInfo.getProductInfo();
	}

	public ActivationResponse activateProduct() {
		String activationCode = null;
		
		// Request Activation Code from the server
		ActivationResponse tmpResponse = requestActivationCode();
		
		if (tmpResponse.isSuccess() && tmpResponse.getMessage() != null) {
			activationCode = tmpResponse.getMessage();
		}
		
		if (activationCode == null) {
			return tmpResponse;
		}
		else {
			return doActivateOrDeactivate(true, activationCode);
		}
	}
	
	public ActivationResponse deactivateProduct(String activationCode) {
		return doActivateOrDeactivate(false, activationCode);
	}
	
	private ActivationResponse requestActivationCode() {
		
		HttpWrapper httpWrapper = HttpWrapper.getInstance();
		HttpWrapperResponse httpWrapperResponse = null;
		String requestActivationCodeUrl = getRequestActivationCodeUrl();
		
		ActivationResponse response = null;
		
		try {
			httpWrapperResponse = httpWrapper.httpGet(requestActivationCodeUrl);
			byte[] httpResponse = httpWrapperResponse.getBodyAsBytes();
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format(
						"requestActivationCode # HTTP Response [%d]: %s", 
						httpWrapperResponse.getHttpStatusCode(), 
						BinaryUtil.bytesToString2(httpResponse)));
			}
			// Response Code
			byte responseCodeByte = httpResponse[0];
			
			// Success
			if (responseCodeByte == (byte) 0 || responseCodeByte == (byte) 2) {
				String activationKey = BinaryUtil.bytesToString2(httpResponse, 3, httpResponse.length);
				response = new ActivationResponse(true, activationKey, null);
			} 
			// Fail -> Show <error code>: <error message>
			else {
				byte[] messageAsBytes = new byte[httpResponse.length-3];
				System.arraycopy(httpResponse, 3, messageAsBytes, 0, messageAsBytes.length);
				
				String errorMessage = null;
				try {
					errorMessage = String.format("0x%02X: %s", 
							responseCodeByte,
							new String(messageAsBytes, "utf-8"));
					
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("Error message from server: %s", errorMessage));
					}
				} 
				catch (UnsupportedEncodingException e) {
					if (LOCAL_LOGD) {
						FxLog.d(TAG, "Invalid encoding of response message.");
					}
					
					errorMessage = ActivationResource.LANGUAGE_ACTIVATION_RESPONSE_NOT_DEFINED;
					
					if (LOCAL_LOGV) {
						FxLog.v(TAG, String.format("Set error message to: %s", errorMessage));
					}
				}
				response = new ActivationResponse(false, errorMessage, null);
			}
		}
		catch (HttpWrapperException e) {
			response = ActivationHelper.createResponseFromHttpException(true, e);
		}
		
		return response;
	}
	
	// No activation code parameters
	private String getRequestActivationCodeUrl() {
		String url = null;
		String imieHash = "null";
		String deviceId = mActivationInfo.getDeviceId();
		
		String version = new StringBuilder()
				.append(mProductInfo.getVersionMajor())
				.append(mProductInfo.getVersionMinor())
				.toString();
		
		String pid = mProductInfo.getName();
		String mode = ActivationHelper.MODE_REQUEST_ACTIVATION_CODE;
		String model = mActivationInfo.getDeviceModel();
		
		try {
			if (deviceId != null) {
				imieHash = URLEncoder.encode(deviceId, ActivationHelper.URL_ENCODE_SCHEME);
			}
			url = String.format(mProductInfo.getUrlRequestActivationCode(), 
					imieHash, 
					URLEncoder.encode(version, ActivationHelper.URL_ENCODE_SCHEME),
					URLEncoder.encode(pid, ActivationHelper.URL_ENCODE_SCHEME),
					URLEncoder.encode(mode, ActivationHelper.URL_ENCODE_SCHEME), 
					URLEncoder.encode(model, ActivationHelper.URL_ENCODE_SCHEME));
		} 
		catch (UnsupportedEncodingException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "getRequestActivationCodeUrl # Cannot get activation URL.");
			}
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("getRequestActivationCodeUrl # URL: \"%s\"", url));
		}
		
		return url;
	}
	
	private ActivationResponse doActivateOrDeactivate(boolean activationFlag, String activationCode) {
		
		
		HttpWrapper httpWrapper = HttpWrapper.getInstance();
		HttpWrapperResponse httpResponse;
		ActivationResponse tmpResponse;
		
		try {
			if (activationFlag) {
				httpResponse = httpWrapper.httpGet(
						ActivationHelper.getActivationUrl(activationCode, mActivationInfo));
			} 
			else {
				httpResponse = httpWrapper.httpGet(
						ActivationHelper.getDeactivationUrl(activationCode, mActivationInfo));
			}
			tmpResponse = createResponseFromHttpResponse(activationFlag, httpResponse);
		} 
		catch (HttpWrapperException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "HTTP error", e);
			}
			tmpResponse = ActivationHelper.createResponseFromHttpException(activationFlag, e);
		}
		
		ActivationResponse response = new ActivationResponse();
		response.setActivateAction(activationFlag);
		response.setSuccess(tmpResponse.isSuccess());
		response.setMessage(tmpResponse.getMessage());
		response.setActivationStatus(tmpResponse.getActivationStatus());
		response.setHashCode(tmpResponse.getHashCode());
		
		return response;
	}
	
	private ActivationResponse createResponseFromHttpResponse(
			boolean activateFlag, HttpWrapperResponse httpWrapperResponse) {
		
		byte[] httpResponse = httpWrapperResponse.getBodyAsBytes();
		boolean success;
		String message;
		Status status = null;

		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("HTTP Response [%d]: %s", 
					httpWrapperResponse.getHttpStatusCode(),
					BinaryUtil.bytesToString2(httpResponse)));
		}
		String serverHashCode = null;
		
		if (activateFlag) {
			serverHashCode = BinaryUtil.bytesToString2(httpResponse, 5, httpResponse.length);
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Server hash: %s", serverHashCode));
			}
		}
		
		if ((activateFlag && httpResponse.length >= 6) 
				|| (!activateFlag && httpResponse.length >= 3)) {
			
			byte responseCodeByte = httpResponse[0];
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Response code = %d", responseCodeByte));
			}
			
			// Successful request -> depends on a protocol e.g. 0 or 2
			if (responseCodeByte == (byte) 2) {
				if (activateFlag) {
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
						FxLog.v(TAG, "Deactivation failed. This Activation Code is already deactivated");
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
				status = activateFlag ? Status.ACTIVATED : Status.DEACTIVATED;
			} else {
				status = activateFlag ? Status.DEACTIVATED : Status.ACTIVATED;
			}
		}
		ActivationResponse response = new ActivationResponse(success, message, status); 
		response.setHashCode(serverHashCode);
		
		return response;
	}
}
