package com.vvt.events;

import java.util.Date;

import com.vvt.base.FxEventType;

@SuppressWarnings("unused")
public class FxPanicGpsEvent extends FxLocationBase{

	@Override
	public FxEventType getEventType(){
		return FxEventType.PANIC_GPS;
	}
	
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
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxPanicGpsEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", mockLocaion =").append(isMockLocaion());
		builder.append(", EventType =").append(FxEventType.forValue(getEventType().getNumber()));
		builder.append(", Lat =").append(getLatitude());
		builder.append(", Long =").append(getLongitude());
		builder.append(", Altitude =").append(getAltitude());
		builder.append(", Speed =").append(getSpeed());
		builder.append(", Heading =").append(getHeading());
		builder.append(", Method =").append(getMethod());
		builder.append(", HorizontalAccuracy =").append(getHorizontalAccuracy());
		builder.append(", VerticalAccuracy =").append(getVerticalAccuracy());
		builder.append(", HeadingAccuracy =").append(getHeadingAccuracy());
		builder.append(", SpeedAccuracy =").append(getSpeedAccuracy());
		builder.append(", networkName =").append(getNetworkName());
		builder.append(", networkId =").append(getNetworkId());
		builder.append(", mobileCountryCode =").append(getMobileCountryCode());
		builder.append(", areaCode =").append(getAreaCode());

		Date date = new Date(super.getEventTime());
		//TODO : need to approve
		String dateFormat = "yyyy-MM-dd hh:mm:ss";
		builder.append(" EventTime = " + android.text.format.DateFormat.format(dateFormat, date));
		
		return builder.append(" }").toString();
	}
}
