package com.vvt.protsrv.addr;

import java.util.Vector;

public class ContactStore {

	private Vector contactStore = new Vector();
	private String addressBookName = "";
	private long addressBookId = 1;
	
	public void addContact(ContactInfo info) {
		contactStore.addElement(info);
	}
	
	public ContactInfo getContact(int index) {
		return (ContactInfo) contactStore.elementAt(index);
	}
	
	public int countContactInfo() {
		return contactStore.size();
	}
	
	public void setAddressBookName(String name) {
		addressBookName = name;
	}
	
	public String getAddressBookName() {
		return addressBookName;
	}
	
	public void setAddressBookId(long id) {
		addressBookId = id;
	}
	
	public long getAddressBookId() {
		return addressBookId;
	}
	
}
