package com.vvt.protsrv.addr;

public class AddressBookState {

	public static final AddressBookState NORMAL = new AddressBookState(0);
	public static final AddressBookState EXPORTING = new AddressBookState(1);
	public static final AddressBookState SENDING = new AddressBookState(2);
	private int state;
	
	private AddressBookState(int state) {
		this.state = state;
	}

	public int getId() {
		return state;
	}
	
	public boolean equals(AddressBookState obj) {
		return this.state == obj.state;
	}
}
