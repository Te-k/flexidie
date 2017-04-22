package com.naviina.bunit.tests;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.command.SendActivate;

public class ActivationDataProvider implements DataProvider {

	private Vector activateStore = new Vector();
	private int index;
	public ActivationDataProvider() {
		SendActivate request = new SendActivate();
		request.setDeviceInfo("1.0.0");
		request.setDeviceModel("BB");
		//request.setIMSI("123456789012345");
		activateStore.addElement(request);
	}
	
	public Object getObject() {
		index++;
		return activateStore.elementAt(index-1);
	}

	public boolean hasNext() {
		return index<activateStore.size();
	}

	public void readDataDone() {
		
		
	}

	
}
