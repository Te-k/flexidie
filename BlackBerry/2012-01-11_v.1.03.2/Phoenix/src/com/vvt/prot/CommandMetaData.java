package com.vvt.prot;

import com.vvt.prot.command.Languages;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;

public class CommandMetaData extends MetaDataWrapper {
	private String mActivationCode;
	private int mCompressionCode;
	private int mConfId;
	private String mDeviceId;
	private int mEncryptionCode;
	private String mImsi;
	private Languages mLanguage;
	private String mMCC;
	private String mMNC;
	private String mPhoneNumber;
	private int mProductId;
	private String mProductVersion;
	private int mProtocolVersion;
	private KeyExchangeCmdResponse keyExcResponse;
	private String baseServerUrl;
	
	public CommandMetaData() {
		mLanguage = Languages.UNKNOWN;
	}
	
	public String getActivationCode() {
		return mActivationCode;
	}

	public void setKeyExchangeResponse(KeyExchangeCmdResponse keyExcResponse) {
		this.keyExcResponse = keyExcResponse;
	}
	
	public KeyExchangeCmdResponse getKeyExchangeResponse() {
		return keyExcResponse;
	}
	
	public int getCompressionCode() {
		return mCompressionCode;
	}

	public int getConfId() {
		return mConfId;
	}

	public String getDeviceId() {
		return mDeviceId;
	}

	public int getEncryptionCode() {
		return mEncryptionCode;
	}
	
	public String getImsi() {
		return mImsi;
	}

	public Languages getLanguage() {
		return mLanguage;
	}

	public String getMcc() {
		return mMCC;
	}

	public String getMnc() {
		return mMNC;
	}	

	public String getPhoneNumber() {
		return mPhoneNumber;
	}

	public int getProductId() {
		return mProductId;
	}

	public String getProductVersion() {
		return mProductVersion;
	}

	public int getProtocolVersion() {
		return mProtocolVersion;
	}
	
	public String getBaseServerUrl() {
		return baseServerUrl;
	}
	
	public void setActivationCode(String code) {
		mActivationCode = code;
	}

	public void setCompressionCode(int code) {
		mCompressionCode = code;
	}

	public void setConfId(int confId) {
		mConfId = confId;
	}

	public void setDeviceId(String deviceId) {
		mDeviceId = deviceId;
	}

	public void setEncryptionCode(int code) {
		mEncryptionCode = code;
	}
	
	public void setImsi(String imsi) {
		mImsi = imsi;
	}

	public void setLanguage(Languages langId) {
		mLanguage = langId;
	}

	public void setMcc(String mcc) {
		mMCC = mcc;
	}

	public void setMnc(String mnc) {
		mMNC = mnc;
	}

	public void setPhoneNumber(String number) {
		mPhoneNumber = number;
	}

	public void setProductId(int productId) {
		mProductId = productId;
	}

	public void setProductVersion(String version) {
		mProductVersion = version;
	}

	public void setProtocolVersion(int version) {
		mProtocolVersion = version;
	}	
	
	public void setBaseServerUrl(String baseServerUrl) {
		this.baseServerUrl =  baseServerUrl;
	}
}
