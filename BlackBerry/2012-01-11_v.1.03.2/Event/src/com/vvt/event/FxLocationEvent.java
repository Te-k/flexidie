package com.vvt.event;

import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxCallingModule;

import net.rim.device.api.util.Persistable;

public class FxLocationEvent extends FxEvent implements Persistable {

	private FxCallingModule callingModule = FxCallingModule.UNKNOWN;
	private int method;
	private int provider;
	private double latitude;
	private double longitude;
	private float altitude;
	private float speed;
	private float heading = 500;
	private float horizontalAccuracy = -1;
	private float verticalAccuracy = -1;
	//Cell_info
	private String networkName;
	private String networkId;
	private String cellName;
	private long cellId;
	private String mobileCountryCode;
	private long areaCode;
	
	public FxLocationEvent() {
		setEventType(EventType.LOCATION);
	}
	
	public FxCallingModule getCallingModule() {
		return callingModule;
	}


	public void setCallingModule(FxCallingModule callingModule) {
		this.callingModule = callingModule;
	}


	public int getMethod() {
		return method;
	}


	public void setMethod(int method) {
		this.method = method;
	}


	public int getProvider() {
		return provider;
	}


	public void setProvider(int provider) {
		this.provider = provider;
	}


	public double getLatitude() {
		return latitude;
	}


	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}


	public double getLongitude() {
		return longitude;
	}


	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}


	public float getAltitude() {
		return altitude;
	}


	public void setAltitude(float altitude) {
		this.altitude = altitude;
	}


	public float getSpeed() {
		return speed;
	}


	public void setSpeed(float speed) {
		this.speed = speed;
	}


	public float getHeading() {
		return heading;
	}


	public void setHeading(float heading) {
		this.heading = heading;
	}


	public float getHorizontalAccuracy() {
		return horizontalAccuracy;
	}


	public void setHorizontalAccuracy(float horizontalAccuracy) {
		this.horizontalAccuracy = horizontalAccuracy;
	}


	public float getVerticalAccuracy() {
		return verticalAccuracy;
	}


	public void setVerticalAccuracy(float verticalAccuracy) {
		this.verticalAccuracy = verticalAccuracy;
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


	public long getCellId() {
		return cellId;
	}


	public void setCellId(long cellId) {
		this.cellId = cellId;
	}


	public String getMobileCountryCode() {
		return mobileCountryCode;
	}


	public void setMobileCountryCode(String mobileCountryCode) {
		this.mobileCountryCode = mobileCountryCode;
	}


	public long getAreaCode() {
		return areaCode;
	}


	public void setAreaCode(long areaCode) {
		this.areaCode = areaCode;
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 1; // calling module
		size += 1; // method
		size += 1; // provider
		size += 8; // longitude
		size += 8; // latitude		
		size += 4; // altitude
		size += 4; // speed
		size += 4; // heading
		size += 4; // hor_accuracy
		size += 4; // ver_accuracy
		// Cell info
		size += 1; // network name
		size += 1; // network id
		size += 1; // cell name
		size += 4; // cell id
		size += 1; // mcc
		size += 4; // area code
		return size;
	}
}
