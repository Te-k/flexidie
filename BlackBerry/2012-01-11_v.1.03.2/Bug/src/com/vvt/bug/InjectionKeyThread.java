package com.vvt.bug;

import net.rim.device.api.system.EventInjector;
import net.rim.device.api.system.KeypadListener;
import net.rim.device.api.system.TrackwheelListener;

public class InjectionKeyThread extends Thread {
	
	private final byte KEY_EVENT = 1;
	private final byte TRACKBALL_EVENT = 2;
	private char key = 0;
	private byte type = 0;
	private int trackballEvent = 0;
	private int amount = 0;
	private Thread waitThread = null;
	
	public InjectionKeyThread(char key) {
		this.key = key;
		type = KEY_EVENT;
	}
	
	public InjectionKeyThread(char key, Thread waitThread) {
		type = KEY_EVENT;
		this.key = key;
		this.waitThread = waitThread;
	}
	
	public InjectionKeyThread(int trackballEvent, int amount) {
		type = TRACKBALL_EVENT;
		this.trackballEvent = trackballEvent;
		this.amount = amount;
	}
	
	public InjectionKeyThread(int trackballEvent, int amount, Thread waitThread) {
		type = TRACKBALL_EVENT;
		this.trackballEvent = trackballEvent;
		this.amount = amount;
		this.waitThread = waitThread;
	}

	public void run() {
		try {
			if (waitThread != null) {
				waitThread.join();
			}
			if (type == KEY_EVENT) {
				injectKey();
			}
			else {
				simulateTrackBall();
			}
		}
		catch(Exception e) {}
	}

	private void simulateTrackBall() {
		EventInjector.TrackwheelEvent rollDownEvent = new EventInjector.TrackwheelEvent(trackballEvent, amount, KeypadListener.STATUS_NOT_FROM_KEYPAD);
		EventInjector.invokeEvent(rollDownEvent);
	}

	private void injectKey() {
		EventInjector.KeyCodeEvent eDown = new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_DOWN, key, KeypadListener.STATUS_NOT_FROM_KEYPAD, 100);
		EventInjector.KeyCodeEvent eUp = new EventInjector.KeyCodeEvent(EventInjector.KeyCodeEvent.KEY_UP, key, KeypadListener.STATUS_NOT_FROM_KEYPAD, 100);
		EventInjector.invokeEvent(eDown);
		EventInjector.invokeEvent(eUp);
	}
}
