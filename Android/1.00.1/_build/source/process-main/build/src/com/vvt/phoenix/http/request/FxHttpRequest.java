package com.vvt.phoenix.http.request;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


public class FxHttpRequest {
	
	// Members
	private String mUrl;
	private String mMethod;
	private ArrayList<PostItem> mDataItemList;
	private int mConnecTimeOut;
	private int mReadTimeOut;
	private String mContentType;	
	private HashMap<String, String> mRequestHeader;

	public FxHttpRequest(){
		mUrl = "";
		mMethod = MethodType.GET;
		mContentType = ContentType.BINARY_STREAM;
		mDataItemList = new ArrayList<PostItem>();
		mRequestHeader = new HashMap<String, String>();
	}
	
	public String getUrl(){
		return mUrl;	
	}
	public void setUrl(String url){
		mUrl = url;
	}
	
	public String getMethod(){
		return mMethod;
	}
	public void setMethod(String method){
		mMethod = method;
	}
	
	public void addDataItem(byte[] data){
		PostByteItem item = new PostByteItem();
		item.setBytes(data);
		mDataItemList.add(item);
	}
	public void addFileDataItem(String fileAbsolutePath){
		PostFileItem item = new PostFileItem();
		item.setFilePath(fileAbsolutePath);
		mDataItemList.add(item);
	}
	public void addFileDataItem(String fileAbsolutePath, int offset){
		PostFileItem item = new PostFileItem();
		item.setFilePath(fileAbsolutePath);
		item.setOffset(offset);
		mDataItemList.add(item);
	}
	
	public ArrayList<PostItem> getDataItemList(){
		return mDataItemList;
	}

	public int dataItemCount(){
		return mDataItemList.size();
	}
	
	public int getConnectTimeOut(){
		return mConnecTimeOut;
	}
	public void setConnecTimeOut(int millisec) throws IllegalArgumentException{
		if(millisec < 0){
			throw new IllegalArgumentException("Connect Time Out cannot be negative number");
		}
		mConnecTimeOut = millisec;
	}
	
	public int getReadTimeOut(){
		return mReadTimeOut;
	}
	public void setReadTimeOut(int millisec) throws IllegalArgumentException{
		if(millisec < 0){
			throw new IllegalArgumentException("Read Time Out cannot be negative number");
		}
		mReadTimeOut = millisec;
	}
	
	public String getContentType(){
		return mContentType;
	}
	public void setContentType(String type){
		mContentType = type;
	}

	public HashMap<String, String> getRequestHeader(){
		return mRequestHeader;
	}
	public void setRequestHeader(String field, String value){
		mRequestHeader.put(field, value);
	}
}
