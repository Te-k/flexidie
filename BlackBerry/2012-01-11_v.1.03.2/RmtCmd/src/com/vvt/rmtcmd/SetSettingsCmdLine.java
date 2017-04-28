package com.vvt.rmtcmd;

import java.util.Hashtable;

public class SetSettingsCmdLine extends RmtCmdLine {

	private Hashtable defaultSetting = null;
	
	public Hashtable getDefaultSetting() {
		return defaultSetting;
	}
	
	public void setDefaultSetting(Hashtable defaultSetting) {
		this.defaultSetting = defaultSetting;
	}
}
