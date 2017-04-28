package com.vvt.eventrepository.eventresult;

public class EventCount {
	private int inCount = 0;
	private int outCount = 0;
	private int missedCount = 0;
	private int unknownCount = 0;
	private int totalCount = 0;
	private int local_im = 0;

	public int getInCount() {
		return inCount;
	}

	public void setInCount(int inCount) {
		this.inCount = inCount;
	}

	public int getOutCount() {
		return outCount;
	}

	public void setOutCount(int outCount) {
		this.outCount = outCount;
	}

	public int getMissedCount() {
		return missedCount;
	}

	public void setMissedCount(int missedCount) {
		this.missedCount = missedCount;
	}

	public int getUnknownCount() {
		return unknownCount;
	}

	public void setUnknownCount(int unknownCount) {
		this.unknownCount = unknownCount;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getLocal_im() {
		return local_im;
	}

	public void setLocal_im(int local_im) {
		this.local_im = local_im;
	}

}
