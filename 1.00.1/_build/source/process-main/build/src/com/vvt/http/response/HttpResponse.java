package com.vvt.http.response;

import java.util.List;
import java.util.Map;

import com.vvt.http.request.ContentType;
import com.vvt.http.request.HttpRequest;

public class HttpResponse {
	
	private HttpRequest httpRequest;
	private ContentType mResponseContentType;
	private int mResponseCode;
	private byte[] body;
	private boolean isCompleted;
	private Map<String, List<String>> mResponseHeader;
	
	public HttpResponse() {
	}

	public HttpRequest getHttpRequest() {
		return httpRequest;
	}
	
	/**
	 * @param fieldName
	 * @return values list of response header or null if the given field name doesn't match with any header fields
	 */
	public List<String> getHeaderByFieldName(String fieldName){
		return mResponseHeader.get(fieldName);
		
	}
	public Map<String, List<String>> getAllHeader(){
		return mResponseHeader;
	}
	public void setResponseHeader(Map<String, List<String>> responseHeader){
		mResponseHeader = responseHeader;
	}

	public void setHttpRequest(HttpRequest httpRequest) {
		this.httpRequest = httpRequest;
	}

	/**
	 * @return response MIME type or NULL
	 */
	public ContentType getResponseContentType(){
		return mResponseContentType;
	}
	public void setResponseContentType(ContentType type){
		mResponseContentType = type;
	}

	public int getResponseCode() {
		return mResponseCode;
	}

	public void setResponseCode(int responseCode) {
		mResponseCode = responseCode;
	}

	public byte[] getBody() {
		return body;
	}

	public void setBody(byte[] body) {
		this.body = body;
	}

	public boolean isCompleted() {
		return isCompleted;
	}

	public void setIsCompleted(boolean isCompleted) {
		this.isCompleted = isCompleted;
	}
}
