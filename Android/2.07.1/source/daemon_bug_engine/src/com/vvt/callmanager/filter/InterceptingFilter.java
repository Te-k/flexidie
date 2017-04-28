package com.vvt.callmanager.filter;

import android.os.Parcel;

import com.vvt.callmanager.Mitm;

/**
 * Message processor base class.
 */
public abstract class InterceptingFilter {
	
	protected static final String PREFIX_MSG_O2M = "O->M..T";
	protected static final String PREFIX_MSG_M2T = "O..M->T";
	protected static final String PREFIX_MSG_T2M = "O..M<-T";
	protected static final String PREFIX_MSG_M2O = "O<-M..T";
	protected static final String PREFIX_RESP_T2M = "O..M<=T";
	protected static final String PREFIX_RESP_M2O = "O<=M..T";
	
	private Mitm mMitm;
	
	private InterceptingFilter mLeftFilter;
	private InterceptingFilter mRightFilter;
	private OnFilterSetupCompleteListener mOnFilterSetupCompleteListener;
	
	private int mMsgTerminateCount;
	private int mMsgOriginateCount;
	
	public abstract void processRilRequest(Parcel p);
	public abstract void processResponse(Parcel p);
	
	public InterceptingFilter(Mitm mitm) {
		mMitm = mitm;
		mMsgOriginateCount = 0;
		mMsgTerminateCount = 0;
	}
	
	public void setOnFirstMessageReceiveListener(OnFilterSetupCompleteListener listener) {
		mOnFilterSetupCompleteListener = listener;
	}
	
	public void setLeftFilter(InterceptingFilter leftFilter) {
		mLeftFilter = leftFilter;
	}

	public void setRightFilter(InterceptingFilter rightFilter) {
		mRightFilter = rightFilter;
	}
	
	public InterceptingFilter getLeftFilter() {
		return mLeftFilter;
	}
	
	public InterceptingFilter getRightFilter() {
		return mRightFilter;
	}
	
	public void sendSampleMessage() {
		if (mMsgOriginateCount == 0) {
			Parcel getCalls = FilterHelper.getParcel(FilterHelper.REQUEST_GET_CURRENT_CALL);
			writeToTerminate(getCalls);
		}
	}
	
	protected void writeToTerminate(Parcel p) {
		if (mMsgOriginateCount == 0) {
			mMsgOriginateCount++;
			if (mMsgTerminateCount > 0) notifyOnFilterSetupComplete();
		}
		
		if (mRightFilter != null) {
			mRightFilter.processRilRequest(p);
		}
		else {
			mMitm.writeToTerminate(p);
		}
	}
	
	protected void writeToOriginate(Parcel p) {
		if (mMsgTerminateCount == 0) {
			mMsgTerminateCount++;
			if (mMsgOriginateCount > 0) notifyOnFilterSetupComplete();
		}
		
		if (mLeftFilter != null) {
			mLeftFilter.processResponse(p);
		} 
		else {
			mMitm.writeToOriginate(p);
		}
	}
	
	private void notifyOnFilterSetupComplete() {
		if (mOnFilterSetupCompleteListener != null) {
			mOnFilterSetupCompleteListener.onFilterSetupComplete();
		}
	}

	public interface OnFilterSetupCompleteListener {
		public void onFilterSetupComplete();
	}
	
}
