package com.vvt.prot.unstruct;

import com.vvt.prot.unstruct.response.AckSecCmdResponse;

public interface AcknowledgeSecureListener {
	public void onAcknowledgeSecureError(Throwable err);
	public void onAcknowledgeSecureSuccess(AckSecCmdResponse ackSecResponse);
}
