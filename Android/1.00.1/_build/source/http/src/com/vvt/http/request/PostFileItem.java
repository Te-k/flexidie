package com.vvt.http.request;

import java.io.FileInputStream;
import java.io.IOException;

import com.vvt.http.Customization;
import com.vvt.logger.FxLog;

public class PostFileItem extends PostDataItem{
	
	/*
	 * Debugging
	 */
	private static final String TAG = "PostFileItem";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGW = Customization.WARNING;
		
	private String mFileAbsolutePath;
	private FileInputStream mFileStream;
	private int mOffset;
	private int mLength;
	private int mTotalReadCount;
	
	/*
	 * Constructor
	 */
	public PostFileItem(String fileAbsolutePath){
		mFileAbsolutePath = fileAbsolutePath;
		mOffset = 0;
		mLength = 0;
		mTotalReadCount = 0;
	}
	
	public void setOffset(int offset){
		mOffset = offset;
	}
	public int getOffset(){
		return mOffset;
	}
	
	public void setLength(int length){
		mLength = length;
	}
	public int getLength(){
		return mLength;
	}

	@Override
	public PostDataItemType getType() {
		return PostDataItemType.FILE;
	}

	@Override
	public int getTotalDataSize() {
		return mLength;
	}

	@Override
	public int read(byte[] buffer) throws IOException {
		int currentReadCount = 0;
		//first call
		if(mFileStream == null){
			//initiate input stream and skip for offset
			if(LOGV) FxLog.v(TAG, "> read # Initiate FileInputStream");
			mFileStream = new FileInputStream(mFileAbsolutePath);
			mFileStream.skip(mOffset);
		}
		
		//if buffer size if greater than the area to read then specify read count
		if(mTotalReadCount == mLength){
			if(LOGW) FxLog.w(TAG, String.format("> read # We have done reading, return -1"));
			currentReadCount = -1;
		}else if((mTotalReadCount + buffer.length) > mLength){
			int byteToRead = mLength - mTotalReadCount;
			if(LOGW) FxLog.w(TAG, String.format("> read # This is last chunk to read, byte to read = %d", byteToRead));
			currentReadCount = mFileStream.read(buffer, 0, byteToRead);
			mTotalReadCount += currentReadCount;
		}else{
			currentReadCount = mFileStream.read(buffer);
			mTotalReadCount += currentReadCount;
		}
		
		if(LOGV) FxLog.v(TAG, String.format("> read # In this round, current read count = %d, total read count = %d", currentReadCount, mTotalReadCount));
		
		return currentReadCount;
	}
	
	@Override
	public void close() throws IOException{
		mFileStream.close();
	}	
}
