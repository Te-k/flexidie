package com.vvt.http.request;

import java.io.ByteArrayInputStream;
import java.io.IOException;

public class PostByteItem extends PostDataItem{
	
	private int mLength;
	private ByteArrayInputStream mStream;
	
	public PostByteItem(byte[] data){
		mLength = data.length;
		mStream = new ByteArrayInputStream(data);
	}

	@Override
	public PostDataItemType getType() {
		return PostDataItemType.BUFFER;
	}

	@Override
	public int getTotalDataSize() {
		return mLength;
	}

	@Override
	public int read(byte[] buffer) throws IOException {
		return mStream.read(buffer);
	}

	@Override
	public void close() throws IOException{
		mStream.close();
	}	

}
