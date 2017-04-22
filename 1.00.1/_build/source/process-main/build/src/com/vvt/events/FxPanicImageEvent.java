package com.vvt.events;

import java.util.Date;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public class FxPanicImageEvent extends FxEvent{
	
	private String networkName;
	private String networkId;
	private String cellName;
	private int cellId;
	private String countryCode;
	private String areaCode;
	private FxMediaType format;
	private byte imageData[];
	private int actualSize;
	private int actualDuration;
	private String actualFullPath;
	private FxGeoTag geoTag;
	
	
	@Override
	public FxEventType getEventType() {
		return FxEventType.PANIC_IMAGE;
	}
	
	
	public String getNetworkName() {
		return networkName;
	}
	
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}
	
	public String getNetworkId() {
		return networkId;
	}
	
	public void setNetworkId(String networkId) {
		this.networkId = networkId;
	}
	
	public String getCellName() {
		return cellName;
	}
	
	public void setCellName(String cellName) {
		this.cellName = cellName;
	}
	
	public int getCellId() {
		return cellId;
	}
	
	public void setCellId(int cellId) {
		this.cellId = cellId;
	}
	
	public String getCountryCode() {
		return countryCode;
	}
	
	public void setCountryCode(String countryCode) {
		this.countryCode = countryCode;
	}
	
	public String getAreaCode() {
		return areaCode;
	}
	
	public void setAreaCode(String areaCode) {
		this.areaCode = areaCode;
	}
	
	public FxMediaType getFormat() {
		return format;
	}
	
	public void setFormat(FxMediaType format) {
		this.format = format;
	}
	
	public byte[] getImageData() {
		return imageData;
	}
	
	public void setImageData(byte[] imageData) {
		this.imageData = imageData;
	}

	public int getActualSize() {
		return actualSize;
	}

	public void setActualSize(int actualSize) {
		this.actualSize = actualSize;
	}

	public int getActualDuration() {
		return actualDuration;
	}

	public void setActualDuration(int actualDuration) {
		this.actualDuration = actualDuration;
	}

	public String getActualFullPath() {
		return actualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.actualFullPath = actualFullPath;
	}

	public FxGeoTag getGeoTag() {
		return geoTag;
	}

	public void setGeoTag(FxGeoTag geoTag) {
		this.geoTag = geoTag;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxPanicGpsEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", networkName =").append(getNetworkName());
		builder.append(", networkId =").append(getNetworkId());
		builder.append(", cellName =").append(getCellName());
		builder.append(", cellId =").append(getCellId());
		builder.append(", countryCode =").append(getCountryCode());
		builder.append(", areaCode =").append(getAreaCode());
		builder.append(", format =").append(getFormat());
		builder.append(", actualSize =").append(getActualSize());
		builder.append(", actualDuration =").append(getActualDuration());
		builder.append(", actualFullPath =").append(getActualFullPath());
		if(geoTag != null) {
			builder.append(", GeoTag =").append(geoTag.toString());
		}
		
		Date date = new Date(super.getEventTime());
		//TODO : need to approve
		String dateFormat = "yyyy-MM-dd hh:mm:ss";
		builder.append(" EventTime = " + android.text.format.DateFormat.format(dateFormat, date));

		return builder.append(" }").toString();
	}
	
	
}
