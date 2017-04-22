package com.vvt.event;

import java.util.Vector;
import net.rim.device.api.util.Persistable;

public class ContactEvent extends FileBasedEvent implements Persistable {
	
	private Vector vCardStore = new Vector();
	
	public void addVCard(VCard vCard) {
		vCardStore.addElement(vCard);
	}
	
	public int countVCard() {
		return vCardStore.size();
	}
}
