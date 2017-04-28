package com.vvt.phoenix.prot;

import com.vvt.phoenix.prot.command.response.ResponseData;

public interface CommandListener {
	
	//fields for AsyncCallback approach
	public static final int ON_CONSTRUCT_ERROR = 1;
	public static final int ON_TRANSPORT_ERROR = 2;
	public static final int ON_SERVER_ERROR = 3;
	public static final int ON_SUCCESS = 4;

	public void onConstructError(long csid, Exception e);
	public void onTransportError(long csid, Exception e);
	public void onSuccess(ResponseData response);
	public void onServerError(ResponseData response);
	
}
