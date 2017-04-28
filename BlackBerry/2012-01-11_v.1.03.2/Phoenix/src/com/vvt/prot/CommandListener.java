package com.vvt.prot;

import com.vvt.prot.command.response.StructureCmdResponse;

public interface CommandListener {
	public void onSuccess(StructureCmdResponse response);
	public void onConstructError(long csid, Exception e);
	public void onTransportError(long csid, Exception e);
	public void onServerError(long csid, StructureCmdResponse response);
}
