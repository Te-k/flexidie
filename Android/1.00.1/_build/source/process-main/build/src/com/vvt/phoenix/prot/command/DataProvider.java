package com.vvt.phoenix.prot.command;

public interface DataProvider {

	public boolean hasNext();
	public Object getObject();
}
