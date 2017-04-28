package com.vvt.eventrepository;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

public class RepositoryChangeMap {
	
	HashMap<RepositoryChangeListener, RepositoryChangePolicy> map;
	
	public RepositoryChangeMap() {
		map = new HashMap<RepositoryChangeListener, RepositoryChangePolicy>();
	}
	
	public void addListnerPolicy(RepositoryChangeListener listener, RepositoryChangePolicy policy) {
		map.put(listener, policy);
	}
	
	public void removeListnerPolicy(RepositoryChangeListener listener) {
		if(map.containsKey(listener))
			map.remove(listener);
	}
	
	public List<RepositoryChangeListener> getListeners(RepositoryChangeEvent requestEventType) {
		List<RepositoryChangeListener> listners = new ArrayList<RepositoryChangeListener>();
		Set<Entry<RepositoryChangeListener, RepositoryChangePolicy>> set = map.entrySet();
		Iterator<Entry<RepositoryChangeListener, RepositoryChangePolicy>> i = set.iterator(); 
		
		while(i.hasNext()) { 
			Map.Entry<RepositoryChangeListener, RepositoryChangePolicy> me = i.next(); 
			RepositoryChangeListener listner = me.getKey();
			RepositoryChangePolicy policy = me.getValue();
			HashSet<RepositoryChangeEvent> registeredChangeEvents = policy.getChangeEvent();
			
			for(RepositoryChangeEvent registeredChangeEvent: registeredChangeEvents) {
				if(registeredChangeEvent == requestEventType) {
					listners.add(listner);
				}
			}
		} 
		return listners;
	}
	
	public List<RepositoryChangeListener> getListeners(RepositoryChangeEvent requestEventType, int eventCount) {
		List<RepositoryChangeListener> listners = new ArrayList<RepositoryChangeListener>();
		Set<Entry<RepositoryChangeListener, RepositoryChangePolicy>> set = map.entrySet(); 
		Iterator<Entry<RepositoryChangeListener, RepositoryChangePolicy>> i = set.iterator(); 
		
		while(i.hasNext()) { 
			Map.Entry<RepositoryChangeListener, RepositoryChangePolicy> me = i.next(); 
			RepositoryChangeListener listner = me.getKey();
			RepositoryChangePolicy policy = me.getValue();
			HashSet<RepositoryChangeEvent> registeredChangeEvents = policy.getChangeEvent();
			
			for(RepositoryChangeEvent registeredChangeEvent: registeredChangeEvents) {
				if(registeredChangeEvent == requestEventType && eventCount >= policy.getMaxEventNumber()) {
					listners.add(listner); 
				}
			}
		} 
		return listners;
	}
	
	 
	
}
