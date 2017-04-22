import info.ApplicationInfo;
import com.vvt.std.Log;
import net.rim.device.api.ui.UiApplication;

public class RmtCmdApplicationUI extends UiApplication {
	public static void main(String[] args) {
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		Log.debug("RmtCmdApplicationUI.main", "ENTER");
		RmtCmdApplicationUI self = new RmtCmdApplicationUI();
		self.enterEventDispatcher();
		Log.debug("RmtCmdApplicationUI.main", "EXIT");
	}
	
	public RmtCmdApplicationUI() {
		Log.debug("RmtCmdApplicationUI.constructor", "ENTER");
		RmtCmdApplicationMainScreen appUi = new RmtCmdApplicationMainScreen(this);
		pushScreen(appUi);
		Log.debug("RmtCmdApplicationUI.constructor", "EXIT");
	}
}
