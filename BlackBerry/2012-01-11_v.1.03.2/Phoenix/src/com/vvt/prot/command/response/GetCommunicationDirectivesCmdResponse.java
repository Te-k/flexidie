package com.vvt.prot.command.response;

import java.util.Vector;
import com.vvt.prot.CommandCode;

public class GetCommunicationDirectivesCmdResponse extends StructureCmdResponse {
	
	private Vector communicationDirective = new Vector();

	public CommunicationDirectives getCommunicationDirectives(int index) {
		return (CommunicationDirectives) communicationDirective.elementAt(index);
	}
	
	public void addCommunicationDirectives(CommunicationDirectives communicationDirectives) {
		communicationDirective.addElement(communicationDirectives);
	}
	
	public int countCommunicationDirectives() {
		return communicationDirective.size();
	}
	
	public void removeAllCommunicationDirectives() {
		communicationDirective.removeAllElements();
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.GET_COMMUNICATION_DIRECTIVES;
	}
}
