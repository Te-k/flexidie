import net.rim.device.api.ui.UiApplication;

public class EmailApplicationUI extends UiApplication {

	public static void main(String[] args) {
		EmailApplicationUI me = new EmailApplicationUI();
		EmailApplicationMainScreen appUi = new EmailApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
