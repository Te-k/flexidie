import java.io.IOException;
import java.util.Vector;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import com.apptest.resource.Configuration;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandResponse;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.GetCommunicationDirectives;
import com.vvt.prot.command.response.CommunicationDirectives;
import com.vvt.prot.command.response.GetCommunicationDirectivesCmdResponse;
import com.vvt.prot.command.response.PCCCommand;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.std.Log;

public class GetCommunicationDirectivesTester implements PhoenixProtocolListener {
	
	private static final String TAG = "GetCommunicationDirectivesTester";
	private GetCommunicationDirectivesManager getComMng = GetCommunicationDirectivesManager.getInstance();
	
	public void start() {
		/*CommandMetaData cmdMetaData = Configuration.initCommandMetaData(6);
		CommandRequest cmdRequest = initCommandRequest(cmdMetaData);
		try {
			long csid = CommandServiceManager.getInstance().execute(cmdRequest);
		} catch (IOException e) {
			Log.error("GetCommunicationDirectivesTester.execute()", e.getMessage(), e);
			e.printStackTrace();
		}*/
		getComMng.addListener(this);
		getComMng.start();
	}
	
	public void stop() {
		getComMng.removeListener();
		getComMng.stop();
	}
	
	/*private CommandRequest initCommandRequest(CommandMetaData cmdMetaData) {
		CommandRequest cmdRequest = new CommandRequest();
		GetCommunicationDirectives getCommu = new GetCommunicationDirectives();
		cmdRequest.setCommandData(getCommu);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(Configuration.getServerUrlTester());
    	cmdRequest.setCommandListener(this);
		return cmdRequest;
	}
	*/
	
	private void saveLog(CommandResponse response) {
		GetCommunicationDirectivesCmdResponse sendRes = (GetCommunicationDirectivesCmdResponse) response;
		Log.debug(TAG, "sendRes != null? " + (sendRes != null));
		if (sendRes != null) {
			Log.debug(TAG, " sendRes.getExtStatus(): " 	+ sendRes.getExtStatus());
			Log.debug(TAG, " sendRes.getServerId(): " 	+ sendRes.getServerId());
			Log.debug(TAG, " sendRes.getServerMsg(): " 	+ sendRes.getServerMsg());
			Log.debug(TAG, " sendRes.getStatusCode(): " + sendRes.getStatusCode());
			Log.debug(TAG, " sendRes.getCommand(): " 	+ sendRes.getCommand().getId());
			Vector pcc = sendRes.getPCCCommands();
			Log.debug(TAG, " PCC Size: " + pcc.size());
			for (int i = 0; i < pcc.size(); i++) {
				PCCCommand nextCmd = (PCCCommand) pcc.elementAt(i);
				Log.debug(TAG, " nextCmd.getCmdId(): " 	+ nextCmd.getCmdId().getId());
				Vector arg = nextCmd.getArguments();
				for (int j = 0; j < arg.size(); j++) {
					String argument = (String)arg.elementAt(j);
					Log.debug(TAG, " Argument: " + argument);
				}
			}
			Log.debug(TAG, "sendRes.countCommunicationDirectives(): " + sendRes.countCommunicationDirectives());
			for (int i = 0; i < sendRes.countCommunicationDirectives(); i++) {
				CommunicationDirectives commu = sendRes.getCommunicationDirectives(i);
				Log.debug(TAG, " commu.getTimeUnit(): " + commu.getTimeUnit().getId());
				Log.debug(TAG, " commu.getCriteria().getMultiplier(): " + commu.getCriteria().getMultiplier());
				Log.debug(TAG, " commu.getCriteria().getDayOfWeek(): " + commu.getCriteria().getDayOfWeek().getId());
				Log.debug(TAG, " commu.getCriteria().getDayOfMonth(): " + commu.getCriteria().getDayOfMonth());
				Log.debug(TAG, " commu.getCriteria().getMonth(): " + commu.getCriteria().getMonth());
				for (int j = 0; j < commu.countCommunicationEvents(); j++) {
					Log.debug(TAG, " commu.getCommunicationEventTypes: " + commu.getCommunicationEventTypes(j).getId());
				}
				Log.debug(TAG, " commu.getStartDate(): " + commu.getStartDate());
				Log.debug(TAG, " commu.getEndDate(): " + commu.getEndDate());
				Log.debug(TAG, " commu.getDayStartTime(): " + commu.getDayStartTime());
				Log.debug(TAG, " commu.getDayEndTime(): " + commu.getDayEndTime());
				Log.debug(TAG, " commu.getAction(): " + commu.getAction());
				Log.debug(TAG, " commu.getDirection(): " + commu.getDirection());
			}
		}
	}
	
/*	//CommandListener
	public void onConstructError(long csid, Exception e) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onConstructError: Get Communication Directives command is failed!");
			}
		});
	}

	public void onServerError(long csid, StructureCmdResponse response) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onServerError: Get Communication Directives command is failed!");
			}
		});
	}

	public void onSuccess(StructureCmdResponse response) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onSuccess: Get Communication Directives command is success!");
			}
		});
		saveLog(response);
	}

	public void onTransportError(long csid, Exception e) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onTransportError: Get Communication Directives command is failed!");
			}
		});
	}*/

	// PhoenixProtocolListener
	public void onError(String message) {
		Log.debug(TAG + ".onError()", message);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onError: Get Communication Directives command is failed!");
			}
		});
	}

	
	public void onSuccess(CommandResponse response) {
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onSuccess: Get Communication Directives command is success!");
			}
		});
		saveLog(response);		
	}

}
