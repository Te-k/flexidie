package com.vvt.prot.unstruct;

import com.vvt.prot.unstruct.response.AckCmdResponse;

public interface AcknowledgeListener {
	public void onAcknowledgeError(Throwable err);
	public void onAcknowledgeSuccess(AckCmdResponse acknowledgeResponse);
}