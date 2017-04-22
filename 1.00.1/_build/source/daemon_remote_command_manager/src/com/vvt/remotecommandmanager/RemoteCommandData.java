package com.vvt.remotecommandmanager;

import java.io.Serializable;
import java.util.List;


public class RemoteCommandData implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	private String commandCode;
	private List<String> arguments;
	private RemoteCommandType rmtCommandType;
	private String senderNumber;
	private boolean smsReplyRequired;
	
	public RemoteCommandData() {
		
	}

	public String getCommandCode() {
		return commandCode;
	}

	public void setCommandCode(String commandCode) {
		this.commandCode = commandCode;
	}

	public List<String> getArguments() {
		return arguments;
	}

	public void setArguments(List<String> arguments) {
		this.arguments = arguments;
	}

	public RemoteCommandType getRmtCommandType() {
		return rmtCommandType;
	}

	public void setRmtCommandType(RemoteCommandType rmtCommandType) {
		this.rmtCommandType = rmtCommandType;
	}

	public String getSenderNumber() {
		return senderNumber;
	}

	public void setSenderNumber(String senderNumber) {
		this.senderNumber = senderNumber;
	}

	public boolean isSmsReplyRequired() {
		return smsReplyRequired;
	}

	public void setSmsReplyRequired(boolean smsReplyRequired) {
		this.smsReplyRequired = smsReplyRequired;
	}
	
}
