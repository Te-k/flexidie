package com.vvt.phoenix.util.crc;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.zip.CRC32;
import java.util.zip.CheckedInputStream;

import android.util.Log;

public class CRC32Checksum extends Thread{
	
	//Debug Information
	private static final String TAG = "CRC32Checksum";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Members
	private static final int BUFFER_SIZE = Customization.BUFFER_SIZE;
	private String mInputFilePath;
	private CRC32Listener mListener;
	private boolean mIsWholeFileMode;
	private int mOffset;
	private int mCount;
	
	public static long calculateSynchronous(byte[] data){
		CRC32 chksum = new CRC32();
		chksum.update(data);
		
		return chksum.getValue();
	}
	
	public void calculateASynchronous(String inputFilePath, CRC32Listener listener){
		mInputFilePath = inputFilePath;
		mListener = listener;
		mIsWholeFileMode = true;
		this.start();
	}
	
	public void calculateASynchronous(String inputFilePath, int offsetStart, int count, CRC32Listener listener){
		mInputFilePath = inputFilePath;
		mOffset = offsetStart;
		mCount = count;
		mListener = listener;
		mIsWholeFileMode = false;
		this.start();
	}
	
	@Override
	public void run(){
		if(mIsWholeFileMode){
			runCalculateWholeFile();
		}else{
			runCalculateOffsetFile();
		}
	}
	
	private void runCalculateWholeFile(){
		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "CRC32Checksum Thread is now running for Whole File Asynchrouns CRC Calculation");
		
		//1 open input file
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(mInputFilePath);
		} catch (FileNotFoundException e) {
			mListener.onCalculateCRC32Error(e);
			return;
		}
		
		//2 preparing
        CheckedInputStream cis = null;
        cis = new CheckedInputStream(fIn, new CRC32());          
        byte[] buf = new byte[BUFFER_SIZE];
        
        //3 read file data to CheckedInputStream
        try {
			while(cis.read(buf) >= 0);
		} catch (IOException e) {
			mListener.onCalculateCRC32Error(e);
			return;
		}
		
		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "CRC32Checksum Thread is sending data back to caller");
           
		//4 get checksum value and send back to caller
		long checksum = cis.getChecksum().getValue();
		mListener.onCalculateCRC32Success(checksum);  
		
		//5 close all streams
		try {
			cis.close();
		} catch (IOException e) {
			if(LOCAL_LOGE){
				Log.e(TAG, e.getMessage());
			}
		}

		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "CRC32Checksum Thread is now saying Good Bye");
	}
	
	private void runCalculateOffsetFile(){
		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "CRC32Checksum Thread is now running for Offset File Asynchrouns CRC Calculation");
		
		//1 validate input file
		File f = new File(mInputFilePath);
		if((mOffset+mCount) > f.length()){
			mListener.onCalculateCRC32Error(new IndexOutOfBoundsException("Offset or length is out of file length"));
			return;
		}
		
		//2 open file and skip to offset
		FileInputStream fIn = null;
		try {
			fIn = new FileInputStream(f);
			fIn.skip(mOffset);
		} catch (IOException e) {
			mListener.onCalculateCRC32Error(e);
			return;
		}
		
		//3 preparing
        CheckedInputStream cis = null;
        cis = new CheckedInputStream(fIn, new CRC32());             
       // byte[] buf = new byte[1];
        int round = (mCount / BUFFER_SIZE);
        int lastBufferSize = (mCount % BUFFER_SIZE);
        //byte[] buffer = new byte[BUFFER_SIZE];
        if(LOCAL_LOGV){Log.v(TAG, "round = "+round+", lastBufferSize = "+lastBufferSize);}
        
        //4 read file data to CheckedInputStream
        try {
        	//cis.skip(mOffset);
        	/*int count = cis.read(buf);
        	while(count < mCount){
        		count += cis.read(buf);
        	}*/
        	for(int i=0; i<round; i++){
        		//cis.read(buffer);
        		cis.skip(BUFFER_SIZE);
        		if(LOCAL_LOGV){Log.v(TAG, "round "+round+1);}
        	}
        	//buffer = new byte[lastBufferSize];
        	//cis.read(buffer);
        	//if(LOCAL_LOGV){Log.v(TAG, new String(buffer).toString());}
        	cis.skip(lastBufferSize);
		} catch (IOException e) {
			mListener.onCalculateCRC32Error(e);
			return;
		}
		
		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "CRC32Checksum Thread is sending data back to caller");
           
		//5 get checksum value and send back to caller
		long checksum = cis.getChecksum().getValue();
		mListener.onCalculateCRC32Success(checksum);  
		
		//6 close all streams
		try {
			cis.close();
		} catch (IOException e) {
			if(LOCAL_LOGE){
				Log.e(TAG, e.getMessage());
			}
		}

		//debug msg
		if(LOCAL_LOGV)Log.v(TAG, "CRC32Checksum Thread is now saying Good Bye");
	}
}
