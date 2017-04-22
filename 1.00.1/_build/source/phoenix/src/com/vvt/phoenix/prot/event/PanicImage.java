package com.vvt.phoenix.prot.event;

/**
 * @author tanakharn
 * @version 1.0
 * @created 15-Mar-2011 11:09:50 AM
 */
public class PanicImage extends Event {
	
	
	/*
	 * Constants
	 */
	public static final int COORDINATE_ACCURACY_UNKNOWN = 0;
	public static final int COORDINATE_ACCURACY_COARSE = 1;
	public static final int COORDINATE_ACCURACY_FINE = 2;
	
	/*
	 * Members
	 */
	private double mLat;
	private double mLon;
	private double mAltitude;
	private int mCoorAccu;
	
	private String mNetworkName;
	private String mNetworkId;
	private String mCellName;
	private int mCellId;
	private int mCountryCode;
	private int mAreaCode;
	private int mMediaType;
	private String mImagePath;
	
	/*
	 * Constructor
	 */
	public PanicImage(){
		/*
		 * default values
		 */
		mLat = 500;
		mLon = 0;
		mAltitude = 0;
		mCellId = 0;
		mCountryCode = 0;
		mAreaCode = 0;
	}

	@Override
	public int getEventType(){
		return EventType.PANIC_IMAGE;
	}
	
	public int getMediaType(){
		return mMediaType;
	}
	/**
	 * @param type from MediaType
	 */
	public void setMediaType(int type){
		mMediaType = type;
	}
	
	public String getImagePath(){
		return mImagePath;
	}
	
	public void setImagePath(String path){
		mImagePath = path;
	}
	
	// god dam location data
	
	public double getLattitude(){
		return mLat;
	}
	public void setLattitude(double lat){
		mLat = lat;
	}
	
	public double getLongitude(){
		return mLon;
	}
	public void setLongitude(double lon){
		mLon = lon;
	}
	
	public double getAltitude(){
		return mAltitude;
	}
	public void setAltitude(double altitude){
		mAltitude = altitude;
	}

	public int getCoordinateAccuracy(){
		return mCoorAccu;
	}
	/**
	 * @param accuracy, one of these choices -> Unknown, Coarse, Fine
	 */
	public void setCoordinateAccuracy(int accuracy){
		mCoorAccu = accuracy;
	}
	
	public String getNetworkName(){
		return mNetworkName;
	}
	public void setNetworkName(String name){
		mNetworkName = name;
	}
	
	public String getNetworkId(){
		return mNetworkId;
	}
	public void setNetworkId(String id){
		mNetworkId = id;
	}
		
	public String getCellName(){
		return mCellName;
	}
	public void setCellName(String name){
		mCellName = name;
	}

	public int getCellId(){
		return mCellId;
	}
	public void setCellId(int id){
		mCellId = id;
	}

	public int getCountryCode(){
		return mCountryCode;
	}
	public void setCountryCode(int code){
		mCountryCode = code;
	}

	public int getAreaCode(){
		return mAreaCode;
	}
	public void setAreaCode(int code){
		mAreaCode = code;
	}
	
}