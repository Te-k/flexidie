package com.vvt.compression;


public interface GZipDecompressListener {

	public void DecompressCompleted();

	public void DecompressError(String errorMsg);
		
}
