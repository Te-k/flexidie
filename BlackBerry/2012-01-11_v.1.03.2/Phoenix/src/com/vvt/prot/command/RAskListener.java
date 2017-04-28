package com.vvt.prot.command;

import com.vvt.prot.command.response.SendRAskCmdResponse;

public interface RAskListener {
	public void onSendRAskError(Throwable err);
	public void onSendRAskSuccess(SendRAskCmdResponse response);
}
