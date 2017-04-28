package com.vvt.phoenix.prot.databuilder;

import javax.crypto.SecretKey;

/**
 * @author tanakharn
 * @version 1.0
 * @created 16-Aug-2010 11:33:20 AM
 */
public class PayloadBuilderResponse {

	private SecretKey mAesKey;
	private String mPayloadPath;
	private byte[] mData;
	private int mPayloadType;
	
	public SecretKey getAesKey(){
		return mAesKey;
	}
	public void setAesKey(SecretKey key){
		mAesKey = key;
	}
	
	public String getPayloadPath(){
		return mPayloadPath;
	}
	public void setPayloadPath(String path){
		mPayloadPath = path;
	}
	
	public byte[] getData(){
		return mData;
	}
	public void setData(byte[] data){
		mData = data;
	}
	
	public int getPayloadType(){
		return mPayloadType;
	}
	/**
	 * @param type from PayloadType
	 */
	public void setPayloadType(int type){
		mPayloadType = type;
	}
}