package com.vvt.capture.location;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.os.SystemClock;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventListener;
import com.vvt.capture.location.settings.LocationOption;
import com.vvt.capture.location.util.LocationCallingModule;
import com.vvt.events.FxLocationEvent;
import com.vvt.logger.FxLog;

public class LocationCaptureManagerImp implements LocationCaptureManager{
	
	/*=================================== CONSTANT ===================================*/
	private static final String TAG = "LocationCapture";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;
	
	/*=================================== VARIABLE ===================================*/
	private FxEventListener mLocationCaptureListener;
	private LocationOnDemandListener mOnDemandListener;
//	private LocationOption mCaptureSpac;
	private LocationTracking mTracking;
	private LocationOndemand mOndemand;
	private Context mContext;
	
	private boolean mIsResumeCoreTracking = true;
	private LocationOption mResumeLocationOption;
	private LocationOption mCurrentLocationOption;
	private LocationCallingModule mCurrentCallingModule;
	
	/*===================================  METHOD  ===================================*/
	
	
	public LocationCaptureManagerImp(Context context) {
		mContext = context;
	}
	
	public void setEventListener(FxEventListener eventListener) {
		mLocationCaptureListener = eventListener;
	}
	
	@Override
	public synchronized void startLocationTracking(LocationOption locationOption) {
		if(LOGV) FxLog.v(TAG, "startLocationTracking # ENTER ...");
		if(mCurrentCallingModule == null) {
			mCurrentCallingModule = locationOption.getCallingModule();
			mCurrentLocationOption = locationOption;
			startCapture();
			
		} else {
			switch (mCurrentCallingModule) {
			case MODULE_ALERT:
			case MODULE_PANIC:
				//Ignores newly module. 
				break;
				
			case MODULE_LOCATION_ON_DEMAND:
				if(locationOption.getCallingModule() == LocationCallingModule.MODULE_PANIC
						|| locationOption.getCallingModule() == LocationCallingModule.MODULE_ALERT) {
					pausesCapture();
					mCurrentCallingModule = locationOption.getCallingModule();
					mCurrentLocationOption = locationOption;
					startCapture();
				}
				break;
				
			default:
				FxLog.v(TAG, "startLocationTracking # module : " + locationOption.getCallingModule());
				if(locationOption.getCallingModule() != LocationCallingModule.MODULE_CORE) {
					pausesCapture();
					mCurrentCallingModule = locationOption.getCallingModule();
					mCurrentLocationOption = locationOption;
					startCapture();
				} else {
					//caller change time
					if(mCurrentLocationOption.getTrackingTimeInterval() != locationOption.getTrackingTimeInterval()) {
						stopCapture();
						mCurrentCallingModule = locationOption.getCallingModule();
						mCurrentLocationOption = locationOption;
						startCapture();
					}
				}
				break;
			}
		}
		
		if(LOGV) FxLog.v(TAG, "startLocationTracking # EXIT ...");
		
	}

	@Override
	public void stopLocationTracking(LocationCallingModule callingModule) {
		if(LOGV) FxLog.v(TAG, "stopLocationTracking # ENTER ...");
		if(mCurrentLocationOption != null && mCurrentCallingModule != null) {
			if(LOGD) FxLog.d(TAG, String.format(
					"stopLocationTracking # CurrentLocationModule : %s callingModule : %s",
					mCurrentLocationOption.getCallingModule(), callingModule));
			
			if(mCurrentLocationOption.getCallingModule() == callingModule) {
				stopCapture();
				//if call stop it should stop every thing.
				mIsResumeCoreTracking = false;
				resumeCapture();
			} else {
				if(mResumeLocationOption != null) {
					if(mResumeLocationOption.getCallingModule() == callingModule) {
						mIsResumeCoreTracking = false;
					}
				}
			}
		}
		if(LOGV) FxLog.v(TAG, "stopLocationTracking # EXIT ...");
	}

	@Override
	public void getLocationOnDemand(LocationOnDemandListener onDemandListener) {
		if(LOGV) FxLog.v(TAG, "getLocationOnDemand # ENTER ...");
		mOnDemandListener = onDemandListener;
		
		if(mCurrentCallingModule == null) {
			mCurrentCallingModule = LocationCallingModule.MODULE_LOCATION_ON_DEMAND;
			mCurrentLocationOption = new LocationOption();
			mCurrentLocationOption.setCallingModule(LocationCallingModule.MODULE_LOCATION_ON_DEMAND);
			startCapture();
		}  else {
			
			if(mCurrentCallingModule == LocationCallingModule.MODULE_CORE) {
				pausesCapture();
				mCurrentCallingModule = LocationCallingModule.MODULE_LOCATION_ON_DEMAND;
				LocationOption locationOption = new LocationOption();
				locationOption.setCallingModule(LocationCallingModule.MODULE_LOCATION_ON_DEMAND);
				mCurrentLocationOption = locationOption;
				startCapture();
			}
		}
		if(LOGV) FxLog.v(TAG, "getLocationOnDemand # EXIT ...");
		
	}
	
	private void startCapture () {
		if(LOGV) FxLog.v(TAG, "startCapture # ENTER ...");
		if(LOGD) FxLog.d(TAG, String.format("startCapture # mCurrentLocationOption : %s",mCurrentLocationOption));
		if(mCurrentLocationOption != null) {
			
			if(mCurrentCallingModule == LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
				if(mOndemand == null) {
					mOndemand = new LocationOndemand();
				}
				mOndemand.start();
			} else {
				if (mTracking == null) {
					mTracking = new LocationTracking();
				}
				mTracking.startTracking();
			}
		}
		
		if(LOGV) FxLog.v(TAG, "startCapture # EXIT ...");
	}
	
	private void pausesCapture() {
		if(LOGV) FxLog.v(TAG, "pausesCapture # ENTER ...");
		mResumeLocationOption = mCurrentLocationOption;
		stopCapture();
		if(LOGV) FxLog.v(TAG, "pausesCapture # EXIT ...");
	}
	
	private void resumeCapture() {
		if(LOGV) FxLog.v(TAG, "resumeCapture # ENTER ...");
		if(mResumeLocationOption != null) {
			if(LOGD) FxLog.d(TAG, "resumeCapture # ResumeLocationOption != null");
			if(mIsResumeCoreTracking) {
				FxLog.d(TAG, "resumeCapture # mIsResumeCoreTracking = true");
				mCurrentLocationOption = mResumeLocationOption;
				mCurrentCallingModule = mCurrentLocationOption.getCallingModule();
				mResumeLocationOption = null;
			} else {
				if(LOGD) FxLog.d(TAG, "resumeCapture # mIsResumeCoreTracking = false");
				mCurrentCallingModule = null;
				mCurrentLocationOption = null;
				mResumeLocationOption = null;
			}
			
		} else {
			mCurrentCallingModule = null;
			mCurrentLocationOption = null;
		}
		
		startCapture();
		if(LOGV) FxLog.v(TAG, "resumeCapture # EXIT ...");
	}
	
	/**
	 * call this when you want to stop Tracking.
	 */
	private void stopCapture() {
		if(LOGV) FxLog.v(TAG, "stopCapture # ENTER ...");
		if (mCurrentCallingModule != LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
			if (mTracking != null) {
				mTracking.stopTracking();
			}
			mTracking = null;
		} else {
			if(mOndemand != null) {
				mOndemand.stop();
			}
			mOndemand = null;
		}
		if(LOGV) FxLog.v(TAG, "stopCapture # EXIT ...");
	} 
	
	/*========================================================= INNER CLASS =====================================================*/

	/**
	 * LocationOndemand
	 * @author watcharin_s
	 *
	 */
	private class LocationOndemand implements GettingLocation.Callback {

		private GettingLocation mLocOndemand;
		
		public void start() {

			if (mLocOndemand == null) {
				mLocOndemand = new GettingLocation(mContext, mCurrentLocationOption, this);
			}
			mLocOndemand.enable();
		}
		
		public void stop() {
			if (mLocOndemand != null) {
				mLocOndemand.disable();
			}
			mLocOndemand = null;
			
		}
		
		@Override
		public void onLocationChanged(List<FxEvent> events) {
			
			//make sure nobody stop ondemand during received location.
			if(mLocOndemand != null) {
				if(LOGV) FxLog.v(TAG,"onLocationChanged # ENTER ...");
				if(LOGD) FxLog.d(TAG,"onLocationChanged # Call back ...");
				if(events.size() > 0) {
					mLocationCaptureListener.onEventCaptured(events);
					if(mOnDemandListener != null) {
						FxLocationEvent le = (FxLocationEvent) events.get(0);
						if(le.isMockLocaion()) {
							if(le.getCellId() != 0) {
								mOnDemandListener.locationOndemandError(new Exception("Can not get location but can get cell ID."));
							} else {
								mOnDemandListener.locationOndemandError(new Exception("Can not get location and cell ID."));
							}
						} else {
							mOnDemandListener.locationOnDemandUpdated(events);
						}
					}
				}
				//clear all memver for next command.
				stopCapture();
				resumeCapture();
				if(LOGV) FxLog.v(TAG,"onLocationChanged # EXIT ...");
			}
		}
		
	}
	
	//========================================================= END ON DEMAND =====================================================//
	
	/**
	 * LocationTracking
	 * @author watcharin_s
	 *
	 */
	private class LocationTracking implements GettingLocation.Callback{
		
		private List<FxEvent> mEvents;
		private Timer mFirstTimeTimer;
		private TimerTask mFirstTimeTask;
		private Timer mRequestLocationTimer;
		private TimerTask mRequestLocationTask;
		private GettingLocation mLocTracking;
		private boolean isRunFirstTime = true;
		
		public void startTracking() {
			if(LOGV) FxLog.v(TAG, "startTracking # ENTER ...");
			if(mEvents == null) {
				mEvents = new ArrayList<FxEvent>();
			}
			
			if (mLocTracking == null) {
				mLocTracking = new GettingLocation(mContext, mCurrentLocationOption,this);
			}

			//if tracking mode we don't need to interval schedule. Keep it all.
			if(mCurrentLocationOption.isTrackingMode()) {
				mLocTracking.enable();
			} else {
				scheduleRequestLocationTask();
			}
			
			if(LOGV) FxLog.v(TAG, "startTracking # EXIT ...");
		}
		
		public void stopTracking() {
			if(LOGV) FxLog.v(TAG, "stopTracking # ENTER ...");
			if(mLocTracking != null) {
				mLocTracking.disable();
			}
			cancelTimeoutTask();
			mLocTracking = null;
			mEvents = null;
			if(LOGV) FxLog.v(TAG, "stopTracking # EXIT ...");
		}
		
		private void cancelTimeoutTask() {
			
			if(LOGV) FxLog.v(TAG, "cancelTimeoutTask # ENTER ...");
			
			if (mFirstTimeTask != null) {
				mFirstTimeTask.cancel();
				mFirstTimeTask = null;
			}
			
			if (mRequestLocationTimer != null) {
				mRequestLocationTimer.cancel();
				mRequestLocationTimer = null;
			}
			
			if(LOGV) FxLog.v(TAG, "cancelTimeoutTask # EXIT ...");
		}
		
		private void scheduleRequestLocationTask() {
	
			if(LOGV) FxLog.v(TAG, "scheduleRequestLocationTask # ENTER ...");
			if(LOGV) FxLog.v(TAG, String.format(
						"scheduleRequestLocationTask # delay: %d", mCurrentLocationOption.getTrackingTimeInterval()));
			
			mFirstTimeTask = new TimerTask() {
				@Override
				public void run() {
					// Request location task
					mRequestLocationTask = new TimerTask() {
						@Override
						public void run() {
							if(LOGV) FxLog.v(TAG, "mRequestLocationTask.run # ENTER ...");
							// start capture location when interval time is out. 
							mLocTracking.enable();
							
							// tracking is interval time < 5 minute. We will keep state request location.
							if(mCurrentLocationOption.iskeepState()) {
								if(!isRunFirstTime) {
									SystemClock.sleep(3000);
									getkeepStateLocation();
								}
								
							}
							if(LOGV) FxLog.v(TAG, "mRequestLocationTask.run # EXIT ...");
						}
					};
					
					// Request location Timer
					if (mRequestLocationTimer == null) {
						mRequestLocationTimer = new Timer();
					}
					mRequestLocationTimer.schedule(mRequestLocationTask,0,mCurrentLocationOption.getTrackingTimeInterval());
					
					if(mCurrentLocationOption.iskeepState()) {
						SystemClock.sleep(3000);
						getkeepStateLocation();
					}
					
				}
			};
			
			if (mFirstTimeTimer == null) {
				mFirstTimeTimer = new Timer();
			}
			mFirstTimeTimer.schedule(mFirstTimeTask, mCurrentLocationOption.getTrackingTimeInterval());
			
			if(LOGV) FxLog.v(TAG, "scheduleRequestLocationTask # EXIT ...");
		}
		
		private void getNotKeepStateLocation() {
			if(LOGV) FxLog.v(TAG,"getNotKeepStateLocation # Enter ...");
			mLocTracking.disable();
			if(LOGD) FxLog.d(TAG,"getNotKeepStateLocation # Call back ...");
			mLocationCaptureListener.onEventCaptured(mEvents);
			if(LOGV) FxLog.v(TAG,"getNotKeepStateLocation # Exit ...");
		}
		
		private void getkeepStateLocation() {
			if(LOGV) FxLog.v(TAG,"getkeepStateLocation # Enter ...");
			if(mEvents.size() > 0) {
				if(LOGD) FxLog.d(TAG,"getkeepStateLocation # Call back ...");
				if(LOGV) FxLog.v(TAG, (new Date(System.currentTimeMillis())).toString());
				if(LOGV) FxLog.v(TAG, "getkeepStateLocation # " + ((FxLocationEvent)mEvents.get(0)).toString());
				mLocationCaptureListener.onEventCaptured(mEvents);
			} else  {
				if(LOGD) FxLog.d(TAG,"getkeepStateLocation # NOT Call back ...");
			}
			
			if(LOGV) FxLog.v(TAG,"getkeepStateLocation # Exit ...");
			
			isRunFirstTime = false;
			
		}
		
		public void onLocationChanged(List<FxEvent> events) {
			if(LOGV) FxLog.v(TAG, "onLocationChanged # ENTER ...");
			//always keep location to be pool for keep state.
			mEvents = events;
			if(LOGV) FxLog.v(TAG, (new Date(System.currentTimeMillis())).toString());
			if(LOGV) FxLog.v(TAG, "onLocationChanged # " + ((FxLocationEvent)mEvents.get(0)).toString());
			if(!mCurrentLocationOption.iskeepState()) {
				getNotKeepStateLocation();
			}  
			
			if(mCurrentLocationOption.isTrackingMode()) {
				getkeepStateLocation();
			}
			
//			// only is tracking and keepState
//			if(isRunFirstTime && mCaptureSpac.isKeepRequestState()) {
//				isRunFirstTime = false;
//				getkeepStateLocation();
//			} 
			if(LOGV) FxLog.v(TAG, "onLocationChanged # EXIT ...");
			
		}
		
	}
	
	/**=============================================== for test ===============================================**/
	
	public LocationCallingModule getCallingModule() {
		return mCurrentCallingModule;
		
	}
	
	public LocationOption getLocationOption() {
		return mCurrentLocationOption;
		
	}
}
