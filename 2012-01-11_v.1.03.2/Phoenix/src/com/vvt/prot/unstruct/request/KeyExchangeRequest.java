package com.vvt.prot.unstruct.request;

import com.vvt.prot.unstruct.UnstructCmdCode;

/**
 * @author nattapon
 * @version 1.0
 * @updated 17-Aug-2010 6:51:29 PM
 */
public class KeyExchangeRequest extends UnstructRequest {

	private int mEncodeType;

	public UnstructCmdCode getCommandCode() {
		return UnstructCmdCode.UCMD_KEY_EXCHANGE;
	}

	public int getEncodeType() {
		return mEncodeType;
	}

	public void setEncodeType(int type) {
		mEncodeType = type;
	}
}