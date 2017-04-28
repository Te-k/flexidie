package com.vvt.appcontext;

import android.content.Context;

import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.productinfo.ProductInfo;

public interface AppContext {
	public ProductInfo getProductInfo();
	public PhoneInfo getPhoneInfo();
	public Context getApplicationContext();
	public String getWritablePath();
}
