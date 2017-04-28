package com.vvt.daemon_addressbook_manager.contacts.sync;
 
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import android.provider.ContactsContract;
 

public class EmailContact extends ContactMethod {
	
	public EmailContact() {		
		setType(ContactsContract.CommonDataKinds.Email.TYPE_HOME);
	}
	
	@Override
	public void toXml(Document xml, Element parent, String fullName)
	{
		Element email = Utils.createXmlElement(xml, parent, "email");
		Utils.setXmlElementValue(xml, email, "display-name", fullName);
		Utils.setXmlElementValue(xml, email, "smtp-address", getData());
	}
	
	@Override
	public void fromXml(Element parent)
	{
		this.setData(Utils.getXmlElementString(parent, "smtp-address"));
	}
}
