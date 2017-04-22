package com.vvt.data_delivery_manager.tests;

import android.content.Context;

import com.vvt.appcontext.AppContext;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.phoneinfo.PhoneInfoImpl;
import com.vvt.productinfo.ProductInfo;
import com.vvt.productinfo.ProductInfoImpl;

public class MockAppContext implements AppContext{

	private Context mContext;
	private static String mDeviceId;
	
	public MockAppContext(Context context) {
		mContext = context;
	}
	
	@Override
	public ProductInfo getProductInfo() {
		ProductInfoImpl productInfo = new ProductInfoImpl();
		return productInfo;
	}

	

	@Override
	public Context getApplicationContext() {
		return mContext;
	}


	@Override
	public PhoneInfo getPhoneInfo() {
		PhoneInfoImpl phoneInfo = new PhoneInfoImpl(mContext);
		phoneInfo.setDeviceId(mDeviceId);
		return phoneInfo;
	}
	
	public static void setDeviceId(String deviceId) {
		mDeviceId = deviceId;
	}

	@Override
	public String getWritablePath() {
		return mContext.getFilesDir().toString();
	}

}
