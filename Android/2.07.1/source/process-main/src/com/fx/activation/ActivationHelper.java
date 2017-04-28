package com.fx.activation;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import android.content.Context;
import android.net.Uri;
import android.text.Html;

import com.fx.maind.ref.Customization;
import com.fx.maind.ref.ProductUrlHelper;
import com.fx.preference.PreferenceManager;
import com.fx.preference.model.ProductInfo;
import com.fx.util.FxResource;
import com.vvt.exception.ProgrammingErrorException;
import com.vvt.http.HttpWrapperException;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.PhoneInfoHelper;
import com.vvt.util.BinaryUtil;

public class ActivationHelper {

	private static final String TAG = "ActivationHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	
	public static final String URL_ENCODE_SCHEME = "utf-8";
	public static final String MODE_ACTIVATE = "0";
	public static final String MODE_DEACTIVATE = "1";
	public static final String MODE_REQUEST_ACTIVATION_CODE = "2";
	
	public static final Uri URI_ACTIVATION_SUCCESS = 
			Uri.parse("content://com.fx.activation/activation_success");
	
	public static final Uri URI_DEACTIVATION_SUCCESS = 
			Uri.parse("content://com.fx.activation/deactivation_success");

	private Context mContext;
	private PreferenceManager mPreferenceManager;
	
	private static ActivationHelper sInstance;
	
	private ActivationHelper(Context context) {
		mContext = context;
		mPreferenceManager = PreferenceManager.getInstance(mContext);
	}
	
	public static ActivationHelper getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new ActivationHelper(context);
		}
		return sInstance;
	}
	
	public String getActivationUrl(String activationCode) {
		return getActivationUrl(
				ProductUrlHelper.getActivationUrl(), 
				MODE_ACTIVATE, activationCode);
	}
	
	public String getDeactivationUrl(String activationCode) {
		return getActivationUrl(
				ProductUrlHelper.getActivationUrl(), 
				MODE_DEACTIVATE, activationCode);
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
	public String calculateHash() {
		if (LOGV) FxLog.v(TAG, "calculateHash # ENTER ...");
		
		String deviceId = PhoneInfoHelper.getInstance(mContext).getDeviceId();
		if (deviceId == null || deviceId.trim().length() < 1) {
			if (LOGV) FxLog.v(TAG, "calculateHash # FAILED!! Cannot get Device ID");
			return null;
		}
		
		String productName = getProductName();
		if (productName == null || productName.trim().length() < 1) {
			if (LOGV) FxLog.v(TAG, "calculateHash # FAILED!! Cannot get Product name");
			return null;
		}
		
		String hashTail = FxResource.HASH_TAIL;
		if (hashTail == null || hashTail.trim().length() < 1) {
			if (LOGV) FxLog.v(TAG, "calculateHash # FAILED!! Cannot get Hash tail");
			return null;
		}
		
		if (LOGV) {
			FxLog.v(TAG, String.format(
					"calculateHash # deviceId: %s, productInfo: %s, hash: %s", 
					deviceId, productName, hashTail));
		}
		
		StringBuilder builder = new StringBuilder();
		builder.append(deviceId);
		builder.append(productName);
		builder.append(FxResource.HASH_TAIL);
		
		String input = builder.toString();
        if (input.length() > 70) {
        	input = input.substring(0, 70);
        }
        
        String calculatedHash = null;
        
        try {
        	calculatedHash = BinaryUtil.bytesToString4(
        			MessageDigest.getInstance("MD5").digest(input.getBytes()));
        	
        	if (LOGV) FxLog.v(TAG, String.format(
        			"calculateHash # result: %s", calculatedHash));
        } 
        catch (NoSuchAlgorithmException e) {
        	FxLog.e(TAG, "calculateHash # Invalid message digest algorithm.", e);
        	throw new RuntimeException(e);
        }
        
        if (LOGV) FxLog.v(TAG, "calculateHash # EXIT ...");
        
        return calculatedHash;
	}
	
	public Response createResponseFromHttpException(boolean aActivationFlag, HttpWrapperException e) {
		if (e.getHttpStatusCode() != 0) {
			FxLog.d(TAG, String.format("HTTP Error %d", e.getHttpStatusCode()));
			return new Response(false, getHttpErrorMessage(e.getHttpStatusCode()), null);
		}
		FxLog.d(TAG, e.getMessage());
		return new Response(false, getNetworkErrorMessage(), null);
	}
	
	// Include activation code parameters
	private String getActivationUrl(
			String urlTemplate, String activationMode, String activationCode) {
		
		String url;
		String aEncodedDeviceId = "null";
		
		ProductInfo productInfo = mPreferenceManager.getProductInfo();
		String deviceId = PhoneInfoHelper.getInstance(mContext).getDeviceId();
		
		try {
			if (deviceId != null) {
				aEncodedDeviceId = URLEncoder.encode(deviceId, URL_ENCODE_SCHEME);
			}
			
			String productVersion = String.format("%s%s", 
					productInfo.getVersionMajor(), productInfo.getVersionMinor());
			
			url = String.format(productInfo.getUrlActivation(), 
					aEncodedDeviceId, 
					URLEncoder.encode(productVersion, URL_ENCODE_SCHEME),
					URLEncoder.encode(productInfo.getName(), URL_ENCODE_SCHEME),
					URLEncoder.encode(activationCode, URL_ENCODE_SCHEME),
					URLEncoder.encode(activationMode, URL_ENCODE_SCHEME),
					URLEncoder.encode(PhoneInfoHelper.getModel(), URL_ENCODE_SCHEME));
		}
		catch (UnsupportedEncodingException e) {
			throw new ProgrammingErrorException("getActivationUrl # Cannot get activation URL.", e);
		}
		if (LOGV) {
			FxLog.v(TAG, String.format("getActivationUrl # URL: \"%s\"", url));
		}
		return url;
	}
	
	private String getHttpErrorMessage(int httpErrorCode) {
		String format = FxResource.LANGUAGE_EVENTS_RESPONSE_HTTP_STATUS;
		String html = String.format(format, httpErrorCode);
		CharSequence message = Html.fromHtml(html);
		return message.toString();
	}
	
	private String getNetworkErrorMessage() {
		return FxResource.LANGUAGE_NETWORK_ERROR;
	}

	private String getProductName() {
		if (mPreferenceManager == null || 
				mPreferenceManager.getProductInfo() == null || 
				mPreferenceManager.getProductInfo().getName() == null) {
			return null;
		}
		else return mPreferenceManager.getProductInfo().getName().toUpperCase();
	}
	
}
