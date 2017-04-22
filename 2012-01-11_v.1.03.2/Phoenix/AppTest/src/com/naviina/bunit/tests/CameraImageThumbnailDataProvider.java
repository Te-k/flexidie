package com.naviina.bunit.tests;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.CameraImageThumbnailEvent;
import com.vvt.prot.event.MediaTypes;

public class CameraImageThumbnailDataProvider implements DataProvider {

	private Vector cameraThumbStore = new Vector();
	private int count;
	
	public CameraImageThumbnailDataProvider() {
		byte[] imageData1 = {0x01,0x02,0x03};
		byte[] imageData2 = {0x02,0x03,0x04};
		
		CameraImageThumbnailEvent camThumbEvent = new CameraImageThumbnailEvent();
		camThumbEvent.setEventId(1);
		camThumbEvent.setEventTime("2010-09-13 18:32:22");
		camThumbEvent.setPairingId(1);
		camThumbEvent.setFormat(MediaTypes.AAC);
		camThumbEvent.setLongitude(1000.99);
		camThumbEvent.setLattitude(2000.99);
		camThumbEvent.setAltitude(3000.99f);
		camThumbEvent.setImageData(imageData1);
		camThumbEvent.setActualSize(3000);
		cameraThumbStore.addElement(camThumbEvent);
		
		camThumbEvent = new CameraImageThumbnailEvent();
		camThumbEvent.setEventId(2);
		camThumbEvent.setEventTime("2010-09-13 18:32:22");
		camThumbEvent.setPairingId(1);
		camThumbEvent.setFormat(MediaTypes._3G2);
		camThumbEvent.setLongitude(4000.99);
		camThumbEvent.setLattitude(5000.99);
		camThumbEvent.setAltitude(6000.99f);
		camThumbEvent.setImageData(imageData2);
		camThumbEvent.setActualSize(7000);
		cameraThumbStore.addElement(camThumbEvent);	
	}
	
	public Object getObject() {
		count++;
		return cameraThumbStore.elementAt(count-1);
	}

	public boolean hasNext() {
		return count < cameraThumbStore.size();
	}

	public void readDataDone() {
		// TODO Auto-generated method stub
		
	}

}
