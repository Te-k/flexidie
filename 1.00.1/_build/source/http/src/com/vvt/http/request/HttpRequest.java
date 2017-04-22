package com.vvt.http.request;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * @author tanakharn
 * 22 December 2011
 */
public class HttpRequest {

	/*
	 * Members
	 */
	private ArrayList<PostDataItem> mPostDataItem;
	private String mUrl;
	private MethodType mMethodType;
	private ContentType mContentType;
	private int mConnectionTimeOut;
	private HashMap<String, String> mRequestHeader;
	
	/*
	 * Constructor
	 */
	public HttpRequest(){
		mUrl = "";
		mMethodType = MethodType.GET;
		mContentType = ContentType.BINARY_OCTET_STREAM;
		mRequestHeader = new HashMap<String, String>();
		mPostDataItem = new ArrayList<PostDataItem>();
	}
	
	public void addDataItem(byte[] data){
		PostByteItem item = new PostByteItem(data);
		mPostDataItem.add(item);
	}
	
	/**
	 * Equivalence to addFileDataItem(fileAbsolutePath, 0, fileLength)
	 * 
	 * @param fileAbsolutePath
	 * @param offset
	 */
	public void addFileDataItem(String fileAbsolutePath){
		File f = new File(fileAbsolutePath);
		addFileDataItem(fileAbsolutePath, 0, (int) f.length());
	}
	
	/**
	 * Equivalence to addFileDataItem(fileAbsolutePath, offset, 0)
	 * 
	 * @param fileAbsolutePath
	 * @param offset
	 */
	public void addFileDataItem(String fileAbsolutePath, int offset){
		File f = new File(fileAbsolutePath);
		int length = (int) (f.length() - offset);
		addFileDataItem(fileAbsolutePath, offset, length);
	}
	
	public void addFileDataItem(String fileAbsolutePath, int offset, int length){
		PostFileItem item = new PostFileItem(fileAbsolutePath);
		item.setOffset(offset);
		item.setLength(length);
		mPostDataItem.add(item);
	}
	
	public ArrayList<PostDataItem> getPostDataItem() {
		return mPostDataItem;
	}
	
	public String getUrl() {
		return mUrl;
	}
	public void setUrl(String url) {
		mUrl = url;
	}
	
	public MethodType getMethodType() {
		return mMethodType;
	}
	public void setMethodType(MethodType methodType) {
		mMethodType = methodType;
	}
	
	public ContentType getContentType() {
		return mContentType;
	}
	public void setContentType(ContentType contentType) {
		mContentType = contentType;
	}
	
	public int getConnectionTimeOut() {
		return mConnectionTimeOut;
	}
	/**
	 * Set connection time out in millisecond
	 * @param timeOut
	 */
	public void setConnectionTimeOut(int timeOut) {
		mConnectionTimeOut = timeOut;
	}
	
	public HashMap<String, String> getRequestHeader(){
		return mRequestHeader;
	}
	public void setRequestHeader(String field, String value){
		mRequestHeader.put(field, value);
	}
	
	
}
