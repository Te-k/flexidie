import com.vvt.event.FxEventCentre;
import com.vvt.event.constant.GPSProvider;
import com.vvt.gpsc.GPSCapture;
import com.vvt.gpsc.GPSMethod;
import com.vvt.gpsc.GPSOnDemand;
import com.vvt.gpsc.GPSOption;
import com.vvt.gpsc.GPSPriority;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import info.ApplicationInfo;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;

public class GPSApplicationMainScreen extends MainScreen {
	private final String TITLE = ":: GPS Application ::";
	private final String START_MENU = "Start Capture";
	private final String STOP_MENU = "Stop Capture";
	private final String ON_DEMAND_MENU = "GPS on Demand";
	private final String STATUS = "Status: ";
	private final String START_TEXT = "GPSCapture Start";
	private final String STOP_TEXT = "GPSCapture Stop";
	private final String ON_DEMAND_TEXT = "GPS on Demand Start!";
	// Event Capture Part
	private FxEventCentre eventCentre = null;
	private GPSCapture gpsCapture = null;
	private GPSOnDemand gpsOnDemand = null;
	// UI Part
	private UiApplication appUi = null;
	private MenuItem startMenu = null;
	private MenuItem stopMenu = null; 
	private MenuItem onDemandMenu = null; 
	private LabelField statusLF = null;
	private RichTextField statusRTF = null;
	private HorizontalFieldManager statusHFM = new HorizontalFieldManager();
	public GPSApplicationMainScreen(UiApplication appUi) {
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
        		gpsCapture.startCapture();
        		statusRTF.setText(START_TEXT);
        	}
        };
		stopMenu = new MenuItem(STOP_MENU, 1,1) {
        	public void run() {
        		gpsCapture.stopCapture();
        		statusRTF.setText(STOP_TEXT);
        	}
        };
		onDemandMenu = new MenuItem(ON_DEMAND_MENU, 1,1) {
        	public void run() {
        		gpsOnDemand.getGPSOnDemand();
        		statusRTF.setText(ON_DEMAND_TEXT);
        	}
        };
        addMenuItem(startMenu);
        addMenuItem(stopMenu);
        addMenuItem(onDemandMenu);
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
		gpsCapture = new GPSCapture();
		gpsOnDemand = new GPSOnDemand();
		// GPSOption 1
		GPSOption gpsOption = new GPSOption();
		gpsOption.setInterval(30);
		gpsOption.setTimeout(10);
		gpsCapture.setGPSOption(gpsOption);
		GPSMethod autonomous = new GPSMethod();
		GPSMethod assisted = new GPSMethod();
		GPSMethod cellsite = new GPSMethod();
		GPSMethod google = new GPSMethod();
		autonomous.setMethod(GPSProvider.GPS);
		autonomous.setPriority(GPSPriority.FIRST_PRIORITY);
		assisted.setMethod(GPSProvider.AGPS);
		assisted.setPriority(GPSPriority.SECOND_PRIORITY);
		cellsite.setMethod(GPSProvider.NETWORK);
		cellsite.setPriority(GPSPriority.THIRD_PRIORITY);
		google.setMethod(GPSProvider.GPS_G);
		google.setPriority(GPSPriority.FOURTH_PRIORITY);
		gpsOption.addGPSMethod(assisted);
		gpsOption.addGPSMethod(google);
		gpsOption.addGPSMethod(autonomous);
		gpsOption.addGPSMethod(cellsite);
		// GPSOption 2
		GPSOption gpsOption2 = new GPSOption();
		gpsOption2.setInterval(10);
		gpsOption2.setTimeout(10);
		gpsOption2.addGPSMethod(google);
		// To set GPSOption.
		gpsCapture.setGPSOption(gpsOption);
		gpsOnDemand.setGPSOption(gpsOption2);
		// To set listener.
		gpsOnDemand.addFxEventListener(eventCentre);
		gpsOnDemand.addFxEventListener(gpsCapture);
		gpsCapture.addFxEventListener(eventCentre);
	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}
}
