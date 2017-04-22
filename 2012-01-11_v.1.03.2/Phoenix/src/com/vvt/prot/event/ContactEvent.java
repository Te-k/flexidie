package com.vvt.prot.event;

import java.util.Vector;

public class ContactEvent extends FileBasedEvent {
	private Vector vCardStore = new Vector();
	public void addVCard(VCard vCard) {
		vCardStore.addElement(vCard);
	}
	
	public int countVCard() {
		return vCardStore.size();
	}
}
