package com.vvt.remotecommandmanager.exceptions;


public abstract class RemoteCommandException extends Exception {

	private static final long serialVersionUID = 1L;

	public abstract int getErrorCode();

}
