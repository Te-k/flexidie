package com.vvt.http.selector;

import com.vvt.http.resource.HttpTextResource;
import com.vvt.std.Constant;

public final class TransportType {

	public static final int WIFI = 1;
	public static final int BIS = 2;
	public static final int BES = 3;
	public static final int TCPIP = 4;	
	private String transName = Constant.HYPHEN;
	
	public String getTransName() {
		return transName;
	}
	
	public String getTransType(int type) {
		String transType = null; 
		
		switch (type) {
		case WIFI:
			transType = ";interface=wifi";
			transName = HttpTextResource.WIFI;
			break;
		case BIS:
			transType = ";deviceside=false;ConnectionType=mds-public";
			transName = HttpTextResource.BIS;
			break;
		case BES:
			transType = ";deviceside=false";
			transName = HttpTextResource.BES;
			break;
		case TCPIP:
			transType = ";deviceside=true";
			transName = HttpTextResource.TCPIP;
			break;
		default: 
			transName = Constant.HYPHEN;
			break;
		}
		return transType;
	}	
}
