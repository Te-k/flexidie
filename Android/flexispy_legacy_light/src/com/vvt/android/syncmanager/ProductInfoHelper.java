package com.vvt.android.syncmanager;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;

import com.android.msecurity.R;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.resource.StringResource;
import com.vvt.android.syncmanager.Customization.ProductServer;

public class ProductInfoHelper {

	public static ProductInfo getProductInfo(Context context) {
		int id = Integer.parseInt(Customization.PRODUCT_ID);
		String name = Customization.PRODUCT_NAME;
		String displayName = context.getString(R.string.product_display_name);
		String versionName = null;
		String buildDate = context.getString(R.string.product_build_date);
		String versionMajor = context.getString(R.string.product_version_major);
		String versionMinor = context.getString(R.string.product_version_minor);
		String versionBuild = context.getString(R.string.product_version_build);
		
		String urlActivate = null;
		String urlDelivery = null;
		
		if (Customization.PRODUCT_SERVER == ProductServer.RETAIL) {
			urlActivate = StringResource.URL_RETAIL_ACTIVATION;
			urlDelivery = StringResource.URL_RETAIL_LOG;
		}
		else if (Customization.PRODUCT_SERVER == ProductServer.RESELLER) {
			urlActivate = StringResource.URL_RESELLER_ACTIVATION;
			urlDelivery = StringResource.URL_RESELLER_LOG;
		}
		else {
			urlActivate = StringResource.URL_TEST_ACTIVATION;
			urlDelivery = StringResource.URL_TEST_LOG;
		}
		
		try {
			PackageInfo pkgInfo = 
				context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			versionName = pkgInfo.versionName;
		} 
		catch (NameNotFoundException e) {
			//
		}
		
		return new ProductInfo(id, name, displayName, buildDate, versionName, 
				versionMajor, versionMinor, versionBuild, urlActivate, urlDelivery);
	}
}
