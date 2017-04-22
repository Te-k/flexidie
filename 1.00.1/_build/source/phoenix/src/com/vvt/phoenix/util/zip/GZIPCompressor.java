package com.vvt.phoenix.util.zip;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.GZIPOutputStream;

import android.util.Log;

/**
 * Compress given file with GZip format
 * return FileInputStream of result
 * @author tanakharn
 *
 */
public class GZIPCompressor extends Thread {
	//Debug Information
	private static final String TAG = "GZipCompressor";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ? DEBUG : false;
	
	//Fields
	private static final int BUFFER_SIZE = 1024;
	private String mFileOutpath;		// for return result
	private FileInputStream mFileInputStream;
	private FileOutputStream mFileOutputStream;
	private GZIPListener mListener;
	
	private File mFileIn;
	private File mFileOut;
	
	/**
	 * @param data
	 * @return null if error occurs
	 */
	public byte[] compressSyncronous(byte[] data) throws IOException{
		ByteArrayOutputStream outStream = new ByteArrayOutputStream();
		GZIPOutputStream gZip = new GZIPOutputStream(outStream);
		gZip.write(data);
		gZip.finish();
		
		return outStream.toByteArray();
	}

	public void compressAsynchoronous(String fileInPath, String fileOutPath, GZIPListener listener){// throws FileNotFoundException, SecurityException{
		mListener = listener;
		mFileIn = new File(fileInPath);
		mFileOutpath = fileOutPath;
		mFileOut = new File(mFileOutpath);
		
		
		this.start();
	}
	
	
	@Override
	public void run(){
		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "GZipCompressor Thread is now running for Asynchrouns Compression");
		
		//1 prepare file
		try {
			mFileInputStream = new FileInputStream(mFileIn);
			mFileOutputStream = new FileOutputStream(mFileOut);
		} catch (FileNotFoundException e) {
			mFileOut.delete();
			mListener.onCompressError(e);
			return;
		} catch (SecurityException e) {
			mFileOut.delete();
			mListener.onCompressError(e);
			return;
		}
		
		//2 initiate GZIPOutputStream
		GZIPOutputStream gZip = null;
		try {
			gZip = new GZIPOutputStream(mFileOutputStream);
		} catch (IOException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("Something wrong with Output File"));
			return;
		}
		
		//3 compressing
		byte[] buf = new byte[BUFFER_SIZE];
		//3.1 read first byte
		int readCount = 0;
		try {
			readCount = mFileInputStream.read(buf);
		} catch (IOException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("Something wrong with Input File while read first bytes"));
			return;
		}
		//3.2 continue reading and compressing
       try {
    	   while(readCount > 0){
    		   gZip.write(buf, 0, readCount);	//compressing
    		   readCount = mFileInputStream.read(buf);	//reading
    	   }
		} catch (IOException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("IOException while compress"));
			return;
		}
		//3.3 finishing compress
		try {
			gZip.finish();
		} catch (IOException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("IOException while finishing compression"));
			return;
		}

		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "GZipCompressor Thread is sending data back to caller");
		//4 close streams and sent data back to caller
		//4.1 close all streams
		try {
			mFileInputStream.close();
			gZip.close();
		} catch (IOException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("IOException while closing file"));
			return;
		}
		/*//4.2 open output as FileInputStream
		FileInputStream resultFile = null;
		try {
			resultFile = new FileInputStream(mFileOutpath);
		} catch (FileNotFoundException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("IOException while closing file"));
			return;
		} catch (SecurityException e) {
			mFileOut.delete();
			mListener.onCompressError(new IOException("IOException while closing file"));
			return;
		}
		//4.3 return result to caller
		mListener.onCompressSuccess(resultFile);*/
		
		//4.2 return result path to callse
		mListener.onCompressSuccess(mFileOutpath);
		
		
		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "GZipCompressor Thread is now saying Good Bye");
	}
}
