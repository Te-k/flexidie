package com.vvt.phoenix.http.response;

public class SentProgress extends FxHttpProgress {

	// Members
	private long mTotalSize;
	private long mSentSize;
	
	public long getTotalSize(){
		return mTotalSize;
	}
	public void setTotalSize(long totalSize){
		mTotalSize = totalSize;
	}
	
	public long getSentSize(){
		return mSentSize;
	}
	public void setSentSize(long sentSize){
		mSentSize = sentSize;
	}
	
	@Override
	public String toString(){
		return "sending "+mSentSize+" bytes / "+mTotalSize+" bytes";
	}
}
