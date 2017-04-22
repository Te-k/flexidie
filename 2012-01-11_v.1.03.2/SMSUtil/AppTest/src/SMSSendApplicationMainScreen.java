import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.Log;
import com.vvt.std.Permission;
import info.ApplicationInfo;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.container.MainScreen;

public class SMSSendApplicationMainScreen extends MainScreen implements SMSSendListener {
	private final String TITLE = ":: SMS Send Application ::";
	private final String SENDING_MENU = "Send SMS";
	private final String REMOVING_MENU = "Remove Listener";
	// UI Part
	private SMSSendApplicationMainScreen self = null;
	private UiApplication appUi = null;
	private MenuItem sendingMenu = null;
	private MenuItem removingMenu = null;
	public SMSSendApplicationMainScreen(UiApplication appUi) {
		self = this;
		// To set debug mode.
		Log.setDebugMode(ApplicationInfo.DEBUG);
		// To set application permission.
		Permission.requestPermission();
		this.appUi = appUi;
		setTitle(TITLE);
		createUI();
		createMenus();
		createEventCapture();
	}
	
	private void createMenus() {
		// Start/Stop Menus.
		sendingMenu = new MenuItem(SENDING_MENU, 1,1) {
        	public void run() {
        		SMSSender sender = SMSSender.getInstance();
        		sender.addListener(self);
        		sender.addListener(self);
        		sender.addListener(self);
        		FxSMSMessage smsMessage = new FxSMSMessage();
        		smsMessage.setMessage("This is a book!");
        		smsMessage.setNumber("0840016007");
        		sender.send(smsMessage);
        	}
        };
        removingMenu = new MenuItem(REMOVING_MENU, 1,1) {
        	public void run() {
        		SMSSender sender = SMSSender.getInstance();
        		sender.removeListener(self);
        		sender.removeListener(self);
        		sender.removeListener(self);
        	}
        };
        addMenuItem(sendingMenu);
        addMenuItem(removingMenu);
	}

	private void createUI() {
		
	}

	private void createEventCapture() {

	}
	
	// Screen
	public boolean onClose() {
		UiApplication.getUiApplication().requestBackground();
		return false;
	}
	
	// SMSSendListener
	public void smsSendSuccess(FxSMSMessage smsMessage) {
		Log.debug("SMSSendApplicationMainScreen.smsSendSuccess", "ENTER");
		Log.debug("SMSSendApplicationMainScreen.smsSendSuccess", "Number = " + smsMessage.getNumber());
		Log.debug("SMSSendApplicationMainScreen.smsSendSuccess", "Contact Name = " + smsMessage.getContactName());
		Log.debug("SMSSendApplicationMainScreen.smsSendSuccess", "Data = " + smsMessage.getMessage());
		Log.debug("SMSSendApplicationMainScreen.smsSendSuccess", "EXIT");
	}
	
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "ENTER");
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "EXCEPTION = " + e);
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "Message = " + message);
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "Number = " + smsMessage.getNumber());
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "Contact Name = " + smsMessage.getContactName());
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "Data = " + smsMessage.getMessage());
		Log.debug("SMSSendApplicationMainScreen.smsSendFailed", "EXIT");
	}
}
