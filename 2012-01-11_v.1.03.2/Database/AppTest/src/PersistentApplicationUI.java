import net.rim.device.api.ui.UiApplication;

public class PersistentApplicationUI extends UiApplication {
	public static void main(String[] args) {
		PersistentApplicationUI me = new PersistentApplicationUI();
		PersistentApplicationMainScreen appUi = new PersistentApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
