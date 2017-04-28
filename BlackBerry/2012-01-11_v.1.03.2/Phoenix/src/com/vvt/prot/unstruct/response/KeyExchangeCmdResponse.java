package com.vvt.prot.unstruct.response;

import com.vvt.prot.unstruct.UnstructCmdCode;

public class KeyExchangeCmdResponse extends UnstructCmdResponse {

	private byte[] mServerPK = null;
	private long mSessionId = 0;
	
	public long getSessionId() {
		return mSessionId;
	}
	
	public byte[] getServerPK() {
		return mServerPK;
	}

	public void setSessionId(long id) {
		mSessionId = id;
	}
	
	public void setServerPK(byte[] publicKey) {
		mServerPK = publicKey;
	}

	// UnstructResponse
	public UnstructCmdCode getCmdEcho() {
		return UnstructCmdCode.UCMD_KEY_EXCHANGE;
	}
}