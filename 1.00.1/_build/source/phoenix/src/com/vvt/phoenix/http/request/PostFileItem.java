package com.vvt.phoenix.http.request;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

/**
 * @author tanakharn
 * @version 1.0
 * @created 07-Jun-2010 6:26:11 PM
 */
public class PostFileItem extends PostItem {

	// Members
	private String mFileAbsolutePath;
	private int mOffset;
	private FileInputStream mFile;
	private boolean mFirstRead;
	private boolean mIsFirstCalculateSize;
	private long mFileSize;

	// Constructor
	public PostFileItem() {
		mFileAbsolutePath = "";
		mFirstRead = true;
		mIsFirstCalculateSize = true;
	}
	
	@Override
	public PostItemType getDataType() {
		return PostItemType.FILE;
	}

	public String getFilePath(){
		return mFileAbsolutePath;
	}
	public void setFilePath(String fileAbsolutePath){
		mFileAbsolutePath = fileAbsolutePath;
		mFirstRead = true;
		mOffset = 0;
		mIsFirstCalculateSize = true;
		mFileSize = 0;
	}

	public int getOffset(){
		return mOffset;
	}
	public void setOffset(int offset){
		mOffset = offset;
	}
	
	@Override
	public int read(byte[] buffer)throws FileNotFoundException, SecurityException, IOException {
		//1 check that this is first read or not
		if(mFirstRead){
			mFile = new FileInputStream(mFileAbsolutePath);
			//TODO this line is key point for Phoenix resume.
			mFile.skip(mOffset);
			mFirstRead = false;
		}
		
		//2 initiate buffer
		int readCount = mFile.read(buffer);
		
		//3 check if reach end of file
		if(readCount == -1) mFile.close();
		
		return readCount;
	
	}

	/* (non-Javadoc)
	 * @see com.vvt.http.request.PostItem#totalSize()
	 * 
	 * return the whole file size, doesn't depend on offset.
	 */
	@Override
	public long getTotalSize() throws FileNotFoundException{
		if(mIsFirstCalculateSize){
			File file = new File(mFileAbsolutePath);
			mFileSize = file.length();
			
			if(mFileSize == 0) throw new FileNotFoundException("Can't calculate size of "+mFileAbsolutePath+" This file does not exist");
			
			mIsFirstCalculateSize = false;
			
			return mFileSize;
		}else{
			return mFileSize;
		}
	}



	

}