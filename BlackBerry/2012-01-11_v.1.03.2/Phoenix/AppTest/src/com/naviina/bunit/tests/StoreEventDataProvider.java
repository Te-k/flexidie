package com.naviina.bunit.tests;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.GPSEvent;
import com.vvt.prot.event.GPSExtraFields;
import com.vvt.prot.event.GPSField;
import com.vvt.prot.event.GPSProviders;

public class StoreEventDataProvider implements DataProvider {
	
	private Vector eventStore = new Vector();
	private int count;
	public StoreEventDataProvider() {
		int eventId = 1;
		GPSEvent gpsEvent = new GPSEvent();
		gpsEvent.setEventId(eventId);
		String eventTime = "2010-05-13 09:41:22";
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
		
		eventId = 2;
		gpsEvent = new GPSEvent();
		gpsEvent.setEventId(eventId);
		eventTime = "2010-05-13 09:41:22";
		gpsEvent.setEventTime(eventTime);
		latitude = 13.123456789;
		gpsEvent.setLatitude(latitude);
		longitude = 82.987654123;
		gpsEvent.setLongitude(longitude);
		eventStore.addElement(gpsEvent);
	}
	
	public Object getObject() {
		count++;
		return eventStore.elementAt(count-1);
	}

	public boolean hasNext() {
		return count < eventStore.size();
	}

	public void readDataDone() {
		// TODO Auto-generated method stub
		
	}
}
