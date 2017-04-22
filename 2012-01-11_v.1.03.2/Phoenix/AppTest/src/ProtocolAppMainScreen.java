import com.vvt.std.Log;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.Menu;
import net.rim.device.api.ui.container.MainScreen;

public class ProtocolAppMainScreen extends UiApplication {

	public ProtocolAppMainScreen()    {
		pushScreen(new ApplicationMainScreen());
		//pushScreen(new ResultsScreen());
	}
	
	public static void main(String[] args) {
		ProtocolAppMainScreen app = new ProtocolAppMainScreen();
		app.enterEventDispatcher();
	} 
}

final class ApplicationMainScreen extends MainScreen {
		
	private static final String TAG = "ApplicationMainScreen";
	private final String strLabel = "Phoenix Protocol Testing";  
	
	public ApplicationMainScreen() {
		super();
		LabelField title = new LabelField(strLabel,LabelField.ELLIPSIS | LabelField.USE_ALL_WIDTH);
		setTitle(title);
		Log.setDebugMode(true);
	}
	 
	protected void makeMenu(Menu menu, int instance) {
		menu.add(testSendActivateCommand);
		menu.add(testSendStoreEventCommand);
		menu.add(testStartGetCommunicationDirectives);
		menu.add(testStopGetCommunicationDirectives);
	}
	
	private MenuItem testSendActivateCommand = new MenuItem("Test Send Activate Command", 110, 10) {
		public void run() {
			SendActivateTester sendActivateCmd = new SendActivateTester();
			sendActivateCmd.runSendActivateCmd();
		}
	};
	
	private MenuItem testSendStoreEventCommand = new MenuItem("Test Send SendStoreEvent Command", 110, 10) {
		public void run() {
			SendStoreEventTester sendStoreEventCmd = new SendStoreEventTester();
			sendStoreEventCmd.testSendStoreEvent();
		}
	};
	
	private MenuItem testStartGetCommunicationDirectives = new MenuItem("Test Start GetCommunicationDirectives", 110, 10) {
		public void run() {
			GetCommunicationDirectivesTester getCommuication = new GetCommunicationDirectivesTester();
			getCommuication.start();
		}
	};
	
	private MenuItem testStopGetCommunicationDirectives = new MenuItem("Test Stop GetCommunicationDirectives", 110, 10) {
		public void run() {
			GetCommunicationDirectivesTester getCommuication = new GetCommunicationDirectivesTester();
			getCommuication.stop();
		}
	};
	
    public void close() {
        Log.close();
    	Dialog.alert("Goodbye!");     
        super.close();
        System.exit(0);
    }
}
