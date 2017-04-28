package com.vvt.crc;

import java.io.File;
import java.io.FileInputStream;
import java.util.zip.CRC32;
import java.util.zip.CheckedInputStream;

import com.vvt.async.AsyncCallback;
import com.vvt.async.NullListenerException;
import com.vvt.logger.FxLog;

/**
 * @author tanakharn
 *
 * 1st Refactoring: December 2011
 * : adjust coding style,
 * 	 improve Threading by using AsyncCallback
 * 
 */
public class CRC32Checksum extends AsyncCallback<CRC32Listener>{
	
	//Debug Information
	private static final String TAG = "CRC32Checksum";
	
	/*
	 * constant
	 */
	private static final int BUFFER_SIZE = 1024;
	
	/*
	 * members
	 */
	private String mInputFilePath;
	private CRC32Listener mListener;
	private boolean mWholeFileMode;
	private File mFileIn;
	private boolean mExecutorRunning;
	private int mOffset;
	private int mCount;
	
	public static long calculate(byte[] data){
		CRC32 chksum = new CRC32();
		chksum.update(data);
		
		return chksum.getValue();
	}
	
	/**
	 * Calculate CRC32 value of the given input file.
	 * Result will be notified via the given listener object.
	 * This operation accept only one request at a time.
	 * Call this method while doing previous request will return FALSE
	 * 
	 * @param inputFilePath
	 * @param listener
	 * @return TRUE if request is accepted, FALSE if previous request is pending.
	 */
	public synchronized boolean calculate(String inputFilePath, CRC32Listener listener){

		if(!mExecutorRunning){
			FxLog.d(TAG, "> calculate # Calculate whole file");
			mExecutorRunning = true;
			mInputFilePath = inputFilePath;
			mFileIn = null;
			mListener = listener;
			mOffset = 0;
			mCount = 0;
			mWholeFileMode = true;
			
			//grab caller thread
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					FxLog.w(TAG, "> calculate # NullListenerException");
				}
			}
			
			//start executor
			CrcExecutor executor = new CrcExecutor();
			executor.setPriority(Thread.MIN_PRIORITY);
			executor.start();
			
			return true;
		}else{
			FxLog.w(TAG, "> calculate # Executor is running, skip incoming request");
			return false;
		}
		
	}
	

	/**
	 * Calculate CRC32 value at the specific part of the given input file.
	 * Result will be notified via the given listener object.
	 * This operation accept only one request at a time.
	 * Call this method while doing previous request will return FALSE
	 * 
	 * @param inputFilePath
	 * @param offsetStart	offset from the beginning of the file. offset value must not less than zero or greater than file length.
	 * @param count	number of byte to calculate CRC value. count cannot be zero or negative number.
	 * @param listener
	 * @return TRUE if request is accepted, FALSE if previous request is pending.
	 */
	public boolean calculate(String inputFilePath, int offsetStart, int count, CRC32Listener listener){

		if(!mExecutorRunning){
			FxLog.d(TAG, "> calculate # Calculate file part");
			mExecutorRunning = true;
			mInputFilePath = inputFilePath;
			mFileIn = new File(inputFilePath);
			
			//validate argument
			long fileLen = mFileIn.length();
			if(count <= 0){
				throw new IllegalArgumentException("count cannot be zero or negative");
			}
			if( (offsetStart < 0) || (offsetStart > fileLen)){
				throw new IllegalArgumentException("offset is out of file length");
			}
			if((offsetStart + count) > fileLen){
				throw new IllegalArgumentException("request is out of file length");
			}
			
			
			mOffset = offsetStart;
			mCount = count;
			mListener = listener;
			mWholeFileMode = false;
			
			//grab caller thread
			if(listener != null){
				try {
					addAsyncCallback(listener);
				} catch (NullListenerException e) {
					// unchecked
					FxLog.w(TAG, "> calculate # NullListenerException");
				}
			}
		
			//start executor
			CrcExecutor executor = new CrcExecutor();
			executor.setPriority(Thread.MIN_PRIORITY);
			executor.start();
			
			return true;
		}else{
			FxLog.w(TAG, "> calculate # Executor is running, skip incoming request");
			return false;
		}
	}
	
	private class CrcExecutor extends Thread{
		
		@Override
		public void run(){
			FxLog.v(TAG, String.format("CrcExecutor > run # Executor started with Thread ID %d", Thread.currentThread().getId()));

			if(mFileIn == null){
				mFileIn = new File(mInputFilePath);
			}
			CheckedInputStream cis = null;
			try {
				FileInputStream fInStream = new FileInputStream(mFileIn);
				fInStream.skip(mOffset);
				cis = new CheckedInputStream(fInStream, new CRC32());     
				if(mWholeFileMode){
					FxLog.v(TAG, "CrcExecutor > run # calculate whole file");
					byte[] buf = new byte[BUFFER_SIZE];
					while(cis.read(buf) >= 0);
				}else{
					int round = (mCount / BUFFER_SIZE);
			        int lastBufferSize = (mCount % BUFFER_SIZE);
			        FxLog.v(TAG, String.format("CrcExecutor > run # Round = %d, last buffer size = %d", round, lastBufferSize));
			        for(int i=0; i<round; i++){
		        		cis.skip(BUFFER_SIZE);
		        	}
		        	cis.skip(lastBufferSize);
				}
		        cis.close();
		        fInStream.close();   
		        //throw new Exception("Dummy");
			}catch(Exception e){
				FxLog.e(TAG, String.format("CrcExecutor > run # Exception while calculating file %s\n%s", mInputFilePath, e.getMessage()));
				if(mListener != null){
					invokeAsyncCallback(mListener, CRC32Listener.CALL_BACK_CALCULATE_CRC_ERROR, e);
					removeAsyncCallback(mListener);
					mListener = null;
				}else{
					FxLog.w(TAG, "CrcExecutor > run # Listener is NULL, skip notify");
				}
				mExecutorRunning = false;	
				return;
			}
			
			FxLog.v(TAG, "CrcExecutor > run # Return result back to caller");
			long checksum = cis.getChecksum().getValue();
			if(mListener != null){
				invokeAsyncCallback(mListener, CRC32Listener.CALL_BACK_CALCULATE_CRC_SUCCESS, checksum);
				removeAsyncCallback(mListener);
				mListener = null;
			}else{
				FxLog.w(TAG, "CrcExecutor > run # Listener is NULL, skip notify");
			}

			mExecutorRunning = false;	
		}		
	}

	@Override
	protected void onAsyncCallbackInvoked(CRC32Listener listener, int what, Object... results) {
		FxLog.v(TAG, String.format("> onAsyncCallbackInvoked # Thread ID %d", Thread.currentThread().getId()));
		switch(what){
			case CRC32Listener.CALL_BACK_CALCULATE_CRC_SUCCESS :
				listener.onCalculateCRC32Success((Long) results[0]);
				break;
				
			case CRC32Listener.CALL_BACK_CALCULATE_CRC_ERROR :
				listener.onCalculateCRC32Error((Exception) results[0]);
				break;
		}
		
	}
	
}
