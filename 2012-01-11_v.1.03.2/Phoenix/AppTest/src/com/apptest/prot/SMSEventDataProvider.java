package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.Direction;
import com.vvt.prot.event.Recipient;
import com.vvt.prot.event.RecipientTypes;
import com.vvt.prot.event.SMSEvent;

public class SMSEventDataProvider implements DataProvider {	
	private int count;
	private Vector eventStore = new Vector();
	
	public SMSEventDataProvider() {
		initialSMS();		
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
