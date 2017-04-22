package com.vvt.callmanager.std;


public class CallMgrUtil {
	
	public static final int DIGIT_MODE_4BIT_DTMF = 0x00;
	
	/**
	 * Copy from IccUtils.java.
	 * Converts a hex String to a byte array.
	 * @param s A string of hexadecimal characters, must be an even number of
	 *          chars long
	 * @return byte array representation
	 * @throws RuntimeException on invalid format
	 */
	public static byte[] hexStringToBytes(String s) {
	    byte[] ret;
	
	    if (s == null) return null;
	
	    int sz = s.length();
	
	    ret = new byte[sz/2];
	
	    for (int i=0 ; i <sz ; i+=2) {
	        ret[i/2] = (byte) ((hexCharToInt(s.charAt(i)) << 4)
	                            | hexCharToInt(s.charAt(i+1)));
	    }
	    return ret;
	}

	private static int hexCharToInt(char c) {
        if (c >= '0' && c <= '9') return (c - '0');
        if (c >= 'A' && c <= 'F') return (c - 'A' + 10);
        if (c >= 'a' && c <= 'f') return (c - 'a' + 10);

        throw new RuntimeException ("invalid hex char '" + c + "'");
    }
	
	/**
	 * Converts a 4-Bit DTMF encoded symbol from the calling address number to ASCII character
	 */
	public static byte convertDtmfToAscii(byte dtmfDigit) {
	    byte asciiDigit;
	
	    switch (dtmfDigit) {
	    case  0: asciiDigit = 68; break; // 'D'
	    case  1: asciiDigit = 49; break; // '1'
	    case  2: asciiDigit = 50; break; // '2'
	    case  3: asciiDigit = 51; break; // '3'
	    case  4: asciiDigit = 52; break; // '4'
	    case  5: asciiDigit = 53; break; // '5'
	    case  6: asciiDigit = 54; break; // '6'
	    case  7: asciiDigit = 55; break; // '7'
	    case  8: asciiDigit = 56; break; // '8'
	    case  9: asciiDigit = 57; break; // '9'
	    case 10: asciiDigit = 48; break; // '0'
	    case 11: asciiDigit = 42; break; // '*'
	    case 12: asciiDigit = 35; break; // '#'
	    case 13: asciiDigit = 65; break; // 'A'
	    case 14: asciiDigit = 66; break; // 'B'
	    case 15: asciiDigit = 67; break; // 'C'
	    default:
	        asciiDigit = 32; // Invalid DTMF code
	        break;
	    }
	
	    return asciiDigit;
	}
	
}
