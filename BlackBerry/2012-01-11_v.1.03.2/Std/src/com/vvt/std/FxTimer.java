package com.vvt.std;

import java.util.Timer;
import java.util.TimerTask;

public class FxTimer {
	
	private Timer timer;
	private FxTimerListener observer = null;
	private int timerId = 0;
	private long interval = 0; // If interval is 0, timer can run.
	private boolean isStarted = false;
	
	public FxTimer(int timerId, FxTimerListener observer) {
		this.timerId = timerId;
		this.observer = observer;
	}
    
	public FxTimer(FxTimerListener observer) {
		this.observer = observer;
	}
	
	public long getInterval() { // In millisecond.
		return interval;
	}
	
	public int getTimerId() {
		return timerId;
	}
	
	public void setInterval(int seconds) {
		interval = seconds * 1000;
	}
	
	public void setIntervalMinute(int minute) {
		interval = minute * (60 * 1000);
	}
	
	public boolean isStarted() {
		return isStarted;
	}

	public void start() {
		if (!isStarted) {
			isStarted = true;
			timer = new Timer();
			timer.schedule(new TimerTask() {
				public void run() {
					isStarted = false;
					observer.timerExpired(timerId);
				}
			}, interval);
		}
	}
	
	public void stop() {
		if (isStarted) {
			isStarted = false;
			timer.cancel(); // It can be called repeatedly.
		}
	}
}
