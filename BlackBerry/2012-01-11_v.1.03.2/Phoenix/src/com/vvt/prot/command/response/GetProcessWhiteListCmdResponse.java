package com.vvt.prot.command.response;

import java.util.Vector;
import com.vvt.prot.CommandCode;

public class GetProcessWhiteListCmdResponse extends StructureCmdResponse {
	
	private Vector processes = new Vector();

	public Vector getProcesses() {
		return processes;
	}

	public void addProcesses(ProtProcess process) {
		processes.addElement(process);
	}
	
	public int countProcesses() {
		return processes.size();
	}
	
	public void removeAllProcesses() {
		processes.removeAllElements();
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.GET_PROCESS_WHITELIST;
	}
}
