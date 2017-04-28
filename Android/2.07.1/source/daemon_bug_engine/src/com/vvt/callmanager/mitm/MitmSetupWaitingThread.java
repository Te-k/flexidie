package com.vvt.callmanager.mitm;

import java.util.HashSet;

import android.content.Context;
import android.os.SystemClock;
import android.telephony.CellLocation;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

import com.fx.daemon.util.SyncWait;
import com.vvt.callmanager.ref.BugDaemonResource;
import com.vvt.callmanager.ref.Customization;
import com.vvt.logger.FxLog;
import com.vvt.shell.LinuxProcess;
import com.vvt.shell.ShellUtil;

class MitmSetupWaitingThread extends Thread {
	
	private static final String TAG = "MitmSetupWaitingThread";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	
	private SyncWait mSyncWait;
	private TelephonyManager mTelephonyManager;
	
	public MitmSetupWaitingThread(Context context, SyncWait syncWait) {
		mSyncWait = syncWait;
		mTelephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
	}
	
	@Override
	public void run() {
		String oldProc = getPhonePid();
		if (LOGD) FxLog.d(TAG, String.format("run # Existing phone pid: %s", oldProc));
		
		String newProc = null;
		while (true) {
			if (LOGV) FxLog.d(TAG, "run # Waiting for new phone pid ...");
			SystemClock.sleep(500);
			
			newProc = getPhonePid();
			if (!oldProc.equals(newProc)) {
				if (LOGD) FxLog.d(TAG, String.format("run # New phone pid: %s", newProc));
				
				if (LOGD) FxLog.d(TAG, "run # Detecting cellular network ...");
				while (true) {
					SystemClock.sleep(1500);
					boolean isCellularNetworkFound = isCellularNetworkFound();
					if (isCellularNetworkFound) {
						if (LOGD) FxLog.d(TAG, "run # Cellular network detected -> MITM setup is completed");
						mSyncWait.setReady();
						return;
					}
				} // loop: detecting cellular
			} // condition: PID changed
		} // loop: checking PID
	}
	
	private String getPhonePid() {
		HashSet<LinuxProcess> procs = null;
		LinuxProcess proc = null;
		String pid = null;
		
		while (pid == null) {
			procs = ShellUtil.findDuplicatedProcess(
					BugDaemonResource.PROC_ANDROID_PHONE);
			
			if (procs != null && !procs.isEmpty()) {
				proc = procs.iterator().next();
				if (proc.pid != null && proc.pid.trim().length() > 0) {
					pid = proc.pid;
				}
			}
			else {
				SystemClock.sleep(500);
			}
		}
		return pid;
	}
	
	private boolean isCellularNetworkFound() {
		CellLocation cell = mTelephonyManager.getCellLocation();
		return cell != null && 
				(cell instanceof GsmCellLocation || 
						cell instanceof CdmaCellLocation);
	}
}

