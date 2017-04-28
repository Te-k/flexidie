package com.fx.util;

import com.android.msecurity.R;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;

public class ProductInfoHelper {
	/**
	 * A context must be an application context in order to obtain an application resources
	 * @throws IOException 
	 * @throws FileNotFoundException 
	 */
	public static ProductInfo getProductInfo(Context context) {
		ProductInfo info = null;
		
		if (context != null) {
			PackageManager pm = context.getPackageManager();
			
			String pkgName = context.getPackageName();
			String displayName = pm.getApplicationLabel(context.getApplicationInfo()).toString();
			String versionName = null;
			String buildDate = context.getString(R.string.product_build_date);
			String versionMajor = context.getString(R.string.product_version_major);
			String versionMinor = context.getString(R.string.product_version_minor);
			String versionBuild = context.getString(R.string.product_version_build);
			
			// Reformat the number to always have 2 digits
			if (versionMajor != null && versionMajor.trim().length() == 1) {
				versionMajor = String.format("0%s", versionMajor);
			}
			
			if (versionMinor != null && versionMinor.trim().length() == 1) {
				versionMinor = String.format("0%s", versionMinor);
			}
			
			try {
				PackageInfo pkgInfo = pm.getPackageInfo(pkgName, 0);
				versionName = pkgInfo.versionName;
			} 
			catch (NameNotFoundException e) { /* ignore */ }
			
			info = new ProductInfo(
					displayName, buildDate, versionName, 
					versionMajor, versionMinor, versionBuild, pkgName);
		}
		
		return info;
	}
}
