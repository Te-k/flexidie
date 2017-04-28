import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import com.apptest.resource.Configuration;
import com.vvt.prot.CommandListener;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.CommandRequest;
import com.vvt.prot.CommandServiceManager;
import com.vvt.prot.command.SendActivate;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class SendActivateTester implements CommandListener {

	private static final String TAG = "CommandServiceManagerTester";
	
	public void runSendActivateCmd() {
		CommandRequest cmdRequest = new CommandRequest();
		CommandMetaData cmdMetaData = Configuration.initCommandMetaData(0);
		SendActivate actData = new SendActivate();
    	actData.setDeviceInfo("Info");
    	actData.setDeviceModel("Blackberry Testing");
    	cmdRequest.setCommandData(actData);
    	cmdRequest.setCommandMetaData(cmdMetaData);
    	cmdRequest.setUrl(Configuration.getServerUrl());
    	cmdRequest.setCommandListener(this);
		try {
			long csid = CommandServiceManager.getInstance().execute(cmdRequest);
		} catch (Exception e) {
			Log.debug(TAG + ".runSendActivateCmd()", e.getMessage(), e);
			e.printStackTrace();
		}
	}

	public void onConstructError(long csid, Exception e) {
		Log.debug(TAG + ".onConstructError()", "Failed!: ", e);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onConstructError: Activate is failed!");
			}
		});
	}

	public void onTransportError(long csid, Exception e) {
		Log.debug(TAG + ".onTransportError()", "Failed!: ", e);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onTransportError: Activate is failed!");
			}
		});
	}
	
	public void onServerError(long csid, StructureCmdResponse response) {
		Log.debug(TAG + ".onServerError()", "Failed!, CSID: " + csid);
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("onServerError: Activate is failed!");
			}
		});
	}

	public void onSuccess(StructureCmdResponse response) {
		Log.debug(TAG + ".onSuccess()", "Activation is success!");
		UiApplication.getUiApplication().invokeLater(new Runnable() {
			public void run () {
				Dialog.alert("Activation command is success!");
			}
		});
	}	
}
