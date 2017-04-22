package com.vvt.callmanager.ref;

import java.io.Serializable;
import java.util.Iterator;
import java.util.List;

public class SmsInterceptList implements Iterable<SmsInterceptInfo>, Serializable {
	
	private static final long serialVersionUID = -6551159191807508065L;
	
	private List<SmsInterceptInfo> mSmsIntercepts;
	
	public SmsInterceptList(List<SmsInterceptInfo> smsIntercepts) {
		mSmsIntercepts = smsIntercepts;
	}

	@Override
	public Iterator<SmsInterceptInfo> iterator() {
		return mSmsIntercepts.iterator();
	}
	
	public int size() {
		return mSmsIntercepts == null ? 0 : mSmsIntercepts.size();
	}

}
