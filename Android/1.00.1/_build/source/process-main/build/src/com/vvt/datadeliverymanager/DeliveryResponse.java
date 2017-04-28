package com.vvt.datadeliverymanager;

import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.ErrorResponseType;
import com.vvt.phoenix.prot.command.response.ResponseData;

/**
 * @author aruna
 * @version 1.0
 * @created 14-Sep-2011 11:10:52
 */
public class DeliveryResponse {
	
	private boolean mCanRetry;
	private ResponseData mCSMresponse;
	private DataProviderType mDataProviderType;
	private ErrorResponseType mErrorResponseType;
	private int mStatusCode;
	private String mStatusMessage;
	private boolean mSuccess;

	public boolean isCanRetry() {
		return mCanRetry;
	}

	public void setCanRetry(boolean canRetry) {
		this.mCanRetry = canRetry;
	}

	public ResponseData getCSMresponse() {
		return mCSMresponse;
	}

	public void setCSMresponse(ResponseData CSMresponse) {
		this.mCSMresponse = CSMresponse;
	}

	public DataProviderType getDataProviderType() {
		return mDataProviderType;
	}

	public void setDataProviderType(DataProviderType dataProviderType) {
		this.mDataProviderType = dataProviderType;
	}

	public ErrorResponseType getErrorResponseType() {
		return mErrorResponseType;
	}

	public void setErrorResponseType(ErrorResponseType errorResponseType) {
		this.mErrorResponseType = errorResponseType;
	}

	public int getStatusCode() {
		return mStatusCode;
	}

	public void setStatusCode(int statusCode) {
		this.mStatusCode = statusCode;
	}

	public String getStatusMessage() {
		return mStatusMessage;
	}

	public void setStatusMessage(String statusMessage) {
		this.mStatusMessage = statusMessage;
	}

	public boolean isSuccess() {
		return mSuccess;
	}

	public void setSuccess(boolean success) {
		this.mSuccess = success;
	}

	

}