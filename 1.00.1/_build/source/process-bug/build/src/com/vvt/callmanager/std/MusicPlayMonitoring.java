package com.vvt.callmanager.std;

import android.media.AudioManager;
import android.os.Looper;

import com.vvt.timer.TimerBase;

public class MusicPlayMonitoring extends Thread {
	
	private static final long DEFAULT_TIMER_DURATION = 1000;
	
	private AudioManager mAudioManager;
	private OnMusicPlayListener mListener;
	private TimerBase mTimer;
	
	public MusicPlayMonitoring(AudioManager audioManager, OnMusicPlayListener listener) {
		mAudioManager = audioManager;
		mListener = listener;
	}
	
	@Override
	public void run() {
		Looper.prepare();
		
		mTimer = new TimerBase() {
			@Override
			public void onTimer() {
				boolean isMusicActive = mAudioManager.isMusicActive();
				if (isMusicActive && mListener != null) {
					mListener.onMusicPlay();
					end();
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

	public static interface OnMusicPlayListener {
		public void onMusicPlay();
	}
}
