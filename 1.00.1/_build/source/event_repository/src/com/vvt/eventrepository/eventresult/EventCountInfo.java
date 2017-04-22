package com.vvt.eventrepository.eventresult;

import java.util.HashMap;
import java.util.Iterator;

import com.vvt.base.FxEventType;
import com.vvt.events.FxEventDirection;

public class EventCountInfo {

	private HashMap<FxEventType, EventCount> mEventsCount;

	public EventCountInfo() {
		mEventsCount = new HashMap<FxEventType, EventCount>();
	}

	public int count(FxEventType eventType) {
		EventCount detailedCount = mEventsCount.get(eventType);
		if (detailedCount != null) {
			return detailedCount.getTotalCount();
		} else {
			return 0;
		}
	}

	public int count(FxEventType eventType, FxEventDirection direction) {
		EventCount detailedCount = mEventsCount.get(eventType);
		if (detailedCount != null) {
			switch (direction) {
			case IN:
				return detailedCount.getInCount();
			case OUT:
				return detailedCount.getOutCount();
			case MISSED_CALL:
				return detailedCount.getMissedCount();
			case LOCAL_IM:
				return detailedCount.getLocal_im();
			case UNKNOWN:
				return detailedCount.getUnknownCount();
			default:
				return 0;
			}
		} else {
			return 0;
		}
	}

	public int countTotal() {
		int total = 0;
		EventCount detailedCount = null;
		for (Iterator<FxEventType> it = mEventsCount.keySet().iterator(); it
				.hasNext();) {
			FxEventType eventType = it.next();
			detailedCount = mEventsCount.get(eventType);
			if (detailedCount != null) {
				total += detailedCount.getTotalCount();
			}
		}
		return total;
	}

	public void setCount(FxEventType eventType, EventCount detailedCount) {

		EventCount countDetail = mEventsCount.get(eventType);
		if (countDetail == null) {
			mEventsCount.put(eventType, detailedCount);
		} else {
			countDetail.setInCount(detailedCount.getInCount());
			countDetail.setOutCount(detailedCount.getOutCount());
			countDetail.setMissedCount(detailedCount.getMissedCount());
			countDetail.setUnknownCount(detailedCount.getUnknownCount());
			countDetail.setLocal_im(detailedCount.getLocal_im());
			countDetail.setTotalCount(detailedCount.getTotalCount());
		}
	}
}
