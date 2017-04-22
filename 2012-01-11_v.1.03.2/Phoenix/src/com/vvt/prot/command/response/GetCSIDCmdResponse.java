package com.vvt.prot.command.response;

import java.util.Vector;
import com.vvt.prot.CommandCode;

public class GetCSIDCmdResponse extends StructureCmdResponse {

	private Vector csids = new Vector();

	public Vector getCSIDCmd() {
		return csids;
	}

	public void addCSID(Integer csid) {
		csids.addElement(csid);
	}
	
	public int countCSID() {
		return csids.size();
	}
	
	public void removeAllCSIDs() {
		csids.removeAllElements();
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.GET_CSID;
	}
}
