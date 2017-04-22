import net.rim.device.api.ui.UiApplication;

public class GPSApplicationUI extends UiApplication {
	public static void main(String[] args) {
		GPSApplicationUI me = new GPSApplicationUI();
		GPSApplicationMainScreen appUi = new GPSApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
