package com.vvt.prot.session;

import net.rim.device.api.util.Persistable;
import com.vvt.prot.command.Languages;

public class SessionInfo implements Persistable {
	
	private static  long csidCounter;
	private long 	csid;
	private long	sessionId		= 0;
	private byte[] 	aesKey			= null;
	private int 	protoVersion 	= 0;
	private int 	productId		= 0;
	private String 	productVersion	= null;
	private int 	confId			= 0;
	private String 	deviceId		= null;
	private String 	codeActivate	= null;
	private Languages langId		= Languages.ENGLISH;	// English
	private String 	phoneNumber		= null;
	private String 	mcc				= "0";
	private String 	mnc				= "0";
	private String 	imsi			= null;
	private int 	encpCode 		= 0;
	private int 	compCode		= 0;
	
	private byte[]	serverPublicKey	= null;
	private boolean	payloadReady	= false;
	private String	payloadPath		= null;
	
	private long	payloadSize		= 0L;
	private long	payloadCrc32	= 0L;
	private String	url				= null;
	private String 	baseServerUrl	= null;
	
	public SessionInfo()	{
		if (csidCounter < Integer.MAX_VALUE) {
			++csidCounter;
		}
		else {
			csidCounter 	= 1;
		}
		this.csid 			= csidCounter;
		this.payloadReady	= false;
	}
	
	public String toString()	{
		if (aesKey == null) aesKey = "null".getBytes();
		if (serverPublicKey == null) serverPublicKey = "nokey".getBytes();

		if (deviceId == null) deviceId = "NoDeviceId";
		if (codeActivate == null) codeActivate = "notActivate";
		if (phoneNumber == null) phoneNumber = "NoSIM";
		if (payloadPath == null) payloadPath = "NoPath";
		
		return "csid["+csid+"], ssid="+sessionId+"\r\n " +
				//encType="+ encryptType+",
				" aesKey="+new String(aesKey)+"\r\n "+
				"protVer="+productVersion+", prodId="+productId+"\r\n "+
				"prodVer="+productVersion+", confId="+confId+"\r\n "+
				"deviceId="+deviceId+", activeCode="+codeActivate+"\r\n "+
				"lang="+langId.getId()+", phoneNumber="+phoneNumber+"\r\n "+
				"mcc="+mcc+", mnc="+mnc+", imsi="+imsi+"\r\n "+
				"encCode="+encpCode+", compCode="+compCode+"\r\n "+
				"publicKey="+new String(serverPublicKey)+"\r\n "+
				"payloadPath="+payloadPath+"\r\n "+
				"payloadReady="+payloadReady+
				"\r\n";
	}
	
	public static void setCsidCounter(long num)	{
		csidCounter = num;
	}
	public static long getCsidCounter()	{
		return csidCounter;
	}
	
	public long getCsid()	{
		return csid;
	}
		
	public void setSessionId(long id)	{
		sessionId = id;
	}	
	public long getSessionId()	{
		return sessionId;
	}
	
	public void setAesKey(byte[] key)	{
		aesKey = key;
	}	
	public byte[] getAesKey()	{
		return aesKey;
	}

	public void setProtocolVersion(int num)	{
		protoVersion = num;
	}	
	public int getProtocolVersion()	{
		return protoVersion;
	}
	
	public void setProductId(int num)	{
		productId = num;
	}	
	public int getProductId()	{
		return productId;
	}
	
	public void setProductVersion(String str)	{
		productVersion = str;
	}
	public String getProductVersion()	{
		return productVersion;
	}
	
	public void setConfiguration(int Id) {
		confId = Id;
	}
	
	public int getConfiguration() {
		return confId;
	}
	
	
	public void setDeviceId(String str)	{
		deviceId = str;
	}
	public String getDeviceId()	{
		return deviceId;
	}	

	public void setActivationCode(String str)	{
		codeActivate = str;
	}
	public String getActivationCode()	{
		return codeActivate;
	}

	public void setLanguage(Languages lid)	{
		langId = lid;
	}
	public Languages getLanguage()	{
		return langId;
	}

	public void setPhoneNumber(String str)	{
		phoneNumber = str;
	}
	public String getPhoneNumber()	{
		return phoneNumber;
	}
	
	public void setMcc(String str)	{
		mcc = str;
	}
	public String getMcc()	{
		return mcc;
	}

	public void setMnc(String str)	{
		mnc = str;
	}
	public String getMnc()	{
		return mnc;
	}

	public void setImsi(String str)	{
		imsi = str;
	}
	public String getImsi()	{
		return imsi;
	}
	
	public void setEncryptionCode(int num)	{
		encpCode = num;
	}	
	public int getEncryptionCode()	{
		return encpCode;
	}
	
	public void setCompressionCode(int num)	{
		compCode = num;
	}	
	public int getCompressionCode()	{
		return compCode;
	}

	
	public void setServerPublicKey(byte [] key)	{
		serverPublicKey = key;
	}
	public byte [] getServerPublicKey()	{
		return serverPublicKey;
	}

	public void setPayloadReady(boolean flag)	{
		payloadReady = flag;
	}
	public boolean isPayloadReady()	{
		return payloadReady;
	}

	public void setPayloadPath(String path)	{
		payloadPath = path;
	}
	
	public String getPayloadPath()	{
		return payloadPath;
	}
	
	public void setPayloadSize(long size)	{
		payloadSize = size;
	}
	
	public long getPayloadSize()	{
		return payloadSize;
	}
	
	public void setPayloadCRC32(long checksum)	{
		payloadCrc32 = checksum;
	}
	
	public long getPayloadCRC32()	{
		return payloadCrc32;
	}
	
	public void setUrl(String serverUrl)	{
		url = serverUrl;
	}
	
	public String getUrl()	{
		return url;
	}
	
	public void setBaseServerUrl(String baseServerUrl) {
		this.baseServerUrl = baseServerUrl;
	}
	
	public String getBaseServerUrl() {
		return baseServerUrl;
	}
}
