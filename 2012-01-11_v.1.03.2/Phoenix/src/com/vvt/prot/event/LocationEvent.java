package com.vvt.prot.event;

public class LocationEvent extends PEvent {

	/*
	 * Calling Modules
	 */
	public static final int MODULE_CORE_TRIGGER = 1;
	public static final int MODULE_PANIC = 2;
	public static final int MODULE_ALERT = 3;
	public static final int MODULE_REMOTE_COMMAND = 4;
	
	/*
	 * GPS Methods
	 */
	public static final int METHOD_UNKNOWN = 0;
	public static final int METHOD_CELL_INFO = 1;
	public static final int METHOD_INTEGRATED_GPS = 2;
	public static final int METHOD_AGPS = 3;
	public static final int METHOD_BLUETOOTH = 4;
	public static final int METHOD_NETWORK = 5;
	
	/*
	 * GPS Providers
	 */
	public static final int PROVIDER_UNKNOWN = 0;
	public static final int PROVIDER_GOOGLE = 1;
	
	private CallingModule callingModule = CallingModule.UNKNOWN;
	private int method;
	private int provider;
	private double latitude;
	private double longitude;
	private float altitude;
	private float speed;
	private float heading;
	private float horizontalAccuracy;
	private float verticalAccuracy;
	//Cell_info
	private String networkName;
	private String networkId;
	private String cellName;
	private long cellId;
	private String mobileCountryCode;
	private long areaCode;
	
	public CallingModule getCallingModule() {
		return callingModule;
	}


	public void setCallingModule(CallingModule callingModule) {
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
	
	public EventType getEventType() {
		return EventType.LOCATION;
	}

}
