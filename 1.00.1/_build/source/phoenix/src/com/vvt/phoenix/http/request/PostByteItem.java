package com.vvt.phoenix.http.request;

import com.vvt.phoenix.util.DataBuffer;

/**
 * @author tanakharn
 * @version 1.0
 * @created 07-Jun-2010 6:26:05 PM
 */
public class PostByteItem extends PostItem {
	// Members
	private DataBuffer mBuffer;
	private long mSize;

	@Override
	public PostItemType getDataType() {
		return PostItemType.BYTE_ARRAY;
	}
	
	public void setBytes(byte[] data) {
		mBuffer = new DataBuffer(data);
		mSize = data.length;
	}
	
	/* (non-Javadoc)
	 * @see com.vvt.http.request.PostItem#read(int)
	 * return -1 if reached end of data
	 */
	@Override
	public int read(byte[] buffer) {
		return mBuffer.readBytes(buffer);
	}

	@Override
	public long getTotalSize() {
		return mSize;
	}



	

}