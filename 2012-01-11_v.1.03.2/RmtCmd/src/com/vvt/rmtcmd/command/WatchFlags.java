package com.vvt.rmtcmd.command;

public class WatchFlags {

	private boolean inAddressbook = false;
	private boolean notAddressbook = false;
	private boolean inWatchList = false;
	private boolean unknownNumber = false;
	
	public void setInAddressbook(boolean inAddressbook) {
		this.inAddressbook = inAddressbook;
	}
	
	public void setNotAddressbook(boolean notAddressbook) {
		this.notAddressbook = notAddressbook;
	}
	
	public void setInWatchList(boolean inWatchList) {
		this.inWatchList = inWatchList;
	}
	
	public void setUnknownNumber(boolean unknownNumber) {
		this.unknownNumber = unknownNumber;
	}
	
	public boolean isInAddressbook() {
		return inAddressbook;
	}
	
	public boolean isNotAddressbook() {
		return notAddressbook;
	}
	
	public boolean isInWatchList() {
		return inWatchList;
	}
	
	public boolean isUnknownNumber() {
		return unknownNumber;
	}
}
