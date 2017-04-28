package com.vvt.license;

import java.util.Vector;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class LicenseManager {
	
	private static LicenseManager self = null;
	private static final long LICENSE_GUID = 0xdb0f97eb33d6079L;
	private final long LICENSE_KEY = 0x815adbcc3f07ccb3L;
	private LicenseInfo licenseInfo = null;
	private PersistentObject licensePersistent = null;
	private Vector licenseObserverStore = new Vector();
	
	private LicenseManager() {
		licensePersistent = PersistentStore.getPersistentObject(LICENSE_KEY);
		licenseInfo = (LicenseInfo)licensePersistent.getContents();
		if (licenseInfo == null) {
			licenseInfo = new LicenseInfo();
			licensePersistent.setContents(licenseInfo);
			licensePersistent.commit();
		}
	}
	
	public static LicenseManager getInstance() {
		if (self == null) {
			self = (LicenseManager)RuntimeStore.getRuntimeStore().get(LICENSE_GUID);
		}
		if (self == null) {
			LicenseManager license = new LicenseManager();
			RuntimeStore.getRuntimeStore().put(LICENSE_GUID, license);
			self = license;
		}
		return self;
	}
	
	public void registerLicenseChangeListener(LicenseChangeListener observer) {
		boolean isExisted = isLicenseChangeListenerExisted(observer);
		if (!isExisted) {
			licenseObserverStore.addElement(observer);
		}
	}
	
	public LicenseInfo getLicenseInfo() {
		licensePersistent = PersistentStore.getPersistentObject(LICENSE_KEY);
		licenseInfo = (LicenseInfo)licensePersistent.getContents();
		return licenseInfo;
	}
	
	public void commit(LicenseInfo licenseInfo) {
		licensePersistent.setContents(licenseInfo);
		licensePersistent.commit();
		for (int i = 0; i < licenseObserverStore.size(); i++) {
			LicenseChangeListener observer = (LicenseChangeListener)licenseObserverStore.elementAt(i);
			observer.licenseChanged(licenseInfo);
		}
	}
	
	private boolean isLicenseChangeListenerExisted(LicenseChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < licenseObserverStore.size(); i++) {
			if (licenseObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
}
