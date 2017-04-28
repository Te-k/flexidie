package com.vvt.compression;


public interface GZipCompressListener {

	public void CompressCompleted();

	public void CompressError(String errorMsg);
		
}
