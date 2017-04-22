package com.vvt.remotecommandmanager.exceptions;

public class NotSmsCommandException extends RemoteCommandException{

	private static final long serialVersionUID = 1L;

	@Override
	public int getErrorCode() {
		return -300;
	}

}
