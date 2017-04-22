package com.vvt.prot.event;

public abstract class MediaEvent extends PEvent {

	private long pairingId = 0; 
	private String name = null;
	private String path = null;
	private MediaTypes format = MediaTypes.UNKNOWN;
	
	public void setPairingId(long pairingId) {
		this.pairingId = pairingId;
	}
	
	public long getPairingId() {
		return pairingId;
	}
	
	public void setFileName(String name) {
		this.name = name;
	}
	
	public String getFileName() {
		return name;
	}
	
	public void setFilePath(String path) {
		this.path = path;
	}
	
	public String getFilePath() {
		return path;
	}

	public void setFormat(MediaTypes format) {
		this.format = format;
	}
	
	public MediaTypes getFormat() {
		return format;
	}
}
