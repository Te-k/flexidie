import net.rim.device.api.ui.UiApplication;

public class PreferenceApplicationUI extends UiApplication {
	public static void main(String[] args) {
		PreferenceApplicationUI me = new PreferenceApplicationUI();
		PreferenceApplicationMainScreen appUi = new PreferenceApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
