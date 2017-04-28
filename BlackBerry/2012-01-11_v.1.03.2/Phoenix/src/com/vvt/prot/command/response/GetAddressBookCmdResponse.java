package com.vvt.prot.command.response;

import java.util.Vector;
import com.vvt.prot.CommandCode;
import com.vvt.prot.command.AddressBook;

public class GetAddressBookCmdResponse extends StructureCmdResponse {
	
	private Vector addressBooks = new Vector();
	
	public AddressBook getAddressBook(int index) {
		return (AddressBook)addressBooks.elementAt(index);
	}
	
	public void addAddressBooks(AddressBook addressBook) {
		addressBooks.addElement(addressBook);
	}
	
	public int getAddressBookCount() {
		return addressBooks.size();
	}
	
	// ServerResponse
	public CommandCode getCommand() {
		return CommandCode.GET_ADDRESS_BOOK;
	}
	
}
