package com.vvt.data_delivery_manager.testsfunctional;

import java.util.ArrayList;

import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.event.Event;

public class MyEventProvider implements DataProvider {

	private ArrayList<Event> mEventList;
	private int mCurrentIndex;

	public MyEventProvider(ArrayList<Event> eventList) {
		mEventList = eventList;
		mCurrentIndex = 0;
	}

	@Override
	public Object getObject() {

		/*
		 * For better performance, DataProvider should query event data from
		 * database only when getObject() is called. Store all events in memory
		 * is not a good practice.
		 */

		Event event = mEventList.get(mCurrentIndex);
		mCurrentIndex++;

		return event;
	}

	@Override
	public boolean hasNext() {
		return mCurrentIndex < mEventList.size();
	}
}
