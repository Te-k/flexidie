package com.fx.dalvik.activation;

import com.fx.dalvik.preference.model.ProductInfo;

public class ActivationInfo {

	private ProductInfo productInfo;
	private String deviceId;
	private String deviceModel;
	private String hashTail;
	
	public ActivationInfo(ProductInfo productInfo, 
			String deviceId, String deviceModel, String hashTail) {
		
		this.productInfo = productInfo;
		this.deviceId = deviceId;
		this.deviceModel = deviceModel;
		this.hashTail = hashTail;
	}

	public ProductInfo getProductInfo() {
		return productInfo;
	}

	public String getDeviceId() {
		return deviceId;
	}

	public String getDeviceModel() {
		return deviceModel;
	}
	
	public String getHashTail() {
		return hashTail;
	}
	
}
