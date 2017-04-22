package com.vvt.prot.parser;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import com.vvt.prot.unstruct.request.AckRequest;
import com.vvt.prot.unstruct.request.AckSecRequest;
import com.vvt.prot.unstruct.request.KeyExchangeRequest;
import com.vvt.prot.unstruct.request.PingRequest;
import com.vvt.prot.unstruct.request.UnstructRequest;
import com.vvt.std.ByteUtil;
import com.vvt.std.IOUtil;

public class UnstructParser {

	public static byte[] parseRequest(UnstructRequest request) throws Exception {		
		byte[] data = null;
		if (request instanceof KeyExchangeRequest) {
			data = parseKeyExchangeRequest((KeyExchangeRequest)request);
		} else if (request instanceof AckSecRequest) {
			data = parseAckSecRequest((AckSecRequest)request);
		} else if (request instanceof AckRequest) {
			data = parseAckRequest((AckRequest)request);
		} else if (request instanceof PingRequest) {
			data = parsePingRequest((PingRequest)request);
		}
		return data;
	}
	
	private static byte[] parseKeyExchangeRequest(KeyExchangeRequest request) throws Exception {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		byte[] data = null;
		try {
			short cmdCode = (short)request.getCommandCode().getId();
			dos.write(ByteUtil.toByte(cmdCode));
			short code = (short)request.getCode();
			dos.write(ByteUtil.toByte(code));
			byte encType = (byte)request.getEncodeType();
			dos.write(ByteUtil.toByte(encType));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(dos);
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseAckSecRequest(AckSecRequest request) throws Exception {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		byte[] data = null;
		try {
			short cmdCode = (short)request.getCommandCode().getId();
			dos.write(ByteUtil.toByte(cmdCode));
			short code = (short)request.getCode();
			dos.write(ByteUtil.toByte(code));
			int sessionId = (int) request.getSessionId();
			dos.write(ByteUtil.toByte(sessionId));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(dos);
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parseAckRequest(AckRequest request) throws Exception {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		byte[] data = null;
		try {
			//CMD_CODE 2 Bytes
			short cmdCode = (short)request.getCommandCode().getId();
			dos.write(ByteUtil.toByte(cmdCode));
			//CODE 2 Bytes
			short code = (short)request.getCode();
			dos.write(ByteUtil.toByte(code));
			//SESSION_ID 4 Bytes
			int sessionId = (int)request.getSessionId();
			dos.write(ByteUtil.toByte(sessionId));
			//DEVICE_ID'S LENGTH 1 Byte
			byte[] deviceId = request.getDeviceId();
			if ( deviceId != null ) {
				byte lenDeviceId = (byte)request.getDeviceId().length;
				dos.write(ByteUtil.toByte(lenDeviceId));
				if (lenDeviceId > 0) {
					//DEVICE_ID
					dos.write(request.getDeviceId());
				}
			} else {
				dos.write(ByteUtil.toByte((byte)0));
			}
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(dos);
			IOUtil.close(bos);
		}
		return data;
	}
	
	private static byte[] parsePingRequest(PingRequest request) throws Exception {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		DataOutputStream dos = new DataOutputStream(bos);
		byte[] data = null;
		try {
			short cmdCode = (short)request.getCommandCode().getId();
			dos.write(ByteUtil.toByte(cmdCode));
			short code = (short)request.getCode();
			dos.write(ByteUtil.toByte(code));
			// To byte array.
			data = bos.toByteArray();
		} finally {
			IOUtil.close(dos);
			IOUtil.close(bos);
		}
		return data;
	}	
}