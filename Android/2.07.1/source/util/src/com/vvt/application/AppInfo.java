package com.vvt.application;

import java.text.SimpleDateFormat;
import java.util.Date;

public class AppInfo {
	
	private static final SimpleDateFormat sFormat = new SimpleDateFormat("yyyy/MM/dd");

	private String name;
	private String packageName;
	private String version;
	private long installDate;
	private int size;
	private byte[] iconBytes;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getPackageName() {
		return packageName;
	}
	public void setPackageName(String packageName) {
		this.packageName = packageName;
	}
	public String getVersion() {
		return version;
	}
	public void setVersion(String version) {
		this.version = version;
	}
	public long getInstallDate() {
		return installDate;
	}
	public void setInstallDate(long installDate) {
		this.installDate = installDate;
	}
	public int getSize() {
		return size;
	}
	public void setSize(int size) {
		this.size = size;
	}
	public byte[] getIconBytes() {
		return iconBytes;
	}
	public void setIconBytes(byte[] iconBytes) {
		this.iconBytes = iconBytes;
	}
	
	@Override
	public String toString() {
		return String.format(
				"%s, pkg: %s, ver: %s, date: %s", 
				name, packageName, version, sFormat.format(new Date(installDate)));
	}
	
	@Override
	public boolean equals(Object o) {
		if (o instanceof AppInfo) {
			AppInfo appInfo = (AppInfo) o;
			return name.equals(appInfo.getName()) && 
					packageName.equals(appInfo.getPackageName());
		}
		return false;
	}
}
