package com.vvt.eventrepository.eventresult;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class EventResultSet {

	private List<FxEvent> mFxEventsList;

	public EventResultSet() {
		mFxEventsList = new ArrayList<FxEvent>();
	}

	public void addEvents(List<FxEvent> events) {
		mFxEventsList.addAll(events);
	}

	public List<FxEvent> getEvents() {
		return mFxEventsList;
	}

	public EventKeys shrinkAsEventKeys() {
		EventKeys eventKeys = new EventKeys();

		HashMap<FxEventType, List<Long>> temp = new HashMap<FxEventType, List<Long>>();
		List<Long> ids;

		if (mFxEventsList != null) {
			for (int i = 0; i < mFxEventsList.size(); i++) {
				FxEventType type = mFxEventsList.get(i).getEventType();
				long id = mFxEventsList.get(i).getEventId();

				if (temp.get(type) != null) {
					ids = temp.get(type);
					ids.add(id);
				} else {
					ids = new ArrayList<Long>();
					ids.add(id);
					temp.put(type, ids);
				}

			}

			ids = new ArrayList<Long>();

			for (Iterator<FxEventType> it = temp.keySet().iterator(); it
					.hasNext();) {
				FxEventType eventType = it.next();
				ids = temp.get(eventType);
				if (ids != null) {
					eventKeys.put(eventType, ids);
				}
			}
		}

		return eventKeys;

	}

}
