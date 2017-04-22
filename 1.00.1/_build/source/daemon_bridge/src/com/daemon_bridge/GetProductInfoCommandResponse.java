package com.daemon_bridge;

import java.io.Serializable;

public class GetProductInfoCommandResponse extends CommandResponseBase implements Serializable {
	private static final long serialVersionUID = 5924906293235337652L;

	private int mProductId;
	private String mProductVersion;
	
	public GetProductInfoCommandResponse(int responseCode) {
		super(responseCode);
	}

	public int getProductId() {
		return mProductId;
	}

	public void setProductId(int productInfo) {
		this.mProductId = productInfo;
	}
	
	public String getProductVersion() {
		return mProductVersion;
	}
	
	public void setProductVersion(String productVersion) {
		this.mProductVersion = productVersion;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("GetProductInfoCommandResponse {");
		builder.append(" responseCode =").append(String.valueOf(getResponseCode()));
		builder.append(", ProductId =").append(mProductId);
		builder.append(", ProductVersion =").append(mProductVersion);
		return builder.append(" }").toString();		
	}
}
