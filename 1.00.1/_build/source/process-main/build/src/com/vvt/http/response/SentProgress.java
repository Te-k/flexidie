package com.vvt.http.response;

public class SentProgress {
	
	private long totalSize;
	private long sentSize;
	
	public SentProgress() {
	}

	public long getTotalSize() {
		return totalSize;
	}

	public void setTotalSize(long totalSize) {
		this.totalSize = totalSize;
	}

	public long getSentSize() {
		return sentSize;
	}

	public void setSentSize(long sentSize) {
		this.sentSize = sentSize;
	}
}
