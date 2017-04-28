package com.vvt.http.request;

import java.io.IOException;
import net.rim.device.api.util.DataBuffer;

public class PostByteItem extends PostItem{

	private DataBuffer mBuffer = null;
	private long mSize = 0;
	
	public void setBytes(byte[] data) {
		mBuffer = new DataBuffer();
		mBuffer.write(data);
		mBuffer.setPosition(0);
		mSize = data.length;
	}
	
	public byte getDataType() {
		return PostItemType.BYTE_ARRAY;
	}

	public long getTotalSize() throws SecurityException, IOException {
		return mSize;
	}

	public int read(byte[] buffer) throws IllegalArgumentException, SecurityException, IOException {
		int len = mBuffer.read(buffer, 0, buffer.length);
		if (len == 0) {
			len = -1;
		}
		return len;
	}
}
