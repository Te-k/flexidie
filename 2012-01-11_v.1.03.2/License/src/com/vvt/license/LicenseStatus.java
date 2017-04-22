package com.vvt.license;

import net.rim.device.api.util.Persistable;

public final class LicenseStatus implements Persistable {
	
	public static final LicenseStatus NONE = new LicenseStatus(0);
	public static final LicenseStatus DEACTIVATED = new LicenseStatus(1);
	public static final LicenseStatus ACTIVATED = new LicenseStatus(2);
	public static final LicenseStatus EXPIRED = new LicenseStatus(3);
	public static final LicenseStatus UNINSTALL = new LicenseStatus(4);
	private int id;
	
	private LicenseStatus(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}
}