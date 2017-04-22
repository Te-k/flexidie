package com.vvt.phoenix.prot.databuilder;

import javax.crypto.SecretKey;

/**
 * @author tanakharn
 * @version 1.0
 * @created 16-Aug-2010 10:55:31 AM
 */
public class ProtocolPacketBuilderResponse {

	private byte[] mMetaDataWithHeader;
	private SecretKey mAesKey;
	private int mPayloadType;
	private String mPayloadPath;
	private byte[] mPayloadData;
	private long mPayloadSize;
	private long mPayloadCrc32;
	
	
	public byte[] getMetaDataWithHeader() {
		return mMetaDataWithHeader;
	}
	public void setMetaDataWithHeader(byte[] metaData) {
		mMetaDataWithHeader = metaData;
	}
	
	public String getPayloadPath() {
		return mPayloadPath;
	}
	public void setPayloadPath(String payloadPath) {
		mPayloadPath = payloadPath;
	}
	
	/*public byte[][] getMetaDataWithHeader() {
		return mMetaDataWithHeader;
	}
	public void setMetaDataWithHeader(byte[][] metaDataWithHeader) {
		mMetaDataWithHeader = metaDataWithHeader;
	}*/
	
	public SecretKey getAesKey() {
		return mAesKey;
	}
	public void setAesKey(SecretKey aesKey) {
		mAesKey = aesKey;
	}
	
	public int getPayloadType() {
		return mPayloadType;
	}
	/**
	 * @param payloadType from PayloadType
	 */
	public void setPayloadType(int payloadType) {
		mPayloadType = payloadType;
	}
	
	public byte[] getPayloadData() {
		return mPayloadData;
	}
	public void setPayloadData(byte[] payloadData) {
		mPayloadData = payloadData;
	}
	
	public long getPayloadSize() {
		return mPayloadSize;
	}
	public void setPayloadSize(long payloadSize) {
		mPayloadSize = payloadSize;
	}
	
	public long getPayloadCrc32() {
		return mPayloadCrc32;
	}
	public void setPayloadCrc32(long payloadCrc32) {
		mPayloadCrc32 = payloadCrc32;
	}


}