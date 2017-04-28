package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 16-May-2011 5:38:27 PM
 */
public class LocationEvent extends Event {
	
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
	
	/*
	 * Members
	 */
	private int mCallingModule;
	private int mMethod;
	private int mProvider;
	private double mLat;
	private double mLon;
	private float mAltitude;
	private float mSpeed;
	private float mHeading;
	private float mHorizontalAccuracy;
	private float mVerticalAccuracy;
	//Cell_info
	private String mNetworkName;
	private String mNetworkId;
	private String mCellName;
	private long mCellId;
	private String mMobileCountryCode;
	private long mAreaCode;
	
	@Override
	public int getEventType(){
		return EventType.LOCATION;
	}

	public int getCallingModule() {
		return mCallingModule;
	}


	public void setCallingModule(int callingModule) {
		mCallingModule = callingModule;
	}


	public int getMethod() {
		return mMethod;
	}


	public void setMethod(int method) {
		mMethod = method;
	}


	public int getProvider() {
		return mProvider;
	}


	public void setProvider(int provider) {
		mProvider = provider;
	}


	public double getLat() {
		return mLat;
	}


	public void setLat(double lat) {
		mLat = lat;
	}


	public double getLon() {
		return mLon;
	}


	public void setLon(double lon) {
		mLon = lon;
	}


	public float getAltitude() {
		return mAltitude;
	}


	public void setAltitude(float altitude) {
		mAltitude = altitude;
	}


	public float getSpeed() {
		return mSpeed;
	}


	public void setSpeed(float speed) {
		mSpeed = speed;
	}


	public float getHeading() {
		return mHeading;
	}


	public void setHeading(float heading) {
		mHeading = heading;
	}


	public float getHorizontalAccuracy() {
		return mHorizontalAccuracy;
	}


	public void setHorizontalAccuracy(float horizontalAccuracy) {
		mHorizontalAccuracy = horizontalAccuracy;
	}


	public float getVerticalAccuracy() {
		return mVerticalAccuracy;
	}


	public void setVerticalAccuracy(float verticalAccuracy) {
		mVerticalAccuracy = verticalAccuracy;
	}


	public String getNetworkName() {
		return mNetworkName;
	}


	public void setNetworkName(String networkName) {
		mNetworkName = networkName;
	}


	public String getNetworkId() {
		return mNetworkId;
	}


	public void setNetworkId(String networkId) {
		mNetworkId = networkId;
	}


	public String getCellName() {
		return mCellName;
	}


	public void setCellName(String cellName) {
		mCellName = cellName;
	}


	public long getCellId() {
		return mCellId;
	}


	public void setCellId(long cellId) {
		mCellId = cellId;
	}


	public String getMobileCountryCode() {
		return mMobileCountryCode;
	}


	public void setMobileCountryCode(String mobileCountryCode) {
		mMobileCountryCode = mobileCountryCode;
	}


	public long getAreaCode() {
		return mAreaCode;
	}


	public void setAreaCode(long areaCode) {
		mAreaCode = areaCode;
	}

	
	@Override
	public String toString(){
		String res = "Location Event Details.\n";
		res += "Calling Module: " + mCallingModule + "\n";
		res += "Method: "+ mMethod + "\n";
		res += "Provider: "+ mProvider + "\n";
		res += "Lat: "+ mLat + "\n";
		res += "Lon: "+ mLon + "\n";
		res += "Altitude: "+ mAltitude + "\n";
		res += "Speed: "+ mSpeed + "\n";
		res += "Heading: " + mHeading + "\n";
		res += "Horizontal Accuracy: "+ mHorizontalAccuracy + "\n";
		res += "Vertical Accuracy: "+ mVerticalAccuracy + "\n";
		res += "Network Name: " + mNetworkName + "\n";
		res += "Network ID: " + mNetworkId + "\n";
		res += "Cell Name: " + mCellName + "\n";
		res += "Cell ID: " + mCellId + "\n";
		res += "MCC: " + mMobileCountryCode + "\n";
		res += "Area Code: " + mAreaCode + "\n";
		
		return res;
	}
}