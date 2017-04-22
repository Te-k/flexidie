package com.vvt.events;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 11:46:50
 */
public class FxGeoTag {

	/**
	 * Members
	 */
	private double mLat;
	private double mLon;
	private float mAltitude;

	
	public double getLat(){
		return mLat;
	}

	/**
	 * 
	 * @param lat    lat
	 */
	public void setLat(double lat){
		mLat = lat;
	}

	public double getLon(){
		return mLon;
	}

	/**
	 * 
	 * @param lon    lon
	 */
	public void setLon(double lon){
		mLon = lon;
	}

	public float getAltitude(){
		return mAltitude;
	}

	/**
	 * 
	 * @param altitude    altitude
	 */
	public void setAltitude(float altitude){
		mAltitude= altitude;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("FxGeoTag {");
		builder.append(" Lat =").append(mLat);
		builder.append(", Lon =").append(mLon);
		builder.append(", Altitude =").append(mAltitude);
		return builder.append(" }").toString();
	}
}