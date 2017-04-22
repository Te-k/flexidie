package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.Direction;
import com.vvt.prot.event.EmailEvent;
import com.vvt.prot.event.Recipient;
import com.vvt.prot.event.RecipientTypes;

public class EmailEventDataProvider implements DataProvider {	
	private int count;
	private Vector eventStore = new Vector();
	
	public EmailEventDataProvider() {
		//initialEmail();	
		initialEmailIssue();
	}
	
	private void initialEmailIssue() {
		
	}
	
	private void initialEmail() {
		for (int i = 1; i <= 5000; i++) {
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
