import net.rim.device.api.ui.UiApplication;

public class SMSSendApplicationUI extends UiApplication {

	public static void main(String[] args) {
		SMSSendApplicationUI me = new SMSSendApplicationUI();
		SMSSendApplicationMainScreen appUi = new SMSSendApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
