package com.fx.maind.ref;

import java.io.Serializable;

public class AppInfo implements Serializable {

	private static final long serialVersionUID = 8787869107757483881L;
	
	/*private int mProductId;*/
	private int mConfig;
	/*private String mVersion;*/
	
	/*public int getProductId() {
		return mProductId;
	}
	public void setProductId(int mProductId) {
		this.mProductId = mProductId;
	}*/
	
	public int getConfig() {
		return mConfig;
	}
	public void setConfig(int mConfig) {
		this.mConfig = mConfig;
	}
	
	/*public String getVersion() {
		return mVersion;
	}
	public void setVersion(String mVersion) {
		this.mVersion = mVersion;
	}*/
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("AppInfo {");
		/*builder.append(" ProductId =").append(mProductId);*/
		builder.append(" Config =").append(mConfig);
		/*builder.append(" Version =").append(mVersion);*/
		return builder.append(" }").toString();		
	}
}
