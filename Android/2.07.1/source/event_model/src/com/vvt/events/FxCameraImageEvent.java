package com.vvt.events;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 01:44:24
 */
public class FxCameraImageEvent extends FxEvent {

	/**
	 * Members
	 */
	private long m_ParingId;
	private String m_FileName;
	private byte m_ImageData[];
	private FxMediaType m_MediaType;
	public FxGeoTag m_GeoTag;
	
	@Override
	public FxEventType getEventType(){
		return FxEventType.CAMERA_IMAGE;
	}

	public long getParingId(){
		return m_ParingId;
	}

	/**
	 * 
	 * @param paringId    paringId
	 */
	public void setParingId(long paringId){
		m_ParingId = paringId;
	}

	public FxMediaType getFormat(){
		return m_MediaType;
	}

	/**
	 * 
	 * @param mediaType    mediaType
	 */
	public void setFormat(FxMediaType mediaType){
		m_MediaType = mediaType;
	}

	public FxGeoTag getGeo(){
		return m_GeoTag;
	}

	/**
	 * 
	 * @param geo    geo
	 */
	public void setGeo(FxGeoTag geo){
		m_GeoTag = geo;
	}

	public String getFileName(){
		return m_FileName;
	}

	/**
	 * 
	 * @param fileName    fileName
	 */
	public void setFileName(String fileName){
		m_FileName = fileName;
	}

	public byte[] getImageData(){
		return m_ImageData;
	}

	/**
	 * 
	 * @param imageData    imageData
	 */
	public void setImageData(byte[] imageData){
		m_ImageData = imageData;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		
		builder.append("FxCameraImageEvent {");
		
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", ParingId  =").append(getParingId());
		builder.append(", FileName =").append(getFileName());
		builder.append(", MediaType =").append(getFormat());
		builder.append(", GeoTag =").append(getGeo());
		builder.append(", EventTime =").append(super.getEventTime());
		return builder.append(" }").toString();
	}
}