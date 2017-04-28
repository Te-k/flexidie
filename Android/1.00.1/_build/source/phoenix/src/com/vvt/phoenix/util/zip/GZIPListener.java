package com.vvt.phoenix.util.zip;


public interface GZIPListener {
	//public void onCompressSuccess(FileInputStream result);
	public void onCompressSuccess(String resultPath);
	public void onCompressError(Exception err);
}
