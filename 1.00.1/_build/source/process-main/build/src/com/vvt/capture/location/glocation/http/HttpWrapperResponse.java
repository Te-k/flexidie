package com.vvt.capture.location.glocation.http;

import java.io.UnsupportedEncodingException;

import org.apache.http.HttpResponse;

import com.vvt.capture.location.Customization;
import com.vvt.logger.FxLog;

public class HttpWrapperResponse {

	// -------------------------------------------------------------------------------------------------
	// PRIVATE API
	// -------------------------------------------------------------------------------------------------

	private static final String TAG = "HttpWrapperResponse";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String ASCII = "ASCII";

	private byte[] mBodyAsBytes;
	private HttpResponse mApacheHttpResponse;

	// -------------------------------------------------------------------------------------------------
	// PUBLIC API
	// -------------------------------------------------------------------------------------------------

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

	public HttpWrapperResponse(HttpResponse apacheHttpResponse,
			byte[] bodyAsBytes) {
		mApacheHttpResponse = apacheHttpResponse;
		mBodyAsBytes = bodyAsBytes;
	}

	public byte[] getBodyAsBytes() {
		return mBodyAsBytes;
	}

	public int getHttpStatusCode() {
		return mApacheHttpResponse.getStatusLine().getStatusCode();
	}

	public Header[] getAllHeaders() {
		org.apache.http.Header headers1[] = mApacheHttpResponse.getAllHeaders();
		Header[] headers2 = new Header[headers1.length];

		for (int i = 0; i < headers1.length; i++) {
			headers2[i] = new Header();
			headers2[i].setName(headers1[i].getName());
			headers2[i].setValue(headers1[i].getValue());
		}

		return headers2;
	}

	public String toString() {
		if(LOGV) FxLog.v(TAG, "... toString() ...");
		
		try {
			String bodyAsString = new String(mBodyAsBytes, ASCII);
			/*if (LOCAL_LOGV) {
				FxLog.v(TAG, String.format("Response binary: %s", GeneralUtil
						.bytesToString1(mBodyAsBytes)));
				FxLog
						.v(TAG, String.format("Response string: %s",
								bodyAsString));
			}*/
			return bodyAsString;
		} catch (UnsupportedEncodingException e) {
			if(LOGE) FxLog.e(TAG, "UnsupportedEncodingException: "+e.getMessage());
		}
		return super.toString();
	}

}
