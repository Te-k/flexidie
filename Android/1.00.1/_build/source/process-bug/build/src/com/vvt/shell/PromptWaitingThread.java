package com.vvt.shell;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

import android.util.Log;

public class PromptWaitingThread extends Thread {
	
	private static final boolean LOGV = Customization.SHELL_DEBUG ;
	
	private static final long DEFAULT_TIMEOUT_MS = 2*1000;
	
	private FileInputStream mTermIn;
	private String mTag;
	private PromptWait mPromptWait;
	private Timer mTimer;
	private TimerTask mTimerTask;
	
	public PromptWaitingThread(String tag, PromptWait syncWait, FileInputStream termIn) {
		mTag = tag;
		mPromptWait = syncWait;
		mTermIn = termIn;
	}
	
	@Override
	public void run() {
		setupTimeoutTimer();
		
		try {
			byte[] buffer = new byte[4*1024];
        	int read = mTermIn.read(buffer);
        	
        	cancelTimer();
        	
        	mPromptWait.setPromptRead(new String(buffer, 0, read));
        	mPromptWait.setReady();
        }
        catch (IOException e) { /* ignore */ }
	}

	private void setupTimeoutTimer() {
		mTimerTask = new TimerTask() {
			@Override
			public void run() {
				if (LOGV) Log.v(mTag, "Shell # Reading prompt timeout!!");
				mPromptWait.setReady();
			}
		};
		
		mTimer = new Timer();
		mTimer.schedule(mTimerTask, DEFAULT_TIMEOUT_MS);
	}
	
	private void cancelTimer() {
		if (mTimerTask != null) {
			mTimerTask.cancel();
			mTimerTask = null;
		}
		
		if (mTimer != null) {
			mTimer.cancel();
			mTimer = null;
		}
	}
}

