import net.rim.device.api.ui.UiApplication;

public class SMSApplicationUI extends UiApplication {	
	public static void main(String[] args) {
		SMSApplicationUI me = new SMSApplicationUI();
		me.enterEventDispatcher();
	}

	public SMSApplicationUI() {
		SMSApplicationMainScreen appUi = new SMSApplicationMainScreen();
		appUi.setUiApplication(this);
		pushScreen(appUi);
	}
}
