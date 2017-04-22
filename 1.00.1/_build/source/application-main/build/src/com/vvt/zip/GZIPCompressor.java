package com.vvt.zip;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.GZIPOutputStream;

import com.vvt.async.AsyncCallback;
import com.vvt.async.NullListenerException;
import com.vvt.logger.FxLog;

/**
 * Compress given file with GZip format
 * return FileInputStream of result
 * @author tanakharn
 * 
 * 1st Refactoring: December 2011
 * : adjust coding style,
 * 	 improve Threading by using AsyncCallback
 *
 */
public class GZIPCompressor extends AsyncCallback<GZIPListener>{
	//Debug Information
	private static final String TAG = "GZipCompressor";


	//Fields
	private static final int BUFFER_SIZE = 1024;
	private String mInputPaht;
	private String mOutputPath;	
	private GZIPListener mListener;
	private boolean mExecutorRunning;

	/**
	 * Compress byte array using Gzip format.
	 * 
	 * @param data: byte array to compress
	 * @return compressed data
	 * @throws IOException if error 
	 * 
	 */
	public static byte[] compress(byte[] data) throws IOException{
		ByteArrayOutputStream outStream = new ByteArrayOutputStream();
		GZIPOutputStream gZip;
		try {
			gZip = new GZIPOutputStream(outStream);
			gZip.write(data);
			gZip.finish();
			gZip.close();
			//throw new IOException("dummy exception");
			return outStream.toByteArray();
		} catch (IOException e) {
			FxLog.e(TAG, String.format("> compress # IOException while compressing data.\n%s", e.getMessage()));
			FxLog.w(TAG, "> compress # Throwing Exception to caller");
			throw e;
		}

	}

	/**
	 * Compress file from inputPath and store output in outputPath.
	 * This operation accept only one request at a time.
	 * Call this method while doing previous request will return FALSE
	 * 
	 * @param inputPath
	 * @param outputPath
	 * @param listener NULL is allow
	 * @return TRUE if request is accepted, FALSE if previous request is pending.
	 */
	public boolean compress(String inputPath, String outputPath, GZIPListener listener){

		// start GZIPExcutor
		if(!mExecutorRunning){
			mExecutorRunning = true;
						
			mInputPaht = inputPath;
			mOutputPath = outputPath;
			mListener = listener;
			
			// grab caller Thread
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					FxLog.w(TAG, "> compress # NullListenerException");
				}
			}
			
			
			GZIPExecutor executor = new GZIPExecutor();
			executor.setPriority(Thread.MIN_PRIORITY);
			executor.start();
			
			return true;
		}else{
			FxLog.w(TAG, "> compress # Executor is running, skip incoming request");
			return false;
		}
		
	}
	
	private class GZIPExecutor extends Thread{


		@Override
		public void run(){
			FxLog.v(TAG, String.format("GZIPExecutor > run # Executor started with Thread ID %d", Thread.currentThread().getId()));
			
			File fIn = new File(mInputPaht);
			FileInputStream fInStream;
			File fOut = new File(mOutputPath);
			FileOutputStream fOutStream;
			
			try {
				fInStream = new FileInputStream(fIn);
				fOutStream = new FileOutputStream(fOut);
				
				GZIPOutputStream gZip = new GZIPOutputStream(fOutStream);
				byte[] buf = new byte[BUFFER_SIZE];
				int readCount = fInStream.read(buf);
				while(readCount > 0){
	    		   gZip.write(buf, 0, readCount);	//compressing
	    		   readCount = fInStream.read(buf);	//reading
		    	}
				gZip.finish();
		    	gZip.close();
		    	fOutStream.close();
		    	fInStream.close();
			}catch(Exception e){
				FxLog.e(TAG, String.format("GZIPExecutor > run # Got Exception while compressing\n%s", e.getMessage()));
				fOut.delete();
				mExecutorRunning = false;	
				if(mListener != null){
					invokeAsyncCallback(mListener, GZIPListener.CALL_BACK_COMPRESS_ERROR, e);
					removeAsyncCallback(mListener);
					mListener = null;
				}else{
					FxLog.w(TAG, "GZIPExecutor > run # Listener is NULL, skip notify");
				}
				return;
			}
				
			// return result
		    FxLog.v(TAG, "GZIPExecutor > run # Return result back to caller");
		    if(mListener != null){
		    	invokeAsyncCallback(mListener, GZIPListener.CALL_BACK_COMPRESS_SUCCESS, mOutputPath);
		    	removeAsyncCallback(mListener);
		    	mListener = null;
		    }else{
		    	FxLog.w(TAG, "GZIPExecutor > run # Listener is NULL, skip notify");
		    }
		    mExecutorRunning = false;	
				
		}
	}

	@Override
	protected void onAsyncCallbackInvoked(GZIPListener listener, int what, Object... results) {
		FxLog.d(TAG, String.format("> onAsyncCallbackInvoked # Invoke callback on Thread ID %d", Thread.currentThread().getId()));
		switch(what){
			case GZIPListener.CALL_BACK_COMPRESS_SUCCESS :
				listener.onCompressSuccess((String) results[0]);
				break;
			case GZIPListener.CALL_BACK_COMPRESS_ERROR :
				listener.onCompressError((Exception) results[0]);
				break;
		}
		
	}

	

}
