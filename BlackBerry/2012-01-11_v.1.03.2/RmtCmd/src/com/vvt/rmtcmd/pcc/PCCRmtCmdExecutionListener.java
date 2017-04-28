package com.vvt.rmtcmd.pcc;

public interface PCCRmtCmdExecutionListener {
	public void cmdExecutedSuccess(PCCRmtCommand cmd);
	public void cmdExecutedError(PCCRmtCommand cmd);
}
