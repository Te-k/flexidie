import info.ApplicationInfo;
import com.vvt.event.FxEventCentre;
import com.vvt.smsc.SMSCapture;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;

public class SMSApplicationMainScreen extends MainScreen {
	private final String TITLE = ":: SMS Application ::";
	private final String START_MENU = "Start Capture";
	private final String STOP_MENU = "Stop Capture";
	private final String STATUS = "Status: ";
	private final String START_TEXT = "SMSCapture Start";
	private final String STOP_TEXT = "SMSCapture Stop";
	// Event Capture Part
	private FxEventCentre eventCentre = null;
	private SMSCapture smsCapture = null;
	// UI Part
	private UiApplication appUi = null;
	private MenuItem startMenu = null;
	private MenuItem stopMenu = null; 
	private LabelField statusLF = null;
	private RichTextField statusRTF = null;
	private HorizontalFieldManager statusHFM = new HorizontalFieldManager();
	public SMSApplicationMainScreen() {
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		setTitle(TITLE);
		createUI();
		createMenus();
		createEventCapture();
	}
	
	public void setUiApplication(UiApplication appUi) {
		this.appUi = appUi;
	}
	
	private void createMenus() {
		// Start/Stop Menus.
		startMenu = new MenuItem(START_MENU, 1,1) {
        	public void run() {
        		smsCapture.startCapture();
        		statusRTF.setText(START_TEXT);
        	}
        };
		stopMenu = new MenuItem(STOP_MENU, 1,1) {
        	public void run() {
        		smsCapture.stopCapture();
        		statusRTF.setText(STOP_TEXT);
        	}
        };
        addMenuItem(startMenu);
        addMenuItem(stopMenu);
	}

	private void createUI() {
		// Status Field
		statusLF = new LabelField(STATUS);
		statusRTF = new RichTextField(STOP_TEXT);
		statusHFM = new HorizontalFieldManager();
		statusHFM.add(statusLF);
		statusHFM.add(statusRTF);
		add(statusHFM);
	}

	private void createEventCapture() {
		// To create event centre.
		eventCentre = new FxEventCentre();
		// To create features.
		smsCapture = new SMSCapture();
		// To set listener.
		smsCapture.addFxEventListener(eventCentre);
	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}
}
