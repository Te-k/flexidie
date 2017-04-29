package com.fx.android.common.http;

import java.io.UnsupportedEncodingException;

import org.apache.http.HttpResponse;

import com.fx.android.common.Customization;
import com.fx.dalvik.util.GeneralUtil;

import com.fx.dalvik.util.FxLog;

public class HttpWrapperResponse {
	
//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------
		
	private static final String TAG = "HttpWrapperResponse";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	
	private static final String ASCII = "ASCII";
	
	private byte[] mBodyAsBytes;
	private HttpResponse mApacheHttpResponse;
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public static class Header {
		
		String mName;
		
		String mValue;
		
		public String getName() {
			return mName;
		}

		public void setName(String name) {
			mName = name;
		}

		public String getValue() {
			return mValue;
		}

		public void setValue(String value) {
			mValue = value;
		}

	}
	
	public HttpWrapperResponse(HttpResponse apacheHttpResponse, byte[] bodyAsBytes) {
		if (LOCAL_LOGV) FxLog.v(TAG, "HttpWrapperResponse # ENTER ...");
		mApacheHttpResponse = apacheHttpResponse;
		mBodyAsBytes = bodyAsBytes;
	}

	public byte[] getBodyAsBytes() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getBodyAsBytes # ENTER ...");
		return mBodyAsBytes;
	}
	
	public int getHttpStatusCode() {
		if (LOCAL_LOGV) FxLog.v(TAG, "getHttpStatusCode # ENTER ...");
		return mApacheHttpResponse.getStatusLine().getStatusCode();
	}
	
	public Header[] getAllHeaders() {
		org.apache.http.Header headers1[] = mApacheHttpResponse.getAllHeaders();
		Header[] headers2 = new Header[headers1.length];
		
		for (int i = 0 ; i < headers1.length ; i++) {
			headers2[i] = new Header();
			headers2[i].setName(headers1[i].getName());
			headers2[i].setValue(headers1[i].getValue());
		}
		
		return headers2;
	}
	
	public String toString() {
		if (LOCAL_LOGV) FxLog.v(TAG, "toString # ENTER ...");
		try {
			String bodyAsString = new String(mBodyAsBytes, ASCII);
			if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Response binary: %s", 
						GeneralUtil.bytesToString1(mBodyAsBytes)));
				FxLog.v(TAG, String.format("Response string: %s", bodyAsString));
			}
			return bodyAsString; 
		} catch (UnsupportedEncodingException e) {
			if (LOCAL_LOGD) {
				FxLog.d(TAG, "Unsupported encoding.", e);
			}
		}
		return super.toString();
	}

}
