package com.vvt.daemon_addressbook_manager.contacts.sync;
 

import org.w3c.dom.Document;
import org.w3c.dom.Element;

//import android.content.ContentValues;

public abstract class ContactMethod {
	private int kind, type;

	private String data;

	public final void setData(String data) {
		this.data = data;
	}

	public final String getData() {
		return data;
	}

	protected final void setKind(int kind) {
		this.kind = kind;
	}

	public final int getKind() {
		return kind;
	}

	public final void setType(int type) {
		this.type = type;
	}

	public final int getType() {
		return type;
	}
	
	@Override
	public String toString()
	{
		return getData();
	}

	//public abstract ContentValues toContentValues();
	
	//public abstract String getContentDirectory();

	public abstract void toXml(Document xml, Element parent, String fullName);
	public abstract void fromXml(Element parent);
}