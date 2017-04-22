import net.rim.device.api.ui.UiApplication;

public class CellInfoApplicationUI extends UiApplication {

	public static void main(String[] args) {
		CellInfoApplicationUI me = new CellInfoApplicationUI();
		CellInfoApplicationMainScreen appUi = new CellInfoApplicationMainScreen(me);
		me.pushScreen(appUi);
		me.enterEventDispatcher();
	}
}
