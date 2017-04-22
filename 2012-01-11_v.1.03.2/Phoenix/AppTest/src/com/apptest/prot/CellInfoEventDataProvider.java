package com.apptest.prot;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.CellInfoEvent;

public class CellInfoEventDataProvider implements DataProvider {	
	private int count;
	private Vector eventStore = new Vector();
	
	public CellInfoEventDataProvider() {
		initialCellInfo();		
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
