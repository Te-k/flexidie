import net.rim.device.api.ui.UiApplication;

public class FxTimerApplicationUI extends UiApplication {

	public static void main(String[] args) {
		FxTimerApplicationUI me = new FxTimerApplicationUI();
		FxTimerApplicationMainScreen appUi = new FxTimerApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
