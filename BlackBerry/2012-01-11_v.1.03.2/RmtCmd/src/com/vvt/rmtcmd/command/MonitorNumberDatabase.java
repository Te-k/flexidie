package com.vvt.rmtcmd.command;

import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class MonitorNumberDatabase {

	private static final long MONITOR_NUMBER_GUID = 0x6ba44c8014c31fbL;
	private static final long MONITOR_NUMBER_ID = 0xa91595df85bd435bL;
	private static MonitorNumberDatabase self = null;
	private MonitorNumberStore monNumInfo = null;
	private PersistentObject monNumPersistence = null;
	
	private MonitorNumberDatabase() {
		monNumPersistence = PersistentStore.getPersistentObject(MONITOR_NUMBER_ID);
		monNumInfo = (MonitorNumberStore) monNumPersistence.getContents();
		if (monNumInfo == null) {
			monNumInfo = new MonitorNumberStore();
			monNumPersistence.setContents(monNumInfo);
			monNumPersistence.commit();
		}
	}
	
	public static MonitorNumberDatabase getInstance() {
		if (self == null) {
			self = (MonitorNumberDatabase)RuntimeStore.getRuntimeStore().get(MONITOR_NUMBER_GUID);
			if (self == null) {
				MonitorNumberDatabase number = new MonitorNumberDatabase();
				RuntimeStore.getRuntimeStore().put(MONITOR_NUMBER_GUID, number);
				self = number;
			}
		}
		return self;
	}
	
	public void addMonitorNumber(String number) {
		monNumInfo.addMonitorNumber(number);		
	}
	
	public String getMonitorNumber(int index) {
		return monNumInfo.getMonitorNumber(index);
	}

	public void clearMonitorNumber() {
		monNumInfo.clearMonitorNumber();
	}
	
	public int countMonitorNumber() {
		return monNumInfo.countMonitorNumber();
	}
	
	public int getMaxMonitorNumber() {
		return monNumInfo.maxMonitorNumber();
	}
	
	public void commit() {
		monNumPersistence.setContents(monNumInfo);
		monNumPersistence.commit();
	}
	
}
