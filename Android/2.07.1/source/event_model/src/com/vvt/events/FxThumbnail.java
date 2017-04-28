package com.vvt.events;


/**
 * @author Aruna
 * @version 1.0
 * @created 13-Jul-2011 03:06:23
 */
public class FxThumbnail {

	private byte m_imageData[];
	private String m_thumbnailPath;
	
	public void setThumbnailPath(String thumbnailPath)
	{
		m_thumbnailPath = thumbnailPath;
	}
	 
	public String getThumbnailPath()
	{
		return m_thumbnailPath;
	}
	
	
	public void setImageData(byte[] imageData)
	{
		m_imageData = imageData;
	}
	 
	public byte[] getImageData()
	{
		return m_imageData;
	}
	
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("FxThumbnail {");
		
		if(m_imageData != null)
			builder.append(" Data Size =").append(m_imageData.length);
		else
			builder.append(" Data Size =").append("0");
		
		builder.append(" ThumbnailPath =").append(m_thumbnailPath);
			
		return builder.append(" }").toString();
	}
}