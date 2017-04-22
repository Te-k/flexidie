package com.vvt.http.request;

import java.io.IOException;

public abstract class PostDataItem {
	
	public abstract PostDataItemType getType();
	public abstract int getTotalDataSize();
	public abstract int read(byte[] buffer) throws IOException;
	public abstract void close() throws IOException;

}
