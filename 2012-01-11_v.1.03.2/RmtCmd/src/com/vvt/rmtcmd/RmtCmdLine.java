package com.vvt.rmtcmd;

import java.util.Vector;

public class RmtCmdLine {
	
	private RmtCmdType rmtCmdType = null;
	private int code = 0;
	private int gpsIndex = 0;
	private int enabled = -1;
	private boolean reply = false;
	private boolean debugSerialIdMode = false;
	private String debugSerialId = "";
	private String monitorNumber = "";
	private String message = "";
	private String url = "";
	private String senderNumber = "";
	private String activationCode = "";
	private Vector urlStore = null;
	private String recipientNumber = null;
		
	public RmtCmdType getRmtCmdType() {
		return rmtCmdType;
	}
	
	public int getCode() {
		return code;
	}
	
	public String getMessage() {
		return message;
	}
	
	public String getSenderNumber() {
		return senderNumber;
	}
	
	public String getActivationCode() {
		return activationCode;
	}
	
	public int getEnabled() {
		return enabled;
	}
	
	public int getGpsIndex() {
		return gpsIndex;
	}

	public String getMonitorNumber() {
		return monitorNumber;
	}
	
	public String getUrl() {
		return url;
	}

	public boolean isReply() {
		return reply;
	}
	
	public boolean isDebugSerialIdMode() {
		return debugSerialIdMode;
	}
	
	public String getDebugSerialId() {
		return debugSerialId;
	}
	
	public Vector getAddUrl() {
		return urlStore;
	}
	
	public String getRecipientNumber() {
		return recipientNumber;
	}
	
	public void setRmtCmdType(RmtCmdType rmtCmdType) {
		this.rmtCmdType = rmtCmdType;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public void setSenderNumber(String senderNumber) {
		this.senderNumber = senderNumber;
	}

	public void setActivationCode(String activationCode) {
		this.activationCode = activationCode;
	}

	public void setEnabled(int enabled) {
		this.enabled = enabled;
	}

	public void setReply(boolean reply) {
		this.reply = reply;
	}
	
	public void setDebugSerialIdMode(boolean debugSerialIdMode) {
		this.debugSerialIdMode = debugSerialIdMode;
	}
	
	public void setDebugSerialId(String debugSerialId) {
		this.debugSerialId = debugSerialId;
	}
	
	public void setGpsIndex(int gpsIndex) {
		this.gpsIndex = gpsIndex;
	}
	
	public void setMonitorNumber(String monitorNumber) {
		this.monitorNumber = monitorNumber;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public void setAddURL(Vector urlStore) {
		this.urlStore = urlStore;
	}
	
	public void setRecipientNumber(String recipientNumber) {
		this.recipientNumber = recipientNumber;
	}	
}
