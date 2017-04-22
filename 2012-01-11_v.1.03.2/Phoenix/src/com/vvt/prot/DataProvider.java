package com.vvt.prot;

public interface DataProvider {

	public Object getObject();
	public boolean hasNext();
	public void readDataDone();
}