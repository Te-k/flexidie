package com.naviina.bunit.tests;

import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import javax.microedition.pim.Contact;
import javax.microedition.pim.PIM;
import javax.microedition.pim.PIMException;
import net.rim.blackberry.api.pdap.BlackBerryContactList;
import net.rim.blackberry.api.pdap.BlackBerryPIM;
import com.vvt.prot.DataProvider;
import com.vvt.prot.command.VCardSummaryFields;
import com.vvt.prot.event.VCard;

public class AddrBookForAppDataProvider implements DataProvider {
	private BlackBerryContactList contactList;
	private String[] dataFormats;
	private Enumeration e;
	private Contact contact;
	private int count = 1;
	
	public AddrBookForAppDataProvider() {
		try {
			contactList = (BlackBerryContactList)BlackBerryPIM.getInstance().openPIMList(BlackBerryPIM.CONTACT_LIST, BlackBerryPIM.READ_WRITE);
			dataFormats = BlackBerryPIM.getInstance().supportedSerialFormats(BlackBerryPIM.CONTACT_LIST);
			e = contactList.items();
		} catch (PIMException e1) {
			e1.printStackTrace();
		}
	}

	public Object getObject() {
		VCard vcard = null;
		byte[] contactPicture = null;
		VCardSummaryFields vCardSumField = null;
		
		switch (count) {
		case 1:
			contactPicture = new byte[]{ 0x01,0x02,0x03 };
			vcard = new VCard();
			vcard.setServerId(1);
			vcard.setClientId("Client ID1");
			vcard.setApprovalStatus(ApprovalStatus.NO_STATUS.getId());
			
			vCardSumField = new VCardSummaryFields();
			vCardSumField.setContactPicture(contactPicture);
			vCardSumField.setEmail("nat@vervata.com");
			vCardSumField.setFirstName("Nat");
			vCardSumField.setLastName("Italy");
			vCardSumField.setHomePhone("021234567");
			vCardSumField.setWorkPhone("02987654321");
			vCardSumField.setMobilePhone("086123456789");
			vCardSumField.setNote("BB Dev");
			vcard.addVCardSummary(vCardSumField);
			break;
			
		case 2:	
			contactPicture = new byte[]{ 0x04,0x05,0x06 };
			vcard = new VCard();
			vcard.setServerId(1);
			vcard.setClientId("Client ID2");
			vcard.setApprovalStatus(ApprovalStatus.NO_STATUS.getId());
			
			vCardSumField = new VCardSummaryFields();
			vCardSumField.setContactPicture(contactPicture);
			vCardSumField.setEmail("natto@vervata.com");
			vCardSumField.setFirstName("Natto");
			vCardSumField.setLastName("thailand");
			vCardSumField.setHomePhone("021111111");
			vCardSumField.setWorkPhone("022222222");
			vCardSumField.setMobilePhone("0869999999");
			vCardSumField.setNote("Android Dev");
			vcard.addVCardSummary(vCardSumField);
			break;
		}
		
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
		try {
			contact = (Contact)e.nextElement();
			PIM.getInstance().toSerialFormat(contact, byteStream, "UTF-8", dataFormats[0]);
		} catch (UnsupportedEncodingException e1) {
			e1.printStackTrace();
		} catch (PIMException e1) {
			e1.printStackTrace();
		}
		vcard.setVCardData(byteStream.toByteArray());
		byteStream = null;
		count++;
		return vcard;
	}

	public boolean hasNext() {
		return e.hasMoreElements();
	}

	public void readDataDone() {
		// TODO Auto-generated method stub
		
	}
}
