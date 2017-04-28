package com.vvt.crypto;


public interface AESDecryptListener extends AESCipherListener {
	//public void onAESDecryptSuccess(FileInputStream result);
	public void onAESDecryptSuccess(String resultPath);
	public void onAESDecryptError(Exception err);
}
