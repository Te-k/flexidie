package com.vvt.callmanager.ref;

import java.io.Serializable;
import java.util.Iterator;
import java.util.List;

public class MonitorList implements Iterable<MonitorNumber>, Serializable {
	
	private static final long serialVersionUID = 5861075021746983037L;
	
	private List<MonitorNumber> mMonitors;
	
	public MonitorList(List<MonitorNumber> monitors) {
		mMonitors = monitors;
	}

	@Override
	public Iterator<MonitorNumber> iterator() {
		return mMonitors.iterator();
	}
	
	public int size() {
		return mMonitors == null ? 0 : mMonitors.size();
	}

}
