package com.vvt.eventrepository.eventresult;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import com.vvt.base.FxEventType;

public class EventKeys implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private HashMap<FxEventType, List<Long>> mEventKeys;

	public EventKeys() {
		mEventKeys = new HashMap<FxEventType, List<Long>>();
	}

	public List<Long> getEventIDs(FxEventType eventType) {
		return mEventKeys.get(eventType);
	}

	public Set<FxEventType> getKeys() {
		return mEventKeys.keySet();
	}

	public void put(FxEventType eventType, List<Long> list) {
		mEventKeys.put(eventType, list);
	}

}
