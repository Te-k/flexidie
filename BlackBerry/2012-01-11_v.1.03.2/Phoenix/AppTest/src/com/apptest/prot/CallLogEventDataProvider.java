package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.CallLogEvent;
import com.vvt.prot.event.Direction;

public class CallLogEventDataProvider implements DataProvider {	
	private int count;
	private Vector eventStore = new Vector();
	
	public CallLogEventDataProvider() {
		initialCallLog();		
	}
	
	private void initialCallLog() {
		for (int i = 1; i <= 5000; i++) {
			CallLogEvent callEvent = new CallLogEvent();
			int eventId = i;
			callEvent.setEventId(eventId);
			String eventTime = "2010-05-13 09:41:22";
			callEvent.setEventTime(eventTime);
			callEvent.setDirection(Direction.IN);
			int duration = 9000;
			callEvent.setDuration(duration);
			String address = "08512_"+i;
			callEvent.setAddress(address);
			String contactName = "Phoenix";
			callEvent.setContactName(contactName);
			eventStore.addElement(callEvent);
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
