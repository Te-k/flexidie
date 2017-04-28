package com.vvt.http.response;

public class SentProgress {

	//Fields
	private long mTotalSize;
	private long mSentSize;
	
	//Constructor
	public SentProgress() {
		mTotalSize = 0;
		mSentSize = 0;
	}
	
	public long getTotalSize() {
		return mTotalSize;
	}
	
	public void setTotalSize(long totalSize) {
		mTotalSize = totalSize;
	}
	
	public long getSentSize() {
		return mSentSize;
	}
	
	public void setSentSize(long sentSize) {
		mSentSize = sentSize;
	}
	
	public String toString() {
		return "sending "+mSentSize+" bytes / "+mTotalSize+" bytes";
	}
}
