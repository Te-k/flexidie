package com.vvt.prot.command;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class GetAddressBook implements CommandData {

	public CommandCode getCommand() {
		return CommandCode.GET_ADDRESS_BOOK;
	}
}
