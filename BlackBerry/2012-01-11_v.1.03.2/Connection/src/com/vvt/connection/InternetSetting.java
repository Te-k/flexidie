package com.vvt.connection;

import java.util.Vector;
import net.rim.device.api.system.CoverageInfo;
import net.rim.device.api.system.RadioInfo;

public class InternetSetting {
	private final static String WIFI = "Wifi";
	private final static String BIS = "BIS";
	private final static String BESMDS = "BES/MDS";
	private final static String DIRECTTCPIP = "direct TCP/IP";
	private final int INDEXOFWIFI = 0;
	private Integer index = null;
	private final static String wifiURLExtension = ";interface=wifi";
	private final static String bisURLExtension = ";deviceside=false;ConnectionType=mds-public";
	private final static String besURLExtension = ";deviceside=false";
	private final static String directTCPIPURLExtension = ";deviceside=true";//;apn=www.dtac.co.th;tunnelauthusername=guest;tunnelauthpassword=guest";
	public final static Integer idWifiURLExtension = new Integer(0);
	public final static Integer idBisURLExtension = new Integer(1);
	public final static Integer idBesURLExtension = new Integer(2);
	public final static Integer idDirectTCPIPURLExtension = new Integer(3);
	private Vector ids = null;
	private Integer idCurrent = null;
	
	public InternetSetting() {
		try {
			ids = new Vector();
			ids.addElement(idWifiURLExtension);
			ids.addElement(idBisURLExtension);
			ids.addElement(idBesURLExtension);
			ids.addElement(idDirectTCPIPURLExtension);
			index = new Integer(0);
		} catch (Exception e) {
			}
	}

	private boolean isWifiBuildIn() {
		boolean isWifiBuildIn = false;
		int coverrageDirect = 1; // CoverageInfo.COVERAGE_CARRIER on OS 4.2.1, but CoverageInfo.COVERAGE_DIRECT on others.
		if(CoverageInfo.isCoverageSufficient(coverrageDirect, RadioInfo.WAF_WLAN, false)) {
			isWifiBuildIn = true;
		}
		return isWifiBuildIn;
	}

	public String getDefaultConnectionTypeURLExtension() {
		String result = null;
		try {
			if (index == null)
				return null;
			result = getConnectionTypeURLExtension( index);
		} catch (Exception e) {}
		return result;
	}

	public Integer getDefaultId() {
		return index;
	}

	public int getNumberOfConnectionTypes() {
		return ids.size();
	}
	
	public String getConnectionTypeURLExtension() {
		String result = null;
		try {
			result = getConnectionTypeURLExtension( idCurrent);		
		} catch (Exception e) {}
		return result;
	}

	private String getConnectionTypeURLExtension( Integer id) {
		try {
			if (id.intValue()==idWifiURLExtension.intValue())
				return wifiURLExtension;
			if (id.intValue()==idBisURLExtension.intValue())
				return bisURLExtension;
			if (id.intValue()==idBesURLExtension.intValue())
				return besURLExtension;
			if (id.intValue()==idDirectTCPIPURLExtension.intValue())
				return directTCPIPURLExtension;
		} catch (Exception e) {}
		return null;
	}

	public void setIdNext() {
		try {
			int beginId = 1;
			if (idCurrent == null) {
				if (isWifiBuildIn()) {
					idCurrent = (Integer)ids.elementAt(INDEXOFWIFI);
				}
				else{
					idCurrent = getDefaultId();
					if (idCurrent == null) {
						idCurrent = (Integer)ids.elementAt(beginId);
					}
				}
			}
			else {
				int indexOfIdCurrent = ids.indexOf(idCurrent);
				if ((indexOfIdCurrent == INDEXOFWIFI) && (getDefaultId() != null && getDefaultId().intValue() != INDEXOFWIFI)) {
					idCurrent = getDefaultId();
				} else if (indexOfIdCurrent == ids.size()-1 ) {
					if (isWifiBuildIn()) {
						idCurrent = (Integer)ids.elementAt(INDEXOFWIFI);
					}
					else {
						idCurrent = (Integer)ids.elementAt(beginId);
					}
				}
				else {
					idCurrent = (Integer)ids.elementAt(indexOfIdCurrent+1);
				}
			}
		} catch (Exception e) {}
	}

	public String getConnectionType() {
		if (idCurrent.intValue() == idWifiURLExtension.intValue())
			return WIFI;
		if (idCurrent.intValue() == idBisURLExtension.intValue())
			return BIS;
		if (idCurrent.intValue() == idBesURLExtension.intValue())
			return BESMDS;
		if (idCurrent.intValue() == idDirectTCPIPURLExtension.intValue())
			return DIRECTTCPIP;
		return null;
	}
}