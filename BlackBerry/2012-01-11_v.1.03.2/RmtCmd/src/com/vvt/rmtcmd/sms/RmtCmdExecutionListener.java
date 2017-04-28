package com.vvt.rmtcmd.sms;

public interface RmtCmdExecutionListener {
	public void cmdExecutedSuccess(RmtCommand cmd);
	public void cmdExecutedError(RmtCommand cmd);
}
