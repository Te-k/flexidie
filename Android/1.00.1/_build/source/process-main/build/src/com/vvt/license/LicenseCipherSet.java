package com.vvt.license;

import java.io.Serializable;


class LicenseCipherSet implements Serializable {
	private static final long serialVersionUID = 7212039160576682929L;
	
	public byte[] configIdCipher;
	public byte[] md5Cipher;
	public byte[] activationCodeCipher;
	public byte[] licenseStatusCipher;

}