package com.vvt.gpsc.gloc;

public interface GLocationListener {
	public void notifyGLocation(GLocResponse resp);
	public void notifyError(Exception e);
}
