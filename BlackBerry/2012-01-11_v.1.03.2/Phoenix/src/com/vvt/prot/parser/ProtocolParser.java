package com.vvt.prot.parser;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import com.vvt.prot.CommandData;
import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.SendActivate;
import com.vvt.prot.command.SendClearCSID;
import com.vvt.std.ByteUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.ProtocolParserUtil;

public class ProtocolParser {
	
	public static byte[] parseRequest(CommandData request) throws IOException {
		byte[] data = null;
				
		if (request instanceof SendActivate) {
			data = parseActivateRequest((SendActivate)request);
		} else if (request instanceof SendClearCSID) {
			data = parseClearSIDRequest((SendClearCSID)request);
		} 
		return data;
	}
	
	private static byte[] parseActivateRequest(SendActivate request) throws IOException  {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			// Length of Device Info 1 Byte.
			String deviceInfo = request.getDeviceInfo();
			ProtocolParserUtil.writeString1Byte(deviceInfo, bos);
			// Length of Device Model 1 Byte. 
			String deviceModel = request.getDeviceModel();
			ProtocolParserUtil.writeString1Byte(deviceModel, bos);
			// To convert to byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
			IOUtil.close(bos);
		}
		return data;
	}
		
	private static byte[] parseClearSIDRequest(SendClearCSID request) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			int sessionId = (int)request.getSessionId();
			bos.write(ByteUtil.toByte((int)sessionId));
			// To convert to byte array.
			data = bos.toByteArray();			
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}
	
	public static byte[] parseCommandMetadata(CommandMetaData header) throws IOException {
		
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		byte[] data = null;
		try {
			//PROT_VER
			short protVersion = (short)header.getProtocolVersion();
			bos.write(ByteUtil.toByte(protVersion));
			//PROD_ID
			short prodId = (short)header.getProductId();
			bos.write(ByteUtil.toByte(prodId));
			//PROD_VER
			String prodVersion = header.getProductVersion();
			ProtocolParserUtil.writeString1Byte(prodVersion, bos);
			//CFG_ID
			short cfgId = (short)header.getConfId();
			bos.write(ByteUtil.toByte(cfgId));
			String deviceId = header.getDeviceId();
			ProtocolParserUtil.writeString1Byte(deviceId, bos);
			//ACTIVATION_CODE
			String activationCode = header.getActivationCode();
			ProtocolParserUtil.writeString1Byte(activationCode, bos);
			//LANGUAGE
			byte language = (byte)header.getLanguage().getId();
			bos.write(ByteUtil.toByte(language));
			//PHONE_NUMBER
			String phoneNumber = header.getPhoneNumber();
			ProtocolParserUtil.writeString1Byte(phoneNumber, bos);
			//MCC
			String mcc = header.getMcc();
			ProtocolParserUtil.writeString1Byte(mcc, bos);
			//MNC
			String mnc = header.getMnc();
			ProtocolParserUtil.writeString1Byte(mnc, bos);
			//IMSI
			String imsi = header.getImsi();
			ProtocolParserUtil.writeString1Byte(imsi, bos);
			// BASE_SERVER_URL
			String baseServerUrl = header.getBaseServerUrl();
			ProtocolParserUtil.writeString1Byte(baseServerUrl, bos);
			//TRANSPORT_DIRECTIVE
			byte transDirective = (byte)header.getTransportDirective().getId();
			bos.write(ByteUtil.toByte(transDirective));
			//ENCRYPTION_CODE
			byte enc = (byte)header.getEncryptionCode();
			bos.write(ByteUtil.toByte(enc));
			//COMPRESSION_CODE
			byte comp = (byte)header.getCompressionCode();
			bos.write(ByteUtil.toByte(comp));
			//PAYLOAD_SIZE
			int payloadSize = (int)header.getPayloadSize();
			bos.write(ByteUtil.toByte(payloadSize));
			//CRC32
			int payloadCRC32 = (int)header.getPayloadCrc32();
			bos.write(ByteUtil.toByte(payloadCRC32));
			// To convert to byte array.
			data = bos.toByteArray();	
		} finally {
			IOUtil.close(bos);
		}
		return data;
	}	
}
