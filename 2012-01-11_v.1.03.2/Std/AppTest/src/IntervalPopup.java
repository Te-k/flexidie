import net.rim.device.api.ui.container.*;
import net.rim.device.api.ui.*;
import net.rim.device.api.ui.component.*;

public class IntervalPopup extends PopupScreen implements FieldChangeListener {
	private ButtonField setButton, cancelButton;
	private EditField intervalField;
	private FxTimerApplicationMainScreen main = null;
	public IntervalPopup(FxTimerApplicationMainScreen main) {
		super(new VerticalFieldManager(), Field.FIELD_HCENTER | Field.FOCUSABLE);
		this.main = main;
		LabelField text1 = new LabelField("Please enter the interval value.");
		intervalField = new EditField("", "", 32, EditField.FILTER_NUMERIC);
		add(text1);
		add(intervalField);
		HorizontalFieldManager hfm = new HorizontalFieldManager(Manager.FIELD_HCENTER);
		VerticalFieldManager vfLeft = new VerticalFieldManager();
		VerticalFieldManager vfRight = new VerticalFieldManager();
		setButton = new ButtonField("Set", ButtonField.CONSUME_CLICK);
		cancelButton = new ButtonField("Cancel", ButtonField.CONSUME_CLICK);
		setButton.setChangeListener(this);
		cancelButton.setChangeListener(this);
		vfLeft.add(setButton);
		vfRight.add(cancelButton);
		hfm.add(vfLeft);
		hfm.add(vfRight);
		add(hfm);
	}

	public void fieldChanged(Field field, int context) {
		if (field == setButton) {
			if (intervalField.getText().trim().equals("")) {
				Dialog.alert("You must set the interval value!");
			} else {
				main.setInterval(Integer.parseInt(intervalField.getText()));
				UiApplication.getUiApplication().popScreen(this);
			}
		} else if (field == cancelButton) {
			cancel();
		}
	}

	private void cancel() {
		UiApplication.getUiApplication().popScreen(this);
	}
}