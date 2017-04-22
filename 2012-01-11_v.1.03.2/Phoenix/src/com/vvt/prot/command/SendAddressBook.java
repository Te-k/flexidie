package com.vvt.prot.command;

import java.util.Vector;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class SendAddressBook implements CommandData {

	private int addrBookCount;
	private Vector addrBookStore = new Vector();
		
	public void addAddressBook(AddressBook addrBook) {
		addrBookStore.addElement(addrBook);
	}
	
	public AddressBook getAddressBook(int index) {
		return (AddressBook)addrBookStore.elementAt(index);
	}
	
	public int getAddressBookCount() {
		return addrBookCount;
	}
	
	public void setAddressBookCount(int addrBookCount) {
		this.addrBookCount = addrBookCount;
	}
	
	public CommandCode getCommand() {
		return CommandCode.SEND_ADDRESS_BOOK;
	}	
}
