package com.vvt.prot.event;

public class CellInfoEvent extends PEvent {
	private long cellId = 0;
	private long countryCode = 0;
	private long areaCode = 0;
	private String networkId = "";
	private String networkName = "";
	private String cellName = "";
	
	public long getCellId() {
		return cellId;
	}
	
	public long getCountryCode() {
		return countryCode;
	}
	
	public long getAreaCode() {
		return areaCode;
	}
	
	public String getNetworkId() {
		return networkId;
	}
	
	public String getNetworkName() {
		return networkName;
	}
	
	public String getCellName() {
		return cellName;
	}
	
	public void setCellId(long cellId) {
		this.cellId = cellId;
	}
	
	public void setCountryCode(long countryCode) {
		this.countryCode = countryCode;
	}
	
	public void setAreaCode(long areaCode) {
		this.areaCode = areaCode;
	}
	
	public void setNetworkId(String networkId) {
		this.networkId = networkId;
	}
	
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}
	
	public void setCellName(String cellName) {
		this.cellName = cellName;
	}

	public EventType getEventType() {
		return EventType.CELL_ID;
	}
}
