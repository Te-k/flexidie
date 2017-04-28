package com.vvt.protsrv;

import com.vvt.prot.CommandResponse;

public interface ActualMediaListener {
	public void onActualMediaSuccess(CommandResponse response, long paringId);
	public void onActualMediaError(String message, long paringId);
}
