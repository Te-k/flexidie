package com.vvt.events;

import java.util.ArrayList;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class FxSettingEvent extends FxEvent {
	
	private ArrayList<FxSettingElement> mSettingElements;
	
	public FxSettingEvent() {
		mSettingElements = new ArrayList<FxSettingElement>();
	}

	@Override
	public FxEventType getEventType() {
		return FxEventType.SETTINGS;
	}
	
	public FxSettingElement getSettingElement(int index){
		return mSettingElements.get(index);
	
	}
	
	public int getSettingElementCount() {
		return mSettingElements.size();
	}
	
	public void deleteSettingElement(int index) {
		mSettingElements.remove(index);
	}
	
	public void addSettingElement(FxSettingElement element) {
		mSettingElements.add(element);
		
	}
	
	

}
