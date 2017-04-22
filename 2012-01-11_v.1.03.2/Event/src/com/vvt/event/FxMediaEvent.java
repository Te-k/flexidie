package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.FxMediaTypes;
import com.vvt.event.constant.FxStatus;

public abstract class FxMediaEvent extends FxEvent implements Persistable {

	private long pairingId = 0; 
	private String name = null;
	private String path = null;
	private FxMediaTypes format = FxMediaTypes.UNKNOWN;
	private FxStatus status = FxStatus.NOT_SEND;
	
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

	public void setFormat(FxMediaTypes format) {
		this.format = format;
	}
	
	public FxMediaTypes getFormat() {
		return format;
	}
	
	public void setStatus(FxStatus status) {
		this.status = status;
	}
	
	public FxStatus getStatus() {
		return status;
	}
}
