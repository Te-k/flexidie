package com.vvt.http.request;

import java.util.Hashtable;
import java.util.Vector;

public class FxHttpRequest {
	
	//Fields
	private String mUrl = "";
	private MethodType mMethod;
	private Hashtable header;
	private Vector mDataItemList;
	private ContentType mContentType;
	
	public FxHttpRequest(){
		mUrl = "";
		mDataItemList = new Vector();
		header = new Hashtable();
	}
	
	public String getUrl(){
		return mUrl;	
	}
	
	public void setUrl(String url){
		mUrl = url;
	}
	
	public MethodType getMethod() {
		return mMethod;
	}
	
	public void setMethod(MethodType method) {
		mMethod = method;
	}
	
	public void setContentType(ContentType conType) {
		mContentType = conType;
	}
	
	public ContentType getContentType(){
		return mContentType;
	}
	
	public void setHeaderType (String key, String value) {
		header.put(key, value);
	}
	
	public Hashtable getHeaderType() {
		return header;
	}
	
	public void addDataItem(byte[] data){
		PostByteItem item = new PostByteItem();
		item.setBytes(data);
		mDataItemList.addElement(item);
		
	}
	
	public void addFileDataItem(String fileAbsolutePath){
		PostFileItem item = new PostFileItem();
		item.setFilePath(fileAbsolutePath);
		mDataItemList.addElement(item);
	}
	
	public void addFileDataItem(String fileAbsolutePath, int offset){
		PostFileItem item = new PostFileItem();
		item.setFilePath(fileAbsolutePath);
		item.setOffset(offset);
		mDataItemList.addElement(item);
	}
	
	public Vector getDataItemList(){
		return mDataItemList;
	}
	
	public int dataItemCount(){
		return mDataItemList.size();
	}
}
