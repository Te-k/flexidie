package com.vvt.prot.event;

public abstract class PanicEvent extends PEvent {

	private double latitude = 0;
	private double longitude = 0;
	private double altitude = 0;
	private long cellId = 0;
	private long countryCode = 0;
	private long areaCode = 0;
	private String networkName = "";
	private String networkId = "";
	private String cellName = "";
	private CoordinateAccuracy coordinate = CoordinateAccuracy.UNKNOWN;
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	
	public void setAltitude(double altitude) {
		this.altitude = altitude;
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
	
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}
	
	public void setNetworkId(String networkId) {
		this.networkId = networkId;
	}
	
	public void setCellName(String cellName) {
		this.cellName = cellName;
	}
	
	public void setCoordinateAccuracy(CoordinateAccuracy coordinate) {
		this.coordinate = coordinate;
	}
	
	public double getLatitude() {
		return latitude;
	}
	
	public double getLongitude() {
		return longitude;
	}
	
	public double getAltitude() {
		return altitude;
	}
	
	public long getCellId() {
		return cellId;
	}
	
	public long getCountryCode() {
		return countryCode;
	}
	
	public long getAreaCode() {
		return areaCode;
	}
	
	public String getNetworkName() {
		return networkName;
	}
	
	public String getNetworkId() {
		return networkId;
	}
	
	public String getCellName() {
		return cellName;
	}
	
	public CoordinateAccuracy getCoordinateAccuracy() {
		return coordinate;
	}	
}
