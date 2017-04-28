package com.vvt.ioutil;

public class BinaryUtil {

	/**
	 * Converts the data bytes to a string using format 1. 
	 */
	public static String bytesToString1(byte[] aData) {
		StringBuilder aOut = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				aOut.append(String.format(" [%2d]=%02X", i, aData[i]));
			}
		}
		return aOut.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 2. 
	 */
	public static String bytesToString2(byte[] aData) {
		StringBuilder aOut = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				byte b = aData[i];
				char c = (char) b;
				if ((c >= 'a' && c <= 'z') || 
					(c >= 'A' && c <= 'Z') || 
					(c >= '0' && c <= '9') || 
					(c == '@') ||
					(c == '/') ||
					(c == ' ') || 
					(c == '.')) {
					aOut.append(c);
				} else {
					aOut.append(String.format("\\x%02X", b));
				}
			}
		}
		return aOut.toString();
	}
	
	/**
	 * Converts the data bytes starting from the given index to the index aEndIndex - 1 
	 * to a string using format 2. 
	 */
	public static String bytesToString2(byte[] aData, int aStartIndex, int aEndIndex) {
		StringBuilder aOut = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				if (i >= aStartIndex && i < aEndIndex) {
					byte b = aData[i];
					char c = (char) b;
					if ((c >= 'a' && c <= 'z') || 
						(c >= 'A' && c <= 'Z') || 
						(c >= '0' && c <= '9') || 
						(c == '@') ||
						(c == '/') ||
						(c == ' ') || 
						(c == '.')) {
						aOut.append(c);
					} else {
						aOut.append(String.format("\\x%02X", b));
					}
				}
			}
		}
		return aOut.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 3. 
	 */
	public static String bytesToString3(byte[] aData) {
		StringBuilder out = new StringBuilder();
		if (aData != null) {
			boolean addSpace = false;
			out.append("<");
			for (int i = 0 ; i < aData.length ; i++) {
				if (addSpace) {
					out.append(" ");
					addSpace = false;
				}
				byte b = aData[i];
				out.append(String.format("%02x", b));
				if (i % 4 == 3) {
					addSpace = true;
				}
			}
			out.append(">");
		}
		return out.toString();
	}
	
	/**
	 * Converts the data bytes to a string using format 4. 
	 */
	public static String bytesToString4(byte[] aData) {
		StringBuilder out = new StringBuilder();
		if (aData != null) {
			for (int i = 0 ; i < aData.length ; i++) {
				out.append(String.format("%02X", aData[i]));
			}
		}
		return out.toString();
	}
	
	/**
	 * Converts two bytes of data in the given byte array to short value.
	 */
	public static short bytesToShort(byte[] aData, int aStartIndex, boolean aBigendian) {		
		short aShort;
		
		if (aBigendian) aShort = (short) ((aData[aStartIndex] << 8) | aData[aStartIndex + 1]);
		else 			aShort = (short) ((aData[aStartIndex + 1] << 8) | aData[aStartIndex]);
		
		return aShort;
	}
	
	/**
	 * Converts a short number to 2 bytes of byte array.
	 */
	public static byte[] shortToBytes(short aShort) {		
		byte[] aBytes = new byte[2];
		
		aBytes[0] = (byte) ((aShort & 0xff00) >> 8);
		aBytes[1] = (byte) (aShort & 0x00ff);
		
		return aBytes;
	}
	
	/**
	 * Converts four bytes of data in the given byte array to int value.
	 */
	public static int bytesToInt(byte[] aData, int aStartIndex, boolean aBigendian) {		
		int aInt;
		
		if (aBigendian) {
			aInt = aData[aStartIndex] << 32 | 
					aData[aStartIndex + 1] << 16 | 
					aData[aStartIndex + 2] << 8 | 
					aData[aStartIndex + 3];
		} 
		else {
			aInt = aData[aStartIndex + 3] << 32 | 
					aData[aStartIndex + 2] << 16 | 
					aData[aStartIndex + 1] << 8 | 
					aData[aStartIndex];
		}
		
		return aInt;
	}
	
}
