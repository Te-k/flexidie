package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.Direction;
import com.vvt.prot.event.IMEvent;
import com.vvt.prot.event.IMService;
import com.vvt.prot.event.Participant;

public class IMEventDataProvider implements DataProvider {	
	private int count;
	private Vector eventStore = new Vector();
	
	public IMEventDataProvider() {
		initialIM();		
	}
	
	private void initialIM() {
		for (int i = 1; i <= 1000; i++) {
			int eventId = count;
			IMEvent imEvent = new IMEvent();
			imEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			imEvent.setEventTime(eventTime);
			imEvent.setDirection(Direction.IN);
			imEvent.setUserID("");
			Participant firstPaticipiant = new Participant();
			firstPaticipiant.setName("Un");
			firstPaticipiant.setUID("");
			imEvent.addParticipant(firstPaticipiant);
			Participant secondPaticipiant = new Participant();
			secondPaticipiant.setName("Shit");
			secondPaticipiant.setUID("123456789");
			imEvent.addParticipant(secondPaticipiant);
			imEvent.setServiceID(IMService.BBM);
			imEvent.setMessage("What?");
			imEvent.setUserDisplayName("Thanawat");
			eventStore.addElement(imEvent);
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
