package com.vvt.phoenix.prot.parser;

import android.util.Log;

import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.prot.event.FxVCard;
import com.vvt.phoenix.util.DataBuffer;

public class AddressBookParser {
	
	//Debugging
	private static final String TAG = "AddressBookParser";
	private static final boolean DEBUG = false;

	public static byte[] parseAddressBook(AddressBook book){
		DataBuffer buffer = new DataBuffer();
		
		//1 parse AddressBook ID
		buffer.writeInt((int) book.getAddressBookId());
		
		//2 parse AddressBook name and length
		String addressBookName = book.getAddressBookName();
		if(addressBookName != null){
			buffer.writeUTFWithLength(addressBookName, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*
		buffer.writeByte((byte) book.getAddressBookName().length());
		buffer.writeUTF(book.getAddressBookName());*/
		
		//3 parse VCard count
		buffer.writeShort((short) book.getVCardCount());
		
		return buffer.toArray();
	}
	
	public static byte[] parseVCard(FxVCard card){
		if(DEBUG){
			Log.v(TAG, "*** parseVCard() ENTER ***");
		}
		
		DataBuffer buffer = new DataBuffer();
		
		//1 parse card ID server
		if(DEBUG){
			Log.v(TAG, "Parse Card ID Server");
		}
		buffer.writeInt((int) card.getCardIdServer());
		
		//2 parse card ID client and length
		if(DEBUG){
			Log.v(TAG, "Parse Card ID Client");
		}
		String cardId = card.getCardIdClient();
		if(cardId != null){
			buffer.writeUTFWithLength(cardId, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*
		buffer.writeByte((byte) card.getCardIdClient().length());
		buffer.writeUTF(card.getCardIdClient());*/
		
		//3 parse approval status
		if(DEBUG){
			Log.v(TAG, "Parse Approval Status");
		}
		buffer.writeByte((byte) card.getApprovalStatus());
		
		//4 parse VCard summary fields
		//4.1 first name and length
		if(DEBUG){
			Log.v(TAG, "Parse First Name");
		}
		String firstName = card.getFirstName();
		if(firstName != null){
			buffer.writeUTFWithLength(firstName, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*buffer.writeByte((byte) card.getFirstName().length());
		buffer.writeUTF(card.getFirstName());*/
		//4.2 last name and length
		if(DEBUG){
			Log.v(TAG, "Parse Last Name");
		}
		String lastName = card.getLastName();
		if(lastName != null){
			buffer.writeUTFWithLength(lastName, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*buffer.writeByte((byte) card.getLastName().length());
		buffer.writeUTF(card.getLastName());*/
		//4.3 home phone and length
		if(DEBUG){
			Log.v(TAG, "Parse Home Phone");
		}
		String homePhone = card.getHomePhone();
		if(homePhone != null){
			buffer.writeUTFWithLength(homePhone, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*buffer.writeByte((byte) card.getHomePhone().length());
		buffer.writeUTF(card.getHomePhone());*/
		//4.4 mobile phone and length
		if(DEBUG){
			Log.v(TAG, "Parse Mobile Phone");
		}
		String mobilePhone = card.getMobilePhone();
		if(mobilePhone != null){
			buffer.writeUTFWithLength(mobilePhone, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*buffer.writeByte((byte) card.getMobilePhone().length());
		buffer.writeUTF(card.getMobilePhone());*/
		//4.5 work phone and length
		if(DEBUG){
			Log.v(TAG, "Parse Work Phone");
		}
		String workPhone = card.getWorkPhone();
		if(workPhone != null){
			buffer.writeUTFWithLength(workPhone, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*buffer.writeByte((byte) card.getWorkPhone().length());
		buffer.writeUTF(card.getWorkPhone());*/
		//4.6 email and length
		if(DEBUG){
			Log.v(TAG, "Parse EMail");
		}
		String email = card.getEMail();
		if(email != null){
			buffer.writeUTFWithLength(email, DataBuffer.BYTE);
		}else{
			buffer.writeByte((byte) 0);
		}
		/*buffer.writeByte((byte) card.getEMail().length());
		buffer.writeUTF(card.getEMail());*/
		//4.7 note and length
		if(DEBUG){
			Log.v(TAG, "Parse Note");
		}
		String note = card.getNote();
		if(note != null){
			buffer.writeUTFWithLength(note, DataBuffer.SHORT);
		}else{
			buffer.writeShort((short) 0);
		}
		/*buffer.writeShort((short) card.getNote().length());
		buffer.writeUTF(card.getNote());*/
		//4.8 contact picture and length
		if(DEBUG){
			Log.v(TAG, "Parse Contact Picture");
		}
		byte[] contactPicture = card.getContactPicture();
		if(contactPicture != null){
			buffer.writeInt((int) contactPicture.length);
			buffer.writeBytes(contactPicture);
		}else{
			buffer.writeInt(0);
		}

		//5 VCard data and length
		/*String vCardData = card.getVCardData();
		if(vCardData != null){
			buffer.writeUTFWithLength(vCardData, DataBuffer.INT);
		}else{
			buffer.writeInt(0);
		}*/
		/*buffer.writeInt(card.getVCardData().length());
		buffer.writeUTF(card.getVCardData());*/
		if(DEBUG){
			Log.v(TAG, "Parse VCard Data");
		}
		byte[] vCardData = card.getVCardData();
		if(vCardData != null){
			buffer.writeInt(vCardData.length);
			buffer.writeBytes(vCardData);
		}else{
			buffer.writeInt(0);
		}
		
		if(DEBUG){
			Log.v(TAG, "*** parseVCard() EXIT ***");
		}
		
		return buffer.toArray();
	}
}
