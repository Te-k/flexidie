package com.vvt.phoenix.prot.command.response;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.event.AddressBook;

public class GetAddressBookResponse extends ResponseData{
	
	//Members
	private AddressBook mAddressBook;
	private ArrayList<AddressBook> mAddrBookList;
	
	@Override
	public int getCmdEcho() {
		return CommandCode.GET_ADDRESS_BOOK;
	}
	
	/*public AddressBook getAddressBook(){
		return mAddressBook;
	}
	public void setAddressBook(AddressBook book){
		mAddressBook = book;
	}*/
	
	/**
	 * Constructor
	 */
	public GetAddressBookResponse(){
		mAddrBookList = new ArrayList<AddressBook>();
	}
	
	public int getAddressBookCount(){
		return mAddrBookList.size();
	}
	
	public AddressBook getAddressBook(int index){
		return mAddrBookList.get(index);
	}
	public void addAddressBook(AddressBook addrBook){
		mAddrBookList.add(addrBook);
	}

}
