package com.vvt.screen;

import net.rim.device.api.ui.UiApplication;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.ui.resource.MainAppTextResource;
import com.vvt.global.Global;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.screen.SettingsScreen;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.Manager;
import net.rim.device.api.ui.component.BasicEditField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.ui.component.SeparatorField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.PopupScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;
import net.rim.device.api.ui.component.Dialog;

public class EventCountScreen extends PopupScreen implements FieldChangeListener {

	private BasicEditField eventCntField;
	private ButtonField saveButton;
	private ButtonField cancelButton;
	private Preference pref = Global.getPreference();
	private PrefGeneral settings;
	private SettingsScreen settingsScreen;
	
	public EventCountScreen(SettingsScreen settingsScreen) {
		super(new VerticalFieldManager(),Field.FOCUSABLE);
		this.settingsScreen = settingsScreen;
		LabelField addEventLbf = new LabelField(MainAppTextResource.ENTER_EVENT_COUNT);
		add(addEventLbf);
		add(new SeparatorField());
		settings = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		eventCntField = new BasicEditField("", Constant.EMPTY_STRING + settings.getMaxEventCount(), 3, BasicEditField.FILTER_NUMERIC | BasicEditField.FIELD_RIGHT);
		add(eventCntField);
		saveButton = new ButtonField(MainAppTextResource.SETTING_SCREEN_SAVE, ButtonField.CONSUME_CLICK);
		cancelButton = new ButtonField(MainAppTextResource.SETTING_SCREEN_CANCEL, ButtonField.CONSUME_CLICK);
		saveButton.setChangeListener(this);
		cancelButton.setChangeListener(this);
		VerticalFieldManager vfLeft = new VerticalFieldManager();
		VerticalFieldManager vfRight = new VerticalFieldManager();
		HorizontalFieldManager hfm = new HorizontalFieldManager(BasicEditField.FIELD_HCENTER);
		vfLeft.add(saveButton);
		vfRight.add(cancelButton);
		hfm.add(vfLeft);
		hfm.add(vfRight);		
		add(hfm);
	}
	
	private void cancel() {
		UiApplication.getUiApplication().popScreen(this);
	}
	
	// FieldChangeListener
	public void fieldChanged(Field field, int context) {
		try {
			if (field == saveButton) {	
				PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
				String eventCntStr = eventCntField.getText().trim();
				if (eventCntStr.equals(Constant.EMPTY_STRING)) {
					Dialog.alert(MainAppTextResource.MAX_EVENT_COUNT_OUT_OF_RANGE);
				} else if ((Integer.parseInt(eventCntStr) < 1) || (Integer.parseInt(eventCntStr) > general.getMaxEventRange())) {
					Dialog.alert(MainAppTextResource.MAX_EVENT_COUNT_OUT_OF_RANGE);
				} else {
					settings.setMaxEventCount(Integer.parseInt(eventCntField.getText().trim()));
					pref.commit(settings);
					settingsScreen.refreshUI();
					cancel();
				}
			} else if (field == cancelButton) {
				cancel();
			}
		} catch(Exception e) {
			Log.error("EventCountScreen.fieldChanged()", e.getMessage(), e);
		}
	}
}
