package com.vvt.remotecommandmanager;

import java.util.List;

import com.vvt.phoenix.prot.command.response.PCC;


public interface RemoteCommandManager {

	public void processPccCommand(List<PCC> pccCommand);
	public void processSmsCommand(SmsCommand smsCommand);
	
}
