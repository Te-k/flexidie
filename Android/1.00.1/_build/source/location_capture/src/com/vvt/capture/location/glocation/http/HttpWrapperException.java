package com.vvt.capture.location.glocation.http;

public class HttpWrapperException extends Exception {

	// -------------------------------------------------------------------------------------------------
	// PRIVATE API
	// -------------------------------------------------------------------------------------------------

	/**
	 * Default serialVersionUID for eclipse.
	 */
	private static final long serialVersionUID = 1L;

	private int httpStatusCode = 0;

	// -------------------------------------------------------------------------------------------------
	// PUBLIC API
	// -------------------------------------------------------------------------------------------------

	public HttpWrapperException() {
		super();
	}

	public HttpWrapperException(String aMessage) {
		super(aMessage);
	}

	public HttpWrapperException(Throwable e) {
		super(e);
	}

	public int getHttpStatusCode() {
		return httpStatusCode;
	}

	public void setHttpStatusCode(int aHttpStatusCode) {
		httpStatusCode = aHttpStatusCode;
	}

}
