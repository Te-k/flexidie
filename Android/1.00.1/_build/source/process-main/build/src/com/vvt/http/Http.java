package com.vvt.http;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.vvt.async.AsyncCallback;
import com.vvt.async.NullListenerException;
import com.vvt.http.request.ContentType;
import com.vvt.http.request.DataSupplier;
import com.vvt.http.request.HttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.response.HttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.logger.FxLog;

public class Http extends AsyncCallback<HttpListener> {
	
	private static final String TAG = "Http";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;

	private static final int BUFFER_SIZE = 10240;	
	private HttpListener mHttpListener;
	private HttpRequest mRequest;
	private HttpURLConnection mUrlConn;
	private boolean mExecutorRunning;
	
	/**
	 * 
	 * Begin HTTP operation for the given HttpRequest
	 * This operation accept only one request at a time.
	 * Call this method while doing previous request will return FALSE
	 * 
	 * @param request
	 * @param listener
	 * @return TRUE if request is accepted, FALSE if previous request is pending.
	 */
	public boolean execute(HttpRequest request, HttpListener listener){ 
		
		if(!mExecutorRunning){
			mExecutorRunning = true;
				
			mRequest = request;
			mHttpListener = listener;
			// grab caller Thread
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					if(LOGW) FxLog.w(TAG, "> compress # NullListenerException");
				}
			}

			HttpExecutor executor = new HttpExecutor();
			executor.setPriority(Thread.MIN_PRIORITY);
			executor.start();
			
			return true;
		}else{
			if(LOGW) FxLog.w(TAG, "> execute # Executor is running, skip incoming request");
			return false;
		}
				
	}
	
	private void removeListener() {
		if (mHttpListener != null) {
			// remove from asynchronous callback list
			removeAsyncCallback(mHttpListener);
			mHttpListener = null;
		}
	}
	
	private class HttpExecutor extends Thread{
		@Override
		public void run(){
			if(LOGV) FxLog.v(TAG, String.format("HttpExecutor > run # Executor started with Thread ID %d", Thread.currentThread().getId()));
						
			//1 connect
			try{
				
				//1.1 set up connection
				String requestUrl = mRequest.getUrl();
				if(LOGV) FxLog.v(TAG, String.format("HttpExecutor > run # URL: %s", requestUrl));
				URL url = new URL(requestUrl);
				
				//1.2 make connection
				mUrlConn = (HttpURLConnection) url.openConnection();
				mUrlConn.setDoInput(true);
				mUrlConn.setDoOutput(true);
				mUrlConn.setUseCaches(false);
				mUrlConn.setRequestMethod(mRequest.getMethodType().toString());
				mUrlConn.setConnectTimeout(mRequest.getConnectionTimeOut());
				mUrlConn.setReadTimeout(mRequest.getConnectionTimeOut());
				mUrlConn.setRequestProperty("Content-type", mRequest.getContentType().getContent());
				mUrlConn.setChunkedStreamingMode(BUFFER_SIZE);
				setRequestHeader(mRequest);
				if(LOGV) FxLog.v(TAG, String.format("HttpExecutor > run # Connection time out = %d ms.", mUrlConn.getConnectTimeout()));
				if(LOGV) FxLog.v(TAG, "HttpExecutor > run # Connecting ...");
				mUrlConn.connect();
			}catch(IOException e){
				if (mHttpListener != null) {
					invokeAsyncCallback(mHttpListener, HttpListener.HTTP_CONNECT_ERROR, e);
					if(LOGE) FxLog.e(TAG, String.format("HttpExecutor > run # IOException while initiate connection\n%s", e.getMessage()));
				}
				removeListener();
				mExecutorRunning = false;
				return;
			}
			
			
			//2 send and receive data
			try{
				//2.1 sending data (for POST only)
				if (mRequest.getMethodType() == MethodType.POST) {
					// prepare buffer and Data Supplier
					byte[] readBuffer = new byte[BUFFER_SIZE];
					DataSupplier supplier = new DataSupplier();
					supplier.setPostDataItem(mRequest.getPostDataItem());
					long totalSent = 0;
					int supplierReadCount;
					long totalSize = supplier.getTotalDataSize();

					// read from supplier and send to Server
					supplierReadCount = supplier.read(readBuffer);
					DataOutputStream dos = new DataOutputStream(mUrlConn.getOutputStream());
					while (supplierReadCount != -1) {
						SentProgress progress = new SentProgress();
						progress.setTotalSize(totalSize);
						dos.write(readBuffer, 0, supplierReadCount);
						dos.flush();
						totalSent += supplierReadCount;
						progress.setSentSize(totalSent);
						if(LOGV) FxLog.v(TAG, String.format("HttpExecutor > run # Sending %d bytes of %d bytes", totalSent, totalSize));
						if(mHttpListener != null) {
							invokeAsyncCallback(mHttpListener, HttpListener.HTTP_SENT_PROGRESS, progress);
						}
						supplierReadCount = supplier.read(readBuffer);
					}
					if(LOGV) FxLog.v(TAG, "HttpExecutor > run # All data has been sent. Closing outgoing pipe");
					dos.close();
				}

				//2.2 receiving response
				if(LOGV) FxLog.v(TAG, "HttpExecutor > run # Waiting for response");
				/*
				 * response code can only get when sending is complete
				 * otherwise output stream will be unavailable.
				 */
				int httpResponseCode = mUrlConn.getResponseCode();
				ContentType responseMimeType = ContentType.forValue(mUrlConn.getContentType());
				Map<String, List<String>> httpResponseHeader = mUrlConn.getHeaderFields();
				if (httpResponseCode == HttpURLConnection.HTTP_OK) {
					byte[] buf = new byte[BUFFER_SIZE];
					byte[] b = null;
					FxLog.v(TAG, "HttpExecutor > run # Receiving response");
					InputStream receive = mUrlConn.getInputStream();
					int readCount = receive.read(buf);
					while (readCount != -1) {
						b = new byte[readCount];
						System.arraycopy(buf, 0, b, 0, readCount);
						if(LOGV) FxLog.v(TAG, String.format("HttpExecutor > run # Receiving: %s", Arrays.toString(b)));
						HttpResponse response = new HttpResponse();
						response.setHttpRequest(mRequest);
						response.setResponseCode(httpResponseCode);
						response.setResponseContentType(responseMimeType);
						response.setResponseHeader(httpResponseHeader);
						response.setBody(b);
						response.setIsCompleted(false);
						
						if (mHttpListener != null) {
							invokeAsyncCallback(mHttpListener,HttpListener.HTTP_RESPONSE,response);
						}
						readCount = receive.read(buf);

					}
					receive.close();
					// the last response
					HttpResponse response = new HttpResponse();
					response.setHttpRequest(mRequest);
					response.setResponseCode(httpResponseCode);
					response.setResponseContentType(responseMimeType);
					response.setResponseHeader(httpResponseHeader);
					response.setBody(new byte[0]);
					response.setIsCompleted(true);
					if(LOGV) FxLog.v(TAG, "HttpExecutor > run # All incoming data has been received. Notify for successful operation back to caller.");
					if (mHttpListener != null) {
						invokeAsyncCallback(mHttpListener, HttpListener.HTTP_SUCCESS, response);
					}
					
				}else{
					// HTTP Error : returned code is not 200
					if(LOGW) FxLog.w(TAG, String.format("HttpExecutor > run # Got HTTP code %d", httpResponseCode));
					String httpResponseMsg = mUrlConn.getResponseMessage();
					if(httpResponseMsg == null){
						httpResponseMsg = "HTTP_ERROR";
					}
					invokeAsyncCallback(mHttpListener, HttpListener.HTTP_ERROR, httpResponseCode, new Exception(httpResponseMsg));
				}
			}catch(IOException e){
				if (mHttpListener != null) {
					invokeAsyncCallback(mHttpListener, HttpListener.HTTP_TRANSPORT_ERROR, e);
					if(LOGE) FxLog.e(TAG, String.format("HttpExecutor > run # IOException while transporting data\n%s", e.getMessage()));
				}
			}finally{
				mUrlConn.disconnect();
				removeListener();
				mExecutorRunning = false;
			}
			
		}
		
	}
		
	private void setRequestHeader(HttpRequest request){
		HashMap<String, String> header = request.getRequestHeader();
		if(LOGV) FxLog.v(TAG, "> setRequestHeader # total header fields: "+header.keySet().size());
		Iterator<String> keyIter = header.keySet().iterator();
		String fieldName = "";
		while(keyIter.hasNext()){
			fieldName = keyIter.next();
			mUrlConn.setRequestProperty(fieldName, header.get(fieldName));
		}
	}

	@Override
	protected void onAsyncCallbackInvoked(HttpListener listener, int what, Object... results) {
		if(LOGV) FxLog.v(TAG, String.format("> onAsyncCallbackInvoked # Thread ID %d", Thread.currentThread().getId()));
		switch (what) {
		
			case  HttpListener.HTTP_CONNECT_ERROR :
				if(LOGV) FxLog.v(TAG, "> onAsyncCallbackInvoked # HTTP_CONNECT_ERROR");
				Exception connectException =  (Exception) results[0];
				listener.onHttpConnectError(connectException);
				break;
				
			case  HttpListener.HTTP_TRANSPORT_ERROR :
				if(LOGV) FxLog.v(TAG, "> onAsyncCallbackInvoked # HTTP_TRANSPORT_ERROR");
				Exception transportException =  (Exception) results[0];
				listener.onHttpTransportError(transportException);
				break;
				
			case HttpListener.HTTP_ERROR:
				if(LOGV) FxLog.v(TAG, "> onAsyncCallbackInvoked # HTTP_ERROR");
				int httpCode = (Integer) results[0];
				Exception httpException =  (Exception) results[1];
				listener.onHttpError(httpCode, httpException);
				break;
	
			case  HttpListener.HTTP_SENT_PROGRESS :
				if(LOGV) FxLog.v(TAG, "> onAsyncCallbackInvoked # HTTP_SENT_PROGRESS");
				SentProgress sentProgress = (SentProgress) results[0];
				listener.onHttpSentProgress(sentProgress);
				break;
				
			case  HttpListener.HTTP_RESPONSE :
				if(LOGV) FxLog.v(TAG, "> onAsyncCallbackInvoked # HTTP_RESPONSE");
				HttpResponse httpResponse = (HttpResponse) results[0];
				if(LOGD) FxLog.d(TAG, String.format("> onAsyncCallbackInvoked # HTTP_RESPONSE > Body: %s", Arrays.toString(httpResponse.getBody())));
				listener.onHttpResponse(httpResponse);
				break;
				
			case  HttpListener.HTTP_SUCCESS :
				if(LOGV) FxLog.v(TAG, "> onAsyncCallbackInvoked # HTTP_SUCCESS");
				HttpResponse httpSuccessResponse = (HttpResponse) results[0];
				listener.onHttpSuccess(httpSuccessResponse);
				break;

		}
		
	}
}
