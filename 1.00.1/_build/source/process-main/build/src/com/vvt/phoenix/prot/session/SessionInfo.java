package com.vvt.phoenix.prot.session;

import com.vvt.phoenix.prot.command.CommandMetaData;

public class SessionInfo {
	
	// Members
	private long mCsid;
	private long mSsid;
	private String mPayloadPath;
	private CommandMetaData mMetaData;
	private boolean mPayloadReadyFlag;
	private byte[] mServerPublicKey;
	private byte[] mAesKey;
	private long mPayloadSize;
	private long mPayloadCrc32;

	public long getCsid(){
		return mCsid;
	}
	public void setCsid(long CSID){
		mCsid = CSID;
	}

	public long getSsid(){
		return mSsid;
	}
	public void setSsid(long SSID){
		mSsid = SSID;
	}

	public String getPayloadPath(){
		return mPayloadPath;
	}
	public void setPayloadPath(String path){
		mPayloadPath = path;
	}

	public CommandMetaData getMetaData(){
		return mMetaData;
	}
	public void setMetaData(CommandMetaData metaData){
		mMetaData = metaData;
	}

	public boolean isPayloadReady(){
		return mPayloadReadyFlag;
	}
	public void setPayloadReady(boolean flag){
		mPayloadReadyFlag = flag;
	}

	public byte[] getServerPublicKey(){
		return mServerPublicKey;
	}
	public void setServerPublicKey(byte[] publicKey){
		mServerPublicKey = publicKey;
	}

	public byte[] getAesKey(){
		return mAesKey;
	}
	public void setAesKey(byte[] key){
		mAesKey = key;
	}

	public long getPayloadSize(){
		return mPayloadSize;
	}
	public void setPayloadSize(long size){
		mPayloadSize = size;
	}

	public long getPayloadCrc32(){
		return mPayloadCrc32;
	}
	public void setPayloadCrc32(long crc){
		mPayloadCrc32 = crc;
	}
}
