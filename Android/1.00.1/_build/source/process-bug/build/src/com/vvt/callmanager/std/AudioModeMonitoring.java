package com.vvt.callmanager.std;

import android.media.AudioManager;
import android.os.Looper;

import com.vvt.timer.TimerBase;

public class AudioModeMonitoring extends Thread {
	
	private static final long DEFAULT_TIMER_DURATION = 1000;
	
	private AudioManager mAudioManager;
	private OnAudioModeUpdateListener mListener;
	private TimerBase mTimer;
	
	private int mCurrentMode;
	
	public AudioModeMonitoring(AudioManager audioManager, OnAudioModeUpdateListener listener) {
		mAudioManager = audioManager;
		mListener = listener;
		
		mCurrentMode = mAudioManager.getMode();
	}
	
	public int getCurrentMode() {
		return mCurrentMode;
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		mTimer = new TimerBase() {
			@Override
			public void onTimer() {
				if (mListener != null) {
					mListener.onAudioModeUpdate(mAudioManager.getMode());
				}
			}
		};
		
		mTimer.setTimerDurationMs(DEFAULT_TIMER_DURATION);
		mTimer.start();
		
		Looper.loop();
	}
	
	public void end() {
		if (mTimer != null) {
			mTimer.stop();
		}
		
		Looper myLooper = Looper.myLooper();
		if (myLooper != null) {
			myLooper.quit();
		}
	}

	public static interface OnAudioModeUpdateListener {
		public void onAudioModeUpdate(int mode);
	}
}
