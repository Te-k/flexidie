package com.vvt.appcontext;

import android.content.Context;

import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.phoneinfo.PhoneInfoImpl;
import com.vvt.productinfo.ProductInfo;
import com.vvt.productinfo.ProductInfoImpl;

public class AppContextImpl implements AppContext{

	private PhoneInfo mPhoneInfo;
	private ProductInfo mProductInfo;
	private Context mContext;
	private String mWritablePath;
	
	public AppContextImpl(Context context) {
		mContext = context;
		mWritablePath = mContext.getCacheDir().getAbsolutePath();
	}
	
	public AppContextImpl(Context context, String writablePath) {
		mContext = context;
		mWritablePath = writablePath;
	}

	@Override
	public ProductInfo getProductInfo() {
		if(mProductInfo == null) {
			createProductInfo();
		}
		return mProductInfo;
	}

	@Override
	public PhoneInfo getPhoneInfo() {
		if(mPhoneInfo == null) {
			createPhoneInfo();
		}
		
		return mPhoneInfo;
	}
	
	public void createProductInfo() {
		mProductInfo = new ProductInfoImpl();
	}
	
	public void createPhoneInfo() {
		mPhoneInfo = new PhoneInfoImpl(mContext);
	}

	@Override
	public Context getApplicationContext() {
		return mContext;
	}

	@Override
	public String getWritablePath() {
		return mWritablePath;
	}

}
