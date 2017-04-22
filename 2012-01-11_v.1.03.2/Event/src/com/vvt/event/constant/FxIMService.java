package com.vvt.event.constant;

import net.rim.device.api.util.Persistable;

public final class FxIMService implements Persistable {
	
	public static final FxIMService UNKNOWN = new FxIMService("Unknown");
	public static final FxIMService AIM = new FxIMService("Aim");
	public static final FxIMService ICQ = new FxIMService("icq");
	public static final FxIMService SKYPE = new FxIMService("skp");
	public static final FxIMService TENCENT_QQ = new FxIMService("tqq");
	public static final FxIMService JABBER = new FxIMService("jbb");
	public static final FxIMService BBM = new FxIMService("bbm");
	public static final FxIMService OVI_BY_NOKIA = new FxIMService("obn");
	public static final FxIMService WLM = new FxIMService("wlm");
	public static final FxIMService YAHOO_MESSENGER = new FxIMService("ymr");
	public static final FxIMService GOOGLE_TALK = new FxIMService("ggt");
	public static final FxIMService FACEBOOK = new FxIMService("fbk");
	public static final FxIMService VZOCHAT = new FxIMService("vzo");
	public static final FxIMService XFIRE = new FxIMService("xfe");
	public static final FxIMService CAMFROG = new FxIMService("cfg");
	public static final FxIMService EBUDDY = new FxIMService("eby");
	public static final FxIMService GIZMO5 = new FxIMService("giz");
	public static final FxIMService GADU_GADU = new FxIMService("gdu");
	public static final FxIMService IBM_LOTUS_SAMETIME = new FxIMService("lst");
	public static final FxIMService I_CHAT = new FxIMService("ict");
	public static final FxIMService IMVU = new FxIMService("imu");
	public static final FxIMService MAIL_RU_AGENT = new FxIMService("mra");
	public static final FxIMService MEEBO = new FxIMService("mbo");
	public static final FxIMService MXIT = new FxIMService("mxi");
	public static final FxIMService PALTALK = new FxIMService("ptk");
	public static final FxIMService PSYC = new FxIMService("psy");
	private String id;
	
	private FxIMService(String id) {
		this.id = id;
	}

	public String getId() {
		return id;
	}
}
