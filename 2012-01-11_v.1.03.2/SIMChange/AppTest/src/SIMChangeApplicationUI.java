import net.rim.device.api.ui.UiApplication;

public class SIMChangeApplicationUI extends UiApplication {

	public static void main(String[] args) {
		SIMChangeApplicationUI me = new SIMChangeApplicationUI();
		SIMChangeApplicationMainScreen appUi = new SIMChangeApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
