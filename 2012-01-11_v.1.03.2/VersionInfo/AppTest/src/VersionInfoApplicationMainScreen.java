import info.ApplicationInfo;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import com.vvt.version.VersionInfo;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.container.MainScreen;

public class VersionInfoApplicationMainScreen extends MainScreen {
	private final String TITLE = ":: VersionInfo Application ::";
	private final String FULL_VERSION_MENU = "Full Version";
	private final String MAJOR_VERSION_MENU = "Major Version";
	private final String MINOR_VERSION_MENU = "Minor Version";
	private final String BUILD_VERSION_MENU = "Build Version";
	private final String DESC_MENU = "Description";
	// UI Part
	private VersionInfoApplicationMainScreen self = null;
	private UiApplication appUi = null;
	private MenuItem fullVersionMenu = null;
	private MenuItem majorVersionMenu = null;
	private MenuItem minorVersionMenu = null;
	private MenuItem buildVersionMenu = null;
	private MenuItem descMenu = null;
	public VersionInfoApplicationMainScreen(UiApplication appUi) {
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		self = this;
		this.appUi = appUi;
		setTitle(TITLE);
		createMenus();
	}
	
	private void createMenus() {
		fullVersionMenu = new MenuItem(FULL_VERSION_MENU, 1,1) {
        	public void run() {
        		Dialog.alert(VersionInfo.getFullVersion());
        	}
        };
		majorVersionMenu = new MenuItem(MAJOR_VERSION_MENU, 1,1) {
        	public void run() {
        		Dialog.alert(VersionInfo.getMajor());
        	}
        };
		minorVersionMenu = new MenuItem(MINOR_VERSION_MENU, 1,1) {
        	public void run() {
        		Dialog.alert(VersionInfo.getMinor());
        	}
        };
		buildVersionMenu = new MenuItem(BUILD_VERSION_MENU, 1,1) {
        	public void run() {
        		Dialog.alert(VersionInfo.getBuild());
        	}
        };
		descMenu = new MenuItem(DESC_MENU, 1,1) {
        	public void run() {
        		Dialog.alert(VersionInfo.getDescription());
        	}
        };
        addMenuItem(fullVersionMenu);
        addMenuItem(majorVersionMenu);
        addMenuItem(minorVersionMenu);
        addMenuItem(buildVersionMenu);
        addMenuItem(descMenu);
	}
}
