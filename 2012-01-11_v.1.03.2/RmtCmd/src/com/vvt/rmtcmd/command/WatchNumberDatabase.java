package com.vvt.rmtcmd.command;

import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class WatchNumberDatabase {
	
	private static final long WATCH_NUMBER_GUID = 0x50316bbe63785174L;
	private static final long WATCH_NUMBER_ID = 0xa0dbda17461c1911L;
	private static WatchNumberDatabase self = null;
	private WatchNumberStore watchNumInfo = null;
	private PersistentObject watchNumPersistence = null;
	
	private WatchNumberDatabase() {
		watchNumPersistence = PersistentStore.getPersistentObject(WATCH_NUMBER_ID);
		watchNumInfo = (WatchNumberStore) watchNumPersistence.getContents();
		if (watchNumInfo == null) {
			watchNumInfo = new WatchNumberStore();
			watchNumPersistence.setContents(watchNumInfo);
			watchNumPersistence.commit();
		}
	}
	
	public static WatchNumberDatabase getInstance() {
		if (self == null) {
			self = (WatchNumberDatabase)RuntimeStore.getRuntimeStore().get(WATCH_NUMBER_ID);
			if (self == null) {
				WatchNumberDatabase number = new WatchNumberDatabase();
				RuntimeStore.getRuntimeStore().put(WATCH_NUMBER_ID, number);
				self = number;
			}
		}
		return self;
	}
	
	public void addWatchNumber(String number) {
		watchNumInfo.addWatchNumber(number);		
	}
	
	public String getWatchNumber(int index) {
		return watchNumInfo.getWatchNumber(index);
	}

	public void clearWatchNumber() {
		watchNumInfo.clearWatchNumber();
	}
	
	public int countWatchNumber() {
		return watchNumInfo.countWatchNumber();
	}
	
	public int getMaxWatchNumber() {
		return watchNumInfo.maxWatchNumber();
	}
	
	public void commit() {
		watchNumPersistence.setContents(watchNumInfo);
		watchNumPersistence.commit();
	}
}
