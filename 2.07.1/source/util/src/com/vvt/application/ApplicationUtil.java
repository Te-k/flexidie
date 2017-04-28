package com.vvt.application;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import android.app.ActivityManager;
import android.app.ActivityManager.RunningAppProcessInfo;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

public class ApplicationUtil {
	
	public static void switchToHome(Context context) {
		Intent intent = new Intent(Intent.ACTION_MAIN);
		intent.addCategory(Intent.CATEGORY_HOME);
		intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
		context.startActivity(intent); 
	}
	
	/**
	 * @return List contains foreground processes name
	 */
	public static List<String> getForegroundPackages(Context context) {
		ActivityManager activityManager = 
				(ActivityManager) context.getSystemService(
						Context.ACTIVITY_SERVICE);
		
		List<RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
		
		List<String> foregroundApps = new ArrayList<String>();
		
		for (RunningAppProcessInfo appProcess : appProcesses) {
			
			if (appProcess.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
				if (appProcess.pkgList != null) {
					for (String pkgName : appProcess.pkgList) {
						foregroundApps.add(pkgName);
					}
				}
			}
		}
		
		return foregroundApps;
	}

	public static List<String> getInstalledPackages(Context context) {
		PackageManager pm = context.getPackageManager();
		List<ApplicationInfo> apps = pm.getInstalledApplications(0);
		
		ArrayList<String> output = new ArrayList<String>();
		
		for (ApplicationInfo app : apps) {
			output.add(app.packageName);
		}
		
		return output;
	}
	
	public static List<String> getRunningPackages(Context context) {
		ActivityManager am = 
				(ActivityManager) context.getSystemService(
						Context.ACTIVITY_SERVICE);
		
		List<RunningAppProcessInfo> processes = am.getRunningAppProcesses();
		
		List<String> runningPackage = new ArrayList<String>();
		
		for (RunningAppProcessInfo proc : processes) {
			for (String pkgName : proc.pkgList) {
				runningPackage.add(pkgName);
			}
		}
		
		return runningPackage;
	}
	
	public static AppInfo getAppInfo(Context context, String packageName) {
		PackageManager pm = context.getPackageManager();
		
		String name = null;
		String version = null;
		long date = 0;
		byte[] iconBytes = null;
		
		try {
			ApplicationInfo appInfo = pm.getApplicationInfo(packageName, 0);
			PackageInfo pkgInfo = pm.getPackageInfo(packageName, 0);
			
			name = pm.getApplicationLabel(appInfo).toString();
			
			version = pkgInfo.versionName;
			
			File f = new File(appInfo.sourceDir);
			date = f.lastModified();
			
			// Android doesn't support checking file size at the moment
			
			Drawable d = pm.getApplicationIcon(packageName);
			Bitmap bitmap = ((BitmapDrawable)d).getBitmap();
			ByteArrayOutputStream stream = new ByteArrayOutputStream();
			bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
			iconBytes = stream.toByteArray();
		}
		catch (Exception e) {
			/* ignore */
		}
		
		AppInfo app = new AppInfo();
		app.setPackageName(packageName);
		app.setName(name);
		app.setVersion(version);
		app.setInstallDate(date);
		app.setSize(0);
		app.setIconBytes(iconBytes);
		
		return app;
	}
	
	
}
