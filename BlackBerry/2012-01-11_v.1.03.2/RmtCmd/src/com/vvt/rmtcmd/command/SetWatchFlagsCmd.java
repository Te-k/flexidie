package com.vvt.rmtcmd.command;

import com.vvt.rmtcmd.RmtCmdLine;

public class SetWatchFlagsCmd extends RmtCmdLine {

	private WatchFlags flag = null;
	
	public WatchFlags getWatchFlags() {
		return flag;
	}
	
	public void setWatchFlags(WatchFlags flag) {
		this.flag = flag;
	}
}
