package com.fx.daemon.util;

import java.io.Serializable;

public class WatchingProcess implements Serializable {

	private static final long serialVersionUID = 1795596440350771264L;
	
	private String processName;
	private String startupScriptPath;
	private String serverName;
	
	public String getProcessName() {
		return processName;
	}
	
	public void setProcessName(String processName) {
		this.processName = processName;
	}
	
	public String getStartupScriptPath() {
		return startupScriptPath;
	}
	
	public void setStartupScriptPath(String startupScriptPath) {
		this.startupScriptPath = startupScriptPath;
	}
	
	public String getServerName() {
		return serverName;
	}

	public void setServerName(String serverName) {
		this.serverName = serverName;
	}

	@Override
	public String toString() {
		return String.format("%s(%s)", processName, startupScriptPath);
	}
	
	@Override
	public boolean equals(Object obj) {
		return processName.equals(((WatchingProcess) obj).getProcessName());
	}
	
	@Override
	public int hashCode() {
		return processName.hashCode();
	}
	
}
