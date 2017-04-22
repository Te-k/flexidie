package com.vvt.event;

import java.util.Vector;
import net.rim.device.api.util.Persistable;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxGPSMethod;

public class FxGPSEvent extends FxEvent implements Persistable {
	
	private double latitude = 0;
	private double longitude = 0;
	private double speed = 0;
	private double heading = 0;
	private double altitude = 0;	
	private double horAccuracy = 0;
	private double verAccuracy = 0;
	private double headAccuracy = 0;
	private double speedAccuracy = 0;
//	private Vector gpsFieldStore = new Vector();
	private FxGPSMethod provider = FxGPSMethod.UNKNOWN;
	
	public FxGPSEvent() {
		setEventType(EventType.GPS);
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
	
	public double getSpeed() {
		return speed;
	}
	
	public double getHeading() {
		return heading;
	}
	
	public double getHorAccuracy() {
		return horAccuracy;
	}
	
	public double getVerAccuracy() {
		return verAccuracy;
	}
	
	public double getHeadAccuracy() {
		return headAccuracy;
	}
	
	public double getSpeedAccuracy() {
		return speedAccuracy;
	}
	
	public FxGPSMethod getGPSProvider() {
		return provider;
	}
	
	/*public FxGPSField getGpsField(int index) {
		return (FxGPSField)gpsFieldStore.elementAt(index);
	}*/
	
	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}
	
	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}
	
	public void setAltitude(double altitude) {
		this.altitude = altitude;
	}
	
	public void setSpeed(double speed) {
		this.speed = speed;
	}
	
	public void setHeading(double heading) {
		this.heading = heading;
	}
	
	public void setHorAccuracy(double horAccuracy) {
		this.horAccuracy = horAccuracy;
	}
	
	public void setVerAccuracy(double verAccuracy) {
		this.verAccuracy = verAccuracy;
	}
	
	public void setHeadAccuracy(double headAccuracy) {
		this.headAccuracy = headAccuracy;
	}
	
	public void setSpeedAccuracy(double speedAccuracy) {
		this.speedAccuracy = speedAccuracy;
	}
	
	public void setGPSProvider(FxGPSMethod provider) {
		this.provider = provider;
	}
	
	/*public void addGPSField(FxGPSField gpsField) {
		gpsFieldStore.addElement(gpsField);
	}
	
	public int countGPSField() {
		return gpsFieldStore.size();
	}*/
	
	public boolean hasFix() {
		return latitude != 0 && longitude != 0;
	}
	
	public long getObjectSize() {
		long size = super.getObjectSize();
		size += 8; // latitude
		size += 8; // longitude
		/*for (int i = 0; i < countGPSField(); i++) {
			FxGPSField field = getGpsField(i);
			size += 2; // GpsFieldId
			size += 4; // GpsFieldData
		}*/
		size += 4; // speed
		size += 4; // heading
		size += 4; // altitude
		size += 1; // provider
		size += 4; // hor_accuracy
		size += 4; // ver_accuracy
		size += 4; // head_accuracy
		size += 4; // speed_accuracy
		return size;
	}
}
