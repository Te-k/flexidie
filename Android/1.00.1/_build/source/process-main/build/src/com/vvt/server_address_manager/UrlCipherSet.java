package com.vvt.server_address_manager;

import java.io.Serializable;

public class UrlCipherSet implements Serializable {
	private static final long serialVersionUID = 1L;
	
	public byte[] structuredServerUrl;
	public byte[] unstructuredServerUrl;
	public byte[] baseServerUrl;
}
