package com.vvt.db;

import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;

public class EventUID {
	
	private PersistentObject persistence = null;
	private Integer uid = null;
	private long uidKey = 0;
	
	public EventUID(long uidKey) {
		this.uidKey = uidKey;
		persistence = PersistentStore.getPersistentObject(uidKey);
		uid = (Integer)persistence.getContents();
		if (uid == null) {
			uid = new Integer(0);
			persistence.setContents(uid);
			persistence.commit();
		}
	}
	
	public int nextUID() {
		persistence = PersistentStore.getPersistentObject(uidKey);
		uid = (Integer)persistence.getContents();
		uid = new Integer(uid.intValue() + 1);
		persistence.setContents(uid);
		persistence.commit();
		return uid.intValue();
	}
	
	public void resetUID() {
		uid = new Integer(0);
		persistence.setContents(uid);
		persistence.commit();
	}
}
