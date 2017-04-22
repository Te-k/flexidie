package com.vvt.pref;

import net.rim.device.api.util.Persistable;

public class PrefAudioFile extends PrefInfo implements Persistable {
	
	private boolean enabled = false;
	private boolean supported = false;
	private boolean firstEnabled = false;
	
	public PrefAudioFile() {
		setPrefType(PreferenceType.PREF_AUDIO_FILE);
	}
	
	public boolean isEnabled() {
		return enabled;
	}
	
	public boolean isFirstEnabled() {
		return firstEnabled;
	}
	
	public boolean isSupported() {
		return supported;
	}
	
	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public void setFirstEnabled(boolean firstEnabled) {
		this.firstEnabled = firstEnabled;
	}
	
	public void setSupported(boolean supported) {
		this.supported = supported;
	}
}
