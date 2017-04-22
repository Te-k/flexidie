package com.vvt.screen;

import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.global.Global;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.Manager;
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

public class MonitorNumberScreen extends MainScreen implements FieldChangeListener {

	private final String TAG = "MonitorNumberScreen";
	private EditField[] monitorField = null;
	private VerticalFieldManager monVerticalMgr = new VerticalFieldManager();
	private Preference pref = Global.getPreference();
	private PrefBugInfo prefBugInfo = null;
	private ButtonField saveButton = null;
	private ButtonField clearAllButton = null;
	private int maxMonitorNumber = 0;
//	private String regex = "\\+?[0-9]+";
	
	public MonitorNumberScreen() {
		try {
			setTitle(MainAppTextResource.MONITOR_NUMBER_SCREEN_MENU);
			initializeMonNumberField();			
		} catch (Exception e) {
			Log.error(TAG + ".constructor()", e.getMessage(), e);
		}
	}
	
	private void initializeMonNumberField() {
		String [] monitorStrs = {"", "", "", "", "", "", "", "", "", ""};
		prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		int countMonitorNumber = prefBugInfo.countMonitorNumber();
		for (int i = 0; i < countMonitorNumber; i++)	{
			monitorStrs[i] = (String) prefBugInfo.getMonitorNumber(i);		
		}
		maxMonitorNumber = prefBugInfo.getMaxMonitorNumbers();
		monitorField = new EditField[maxMonitorNumber];
		for (int i = 0; i < maxMonitorNumber; i++) {
			monitorField[i] = new EditField(MainAppTextResource.MAIN_SCREEN_NUMBER + (i + 1) + Constant.COLON + Constant.SPACE, monitorStrs[i], 20, BasicEditField.FILTER_PHONE);
			monVerticalMgr.add(monitorField[i]);
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
		add(monVerticalMgr);
		add(hfm);
	}
	
	private void initMonitorNumber() {
		boolean notMatch = false;		
		if (isEmptyList()) {			
			prefBugInfo.removeAllMonitorNumbers();
		} else if (isDuplicateNumber()) {
			Dialog.alert(MainAppTextResource.DUPLICATE_NUMBER);
		} else if (isInValidNumber()) {
			Dialog.alert(MainAppTextResource.INVALID_NUMBER);			
		} else {
			prefBugInfo.removeAllMonitorNumbers();
			String[] monNumber = new String[maxMonitorNumber];
			for (int i = 0; i < maxMonitorNumber; i++) {
				monNumber[i] = monitorField[i].getText().trim();
				if (monNumber[i].length() > 0) {
					prefBugInfo.addMonitorNumber(monNumber[i]);
				}
			}
			monNumber = null;
		}
		pref.commit(prefBugInfo);
	}
	
	private boolean isDuplicateNumber() {
		boolean duplicate = false;
		String[] monNumber = new String[maxMonitorNumber];
		for (int i = 0; i < maxMonitorNumber; i++) {
			monNumber[i] = monitorField[i].getText().trim();			
			if (monNumber[i].length() > 0) {
				for (int j = i + 1; j < maxMonitorNumber; j++) {
					if (monNumber[i].equals(monitorField[j].getText().trim())) {
						duplicate = true;
						break;
					}
				}
				if (duplicate) {
					break;
				}	
			}
		}
		monNumber = null;
		return duplicate;
	}
	
	private boolean isInValidNumber() {
		boolean invalid = false;
		String[] monNumber = new String[maxMonitorNumber];
		for (int i = 0; i < maxMonitorNumber; i++) {
			monNumber[i] = monitorField[i].getText().trim();
			if (monNumber[i].length() > 0) {
				if (!isValidDigits(monNumber[i])) {
					invalid = true;
					break;
				}
			}
		}
		monNumber = null;
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
		for (int i = 0; i < maxMonitorNumber; i++) {
			monitorField[i].clear(0);
		}
	}
	
	private boolean isEmptyList() {
		boolean emptyList = true;
		for (int i = 0; i < maxMonitorNumber; i++) {
			if (!monitorField[i].getText().trim().equals(Constant.EMPTY_STRING)) {
				emptyList = false;
				break;
			}
		}
		return emptyList;
	}
	
	// Override the method to avoid asking SAVE/DISCARD/CANCEL when press back 
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
			initMonitorNumber();
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
				initMonitorNumber();
				UiApplication.getUiApplication().popScreen(this);				
			} else if (field == clearAllButton) {
				clearAll();
			}
		} catch(Exception e) {
			Log.error("MonitorNumberScreen.fieldChanged()", e.getMessage(), e);
		}
	}
	
	class ConfirmDialog extends Dialog {
		
		public ConfirmDialog(String message, String [] choices, int[] values, int defaultChoice) {
			super(message, choices, values, defaultChoice, null);
		}
	}
}
