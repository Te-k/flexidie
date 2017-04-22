package com.temp.util.crypto;


public interface AESEncryptListener extends AESCipherListener {

	//public void AESEncryptSuccess();
	//public void onAESEncryptSuccess(FileInputStream result);
	public void onAESEncryptSuccess(String resultPath);
	public void onAESEncryptError(Exception err);
}
