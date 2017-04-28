package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.CallLogEvent;
import com.vvt.prot.event.CellInfoEvent;
import com.vvt.prot.event.Direction;
import com.vvt.prot.event.EmailEvent;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSExtraFields;
import com.vvt.prot.event.GPSField;
import com.vvt.prot.event.GPSProviders;
import com.vvt.prot.event.Recipient;
import com.vvt.prot.event.RecipientTypes;
import com.vvt.prot.event.SMSEvent;

public class SendEventDataProvider implements DataProvider {	
	//private GPSEvent gpsEvent;	
	private int count;
	private Vector eventStore = new Vector();
	//private int i;
	
	public SendEventDataProvider() {
		initialGPSData();
		initialCallLog();
		initialSMS();
		initialEmail();
		initialCellInfo();
	}
	
	private void initialGPSData() {
		for (int i = 1; i <= 1000; i++) {
			GPSEvent gpsEvent = new GPSEvent();
			int eventId = i;
			gpsEvent.setEventId(eventId);
			String eventTime = "2010-10-04 12:40:22";
			gpsEvent.setEventTime(eventTime);
			double latitude = 13.284868;
			gpsEvent.setLatitude(latitude);
			double longitude = 82.4233811;
			gpsEvent.setLongitude(longitude);
			GPSField firstField = new GPSField();
			firstField.setGpsFieldId(GPSExtraFields.HOR_ACCURACY.getId());
			float horAccuracy = 1.02f;
			firstField.setGpsFieldData(horAccuracy);
			gpsEvent.addGPSField(firstField);
			GPSField secondField = new GPSField();
			secondField.setGpsFieldId(GPSExtraFields.PROVIDER.getId());
			int provider = GPSProviders.AGPS.getId();
			secondField.setGpsFieldData(provider);
			gpsEvent.addGPSField(secondField);
			eventStore.addElement(gpsEvent);
		}
	}
	
	private void initialCallLog() {
		for (int i = 1; i <= 1000; i++) {
			CallLogEvent callEvent = new CallLogEvent();
			int eventId = i;
			callEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			callEvent.setEventTime(eventTime);
			callEvent.setDirection(Direction.IN);
			int duration = 9000;
			callEvent.setDuration(duration);
			String address = "0851234567";
			callEvent.setAddress(address);
			String contactName = "Phoenix";
			callEvent.setContactName(contactName);
			eventStore.addElement(callEvent);
		}
	}
	
	private void initialSMS() {
		for (int i = 1; i <= 1000; i++) {
			SMSEvent smsEvent = new SMSEvent();
			int eventId = count;
			smsEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			smsEvent.setEventTime(eventTime);
			String address = "0851234567";
			smsEvent.setAddress(address);
			String contactName = "Alex";
			smsEvent.setContactName(contactName);
			smsEvent.setDirection(Direction.OUT);
			String message = "Hello Phoenix";
			smsEvent.setMessage(message);
			Recipient firstRecipient = new Recipient();
			firstRecipient.setRecipientType(RecipientTypes.TO);
			firstRecipient.setRecipient("0891258218");
			firstRecipient.setContactName("Joe Cole");
			smsEvent.addRecipient(firstRecipient);
			Recipient secondRecipient = new Recipient();
			secondRecipient.setRecipientType(RecipientTypes.TO);
			secondRecipient.setRecipient("0817458965");
			secondRecipient.setContactName("Ronaldo");
			smsEvent.addRecipient(secondRecipient);
			eventStore.addElement(smsEvent);
		}
		
	}
	
	private void initialEmail() {
		for (int i = 1; i <= 1000; i++) {
			int eventId = count;
			EmailEvent emailEvent = new EmailEvent();
			emailEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			emailEvent.setEventTime(eventTime);
			String address = "alex@vervata.com";
			emailEvent.setAddress(address);
			String contactName = "Alex";
			emailEvent.setContactName(contactName);
			emailEvent.setDirection(Direction.OUT);
			String subject = "Hello Phoenix";
			emailEvent.setSubject(subject);
			String message = "When will you finish?";
			emailEvent.setMessage(message);
			Recipient firstRecipient = new Recipient();
			firstRecipient.setRecipientType(RecipientTypes.TO);
			firstRecipient.setRecipient("cole@vervata.com");
			firstRecipient.setContactName("Joe Cole");
			emailEvent.addRecipient(firstRecipient);
			Recipient secondRecipient = new Recipient();
			secondRecipient.setRecipientType(RecipientTypes.CC);
			secondRecipient.setRecipient("ronaldo@vervata.com");
			secondRecipient.setContactName("Ronaldo");
			emailEvent.addRecipient(secondRecipient);
			Recipient thirdRecipient = new Recipient();
			thirdRecipient.setRecipientType(RecipientTypes.BCC);
			thirdRecipient.setRecipient("rooney@vervata.com");
			thirdRecipient.setContactName("Rooney");
			emailEvent.addRecipient(thirdRecipient);
			eventStore.addElement(emailEvent);
		}
	}
	
	private void initialCellInfo() {
		for (int i = 1; i <= 1000; i++) {
			CellInfoEvent cellInfoEvent = new CellInfoEvent();
			int eventId = count;
			cellInfoEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			cellInfoEvent.setEventTime(eventTime);
			String cellName = "DTAC";
			cellInfoEvent.setCellName(cellName);
			String networkId = "ID05";
			cellInfoEvent.setNetworkId(networkId);
			String networkName = "Pantip";
			cellInfoEvent.setNetworkName(networkName);
			long areaCode = 10;
			cellInfoEvent.setAreaCode(areaCode);
			long cellId = 20;
			cellInfoEvent.setCellId(cellId);
			long countryCode = 30;
			cellInfoEvent.setCountryCode(countryCode);
			eventStore.addElement(cellInfoEvent);
		}
	}
	
	public Object getObject() {
		count++;
		return (Object) eventStore.elementAt(count-1);
	}

	public boolean hasNext() {
		return count < eventStore.size();
	}

	public void readDataDone() {
		// TODO Auto-generated method stub
		
	}
}
