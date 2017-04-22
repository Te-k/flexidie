package com.vvt.phoenix.http;

import java.io.DataOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.http.client.HttpClient;

import android.os.AsyncTask;
import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.http.request.DataSupplier;
import com.vvt.phoenix.http.request.FxHttpRequest;
import com.vvt.phoenix.http.request.MethodType;
import com.vvt.phoenix.http.response.FxHttpProgress;
import com.vvt.phoenix.http.response.FxHttpResponse;
import com.vvt.phoenix.http.response.SentProgress;

/**
 * @author tanakharn
 *	support only POST, GET not PUT
 */
public class FxHttp extends AsyncTask<FxHttpRequest, FxHttpProgress, FxHttpResponse> {		//parameter -> Params, Progress, Result

	// Debugging
	private static final String TAG = "FxHttp";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Constants
	//private static final int BUFFER_SIZE = 1024;
	//private static final int BUFFER_SIZE = 5120;
	private static final boolean mTestResume = false;
	private static final long mResumeInteruptInteval = 5000;
	//TODO change buffer size to 10KB after test reusume success
	private static final int BUFFER_SIZE = 10240;//10;	//10KB //set to 10 for test resume only
	//private static final int BUFFER_SIZE = 50;
	
	// Members
	private FxHttpListener mListener;
	private HttpURLConnection mUrlConn;
	private HttpClient mHttp;
	//private boolean mIsForceStop;
	
	public FxHttpListener getHttpListener(){
		return mListener;
	}
	public void setHttpListener(FxHttpListener listener){
		mListener = listener;
	}
	
	/* (non-Javadoc)
	 * @see android.os.AsyncTask#onPreExecute()
	 * invoke on UI Thread
	 */
	@Override
	protected void onPreExecute(){
		if(LOCAL_LOGV)Log.v(TAG, "+++ onPreExecute()+++");
	}
		

	@Override
	protected FxHttpResponse doInBackground(FxHttpRequest... params) {
		if(LOCAL_LOGV)Log.v(TAG, "+++ doInBackground() +++");
		//throw new RuntimeException();

		FxHttpRequest request = params[0];
		FxHttpResponse response = null;
		try{
			response = doOperation(request);
		}catch(Exception e){
			if(mListener != null){
				mListener.onHttpError(e, e.getMessage());
				if(LOCAL_LOGE){
					Log.e(TAG, "Exception type: "+e.getClass()+" in doOperation(), "+e.getMessage());
				}
			}
			cancel(true);	//stop task
		}
		
		return response;
	}
		
	private FxHttpResponse doOperation(FxHttpRequest request) throws Exception{
		if(LOCAL_LOGV)Log.v(TAG, "+++ doOperation() +++");
		

		//1 get url
		String givenUrl = request.getUrl();
		if(LOCAL_LOGV)Log.i(TAG, "URL: "+givenUrl);
		URL url = new URL(givenUrl);

		//2 setup connection		
        mUrlConn = (HttpURLConnection) url.openConnection();
        mUrlConn.setDoInput(true);
        mUrlConn.setDoOutput(true);
        mUrlConn.setUseCaches(false);
        mUrlConn.setRequestMethod(request.getMethod());
        mUrlConn.setConnectTimeout(request.getConnectTimeOut());
        mUrlConn.setReadTimeout(request.getReadTimeOut());
        mUrlConn.setRequestProperty("Content-type", request.getContentType());
        
        //TODO, we're in debug war
        /*int totalSize = 0;
        ArrayList<PostItem> itemList = request.getDataItemList();
        for(int i=0; i<itemList.size(); i++){
        	totalSize += itemList.get(i).getTotalSize();
        }
       mUrlConn.setFixedLengthStreamingMode(totalSize);*/	//not work
        mUrlConn.setChunkedStreamingMode(BUFFER_SIZE);
        
        setRequestHeader(request);   
        if(LOCAL_LOGV){
        	Log.v(TAG, "Connect Time Out Period: "+mUrlConn.getConnectTimeout());
        	Log.v(TAG, "Read Time Out Period: "+mUrlConn.getReadTimeout());
        }
	    mUrlConn.connect();     
	    
		//3 get connection pipe
		DataOutputStream dos = new DataOutputStream(mUrlConn.getOutputStream());
		
		//4 Communicating with Server
		//4.1 send (for POST only)
		if(request.getMethod().equals(MethodType.POST)){
			//4.1.1 prepare buffer and Data Supplier
			byte[] readBuffer = new byte[BUFFER_SIZE];
			DataSupplier supplier = new DataSupplier();
			supplier.setDataItemList(request.getDataItemList());
			long totalSent = 0;
			int supplierReadCount;
			SentProgress progress = new SentProgress();
			progress.setTotalSize(supplier.getTotalDataSize());
			
			//4.1.2 read from supplier and send to Server
			supplierReadCount = supplier.read(readBuffer);
			while(supplierReadCount != -1){
				dos.write(readBuffer, 0, supplierReadCount);
				totalSent += supplierReadCount;
				progress.setSentSize(totalSent);
				publishProgress(progress);
				supplierReadCount = supplier.read(readBuffer);
				if(LOCAL_LOGV){
					Log.v(TAG, "Flushing");
				}
				dos.flush();
				
				//TODO this code is use for generate cause for resume request only
				//for test resume only data sent between 175 to 200 is in payload
				if(mTestResume && ((totalSent > 175) && (totalSent < 200))){
					Log.e(TAG, "Sleeping for "+mResumeInteruptInteval+" seconds.");
					Thread.sleep(mResumeInteruptInteval);
				}
				
			}
			dos.close();
		}
		
		//4.2 receive response
		FxHttpResponse response = new FxHttpResponse();
		response.setRequest(request);
		response.setResponseCode(mUrlConn.getResponseCode());
		response.setResponseHeader(mUrlConn.getHeaderFields());
		InputStream receive = mUrlConn.getInputStream();
		
		//4.3 send data back to caller
		/*int contentLen = mUrlConn.getContentLength();		// return -1 if Server doesn't set this field
		if(LOCAL_LOGV)Log.v(TAG, "Content Length: "+contentLen);*/
		if(response.getResponseCode() == HttpURLConnection.HTTP_OK){
			String requestContentType = request.getContentType();
			if(requestContentType != null){
				if(LOCAL_LOGV){Log.v(TAG, "Request Content Type: "+requestContentType);}
				if(LOCAL_LOGV){Log.v(TAG, "Response Content Type: "+mUrlConn.getContentType());}
				if(!request.getContentType().equalsIgnoreCase(mUrlConn.getContentType())){
					if(LOCAL_LOGV){Log.w(TAG, "Content type doesn't match!");}
					throw new Exception("Content type doesn't match!");
				}
			}else{
				if(LOCAL_LOGV){Log.w(TAG, "No content type in request object.");}
			}
			byte[] buf = new byte[BUFFER_SIZE];
			byte[] b = null;
			int readCount = receive.read(buf);
			/*if(DEBUG){
				Log.v(TAG, "readCount: "+readCount);
			}
			printBuffer(buf);*/
			while(readCount != -1){
				b = new byte[readCount];
				System.arraycopy(buf, 0, b, 0, readCount);
				response.setBody(b);
				response.setIsComplete(false);
				//TODO please check, this response object may not Thread safe; 
				//caller thread may read its body while FxHttp thread assign new body !
				publishProgress(response);			
				readCount = receive.read(buf);
				/*if(DEBUG){
					Log.v(TAG, "readCount: "+readCount);
				}
				printBuffer(buf);*/
			}
			receive.close();
			mUrlConn.disconnect();
			// the last response
			response.setBody(new byte[0]);
			response.setIsComplete(true);
			
		}else{
			//set response with no body (http status code != 200)
			/*byte[] b = new byte[0];
			response.setBody(b);
			response.setIsComplete(false);*/
			if(LOCAL_LOGV){Log.w(TAG, "HTTP code isn't 200.");}
			//throw new Exception("HTTP code isn't 200.");
			throw new Exception("HTTP Response Code: "+response.getResponseCode());
		}
		return response;	// this line will always return response with body length = 0 for success response or unsuccess response
	}
	
	//be careful this method consume CPU and memory !
	/*private void printBuffer(byte[] b){
		if(DEBUG){
			String res = "";
			for(int i=0; i<b.length; i++){
				res += b[i];
			}
			Log.v(TAG, "Data in buf: "+res);
		}
	}*/
	
	private void setRequestHeader(FxHttpRequest request){
		if(LOCAL_LOGV)Log.v(TAG, "+++ setRequestHeader() +++");

		HashMap<String, String> header = request.getRequestHeader();
		if(LOCAL_LOGV)Log.v(TAG, "header field amount: "+header.keySet().size());
		Iterator<String> keyIter = header.keySet().iterator();
		String fieldName = "";
		while(keyIter.hasNext()){
			fieldName = keyIter.next();
			mUrlConn.setRequestProperty(fieldName, header.get(fieldName));
			//Log.v(TAG, "Key: "+key+", Value: "+header.get(key));
		}
	}
	
	
	/* (non-Javadoc)
	 * @see android.os.AsyncTask#onProgressUpdate(Progress[])
	 * invoke on UI Thread
	 */
	@Override
	protected void onProgressUpdate(FxHttpProgress... progress){
		if(LOCAL_LOGV)Log.v(TAG, "++ onProgressUpdate() +++");
		
		if(mListener != null){
			if(progress[0] instanceof SentProgress){
				SentProgress sentProgress = (SentProgress) progress[0];
				mListener.onHttpSentProgress(sentProgress);
			}else{
				if(progress[0] instanceof FxHttpResponse){
					FxHttpResponse httpResponse = (FxHttpResponse) progress[0];
					mListener.onHttpResponse(httpResponse);
				}
			}
		}else{
			if(LOCAL_LOGV)Log.v(TAG, "Listener = null, skip report");
		}
	}
	
	/* (non-Javadoc)
	 * @see android.os.AsyncTask#onPostExecute(java.lang.Object)
	 * invoke on UI thread
	 */
	@Override
	protected void onPostExecute(FxHttpResponse result){
		if(LOCAL_LOGV)Log.v(TAG, "+++ onPostExecute() +++");
		
		if(isCancelled()){
			if(LOCAL_LOGE)Log.e(TAG, "onPostExecute(): got cancelling signal !");
		}else{
			if(mListener != null){
				mListener.onHttpSuccess(result);
			}
		}
	}
	
	/* (non-Javadoc)
	 * @see android.os.AsyncTask#onCancelled()
	 * invoke on UI thread
	 */
	@Override
	protected void onCancelled(){
		if(LOCAL_LOGE)Log.e(TAG, "+++ onCancelled() +++");
		
		if(mListener != null){
			mListener.onHttpError(new DataCorruptedException(""), "Http cancelled");
		}
	}
	
	public void forceStop(){
		if(LOCAL_LOGE)Log.e(TAG, "+++ Force Stop Http Operation +++");
		//mIsForceStop = true;
		cancel(true);
	}

}
