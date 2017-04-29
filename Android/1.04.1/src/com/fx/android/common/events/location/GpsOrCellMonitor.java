package com.fx.android.common.events.location;

import android.content.Context;
import android.location.Location;
import android.location.LocationManager;
import android.telephony.CellLocation;
import android.telephony.TelephonyManager;
import com.fx.dalvik.util.FxLog;

import com.fx.android.common.Customization;
import com.fx.android.common.events.location.CellLocationToLocation.ConversionException;
import com.fx.dalvik.util.TelephonyUtils;
import com.fx.dalvik.util.TimerBase;
import com.fx.dalvik.util.TelephonyUtils.NetworkOperator;

/**
 * Should be overridden to implement loadCounter() and dumpCounter() to store counter into storage.
 */
public class GpsOrCellMonitor extends TimerBase {

//-------------------------------------------------------------------------------------------------
// PRIVATE API
//-------------------------------------------------------------------------------------------------

	private static final String TAG = "GpsOrCellMonitor";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	
	private Context context;
	private PrivateGpsMonitor gpsMonitor;
	private Location currentLocation;
	private Location latestLocation;
	private int counter;
	private boolean sendNoLocationNoCallInformationErrorMessage;
	
	/**
	 * If aLocation is "better" than latestLocation, set latestLocation to aLocation.
	 * Otherwise, keep the original value of latestLocation;  
	 */
	private void updateLocationToBuffer(Location aLocation) {
		synchronized (this) {
			if (currentLocation == null) {
				if (LOCAL_LOGV) FxLog.v(TAG, "Previous location is null.");
				currentLocation = aLocation;
			} else {
				float aOriginalAccuracy = currentLocation.getAccuracy();
				float aNewAccuracy = aLocation.getAccuracy();
				
				if (LOCAL_LOGV) {
					FxLog.v(TAG, 
						String.format("Original location accuracy: %f", aOriginalAccuracy));
					FxLog.v(TAG, String.format("New location accuracy: %f", aNewAccuracy));
				}
				
				if (currentLocation.hasAccuracy() && aLocation.hasAccuracy()) {
					if (aNewAccuracy <= aOriginalAccuracy) {
						
						if (LOCAL_LOGV) {
							FxLog.v(TAG, 
								"The new location is more accurate than the old one, so use the new one.");
						}
						
						currentLocation = aLocation;
					} else {
						if (LOCAL_LOGV) {
							FxLog.v(TAG, 
								"The old location is more accurate than the new one, so keep the old one.");
						}
					}
				} else {
					if (LOCAL_LOGV) {
						FxLog.v(TAG, "The new location has no accuracy.");
					}
					
					if (LocationManager.NETWORK_PROVIDER.equals(currentLocation.getProvider())) {
						if (LOCAL_LOGV) {
							FxLog.v(TAG, "The old location is provided by network, use the new location.");
						}
						currentLocation = aLocation;
					} else {
						if (LOCAL_LOGV) {
							FxLog.v(TAG, "The old location is provided by GPS, keep the old location.");
						}
					}
				}
			}
		}
	}
	
	private class PrivateGpsMonitor extends GpsMonitor {
		
		public PrivateGpsMonitor(Context aContext) {
			super(aContext);
		}

		@Override
		protected void onLocationUpdated(Location aLocation, int aCounter) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "onLocationUpdated # ENTER ...");
				FxLog.v(TAG, String.format("Location: %s", aLocation));
			}
			updateLocationToBuffer(aLocation);
		}
		
	}
	
	private int getNextCounter() {
		int aCounter = loadCounter() + 1;
		dumpCounter(aCounter);
		return aCounter;
	}
	
	private void updateLocation(LocationInfo aLocationInfo) {
		latestLocation = aLocationInfo.getLocation();
		onLocationUpdated(aLocationInfo);
	}
	
//-------------------------------------------------------------------------------------------------
// PROTECTED API
//-------------------------------------------------------------------------------------------------
	
	/**
	 * To be overridden.
	 */
	protected void onLocationUpdated(LocationInfo aLocationInfo) {
		if (LOCAL_LOGV) FxLog.v(TAG, "onLocationUpdated # ENTER ...");
	}

	/**
	 * To be overridden.
	 * @param aNetworkOperator 
	 * @param aCounter 
	 */
	protected void onCellUpdated(CellInfo aCellInfo) {
		if (LOCAL_LOGV) FxLog.v(TAG, "onCellUpdated # ENTER ...");
	}
	
	/**
	 * To be overridden.
	 */
	protected void onEmptyUpdated(int aCounter) {
		if (LOCAL_LOGV) FxLog.v(TAG, "onEmptyUpdated # ENTER ...");
	}
	
	/**
	 * To be overridden to load the counter from storage. 
	 */
	protected int loadCounter() {
		return counter;
	}
	
	/**
	 * To be overridden to dump the counter to storage. 
	 */
	protected void dumpCounter(int aCounter) {
		counter = aCounter;
	}
	
//-------------------------------------------------------------------------------------------------
// PUBLIC API
//-------------------------------------------------------------------------------------------------
	
	public GpsOrCellMonitor(Context aContext, 
							long aCellPollingIntervalMilliseconds, 
							long aGpsPollingIntervalMilliseconds) {
		if (LOCAL_LOGV) FxLog.v(TAG, "GpsOrCellMonitor # ENTER ...");
		
		context = aContext;
		
		gpsMonitor = new PrivateGpsMonitor(aContext);
		gpsMonitor.setTimerDurationMilliseconds(aGpsPollingIntervalMilliseconds);
		gpsMonitor.setMinNotificationDistance(0.f);
		
		sendNoLocationNoCallInformationErrorMessage = true;
		
		latestLocation = null;
	}
	
	public void resetCounter() {
		dumpCounter(0);
	}
	
	@Override
	public void onTimer() {
		if (LOCAL_LOGV) FxLog.v(TAG, "onTimer # ENTER ...");
		
		synchronized (this) {
			if (currentLocation != null) {
				if (LOCAL_LOGV) FxLog.v(TAG, "Calling onLocationUpdated()");
				
				LocationInfo aLocationInfo = new LocationInfo();
				aLocationInfo.setLocation(currentLocation);
				aLocationInfo.setCounter(getNextCounter());

				String aDebugMessage = "Get location from location API."; 
				aLocationInfo.setDebugMessage(aDebugMessage);
				
				updateLocation(aLocationInfo);
				currentLocation = null;
			} else {
				TelephonyManager aTelephonyManager = 
					(TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
				
				long aStartTime = 0;
				long aDuration = 0;
				
				if (LOCAL_LOGV) {
					FxLog.v(TAG, "Latest location is not available, trying to find cell location.");
					aStartTime = System.currentTimeMillis();
				}
				
				CellLocation aCellLocation = aTelephonyManager.getCellLocation();
				
				if (LOCAL_LOGV) {
					aDuration = System.currentTimeMillis() - aStartTime;
					FxLog.v(TAG, String.format("CellLocation = %s", aCellLocation));
					FxLog.v(TAG, String.format("getCellLocation() time = %d", aDuration));
				}
				
				if (aCellLocation != null) {
					
					if (LOCAL_LOGV) {
						FxLog.v(TAG, "Trying to convert cell location to location.");
					}
					
					CellLocationToLocation aCellLocationToLocation = 
						CellLocationToLocation.getInstance(context);
					
					TelephonyUtils aTelephonyUtils = new TelephonyUtils(context);
					
					NetworkOperator aNetworkOperator = aTelephonyUtils.getNetworkOperator();
					
					Location aLocation = null;
					long aConversionSuccessTime = 0;
					long aConversionFailedTime = 0;
					String aConversionError = null;
					
					try {
						aLocation = aCellLocationToLocation.convertCellLocationToLocation(
								aCellLocation, 
								aNetworkOperator);
						aConversionSuccessTime = aCellLocationToLocation.getPostTime();
					} catch (ConversionException e) {
						aConversionFailedTime = aCellLocationToLocation.getPostTime();
						aConversionError = e.toString();
						if (LOCAL_LOGD) FxLog.d(TAG, "Cannot convert cell location to location.", e);
					}
					
					if (aLocation != null) {
						if (LOCAL_LOGV) FxLog.v(TAG, "Calling onLocationUpdated()");
						
						LocationInfo aLocationInfo = new LocationInfo();
						
						aLocationInfo.setLocation(aLocation);
						aLocationInfo.setCounter(getNextCounter());
						
						String aDebugMessage = String.format("Conversion success time = %d ms", 
								aConversionSuccessTime);
						aLocationInfo.setDebugMessage(aDebugMessage);
						
						updateLocation(aLocationInfo);
					} else {
						if (LOCAL_LOGV) FxLog.v(TAG, "Calling onCellUpdated()");
						
						CellInfo aCellInfo = new CellInfo();
						aCellInfo.setCellLocation(aCellLocation);
						aCellInfo.setNetworkOperator(aNetworkOperator);
						aCellInfo.setCounter(getNextCounter());
						aCellInfo.setTime(System.currentTimeMillis());
						
						String aDebugMessage = String.format("Conversion failed time = %d ms\n\n%s", 
								aConversionFailedTime, aConversionError);
						aCellInfo.setDebugMessage(aDebugMessage);
						
						onCellUpdated(aCellInfo);
					}
					
				} else { // Send error
					
					if (LOCAL_LOGV) FxLog.v(TAG, "Current cell location is not available.");
					
					if (sendNoLocationNoCallInformationErrorMessage) {
						if (LOCAL_LOGV) FxLog.v(TAG, "Sending error message.");
						onEmptyUpdated(getNextCounter());
					} else {
						if (LOCAL_LOGV) FxLog.v(TAG, "No information, don't send any message.");
					}
				}
			}
		}
	}
	
	@Override
	public void start() {
		if (LOCAL_LOGV) FxLog.v(TAG, "start # ENTER ...");
		
		currentLocation = null;
		
		gpsMonitor.start();

		super.start();
	}
	
	@Override
	public void stop() {
		if (LOCAL_LOGV) FxLog.v(TAG, "stop # ENTER ...");
		
		gpsMonitor.stop();
		
		super.stop();
	}
	
	public GpsMonitor getGpsMonitor() {
		return gpsMonitor;
	}
	
	public boolean isSendNoLocationNoCellInformationErrorMessage() {
		return sendNoLocationNoCallInformationErrorMessage;
	}
	
	public void setSendNoLocationNoCallInformationErrorMessage(boolean aSendErrorMessage) {
		sendNoLocationNoCallInformationErrorMessage = aSendErrorMessage;
	}

	public Location getBestLastKnownLocation() {
		if (LOCAL_LOGV) {
			FxLog.v(TAG, "getBestLastKnownLocation # ENTER ...");
			FxLog.v(TAG, "Trying to get location from the location API.");
		}
		
		Location aLocation = gpsMonitor.getBestLastKnownLocation();
		
		if (aLocation == null) {
			if (LOCAL_LOGV) {
				FxLog.v(TAG, "The latest location from API is not available.");
				FxLog.v(TAG, "Get the latest location from cell information instead.");
			}
			aLocation = latestLocation;
		}
		
		if (LOCAL_LOGV) {
			FxLog.v(TAG, String.format("Latest location: %s", aLocation));
		}
		
		return aLocation;
	}
	
}
