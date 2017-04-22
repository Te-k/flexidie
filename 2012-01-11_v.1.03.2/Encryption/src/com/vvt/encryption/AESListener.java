package com.vvt.encryption;

public interface AESListener {
	void AESEncryptionCompleted(String targetFile);
	void AESEncryptionError(String error);
}
