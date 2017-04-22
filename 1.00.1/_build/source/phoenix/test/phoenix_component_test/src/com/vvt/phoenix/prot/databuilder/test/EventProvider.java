package com.vvt.phoenix.prot.databuilder.test;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.Event;

public class EventProvider implements DataProvider{
	
	private int mIndex;
	private ArrayList<Event> mList;
	
	public EventProvider(){
		mIndex = 0;
		mList = new ArrayList<Event>();
	}
	
	public void addEvent(Event event){
		mList.add(event);
	}

	@Override
	public boolean hasNext() {
		return (mIndex < mList.size());
	}

	@Override
	public Object getObject() {
		Event event = mList.get(mIndex);
		mIndex++;
		return event;
	}

}
