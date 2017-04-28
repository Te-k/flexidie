package com.vvt.phoenix.http.response;

import java.util.List;
import java.util.Map;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.request.FxHttpRequest;

public class FxHttpResponse extends FxHttpProgress {
	
	// Debugging
	private static final String TAG = "FxHttpResponse";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	//Fields
	private FxHttpRequest mRequest;
	private int mResponseCode;
	private Map<String, List<String>> mResponseHeader;
	private byte[] mBody;
	private boolean mComplete;
	
	public FxHttpRequest getRequest(){
		return mRequest;
	}
	public void setRequest(FxHttpRequest request){
		mRequest = request;
	}
	
	public int getResponseCode(){
		return mResponseCode;
	}
	public void setResponseCode(int code){
		mResponseCode = code;
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
	
	public byte[] getBody(){
		return mBody;
	}
	public void setBody(byte[] body){
		mBody = body;
	}
	
	public boolean isComplete(){
		return mComplete;
	}
	public void setIsComplete(boolean status){
		mComplete = status;
	}
	

	
}
