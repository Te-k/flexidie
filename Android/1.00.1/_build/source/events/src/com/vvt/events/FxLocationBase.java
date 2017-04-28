package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

public abstract class FxLocationBase extends FxEvent{
	private boolean mockLocaion;
	private double mLat;
	private double mLon;
	private float mSpeed;
	private float mHeading;
	private double mAltitude;
	/**
	 * GPSProvider
	 */
	private FxLocationMethod mMethod;
	private FxLocationMapProvider mapProvider;
	private float mHorizontalAccuracy;
	private float mVerticalAccuracy;
	private float mHeadingAccuracy;
	private float mSpeedAccuracy;
	
	/**
	 * @author Watcharin
	 * @created 11-Aug-2011 11:04:15
	 * Telephony
	 */
	private String networkName;
	private String networkId;
	private String cellName = null;
	private long cellId = 0;
	private String mobileCountryCode;
	private long areaCode = 0;
	

	@Override
	public abstract FxEventType getEventType();
	
	 

	public double getLatitude(){
		return mLat;
	}

	/**
	 * 
	 * @param lat    lat
	 */
	public void setLatitude(double lat){
		mLat = lat;
	}

	public double getLongitude(){
		return mLon;
	}

	/**
	 * 
	 * @param lon    lon
	 */
	public void setLongitude(double lon){
		mLon = lon;
	}

	public float getSpeed(){
		return mSpeed;
	}

	/**
	 * 
	 * @param speed    speed
	 */
	public void setSpeed(float speed){
		mSpeed = speed;
	}

	public float getHeading(){
		return mHeading;
	}

	/**
	 * 
	 * @param heading    heading
	 */
	public void setHeading(float heading){
		mHeading = heading;
	}

	public double getAltitude(){
		return mAltitude;
	}

	/**
	 * 
	 * @param altitude    altitude
	 */
	public void setAltitude(double altitude){
		mAltitude = altitude;
	}

	public FxLocationMethod getMethod (){
		return mMethod;
	}

	/**
	 * 
	 * @param provider    provider
	 */
	public void setMethod (FxLocationMethod provider){
		mMethod = provider;
	}	

	public float getHorizontalAccuracy(){
		return mHorizontalAccuracy;
	}

	/**
	 * 
	 * @param accuracy    accuracy
	 */
	public void setHorizontalAccuracy(float accuracy){
		mHorizontalAccuracy = accuracy;
	}

	public float getVerticalAccuracy(){
		return mVerticalAccuracy;
	}

	/**
	 * 
	 * @param accuracy    accuracy
	 */
	public void setVerticalAccuracy(float accuracy){
		mVerticalAccuracy = accuracy;
	}

	public float getHeadingAccuracy(){
		return mHeadingAccuracy;
	}

	/**
	 * 
	 * @param accuracy    accuracy
	 */
	public void setHeadingAccuracy(float accuracy){
		mHeadingAccuracy = accuracy;
	}

	public float getSpeedAccuracy(){
		return mSpeedAccuracy;
	}

	/**
	 * 
	 * @param accuracy    accuracy
	 */
	public void setSpeedAccuracy(float accuracy){
		mSpeedAccuracy = accuracy;
	}


	public String getNetworkName() {
		return networkName;
	}

	/**
	 * 
	 * @param networkName
	 */
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}


	public String getNetworkId() {
		return networkId;
	}

	/**
	 * 
	 * @param networkId
	 */
	public void setNetworkId(String networkId) {
		this.networkId = networkId;
	}


	public String getCellName() {
		return cellName;
	}

	/**
	 * 
	 * @param cellName
	 */
	public void setCellName(String cellName) {
		this.cellName = cellName;
	}


	public long getCellId() {
		return cellId;
	}

	/**
	 * 
	 * @param cellId
	 */
	public void setCellId(long cellId) {
		this.cellId = cellId;
	}

	
	public String getMobileCountryCode() {
		return mobileCountryCode;
	}

	/**
	 * 
	 * @param mobileCountryCode
	 */
	public void setMobileCountryCode(String mobileCountryCode) {
		this.mobileCountryCode = mobileCountryCode;
	}


	public long getAreaCode() {
		return areaCode;
	}

	/**
	 * 
	 * @param areaCode
	 */
	public void setAreaCode(long areaCode) {
		this.areaCode = areaCode;
	}


	public FxLocationMapProvider getMapProvider() {
		return mapProvider;
	}


	public void setMapProvider(FxLocationMapProvider mapProvider) {
		this.mapProvider = mapProvider;
	}


	public boolean isMockLocaion() {
		return mockLocaion;
	}


	public void setIsMockLocaion(boolean isMockLocation) {
		this.mockLocaion = isMockLocation;
	}

}
