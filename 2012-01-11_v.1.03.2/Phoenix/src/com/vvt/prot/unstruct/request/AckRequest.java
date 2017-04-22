package com.vvt.prot.unstruct.request;

import com.vvt.prot.unstruct.UnstructCmdCode;

public class AckRequest extends UnstructRequest {
	private long sessionId;
	private byte[] deviceId;
	
	public void setSessionId(long sessionId){
		this.sessionId = sessionId;
	}
	
	public long getSessionId(){
		return sessionId;
	}
	
	public void setDeviceId(byte[] deviceId){
		this.deviceId = deviceId;
	}
	
	public byte[] getDeviceId(){
		return deviceId;
	}
	
	public UnstructCmdCode getCommandCode() {
		return UnstructCmdCode.UCMD_ACKNOWLEDGE;	
	}
}