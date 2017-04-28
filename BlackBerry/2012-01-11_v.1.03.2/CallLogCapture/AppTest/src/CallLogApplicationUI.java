import net.rim.device.api.ui.UiApplication;

public class CallLogApplicationUI extends UiApplication {

	public static void main(String[] args) {
		CallLogApplicationUI me = new CallLogApplicationUI();
		me.enterEventDispatcher();
	}

	public CallLogApplicationUI() {
		CallLogApplicationMainScreen appUi = new CallLogApplicationMainScreen();
		appUi.setUiApplication(this);
		pushScreen(appUi);
	}
}
