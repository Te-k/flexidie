package com.vvt.phoenix.prot.event;

import java.util.ArrayList;

public class SettingEvent extends Event{
	
	/*
	 * Members
	 */
	private ArrayList<SettingData> mSettingList;

	@Override
	public int getEventType() {
		return EventType.SETTING;
	}
	
	public static class SettingData{
		private int mSettingId;
		private String mSettingValue;
		
		public int getSettingId(){
			return mSettingId;
		}
		public void setSettingId(int id){
			mSettingId = id;
		}
		
		public String getSttingValue(){
			return mSettingValue;
		}
		public void setSettingValue(String value){
			mSettingValue = value;
		}
	}

	/*
	 * Constructor
	 */
	public SettingEvent(){
		mSettingList = new ArrayList<SettingData>();
	}
	
	public void addSettingData(SettingData setting){
		mSettingList.add(setting);
	}
	
	public int getSettingCount(){
		return mSettingList.size();
	}
	
	public SettingData getSettingData(int index){
		return mSettingList.get(index);
	}
}
