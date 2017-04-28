package com.vvt.remotecommandmanager.exceptions;

public class InvalidActivationCodeException extends RemoteCommandException {

	private static final long serialVersionUID = 1L;

	@Override
	public int getErrorCode() {
		return -303;
	}

}
