package com.vvt.rmtcmd;


public class SetPanicModeCmdLine extends RmtCmdLine {

	private int mode = 0;
	
	public void setPanicMode(int mode) {
		this.mode = mode;
	}
	
	public int getPanicMode() {
		return mode;
	}
}
