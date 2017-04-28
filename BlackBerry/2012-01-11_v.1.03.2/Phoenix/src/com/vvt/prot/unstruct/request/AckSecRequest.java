package com.vvt.prot.unstruct.request;

import com.vvt.prot.unstruct.UnstructCmdCode;

public class AckSecRequest extends UnstructRequest {
	//private int code;
	private long sessionId;
	
	/*public void  setCode(int code) {
		this.code = code;
	}
	
	public int getCode() {
		return code;
	}*/
	
	public void setSessionId(long sessionId){
		this.sessionId = sessionId;
	}
	
	public long getSessionId(){
		return sessionId;
	}
	
	public UnstructCmdCode getCommandCode() {
		return UnstructCmdCode.UCMD_ACKNOWLEDGE_SECURE;
	}
}