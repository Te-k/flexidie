package com.vvt.http;

import java.io.UnsupportedEncodingException;

import org.apache.http.HttpResponse;

import com.fx.maind.ref.Customization;
import com.vvt.logger.FxLog;
import com.vvt.util.BinaryUtil;

public class HttpWrapperResponse {
	
	private static final String TAG = "HttpWrapperResponse";
	private static final boolean LOGV = Customization.VERBOSE;
	
	
	private static final String ASCII = "ASCII";
	
	private byte[] mBodyAsBytes;
	private HttpResponse mApacheHttpResponse;
	
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
		if (LOGV) FxLog.v(TAG, "HttpWrapperResponse # ENTER ...");
		mApacheHttpResponse = apacheHttpResponse;
		mBodyAsBytes = bodyAsBytes;
	}

	public byte[] getBodyAsBytes() {
		if (LOGV) FxLog.v(TAG, "getBodyAsBytes # ENTER ...");
		return mBodyAsBytes;
	}
	
	public int getHttpStatusCode() {
		if (LOGV) FxLog.v(TAG, "getHttpStatusCode # ENTER ...");
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
		if (LOGV) FxLog.v(TAG, "toString # ENTER ...");
		try {
			String bodyAsString = new String(mBodyAsBytes, ASCII);
			if (LOGV) {
				FxLog.v(TAG, String.format("Response binary: %s", 
						BinaryUtil.bytesToString1(mBodyAsBytes)));
				FxLog.v(TAG, String.format("Response string: %s", bodyAsString));
			}
			return bodyAsString; 
		} catch (UnsupportedEncodingException e) {
			FxLog.e(TAG, String.format("toString # Error: %s", e));
		}
		return super.toString();
	}

}
