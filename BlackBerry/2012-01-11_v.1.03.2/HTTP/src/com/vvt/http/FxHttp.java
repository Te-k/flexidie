package com.vvt.http;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.Hashtable;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import com.vvt.http.exception.FxHttpConnectException;
import com.vvt.http.exception.FxHttpTimedOutException;
import com.vvt.http.request.DataSupplier;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;
import com.vvt.http.resource.HttpTextResource;
import com.vvt.http.response.FxHttpResponse;
import com.vvt.http.response.SentProgress;
import com.vvt.http.selector.FxCheckConnection;
import com.vvt.http.selector.TransportType;
import com.vvt.std.Constant;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public class FxHttp extends Thread implements FxTimerListener {

	private final String TAG = "FxHttp";
//	private static final int BUFFER_SIZE = 1024 * 100; // 100KB
	private static final int BUFFER_SIZE = 10 * 1024; // 10KB // For testing
	private static final int MINUTE = 5;
	private int transType = 0;
	private int timedOut = MINUTE;
	private boolean timerExpired = false;
	private FxHttpRequest mRequest = null;
	private FxHttpListener mListener = null;
	private HttpConnection urlConn = null;
	private FxTimer timer  = new FxTimer(this);;
	private FxHttpResponse response = null;
	private FxCheckConnection checkConnection = new FxCheckConnection();
	private DataSupplier supplier = new DataSupplier();
	private TransportType type = new TransportType();	
	
	public FxHttp() {	
		timer.setIntervalMinute(timedOut);
	}
	
	public void setRequest(FxHttpRequest request){
		mRequest = request;
	}
	
	public FxHttpListener getHttpListener()
	{
		return mListener;
	}
	
	public void setHttpListener(FxHttpListener listener)
	{
		mListener = listener;
	}
	
	public void setTimedOutSecond(int second) {
		this.timedOut = second;	
		timer.setInterval(timedOut);
	}
	
	public void setTimedOutMinute(int minute) {
		this.timedOut = minute;	
		timer.setIntervalMinute(timedOut);
	}
	
	public void run () {	
		try {
			runFxHttp();
		} catch(Exception e) {
			Log.error("FxHttp.run()", e.getMessage(), e);
			if (mListener != null) {
				mListener.onHttpError(e, e.getMessage());
			}
			e.printStackTrace();
		}	
	}
	
	private void setTimerExpired(boolean flag) {
		timerExpired = flag;
	}
	
	private boolean isTimerExpired() {
		return timerExpired;
	}
	
	private void runFxHttp() throws Exception {
		transType = checkConnection.getWorkingTransType(mRequest);
		if (transType != 0) {
			makeConnection(transType);
		} else {
			if (mListener != null) {
				throw new FxHttpConnectException(HttpTextResource.ACCESS_INTERNET_FAILED + Constant.L_SQUARE_BRACKET + checkConnection.getResponseCode() + Constant.R_SQUARE_BRACKET);
			}
		}
	}
	
	private void makeConnection(int transType) throws Exception {
		try {
			timer.start();
			String strTransType = type.getTransType(transType);
			String url = mRequest.getUrl();
			MethodType method = mRequest.getMethod();
			
			supplier.setDataItemList(mRequest.getDataItemList());
			long totalSize = supplier.getTotalDataSize();
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".makeConnection()", "url: " + url + ", strTransType: " + strTransType);
			}
			urlConn = (HttpConnection)Connector.open(url + strTransType, Connector.READ_WRITE, true);
			urlConn.setRequestMethod(method.toString());
			//urlConn.setRequestProperty("Host", url);
			urlConn.setRequestProperty("Content-Type", mRequest.getContentType().toString());
			urlConn.setRequestProperty("Content-length", Long.toString(totalSize));
			setHeader(mRequest.getHeaderType());			
			if (MethodType.GET.equals(method)) {
				doGet();
			}	else if (MethodType.POST.equals(method)) {
				doPost();
			} 
		} finally { 
			if (urlConn != null) {
				urlConn.close();
			}
			timer.stop();
		}
	}
	
	private void doPost() throws Exception {		
//		timer.start();
		OutputStream os = null;
		try {
			os = urlConn.openOutputStream();
			byte[] readBuffer = new byte[BUFFER_SIZE];
			int totalSent = 0;
			int supplierReadCount = 0;
			long totalSize = supplier.getTotalDataSize();
			SentProgress progress = new SentProgress();
			progress.setTotalSize(totalSize);
			while ((supplierReadCount = supplier.read(readBuffer)) != -1) {
				if (!isTimerExpired()) {
					os.write(readBuffer, 0, supplierReadCount);
					totalSent += supplierReadCount;
					progress.setSentSize(totalSent);
					//TODO: Stop timer.
					timer.stop();
					if (mListener != null) {
						mListener.onHttpSentProgress(progress);
					}
					//TODO: Start timer again.
					timer.start();					
				} else {
					Log.error(TAG + ".doPost()", HttpTextResource.TIME_OUT);
					throw new FxHttpTimedOutException(HttpTextResource.TIME_OUT);		
				}
			}
			timer.stop();
			// TODO: Add
//			os.flush();
//			IOUtil.close(os);
//			Log.debug(TAG + ".doPost()", "Before get response");
			getResponse();
		} finally {	
			IOUtil.close(os);
//			Log.debug(TAG + ".doPost()", "finally, os.close()");
		}
	}
	
	private void doGet() throws Exception {
		getResponse();
	}
	
	private void getResponse() throws Exception {
		//TODO: Start Timer
		timer.start();
		// receive response
		InputStream receive = null;
		try {
			response = new FxHttpResponse();
			response.setRequest(mRequest);
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".getResponse()", "Before get response");
			}*/
			int status = urlConn.getResponseCode();
			response.setResponseCode(status);
			if (status == HttpConnection.HTTP_OK) {
				if (urlConn.getType().equalsIgnoreCase(mRequest.getContentType().toString())) {
					receive = urlConn.openInputStream();
					byte[] buf = new byte[BUFFER_SIZE];
					byte[] b = null;
					int readCount = 0;				
					while ((readCount = receive.read(buf)) != -1) {
						if (!isTimerExpired()) {
							b = new byte[readCount];
							System.arraycopy(buf, 0, b, 0, readCount);				
							response.setBody(b);
							response.setIsComplete(false);
							//TODO: Stop timer.
							timer.stop();
							if (mListener != null) {
								mListener.onHttpResponse(response);
							}
							//TODO: Start timer again.
							timer.start();
						} else {
							Log.error(TAG + ".getResponse()", HttpTextResource.TIME_OUT);
							throw new FxHttpTimedOutException(HttpTextResource.TIME_OUT + Constant.L_SQUARE_BRACKET + status + Constant.R_SQUARE_BRACKET);		
						}
					}
					response.setTransType(type.getTransName());
					response.setBody(new byte[0]);
					response.setResponseCode(urlConn.getResponseCode());					
					response.setIsComplete(true);
					if (mListener != null) {
						mListener.onHttpSuccess(response);
					}
				} else {
					Log.error(TAG + ".getResponse()", HttpTextResource.WRONG_MIME_TYPE + urlConn.getType());
					throw new FxHttpConnectException(HttpTextResource.WRONG_MIME_TYPE + Constant.L_SQUARE_BRACKET + urlConn.getType() + Constant.R_SQUARE_BRACKET);
				}
			} else {
				Log.error(TAG + ".getResponse()", HttpTextResource.ACCESS_INTERNET_FAILED + status);
				throw new FxHttpConnectException(HttpTextResource.ACCESS_INTERNET_FAILED + Constant.L_SQUARE_BRACKET + status + Constant.R_SQUARE_BRACKET);
			}
		} finally {
			if (receive != null) {
				receive.close();
			}
//			Log.debug(TAG + ".getResponse()", "finally, receive.close()");
			//TODO: Stop timer.
//			timer.stop();
		}
	}
	
	private void getHeaderFields(HttpConnection urlConn) throws IOException {		
		Hashtable data = new Hashtable();
		int i = 0;
		String key = "";
		String value = "";
		
		for (;;) {
			
			if ((key = urlConn.getHeaderFieldKey(i)) == null) { 
				break;
			}
			value = urlConn.getHeaderField(i);
			data.put(key, value);
			i++;
		}		
	}

	private void setHeader(Hashtable data) throws IOException {		
		Enumeration e = data.keys();
		while (e.hasMoreElements()) {
			String key = (String) e.nextElement();
		    urlConn.setRequestProperty(key,(String) data.get(key));
		}
	}
  
	public void timerExpired(int id) {
		setTimerExpired(true);
	}
}
