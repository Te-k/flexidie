package com.vvt.phoenix.prot.command;


public class GetAddressBook implements CommandData{
	
	

	@Override
	public int getCmd() {
		return CommandCode.GET_ADDRESS_BOOK;
	}
	
	

}
