package com.vvt.info;

import com.vvt.std.TimeUtil;

import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class StartupTimeDb {

	private static final long STARTUP_TIME_GUID = 0x85bb55cade3c6c67L;
	private PersistentObject startupTimePersistence = null;
	private static StartupTimeDb self;
	private String startuptime;
	
	private StartupTimeDb() {
		startupTimePersistence = PersistentStore.getPersistentObject(STARTUP_TIME_GUID);
		synchronized (startupTimePersistence) {
			if (startupTimePersistence.getContents() != null) {
				startuptime = (String) startupTimePersistence.getContents();
			}
		}
	}
	
	public static StartupTimeDb getInstance() {
		if (self == null) {
			self = (StartupTimeDb)RuntimeStore.getRuntimeStore().get(STARTUP_TIME_GUID);
			if (self == null) {
				StartupTimeDb startupTime = new StartupTimeDb();
				RuntimeStore.getRuntimeStore().put(STARTUP_TIME_GUID, startupTime);
				self = startupTime;
			}
		}
		return self;
	}
	
	public void setStartupTime(long startuptime) {
		synchronized (startupTimePersistence) {
			startupTimePersistence.setContents(TimeUtil.format(startuptime));
			startupTimePersistence.commit();
		}
	}
	
	public String getStartupTime() {
		synchronized (startupTimePersistence) {
			startuptime = (String) startupTimePersistence.getContents();
		}
		return startuptime;
	}
}
