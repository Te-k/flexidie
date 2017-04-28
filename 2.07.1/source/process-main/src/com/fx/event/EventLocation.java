package com.fx.event;

import android.content.ContentValues;
import android.content.Context;

import com.fx.eventdb.EventDatabaseMetadata;

public final class EventLocation extends Event {

//------------------------------------------------------------------------------------------------------------------------
// PRIVATE API
//------------------------------------------------------------------------------------------------------------------------
	
	private String time;
	private double latitude;
	private double longitude;
	private double altitude;
	private double horizontalAccuracy;
	private double verticalAccuracy;
	private String provider;
	
	/**
	 * This constructor is suitable for create a new object
	 */
	public EventLocation(Context context, String time, double latitude, double longitude, double altitude, 
			double horizontalAccuracy, double verticalAccuracy, String provider) {
		
		this.type = Event.TYPE_LOCATION;
		this.rowId = Event.ROWID_UNKNOWN;
		this.identifier = generateIdentifier(context);
		this.sendAttempts = 0;
		
		this.time = time;
		this.latitude = latitude;
		this.longitude = longitude;
		this.altitude = altitude;
		this.horizontalAccuracy = horizontalAccuracy;
		this.verticalAccuracy = verticalAccuracy;
		this.provider = provider;
	}
	
	/**
	 * This constructor is suitable for instantiate from database, 
	 * where you already got all important information
	 */
	public EventLocation(int rowId, int identifier, int sendAttempts, 
			String time, double latitude, double longitude, double altitude, 
			double horizontalAccuracy, double verticalAccuracy, String provider) {
		
		this.type = Event.TYPE_LOCATION;
		this.rowId = rowId;
		this.identifier = identifier;
		this.sendAttempts = sendAttempts;
		
		this.time = time;
		this.latitude = latitude;
		this.longitude = longitude;
		this.altitude = altitude;
		this.horizontalAccuracy = horizontalAccuracy;
		this.verticalAccuracy = verticalAccuracy;
		this.provider = provider;
	}
	
	public String toString() {
		
		String singleLineFormat = String.format("EventLocation = { " +
				"Error = %1$b; ErrorMessage = %2$s; " +
				"Type = %3$d; RowId = %4$d; " +
				"Indentifier = %5$d; SendAttempts = %6$d; " +
				"Time = %7$s; Latitude = %8$f; " +
				"Longtitude = %9$f; Altitude = %10$f; " +
				"Horizontal Acc = %11$f; Vertical Acc = %12$f; Provider = 13%s}", 
				this.error, this.errorMessage, this.type, this.rowId, 
				this.identifier, this.sendAttempts, time, 
				latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, provider);
		
		return singleLineFormat;
	};
	
	@Override
	public ContentValues getContentValues() {
		ContentValues contentValues = new ContentValues();
		contentValues.put(EventDatabaseMetadata.IDENTIFIER, getIdentifier());
		contentValues.put(EventDatabaseMetadata.SENDATTEMPTS, getSendAttempts());
		contentValues.put(EventDatabaseMetadata.Location.TIME, getTime());
		contentValues.put(EventDatabaseMetadata.Location.LATITUDE, getLatitude());
		contentValues.put(EventDatabaseMetadata.Location.LONGITUDE, getLongitude());
		contentValues.put(EventDatabaseMetadata.Location.ALTITUDE, getAltitude());
		contentValues.put(EventDatabaseMetadata.Location.HORIZONTAL_ACCURACY, getHorizontalAccuracy());
		contentValues.put(EventDatabaseMetadata.Location.VERTICAL_ACCURACY, getVerticalAccuracy());
		contentValues.put(EventDatabaseMetadata.Location.PROVIDER, getProvider());
		return contentValues;
	}
	
	public String getTime() { 
		return time; 
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
	
	public double getHorizontalAccuracy() { 
		return horizontalAccuracy; 
	}
	
	public double getVerticalAccuracy() { 
		return verticalAccuracy; 
	}
	
	public String getProvider() {
		return provider;
	}

	@Override
	public String getShortDescription() {
		return String.format(
				"GPS time: %s, provider: %s, lat: %s, long:%s", 
				time, provider, latitude, longitude);
	}

}
