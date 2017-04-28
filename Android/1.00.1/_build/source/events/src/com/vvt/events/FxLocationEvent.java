	
package com.vvt.events;

import java.util.Date;

import com.vvt.base.FxEventType;



/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:20:30
 */
public class FxLocationEvent extends FxLocationBase {

	
	@Override
	public FxEventType getEventType(){ 
		return FxEventType.LOCATION;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxLocationEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", mockLocaion =").append(isMockLocaion());
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