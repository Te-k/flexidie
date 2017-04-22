package com.vvt.http.request;

import java.io.IOException;
import java.util.ArrayList;

import com.vvt.http.Customization;
import com.vvt.logger.FxLog;


public class DataSupplier {
	
	/*
	 * Debugging
	 */
	private static final String TAG = "DataSupplier";
	private static final boolean LOGI = Customization.INFO;
	private static final boolean LOGW = Customization.WARNING;
	
	/*
	 * Members
	 */
	private ArrayList<PostDataItem> mPostDataItemList;
	private int mCurrentItemIndex;
	
	/*
	 * Constructor
	 */
	public DataSupplier(){
		mCurrentItemIndex = 0;
	}
	
	public void setPostDataItem(ArrayList<PostDataItem> dataItems){
		mPostDataItemList = dataItems;
	}
	
	public long getTotalDataSize(){
		long totalSize = 0;
		for(int i=0; i<mPostDataItemList.size(); i++){
			totalSize += mPostDataItemList.get(i).getTotalDataSize();
		}
		
		return totalSize;
	}
	
	public int read(byte[] buffer) throws IOException{
		
		int readCount = 0;
		
		if(mCurrentItemIndex < mPostDataItemList.size()){
			FxLog.v(TAG, String.format("> read # Reading data item at index %d", mCurrentItemIndex));
			// get current data item
			PostDataItem item = mPostDataItemList.get(mCurrentItemIndex);
			readCount = item.read(buffer);
			//if no data left in this item
			if(readCount == -1){
				if(LOGW) FxLog.w(TAG, "> read # Read count = -1, move to next data item using recursion function");
				//close current item
				item.close();
				//move to next item
				mCurrentItemIndex++;
				//recursive
				readCount = read(buffer);
				if(LOGW) FxLog.w(TAG, String.format("> read # We've backtracked from recursion, got read count = %d", readCount));
			}		
		}else{
			if(LOGW) FxLog.w(TAG, "> read # No more data item left");
			// no more data item
			readCount = -1;
		}
		
		if(LOGI) FxLog.i(TAG, String.format("> read # Return read count = %d", readCount));
		return readCount;
	}

}
