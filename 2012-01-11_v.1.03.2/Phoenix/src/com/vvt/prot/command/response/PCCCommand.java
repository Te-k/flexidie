package com.vvt.prot.command.response;

import java.util.Vector;

public class PCCCommand {
	
	private PhoenixCompliantCommand cmdId = null;
	private Vector arguments = new Vector();
	
	public PhoenixCompliantCommand getCmdId() {
		return cmdId;
	}
	
	public Vector getArguments() {
		return arguments;
	}
	
	public void setCmdId(PhoenixCompliantCommand cmdId) {
		this.cmdId = cmdId;
	}
	
	public void addArguments(String arg) {
		arguments.addElement(arg);
	}
	
	public int countArguments() {
		return arguments.size();
	}
	
	public void removeAllArguments() {
		arguments.removeAllElements();
	}
}
