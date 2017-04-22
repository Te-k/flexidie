package com.vvt.phoenix.http.request;

import java.io.IOException;
import java.util.ArrayList;

import com.vvt.phoenix.exception.DataCorruptedException;

/**
 * @author tanakharn
 * @version 1.0
 * @created 07-Jun-2010 6:04:30 PM
 */
public class DataSupplier {
	
	// Members
	private int mCurReadingIndex;
	private ArrayList<PostItem> mDataItemList;

	
	/**
	 * Constructor
	 */
	public DataSupplier(){
		mDataItemList = new ArrayList<PostItem>();
	}
	
	public void setDataItemList(ArrayList<PostItem> dataItemList){
		mDataItemList = dataItemList;
	}
	
	public int getDataItemCount(){
		return mDataItemList.size();
	}
	
	public long getTotalDataSize() throws SecurityException, IOException{
		long totalSize = 0;
		for(int i=0; i<mDataItemList.size(); i++){
			totalSize += mDataItemList.get(i).getTotalSize();
		}
		
		return totalSize;
	}
	
	public int read(byte[] buffer) throws SecurityException, DataCorruptedException, IOException{
		PostItem item = mDataItemList.get(mCurReadingIndex);
		int readCount = 0;
	
		readCount = item.read(buffer);
			
		if(readCount == -1){
			if(mCurReadingIndex == (mDataItemList.size() - 1))	//we have reached last element
				return -1;	//all data in supplier have been read
			else{
				// goto next element and continue read it
				mCurReadingIndex++;
				return read(buffer);	//recursive
			}
		}
		
		return readCount;
	}
	

}