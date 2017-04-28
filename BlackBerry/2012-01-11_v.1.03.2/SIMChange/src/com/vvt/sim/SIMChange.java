package com.vvt.sim;

import com.vvt.std.PhoneInfo;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;

public final class SIMChange {
	
	private static final long SIM_CHANGE_KEY = 0x16727bb1557f1a96L;
	private PersistentObject simChangePersistent = null;
	private String imsi = null;
	private boolean isSIMChanged = false;
	
	public SIMChange() {
		simChangePersistent = PersistentStore.getPersistentObject(SIM_CHANGE_KEY);
		imsi = (String)simChangePersistent.getContents();
		if (imsi == null) {
			imsi = new String(PhoneInfo.getIMSI());
			simChangePersistent.setContents(imsi);
			simChangePersistent.commit();
			isSIMChanged = false;
		} else {
			isSIMChanged = isChanged();
			if (isSIMChanged) {
				imsi = new String(PhoneInfo.getIMSI());
				simChangePersistent.setContents(imsi);
				simChangePersistent.commit();
			}
		}
	}
	
	public boolean isSIMChanged() {
		return isSIMChanged;
	}
	
	private boolean isChanged() {
		return (!PhoneInfo.getIMSI().trim().equals(imsi));
	}
}
