package com.daemon_bridge;

import java.io.Serializable;

public class GetLicenseStatusCommandResponse  extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = -6864587494567020228L;
	private LicenseStatus mStatusCode;
	
	public enum LicenseStatus {
		UNKNOWN, DEACTIVATED, ACTIVATED, EXPIRED, DISABLED;
	}
	
	public GetLicenseStatusCommandResponse(int responseCode) {
		super(responseCode);
	}
	
	public void setStatusCode(LicenseStatus statusCode) {
		this.mStatusCode = statusCode;
	}
	
	public LicenseStatus getStatusCode() {
		return this.mStatusCode;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("GetLicenseStatusCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", statusCode =").append(mStatusCode);
		return builder.append(" }").toString();		
	}
}
