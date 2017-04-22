package com.vvt.events;

 
import java.util.Date;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;

/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 02:02:04
 */
public class FxCameraImageThumbnailEvent extends FxEvent {

	/**
	 * Members
	 */
	private long m_ParingId;
	private FxMediaType m_Format;
	private byte m_ImageData[];
	private long m_ActualSize;
	private FxGeoTag m_GeoTag;
	private String m_ActualFullPath;
	private String m_ThumbnailFullPath;
	 
	@Override
	public FxEventType getEventType(){
		return FxEventType.CAMERA_IMAGE_THUMBNAIL;
	}
	
	public long getParingId(){
		return m_ParingId;
	}

	/**
	 * 
	 * @param paringId    paringId
	 */
	public void setParingId(long paringId){
		m_ParingId= paringId;
	}

	public FxMediaType getFormat(){
		return m_Format;
	}

	/**
	 * 
	 * @param mediaType    from MediaType
	 */
	public void setFormat(FxMediaType mediaType){
		m_Format = mediaType;
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

	public byte[] getData(){
		return m_ImageData;
	}

	/**
	 * 
	 * @param imageData    imageData
	 */
	public void setData(byte[] imageData){
		m_ImageData = imageData;
	}

	public long getActualSize(){
		return m_ActualSize;
	}

	/**
	 * 
	 * @param actualSize    actualSize
	 */
	public void setActualSize(long actualSize){
		m_ActualSize= actualSize;
	}
	
	public String getActualFullPath() {
		return m_ActualFullPath;
	}

	public void setActualFullPath(String actualFullPath) {
		this.m_ActualFullPath = actualFullPath;
	}

	public String getThumbnailFullPath() {
		return m_ThumbnailFullPath;
	}

	public void setThumbnailFullPath(String thumbnailFullPath) {
		this.m_ThumbnailFullPath = thumbnailFullPath;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
	 
		builder.append("FxCameraImageThumbnailEvent {");
		builder.append(" EventId =").append(super.getEventId());
		builder.append(", Format =").append(m_Format);
		builder.append(", ThumbnailFullPath =").append(m_ThumbnailFullPath);
		builder.append(", ActualFullPath =").append(m_ActualFullPath);
		builder.append(", ActualSize =").append(m_ActualSize);
		
		if(m_GeoTag != null) {
			builder.append(", GeoTag =").append(m_GeoTag.toString());
		}
		
		Date date = new Date(super.getEventTime());
		//TODO : need to approve
		String dateFormat = "yyyy-MM-dd hh:mm:ss";
		builder.append(" EventTime = " + android.text.format.DateFormat.format(dateFormat, date));
				
		return builder.append(" }").toString();
	}

	

}