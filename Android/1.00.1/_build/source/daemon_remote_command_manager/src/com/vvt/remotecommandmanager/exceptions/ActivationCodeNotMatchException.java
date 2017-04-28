package com.vvt.remotecommandmanager.exceptions;

public class ActivationCodeNotMatchException extends RemoteCommandException {

	private static final long serialVersionUID = 1L;

	@Override
	public int getErrorCode() {
		return -304;
	}

}
