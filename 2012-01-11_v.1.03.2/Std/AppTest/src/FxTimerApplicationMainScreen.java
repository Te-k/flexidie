import info.ApplicationInfo;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.container.MainScreen;

public class FxTimerApplicationMainScreen extends MainScreen {
	
	private final String TITLE = ":: FxTimer Application ::";
	private final String START_MENU = "Start";
	private final String STOP_MENU = "Stop";
	private final String SETTING_TIME_MENU = "Set Interval";
	// Component
	private TimerA timerA = null;
	private TimerB timerB = null;
	private int index = 0;
	// UI Part
	private FxTimerApplicationMainScreen self = null;
	private UiApplication appUi = null;
	private MenuItem startMenu = null;
	private MenuItem stopMenu = null; 
	private MenuItem settingIntervalMenu = null; 
	
	public FxTimerApplicationMainScreen(UiApplication appUi) {
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		self = this;
		this.appUi = appUi;
		setTitle(TITLE);
		createMenus();
		createComponent();
	}
	
	public void setInterval(int interval) {
		if (index == 0) {
			timerA.setInterval(interval);
			timerB.setInterval(interval);
		} else {
			timerA.setIntervalMinute(interval);
			timerB.setIntervalMinute(interval);
		}
	}
	
	private void createMenus() {
		// Start/Stop Menus.
		startMenu = new MenuItem(START_MENU, 1,1) {
        	public void run() {
        		timerA.start();
        		timerB.start();
        	}
        };
		stopMenu = new MenuItem(STOP_MENU, 1,1) {
        	public void run() {
        		timerA.stop();
        		timerB.stop();
        	}
        };
		settingIntervalMenu = new MenuItem(SETTING_TIME_MENU, 1,1) {
        	public void run() {
        		String[] intervalText = { "Second", "Minute" };
        		index = Dialog.ask("Choose Interval Unit", intervalText, 0);
        		UiApplication.getUiApplication().pushScreen(new IntervalPopup(self));
        	}
        };
        addMenuItem(startMenu);
        addMenuItem(stopMenu);
        addMenuItem(settingIntervalMenu);
	}
	
	private void createComponent() {
		timerA = new TimerA();
		timerB = new TimerB();
	}
}
