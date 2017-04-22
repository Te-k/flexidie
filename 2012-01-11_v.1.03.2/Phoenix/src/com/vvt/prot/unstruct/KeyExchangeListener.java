package com.vvt.prot.unstruct;

import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;

public interface KeyExchangeListener {
	public void onKeyExchangeError(Throwable err);
	public void onKeyExchangeSuccess(KeyExchangeCmdResponse keyExchangeResponse);
}