package com.vvt.http.request;

import java.io.IOException;

public abstract class PostItem {
	public abstract byte getDataType();
	public abstract long getTotalSize() throws  SecurityException,IOException;
	public abstract int read(byte[] buffer)throws IllegalArgumentException, SecurityException, IOException;
	
}