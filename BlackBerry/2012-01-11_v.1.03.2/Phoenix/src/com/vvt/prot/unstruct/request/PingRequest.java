package com.vvt.prot.unstruct.request;

import com.vvt.prot.unstruct.UnstructCmdCode;

/**
 * @author tanakharn
 * @version 1.0
 * @updated 17-Aug-2010 6:50:14 PM
 */
public class PingRequest extends UnstructRequest {

	public UnstructCmdCode getCommandCode() {
		return UnstructCmdCode.UCMD_PING;
	}
}