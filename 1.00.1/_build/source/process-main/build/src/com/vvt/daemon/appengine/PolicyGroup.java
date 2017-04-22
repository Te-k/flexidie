package com.vvt.daemon.appengine;

import com.vvt.eventrepository.querycriteria.EventQueryPriority;

public class PolicyGroup {
	
	public PolicyGroup() {

	}
	
	public EventQueryPriority getEventQueryPriority() {
		EventQueryPriority eventQueryPriority = new EventQueryPriority();
		return eventQueryPriority;
	}
}
