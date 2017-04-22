package com.vvt.prot.databuilder;

public class ProtocolPacketBuilderResponse {
	private byte[] metaData = null;
	private byte[] aesKey = null;
	private byte[] payloadData = null;
	private String payloadPath = "";
	
	private long	payloadSize		= 0L;
	private long	payloadCrc32	= 0L;
	
	
	private PayloadType type = PayloadType.FILE;
	
	public void setMetaData(byte[] metaData) {
		this.metaData = metaData;
	}
	
	public byte[] getMetaData() {
		return metaData;
	}
	
	public void setAesKey(byte[] key) {
		aesKey = key;
	}
	
	public byte[] getAesKey() {
		return aesKey;
	}
	
	public void setPayloadData(byte[] data) {
		payloadData = data;
	}
	
	public byte[] getPayloadData() {
		return payloadData;
	}
	
	public void setPayloadPath(String path) {
		payloadPath = path;
	}
	
	public String getpayloadPath() {
		return payloadPath;
	}
	
	public void setPayloadType(PayloadType type) {
		this.type = type;
	}
	
	public PayloadType getPayloadType() {
		return type;
	}	
	
	public void setPayloadSize(long size)	{
		payloadSize = size;
	}
	
	public long getPayloadSize()	{
		return payloadSize;
	}
	
	public void setPayloadCRC32(long checksum)	{
		payloadCrc32 = checksum;
	}
	public long getPayloadCRC32()	{
		return payloadCrc32;
	}
}
