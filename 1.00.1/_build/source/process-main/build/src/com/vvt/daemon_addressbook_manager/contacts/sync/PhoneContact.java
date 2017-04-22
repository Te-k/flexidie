package com.vvt.daemon_addressbook_manager.contacts.sync;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import android.provider.ContactsContract;
 

public class PhoneContact extends ContactMethod
{
	public PhoneContact()
	{
		setType(ContactsContract.CommonDataKinds.Phone.TYPE_HOME);
	}

	@Override
	public void toXml(Document xml, Element parent, String fullName)
	{
		Element phone = Utils.createXmlElement(xml, parent, "phone");
		switch (this.getType())
		{
		//TODO: we only support 1 home and 1 business number for now		
		case ContactsContract.CommonDataKinds.Phone.TYPE_HOME:
			Utils.setXmlElementValue(xml, phone, "type", "home1");
			break;
		case ContactsContract.CommonDataKinds.Phone.TYPE_WORK:
			Utils.setXmlElementValue(xml, phone, "type", "business1");
			break;
		case ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE:
			Utils.setXmlElementValue(xml, phone, "type", "mobile");
			break;
		default:
			break;
		}
		
		//strip "-" out of phone numbers
		String tmp = getData();
		String stripped = tmp.replaceAll("-", "");
		
		Utils.setXmlElementValue(xml, phone, "number", stripped);
	}
	
	@Override
	public void fromXml(Element parent)
	{
		this.setData(Utils.getXmlElementString(parent, "number"));
		String type = Utils.getXmlElementString(parent, "type");

		if(type != null)
		{
			if(type.startsWith("home")) setType(ContactsContract.CommonDataKinds.Phone.TYPE_HOME);
			if(type.startsWith("business")) setType(ContactsContract.CommonDataKinds.Phone.TYPE_WORK);
			if(type.startsWith("mobile")) setType(ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE);
		}
	}
}