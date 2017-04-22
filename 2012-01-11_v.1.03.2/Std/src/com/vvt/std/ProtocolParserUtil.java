package com.vvt.std;

import java.io.IOException;
import java.io.OutputStream;

public class ProtocolParserUtil {
	
	public static void writeString1Byte(String str, OutputStream os) throws IOException {
		if (str != null) {
			byte[] data = ByteUtil.toByte(str);
			byte len = (byte) data.length;
			// Length 1 byte
			os.write(ByteUtil.toByte(len));
			if (len > 0) {
				// Data n bytes
				os.write(data);
			}
		} else {
			os.write(ByteUtil.toByte((byte) 0));
		}
	}
	
	public static void writeString2Bytes(String str, OutputStream os) throws IOException {
		if (str != null) {
			byte[] data = ByteUtil.toByte(str);
			short len = (short) data.length;
			// Length 2 bytes
			os.write(ByteUtil.toByte(len));
			if (len > 0) {
				// Data n bytes
				os.write(data);
			}
		} else {
			os.write(ByteUtil.toByte((short) 0));
		}
	}
	
	public static void writeString4Bytes(String str, OutputStream os) throws IOException {
		if (str != null) {
			byte[] data = ByteUtil.toByte(str);
			int len = data.length;
			// Length 4 bytes
			os.write(ByteUtil.toByte(len));
			if (len > 0) {
				// Data n bytes
				os.write(data);
			}
		} else {
			os.write(ByteUtil.toByte((int) 0));
		}
	}
}
