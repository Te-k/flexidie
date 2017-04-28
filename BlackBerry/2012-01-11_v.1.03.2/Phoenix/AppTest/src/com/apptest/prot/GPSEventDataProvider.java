package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSExtraFields;
import com.vvt.prot.event.GPSField;
import com.vvt.prot.event.GPSProviders;

public class GPSEventDataProvider implements DataProvider {	
	private int count;
	private Vector eventStore = new Vector();
	
	private int eventCount = 0;
	public void setEventCount(int count) {
		eventCount = count;
	}
	
	public GPSEventDataProvider() {
		initialGPSData();	
	}
	
	private void initialGPSData() {
		for (int i = 1; i <= 10000; i++) {
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
