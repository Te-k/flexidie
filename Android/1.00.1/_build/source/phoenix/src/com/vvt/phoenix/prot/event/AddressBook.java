package com.vvt.phoenix.prot.event;

import com.vvt.phoenix.prot.command.DataProvider;

public class AddressBook{

	//Members
	private long mAddrBookId;
	private String mAddrBookName;
	private int mVCardCount;
	private DataProvider mVCardProvider;
	
	public long getAddressBookId(){
		return mAddrBookId;
	}
	public void setAddressBookId(long id){
		mAddrBookId = id;
	}
	
	public String getAddressBookName(){
		return mAddrBookName;
	}
	public void setAddressBookName(String name){
		mAddrBookName = name;
	}
	
	public int getVCardCount(){
		return mVCardCount;
	}
	public void setVCardCount(int count){
		mVCardCount = count;
	}
	
	public DataProvider getVCardProvider(){
		return mVCardProvider;
	}
	public void setVCardProvider(DataProvider vCardProvider){
		mVCardProvider = vCardProvider;
	}

}
