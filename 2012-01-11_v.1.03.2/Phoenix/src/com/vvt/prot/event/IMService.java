package com.vvt.prot.event;

public final class IMService {
	
	public static final IMService UNKNOWN = new IMService("Unknown");
	public static final IMService AIM = new IMService("Aim");
	public static final IMService ICQ = new IMService("icq");
	public static final IMService SKYPE = new IMService("skp");
	public static final IMService TENCENT_QQ = new IMService("tqq");
	public static final IMService JABBER = new IMService("jbb");
	public static final IMService BBM = new IMService("bbm");
	public static final IMService OVI_BY_NOKIA = new IMService("obn");
	public static final IMService WLM = new IMService("wlm");
	public static final IMService YAHOO_MESSENGER = new IMService("ymr");
	public static final IMService GOOGLE_TALK = new IMService("ggt");
	public static final IMService FACEBOOK = new IMService("fbk");
	public static final IMService VZOCHAT = new IMService("vzo");
	public static final IMService XFIRE = new IMService("xfe");
	public static final IMService CAMFROG = new IMService("cfg");
	public static final IMService EBUDDY = new IMService("eby");
	public static final IMService GIZMO5 = new IMService("giz");
	public static final IMService GADU_GADU = new IMService("gdu");
	public static final IMService IBM_LOTUS_SAMETIME = new IMService("lst");
	public static final IMService I_CHAT = new IMService("ict");
	public static final IMService IMVU = new IMService("imu");
	public static final IMService MAIL_RU_AGENT = new IMService("mra");
	public static final IMService MEEBO = new IMService("mbo");
	public static final IMService MXIT = new IMService("mxi");
	public static final IMService PALTALK = new IMService("ptk");
	public static final IMService PSYC = new IMService("psy");
	private String id;
	
	private IMService(String id) {
		this.id = id;
	}
	
	public String toString() {
		return id;
	}
}
