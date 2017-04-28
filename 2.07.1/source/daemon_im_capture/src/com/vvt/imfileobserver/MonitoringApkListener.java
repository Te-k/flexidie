package com.vvt.imfileobserver;

public interface MonitoringApkListener {
	 public void onApkFileChange(boolean isCreate, String path);
}
