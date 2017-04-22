package com.vvt.eventrepository.querycriteria;

import java.util.ArrayList;
import java.util.List;

import com.vvt.base.FxEventType;

public class QueryCriteria {

	public static final int MAX = 200;
	
	private int mLimit = 50;
	private QueryOrder mQueryOrder;
	List<FxEventType> mEventTypes;

	public QueryCriteria() {
		mEventTypes = new ArrayList<FxEventType>();
	}

	public void setLimit(int limit) {
		this.mLimit = limit;

	}

	public int getLimit() {
		return this.mLimit;
	}

	public void setQueryOrder(QueryOrder order) {
		mQueryOrder = order;

	}

	public QueryOrder getQueryOrder() {
		return mQueryOrder;
	}

	public void addEventType(FxEventType eventType) {
		mEventTypes.add(eventType);
	}

	public List<FxEventType> getEventTypes() {
		return mEventTypes;
	}

	public void clearEventTypes()
	{
		if(mEventTypes != null)
			mEventTypes.clear();
	}
	
}
