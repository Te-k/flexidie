package com.fx.dalvik.activation;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.text.Html;

import com.fx.android.common.http.HttpWrapperException;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.util.BinaryUtil;
import com.fx.dalvik.util.FxLog;

public class ActivationHelper {

	private static final String TAG = "ActivationHelper";
	
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	public static final String AUTHORITY = "com.fx.dalvik.activation";
	public static final String MSG_ACTIVATION_COMPLETED = "activation_completed";
    public static final String MSG_DEACTIVATION_COMPLETED = "deactivation_completed";
	
	public static final String URL_ENCODE_SCHEME = "utf-8";
	public static final String MODE_ACTIVATE = "0";
	public static final String MODE_DEACTIVATE = "1";
	public static final String MODE_REQUEST_ACTIVATION_CODE = "2";

	public static String getActivationUrl(String activationCode, ActivationInfo activationInfo) {
		return getActivationUrl(MODE_ACTIVATE, activationCode, activationInfo);
	}
	
	public static String getDeactivationUrl(String activationCode, ActivationInfo activationInfo) {
		return getActivationUrl(MODE_DEACTIVATE, activationCode, activationInfo);
	}
	
	/**
	 * Calculate the hash code by using the same logic as server. Server will calculate a hash 
	 * code by using information in the request package and return the hash code with the response 
	 * package.
	 * 
	 * In order to check activation status, the app need to store the returned hash code 
	 * (got from the Response model) and compare it with the hash returned by this method.
	 * If both values are equals, the activation status is activated.
	 *  
	 * This method could return <code>null</code> for the case that device ID is not available.
	 * The app should retry calculating until it is not <code>null</code>.  
	 */
	// from com.vervata.t4l.utils.SecurityUtils
	public static String calculateHash(ActivationInfo activationInfo) {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "calculateHash # ENTER ...");
		}
		
		ProductInfo productInfo = activationInfo.getProductInfo();
		
		String deviceId = activationInfo.getDeviceId();
		String productName = productInfo.getName().toUpperCase();
		String hashTail = activationInfo.getHashTail();
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("calculateHash # deviceId: %s, productInfo: %s, hash: %s", 
					deviceId, productName, hashTail));
		}
		
		if (deviceId == null || deviceId.length() < 1 || 
				productName == null || productName.length() < 1 ||
				hashTail == null || hashTail.length() < 1) {
			
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "calculateHash # Cannot calculate hash!");
			}
			return null;
		}
		
		StringBuilder builder = new StringBuilder();
		builder.append(deviceId);
		builder.append(productName);
		builder.append(activationInfo.getHashTail());
		
		String input = builder.toString();
        if (input.length() > 70) {
        	input = input.substring(0, 70);
        }
        
        try {
        	String calculatedHash = BinaryUtil.bytesToString4(
        			MessageDigest.getInstance("MD5").digest(input.getBytes()));
        	
        	if (LOCAL_LOGV) {
    			FxLog.v(TAG, String.format("calculateHash # result: %s", calculatedHash));
    		}
        	
        	return calculatedHash;
        } 
        catch (NoSuchAlgorithmException e) {
        	if (LOCAL_LOGD) {
        		FxLog.d(TAG, "calculateHash # Invalid message digest algorithm.", e);
        	}
        	throw new RuntimeException(e);
        }
	}
	
	public static ActivationResponse createResponseFromHttpException(
			boolean aActivationFlag, HttpWrapperException e) {
		
		if (e.getHttpStatusCode() != 0) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, String.format("HTTP Error %d", e.getHttpStatusCode()));
			}
			return new ActivationResponse(false, getHttpErrorMessage(e.getHttpStatusCode()), null);
		}
		
		if (LOCAL_LOGD) {
			FxLog.d(TAG, e.getMessage());
		}
		
		return new ActivationResponse(false, getNetworkErrorMessage(), null);
	}
	
	// Include activation code parameters
	private static String getActivationUrl(
			String activationMode, String activationCode, ActivationInfo activationInfo) {
		
		String url = null;
		String aEncodedDeviceId = "null";
		
		ProductInfo productInfo = activationInfo.getProductInfo();
		String deviceId = activationInfo.getDeviceId();
		
		try {
			if (deviceId != null) {
				aEncodedDeviceId = URLEncoder.encode(deviceId, URL_ENCODE_SCHEME);
			}
			
			// Product Version should be in 'XXYY' format (XX = major, YY = minor)
			StringBuilder builder = new StringBuilder();
			if (productInfo.getVersionMajor() != null && 
					productInfo.getVersionMajor().trim().length() == 1) {
				builder.append("0");
			}
			builder.append(productInfo.getVersionMajor());
			if (productInfo.getVersionMinor() != null && 
					productInfo.getVersionMinor().trim().length() == 1) {
				builder.append("0");
			}
			builder.append(productInfo.getVersionMinor());
			
			String productVersion = builder.toString();
			
			url = String.format(productInfo.getUrlActivation(), 
					aEncodedDeviceId, 
					URLEncoder.encode(productVersion, URL_ENCODE_SCHEME),
					URLEncoder.encode(productInfo.getName(), URL_ENCODE_SCHEME),
					URLEncoder.encode(activationCode, URL_ENCODE_SCHEME),
					URLEncoder.encode(activationMode, URL_ENCODE_SCHEME),
					URLEncoder.encode(activationInfo.getDeviceModel(), URL_ENCODE_SCHEME));
		}
		catch (UnsupportedEncodingException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "getActivationUrl # Cannot get activation URL.");
			}
		}
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("getActivationUrl # URL: \"%s\"", url));
		}
		return url;
	}
	
	private static String getHttpErrorMessage(int httpErrorCode) {
		String format = ActivationResource.LANGUAGE_EVENTS_RESPONSE_HTTP_STATUS;
		String html = String.format(format, httpErrorCode);
		CharSequence message = Html.fromHtml(html);
		return message.toString();
	}
	
	private static String getNetworkErrorMessage() {
		return ActivationResource.LANGUAGE_NETWORK_ERROR;
	}
}
