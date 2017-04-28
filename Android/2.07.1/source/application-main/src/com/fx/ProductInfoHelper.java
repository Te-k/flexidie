package com.fx;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;

import com.android.msecurity.R;
import com.fx.maind.ref.Customization;
import com.fx.maind.ref.ProductUrlHelper;
import com.fx.preference.PreferenceManager;
import com.fx.preference.model.ProductInfo;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.vvt.logger.FxLog;

public class ProductInfoHelper {
	
	private static final String TAG = "ProductInfoHelper";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;

	/**
	 * A context must be an application context in order to obtain an application resources
	 */
	public static ProductInfo getProductInfo(Context context) {
		ProductEdition edition = Customization.PRODUCT_EDITION;
		int id = Integer.parseInt(Customization.PRODUCT_ID);
		String name = Customization.PRODUCT_NAME;
		String displayName = context.getPackageManager().getApplicationLabel(
				context.getApplicationInfo()).toString();
		String versionName = null;
		String buildDate = context.getString(R.string.product_build_date);
		String versionMajor = context.getString(R.string.product_version_major);
		String versionMinor = context.getString(R.string.product_version_minor);
		String versionBuild = context.getString(R.string.product_version_build);
		
		if (versionMajor != null && versionMajor.trim().length() == 1) {
			versionMajor = String.format("0%s", versionMajor);
		}
		
		if (versionMinor != null && versionMinor.trim().length() == 1) {
			versionMinor = String.format("0%s", versionMinor);
		}
		
		String urlActivate = ProductUrlHelper.getActivationUrl();
		String urlDelivery = ProductUrlHelper.getDeliveryUrl();
		
		try {
			PackageInfo pkgInfo = 
				context.getPackageManager().getPackageInfo(context.getPackageName(), 0);
			versionName = pkgInfo.versionName;
		} 
		catch (NameNotFoundException e) {
			//
		}
		
		String pkgName = context.getPackageName();
		
		return new ProductInfo(edition, id, name, displayName, buildDate, versionName, 
				versionMajor, versionMinor, versionBuild, urlActivate, urlDelivery, pkgName);
	}
	
	public static void collectProductInfo(Context context) {
		ProductInfo productInfo = getProductInfo(context);
		PreferenceManager.getInstance(context).setProductInfo(productInfo);
		if (LOGV) FxLog.v(TAG, "collectProductInfo # Product information is collected");
		
	}
}
