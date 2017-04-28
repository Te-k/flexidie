package com.vvt.event;

import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;

public class FxCellInfoEvent extends FxEvent implements Persistable {
	
	private long cellId = 0;
	private long mobileCountryCode = 0;
	private long areaCode = 0;
	private String networkId = "";
	private String networkName = "";
	private String cellName = "";
	
	public FxCellInfoEvent() {
		setEventType(EventType.CELL_ID);
	}
	
	public long getCellId() {
		return cellId;
	}
	
	public long getMobileCountryCode() {
		return mobileCountryCode;
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
	
	public void setMobileCountryCode(long mobileCountryCode) {
		this.mobileCountryCode = mobileCountryCode;
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
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 8; // cellId
		size += 8; // countryCode
		size += 8; // areaCode
		size += networkId.getBytes().length; // networkId
		size += networkName.getBytes().length; // networkName
		size += cellName.getBytes().length; // cellName
		return size;
	}
}
