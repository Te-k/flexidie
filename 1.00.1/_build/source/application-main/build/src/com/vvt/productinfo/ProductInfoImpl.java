package com.vvt.productinfo;

import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;

public class ProductInfoImpl implements ProductInfo{

	private int mProductId;
	private String mProductVersion;
	private String mProductName;
	private String mProductDescription;
	private byte mProductLanguage;
	private String mProtocolVersion;
	private String mProtocolHashTail;
	
	
	public ProductInfoImpl() {
		createProductInfo();
	}
	
	public void createProductInfo() {
		mProductName = FxSecurity.getConstant(Constant.PRODUCT_NAME);
		mProductId =  Integer.parseInt(FxSecurity.getConstant(Constant.PRODUCT_ID));
		mProductVersion = FxSecurity.getConstant(Constant.PRODUCT_VERSION);
		mProductDescription = FxSecurity.getConstant(Constant.PRODUCT_DESCRIPTION);
		mProductLanguage = Languages.ENGLISH;
		mProtocolVersion = FxSecurity.getConstant(Constant.PROTOCOL_VERSION);
		mProtocolHashTail = FxSecurity.getConstant(Constant.HASH_TAIL);
	}
	
	@Override
	public int getProductId() {
		return mProductId;
	}

	@Override
	public String getProductVersion() {
		return mProductVersion;
	}

	@Override
	public String getProductName() {
		return mProductName;
	}

	@Override
	public String getProductDescription() {
		return mProductDescription;
	}

	@Override
	public byte getProductLanguage() {
		return mProductLanguage;
	}

	@Override
	public String getProtocolVersion() {
		return mProtocolVersion;
	}

	@Override
	public String getProtocolHashTail() {
		return mProtocolHashTail;
	}

}
