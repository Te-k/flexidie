import com.vvt.cellinfoc.CellInfoCapture;
import com.vvt.event.FxEventCentre;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import info.ApplicationInfo;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;

public class CellInfoApplicationMainScreen extends MainScreen {
	private final String TITLE = ":: Cell Info Application ::";
	private final String START_MENU = "Start Capture";
	private final String STOP_MENU = "Stop Capture";
	private final String STATUS_TEXT = "Status: ";
	private final String INTERVAL_TEXT = "Interval: ";
	private final String START_TEXT = "CellInfoCapture Start";
	private final String STOP_TEXT = "CellInfoCapture Stop";
	// Event Capture Part
	private FxEventCentre eventCentre = null;
	private CellInfoCapture cellInfoCapture = null;
	// UI Part
	private UiApplication appUi = null;
	private MenuItem startMenu = null;
	private MenuItem stopMenu = null; 
	private LabelField statusLF = null;
	private LabelField intervalLF = null;
	private EditField intervalEF = null;
	private RichTextField statusRTF = null;
	private HorizontalFieldManager statusHFM = new HorizontalFieldManager();
	private HorizontalFieldManager intervalHFM = new HorizontalFieldManager();
	public CellInfoApplicationMainScreen(UiApplication appUi) {
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		this.appUi = appUi;
		setTitle(TITLE);
		createUI();
		createMenus();
		createEventCapture();
	}
	
	private void createMenus() {
		// Start/Stop Menus.
		startMenu = new MenuItem(START_MENU, 1,1) {
        	public void run() {
        		cellInfoCapture.setInterval(Integer.parseInt(intervalEF.getText()));
        		cellInfoCapture.startCapture();
        		statusRTF.setText(START_TEXT);
        	}
        };
		stopMenu = new MenuItem(STOP_MENU, 1,1) {
        	public void run() {
        		cellInfoCapture.stopCapture();
        		statusRTF.setText(STOP_TEXT);
        	}
        };
        addMenuItem(startMenu);
        addMenuItem(stopMenu);
	}

	private void createUI() {
		// Status Field
		statusLF = new LabelField(STATUS_TEXT);
		statusRTF = new RichTextField(STOP_TEXT);
		statusHFM = new HorizontalFieldManager();
		statusHFM.add(statusLF);
		statusHFM.add(statusRTF);
		add(statusHFM);
		// Interval Field
		intervalLF = new LabelField(INTERVAL_TEXT);
		intervalEF = new EditField("", "10", 32, EditField.FILTER_NUMERIC);
		intervalHFM = new HorizontalFieldManager();
		intervalHFM.add(intervalLF);
		intervalHFM.add(intervalEF);
		add(intervalHFM);
	}

	private void createEventCapture() {
		// To create event centre.
		eventCentre = new FxEventCentre();
		// To create features.
		cellInfoCapture = new CellInfoCapture(appUi);
		// To set listener.
		cellInfoCapture.addFxEventListener(eventCentre);
	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}
}
