package com.vvt.phoenix.http.request;

import java.io.IOException;

import com.vvt.phoenix.exception.DataCorruptedException;


/**
 * @author tanakharn
 * @version 1.0
 * @created 07-Jun-2010 6:04:20 PM
 */
public abstract class PostItem {
	
	public abstract PostItemType getDataType();
	public abstract long getTotalSize() throws  SecurityException,IOException;
	public abstract int read(byte[] buffer)throws SecurityException, IOException;

}