package com.vvt.capture.location.glocation.http;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.HttpConnectionParams;
import org.apache.http.params.HttpParams;

import com.vvt.capture.location.Customization;
import com.vvt.logger.FxLog;

import android.os.Handler;
import android.os.Message;

/**
 * HttpWrapper class wraps HTTP Apache's library.
 */
public class HttpWrapper {

	// -------------------------------------------------------------------------------------------------
	// PRIVATE API
	// -------------------------------------------------------------------------------------------------

	private static final String TAG = "HttpWrapper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;

	private List<NameValue> headerList;
	private int socketTimeoutMilliseconds = 30000;
	private int connectionTimeoutMilliseconds = 30000;

	private class NameValue {
		public String name;
		public String value;
		public boolean add; // true for 'add', false for 'set'

		public NameValue(String aName, String aValue, boolean aAdd) {
			name = aName;
			value = aValue;
			add = aAdd;
		}
	}

	private class RequestParam {
		public String url;
		public byte[] body;
	}

	private interface IHttpAction {
		HttpWrapperResponse performHttpAction(RequestParam aRequestParam)
				throws HttpWrapperException;
	}

	private class ProcessingThread extends Thread {

		private static final String TAG = "HttpWrapper.ProcessingThread";

		private IHttpAction action = null;

		private RequestParam requestParam = null;

		public IHttpWrapperCallback callback = null;

		public HttpWrapperResponse response = null;

		public HttpWrapperException exception = null;

		public ProcessingThread(IHttpAction aAction, RequestParam aRequestParam) {
			action = aAction;
			requestParam = aRequestParam;
		}

		public void run() {
			if(LOGV) FxLog.v(TAG,  "... run() ...");
			try {
				response = action.performHttpAction(requestParam);
			} catch (HttpWrapperException e) {
				exception = e;
			}

			// The callback method cannot be called directly in this method.
			// It will be called in the processingDoneHandler instead.
			Message aMessage = processingDoneHandler.obtainMessage();
			aMessage.obj = this;
			processingDoneHandler.sendMessage(aMessage);
		}

	}

	private class ProcessingDoneHandler extends Handler {

		private static final String TAG = "HttpWrapper.processingDoneHandler";

		public void handleMessage(Message aMessage) {
			if(LOGV) FxLog.v(TAG,  "... handleMessage() ...");
			ProcessingThread processingThread = (ProcessingThread) aMessage.obj;
			IHttpWrapperCallback aCallback = processingThread.callback;
			HttpWrapperResponse aResponse = processingThread.response;
			HttpWrapperException aException = processingThread.exception;
			aCallback.onHttpResponse(aResponse, aException);
		}

	};

	private ProcessingDoneHandler processingDoneHandler = null;

	private class HttpGetAction implements IHttpAction {

		public HttpWrapperResponse performHttpAction(RequestParam aRequestParam)
				throws HttpWrapperException {
			return httpGet(aRequestParam.url);
		}

	}

	private class HttpPostAction implements IHttpAction {

		public HttpWrapperResponse performHttpAction(RequestParam aRequestParam)
				throws HttpWrapperException {
			return httpPost(aRequestParam.url, aRequestParam.body);
		}

	}

	private HttpWrapper() {
		headerList = new ArrayList<NameValue>();
	}

	/**
	 * Performs synchronous HTTP GET or POST.
	 * 
	 * @param aUrl
	 *            the URL of the web server.
	 * @param aBody
	 *            the body part of the HTTP request. If this value is
	 *            <code>null</code> HTTP method will be GET otherwise, HTTP
	 *            method will be POST.
	 * @return the HTTP response.
	 * @throws HttpWrapperException
	 */
	public HttpWrapperResponse httpGetOrPost(String aUrl, byte[] aBody)
			throws HttpWrapperException {

		if(LOGV) FxLog.v(TAG,  "... httpGetOrPost() ...");
		if(LOGD) FxLog.d(TAG,  "Url : "+aUrl);
		
		byte[] aData = new byte[0];
		HttpClient aHttpClient = new DefaultHttpClient();
		HttpRequestBase aHttpRequest;

		HttpParams aParams = aHttpClient.getParams();
		HttpConnectionParams.setConnectionTimeout(aParams,
				connectionTimeoutMilliseconds);
		HttpConnectionParams.setSoTimeout(aParams, socketTimeoutMilliseconds);

		if (aBody == null) {
			aHttpRequest = new HttpGet(aUrl);
		} else {
			aHttpRequest = new HttpPost(aUrl);
		}

		/*if (LOCAL_v) {
			for (Header header : aHttpRequest.getAllHeaders()) {
				FxFxLog.v(TAG, String.format("Header %s", header));
			}
		}*/

		// Add or Set headers
		for (NameValue nameValue : headerList) {
			if (nameValue.add) {
				/*if (LOCAL_v) {
					FxFxLog.v(TAG, String.format("Add header %s: %s",
							nameValue.name, nameValue.value));
				}*/
				aHttpRequest.addHeader(nameValue.name, nameValue.value);
			} else {
				/*if (LOCAL_v) {
					FxFxLog.v(TAG, String.format("Set header %s: %s",
							nameValue.name, nameValue.value));
				}*/
				aHttpRequest.setHeader(nameValue.name, nameValue.value);
			}
		}

		// Add body
		if (aBody != null) {
			HttpPost aHttpPost = (HttpPost) aHttpRequest;
			ByteArrayEntity aRequestEntity = new ByteArrayEntity(aBody);
			aHttpPost.setEntity(aRequestEntity);
		}

		HttpResponse aResponse = null;
		try {
			aResponse = aHttpClient.execute(aHttpRequest);
		} catch (ClientProtocolException e) {
			if(LOGE) FxLog.e(TAG,  "ClientProtocolException: "+e.getMessage());
			throw new HttpWrapperException(e);
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG,  "IOException: "+e.getMessage());
			throw new HttpWrapperException(e);
		}

		int aStatusCode = aResponse.getStatusLine().getStatusCode();

		if(LOGE) FxLog.e(TAG,  "HTTP status code = "+ aStatusCode);
		
		if (aStatusCode != HTTP_STATUS_CODE_OK) {
			String aMessage = String.format("HTTP Error %d", aStatusCode);
			HttpWrapperException e = new HttpWrapperException(aMessage);
			e.setHttpStatusCode(aStatusCode);
			throw e;
		}

		HttpEntity entity = aResponse.getEntity();
		try {
			if (entity != null) {
				InputStream instream = entity.getContent();
				int length = (int) entity.getContentLength();
				if(LOGV) FxLog.v(TAG,  "Content length = "+ length);
				if (length > 0) {
					int n;
					int offset = 0;
					aData = new byte[length];
					n = instream.read(aData, offset, 1024);
					while (n != -1) {
						offset += n;
						FxLog.v(TAG,  n+" bytes read.");
						n = instream.read(aData, offset, 1024);
					}
				} else { // Unknown size
					if(LOGV)FxLog.v(TAG,  "Unknown size, trying to read all...");
					int aSize = 0;
					int aNumRead = 0;
					byte[] aTempBuffer = new byte[1024];
					List<byte[]> aBuffer = new ArrayList<byte[]>();
					byte[] aChunk;

					aNumRead = instream.read(aTempBuffer);
					while (aNumRead != -1) {
						if(LOGV) FxLog.v(TAG,  "Got "+aNumRead+" bytes");
						aChunk = new byte[aNumRead];
						System.arraycopy(aTempBuffer, 0, aChunk, 0, aNumRead);
						aBuffer.add(aChunk);
						aSize += aNumRead;
						aNumRead = instream.read(aTempBuffer);
					}

					aData = new byte[aSize];
					int aPos = 0;
					for (byte[] aChunk2 : aBuffer) {
						System.arraycopy(aChunk2, 0, aData, aPos,
								aChunk2.length);
						aPos += aChunk2.length;
					}

					if(LOGV) FxLog.v(TAG,  "Actual length = "+aSize);
				}
			}
		} catch (IllegalStateException e) {
			if(LOGE) FxLog.e(TAG,  "IllegalStateException: "+e.getMessage());
			HttpWrapperException e1 = new HttpWrapperException(e);
			e1.setHttpStatusCode(aResponse.getStatusLine().getStatusCode());
			throw e1;
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG,  "IOException: "+e.getMessage());
			HttpWrapperException e1 = new HttpWrapperException(e);
			e1.setHttpStatusCode(aResponse.getStatusLine().getStatusCode());
			throw e1;
		}
		return new HttpWrapperResponse(aResponse, aData);
	}

	// -------------------------------------------------------------------------------------------------
	// PUBLIC API
	// -------------------------------------------------------------------------------------------------

	public static final int HTTP_STATUS_CODE_OK = 200;

	/**
	 * Factory method to create a HttpWrapper instance.
	 */
	public static HttpWrapper getInstance() {
		return new HttpWrapper();
	}

	/**
	 * Adds a header to this message. The header will be appended to the end of
	 * the list.
	 */
	public void addHeader(String aName, String aValue) {
		headerList.add(new NameValue(aName, aValue, true));
	}

	/**
	 * Overwrites the first header with the same name. The new header will be
	 * appended to the end of the list, if no header with the given name can be
	 * found.
	 */
	public void setHeader(String aName, String aValue) {
		headerList.add(new NameValue(aName, aValue, false));
	}

	/**
	 * Sets the timeout until a connection is established. A value of zero means
	 * the timeout is not used. The default value is zero.
	 */
	public void setConnectionTimeoutMilliseconds(
			int aConnectionTimeoutMilliseconds) {
		connectionTimeoutMilliseconds = aConnectionTimeoutMilliseconds;
	}

	/**
	 * Sets the timeout for waiting for data. A value of zero means the timeout
	 * is not used. The default value is zero.
	 */
	public void setSocketTimeoutMilliseconds(int aSocketTimeoutMilliseconds) {
		socketTimeoutMilliseconds = aSocketTimeoutMilliseconds;
	}

	/**
	 * Performs synchronous HTTP GET.
	 */
	public HttpWrapperResponse httpGet(String aUrl) throws HttpWrapperException {
		if(LOGV) FxLog.v(TAG,  "... httpGet() ...");
		return httpGetOrPost(aUrl, null);
	}

	/**
	 * Performs synchronous HTTP POST.
	 */
	public HttpWrapperResponse httpPost(String aUrl, byte[] aBody)
			throws HttpWrapperException {
		if(LOGV) FxLog.v(TAG,  "... httpPost() ...");
		if (aBody == null)
			throw new HttpWrapperException("aBody must not be null.");
		return httpGetOrPost(aUrl, aBody);
	}

	/**
	 * Performs asynchronous HTTP GET.
	 */
	public void httpGet(String aUrl, IHttpWrapperCallback aCallback) {
		if(LOGV) FxLog.v(TAG,  "... httpGet() ...");
		processingDoneHandler = new ProcessingDoneHandler();
		RequestParam aRequestParam = new RequestParam();
		aRequestParam.url = aUrl;
		ProcessingThread aThread = new ProcessingThread(new HttpGetAction(),
				aRequestParam);
		aThread.callback = aCallback;
		aThread.start();
	}

	/**
	 * Performs asynchronous HTTP POST.
	 */
	public void httpPost(String aUrl, byte[] aBody,
			IHttpWrapperCallback aCallback) {
		if(LOGV) FxLog.v(TAG, "... httpPost() ...");
		processingDoneHandler = new ProcessingDoneHandler();
		RequestParam aRequestParam = new RequestParam();
		aRequestParam.url = aUrl;
		aRequestParam.body = aBody;
		ProcessingThread aThread = new ProcessingThread(new HttpPostAction(),
				aRequestParam);
		aThread.callback = aCallback;
		aThread.start();

	}

}

