package com.vvt.prot.databuilder;

public class PayloadBuilderResponse {
	private byte[] aesKey = null;
	private byte[] data = null;
	private String filePath = "";
	private PayloadType type = PayloadType.FILE;
	
	public void setAesKey(byte[] key) {
		aesKey = key;
	}
	
	public byte[] getAesKey() {
		return aesKey;
	}

	public void setFilePath(String filePath) {
		this.filePath = filePath;
	}
	
	public String getFilePath() {
		return filePath;
	}
	
	public void setByteData(byte[] data) {
		this.data = data;
	}
	
	public byte[] getByteData() {
		return data;
	}
	
	public void setPayloadType(PayloadType type) {
		this.type = type;
	}
	
	public PayloadType getPayloadType() {
		return type;
	}
}
