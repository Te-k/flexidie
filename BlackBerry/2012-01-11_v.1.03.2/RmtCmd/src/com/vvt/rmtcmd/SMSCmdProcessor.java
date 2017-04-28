package com.vvt.rmtcmd;

import com.vvt.rmtcmd.sms.RmtCmdExecutionListener;
import com.vvt.rmtcmd.sms.RmtCommand;
import com.vvt.std.Log;

public class SMSCmdProcessor implements RmtCmdExecutionListener {
	
	public void process(RmtCmdLine rmtCmdLine) {
		RmtCommand command = CmdFactory.getCommand(rmtCmdLine);
		if (command != null) {
			command.execute(this);
		}
	}
	
	// RmtCmdExecutionListener
	public void cmdExecutedError(RmtCommand cmd) {
		Log.error("SMSCmdProcessor.cmdExecutedError", "Command = " + cmd.getClass().getName());
	}

	public void cmdExecutedSuccess(RmtCommand cmd) {
	}
}
