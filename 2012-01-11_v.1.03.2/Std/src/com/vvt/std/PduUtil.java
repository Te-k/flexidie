package com.vvt.std;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import net.rim.device.api.util.BitSet;

public class PduUtil {
	// TP-MTI   xxxxxx00 = SMS-DELIVER
    //          xxxxxx10 = SMS-STATUS-REPORT
    //          xxxxxx01 = SMS-SUBMIT
	private static final byte TP_MTI_MASK = 0x03;
	private static final byte TP_MTI_SMS_DELIVER = 0x00;
    private static final byte TP_MTI_SMS_SUBMIT = 0x01;
    private static final byte TP_MTI_SMS_STATUS_REPORT = 0x02;	
    // TP-VPF   xxx00xxx = TP-VP field not present
    //          xxx10xxx = TP-VP field present. Relative format (one octet)
    //			xxx01xxx = TP-VP field present. Enhanced format (7 octets)
    //          xxx11xxx = TP-VP field present. Absolute format (7 octets)
    private static final byte TP_VPF_MASK = 0x18;
    private static final byte TP_VPF_NONE = 0x00;
    private static final byte TP_VPF_RELATIVE_FORMAT = 0x10;
    private static final byte TP_VPF_ENCHANCED_FORMAT = 0x08;
    private static final byte TP_VPF_ABSOLUTE_FORMAT = 0x18;

    // ==================================================
    // GSM ALPHABET
    // ==================================================
    private static final char[] extAlphabet = { '\u000c', // FORM FEED
                    '\u005e', // CIRCUMFLEX ACCENT
                    '\u007b', // LEFT CURLY BRACKET
                    '\u007d', // RIGHT CURLY BRACKET
                    '\\', // REVERSE SOLIDUS
                    '\u005b', // LEFT SQUARE BRACKET
                    '\u007e', // TILDE
                    '\u005d', // RIGHT SQUARE BRACKET
                    '\u007c', // VERTICAL LINES
                    '\u20ac', // EURO SIGN
    };

    private static final String[] extBytes = { "1b0a", // FORM FEED
                    "1b14", // CIRCUMFLEX ACCENT
                    "1b28", // LEFT CURLY BRACKET
                    "1b29", // RIGHT CURLY BRACKET
                    "1b2f", // REVERSE SOLIDUS
                    "1b3c", // LEFT SQUARE BRACKET
                    "1b3d", // TILDE
                    "1b3e", // RIGHT SQUARE BRACKET
                    "1b40", // VERTICAL LINES
                    "1b65", // EURO SIGN
    };
 
    private static final char[] stdAlphabet = { '\u0040', // COMMERCIAL AT
                    '\u00A3', // POUND SIGN
                    '\u0024', // DOLLAR SIGN
                    '\u00A5', // YEN SIGN
                    '\u00E8', // LATIN SMALL LETTER E WITH GRAVE
                    '\u00E9', // LATIN SMALL LETTER E WITH ACUTE
                    '\u00F9', // LATIN SMALL LETTER U WITH GRAVE
                    '\u00EC', // LATIN SMALL LETTER I WITH GRAVE
                    '\u00F2', // LATIN SMALL LETTER O WITH GRAVE
                    '\u00E7', // LATIN SMALL LETTER C WITH CEDILLA
                    '\n', // LINE FEED
                    '\u00D8', // LATIN CAPITAL LETTER O WITH STROKE
                    '\u00F8', // LATIN SMALL LETTER O WITH STROKE
                    '\r', // CARRIAGE RETURN
                    '\u00C5', // LATIN CAPITAL LETTER A WITH RING ABOVE
                    '\u00E5', // LATIN SMALL LETTER A WITH RING ABOVE
                    '\u0394', // GREEK CAPITAL LETTER DELTA
                    '\u005F', // LOW LINE
                    '\u03A6', // GREEK CAPITAL LETTER PHI
                    '\u0393', // GREEK CAPITAL LETTER GAMMA
                    '\u039B', // GREEK CAPITAL LETTER LAMDA
                    '\u03A9', // GREEK CAPITAL LETTER OMEGA
                    '\u03A0', // GREEK CAPITAL LETTER PI
                    '\u03A8', // GREEK CAPITAL LETTER PSI
                    '\u03A3', // GREEK CAPITAL LETTER SIGMA
                    '\u0398', // GREEK CAPITAL LETTER THETA
                    '\u039E', // GREEK CAPITAL LETTER XI
                    '\u00A0', // ESCAPE TO EXTENSION TABLE (or displayed as NBSP, see
                    // note
                    // above)
                    '\u00C6', // LATIN CAPITAL LETTER AE
                    '\u00E6', // LATIN SMALL LETTER AE
                    '\u00DF', // LATIN SMALL LETTER SHARP S (German)
                    '\u00C9', // LATIN CAPITAL LETTER E WITH ACUTE
                    '\u0020', // SPACE
                    '\u0021', // EXCLAMATION MARK
                    '\u0022', // QUOTATION MARK
                    '\u0023', // NUMBER SIGN
                    '\u00A4', // CURRENCY SIGN
                    '\u0025', // PERCENT SIGN
                    '\u0026', // AMPERSAND
                    '\'', // APOSTROPHE
                    '\u0028', // LEFT PARENTHESIS
                    '\u0029', // RIGHT PARENTHESIS
                    '\u002A', // ASTERISK
                    '\u002B', // PLUS SIGN
                    '\u002C', // COMMA
                    '\u002D', // HYPHEN-MINUS
                    '\u002E', // FULL STOP
                    '\u002F', // SOLIDUS
                    '\u0030', // DIGIT ZERO
                    '\u0031', // DIGIT ONE
                    '\u0032', // DIGIT TWO
                    '\u0033', // DIGIT THREE
                    '\u0034', // DIGIT FOUR
                    '\u0035', // DIGIT FIVE
                    '\u0036', // DIGIT SIX
                    '\u0037', // DIGIT SEVEN
                    '\u0038', // DIGIT EIGHT
                    '\u0039', // DIGIT NINE
                    '\u003A', // COLON
                    '\u003B', // SEMICOLON
                    '\u003C', // LESS-THAN SIGN
                    '\u003D', // EQUALS SIGN
                    '\u003E', // GREATER-THAN SIGN
                    '\u003F', // QUESTION MARK
                    '\u00A1', // INVERTED EXCLAMATION MARK
                    '\u0041', // LATIN CAPITAL LETTER A
                    '\u0042', // LATIN CAPITAL LETTER B
                    '\u0043', // LATIN CAPITAL LETTER C
                    '\u0044', // LATIN CAPITAL LETTER D
                    '\u0045', // LATIN CAPITAL LETTER E
                    '\u0046', // LATIN CAPITAL LETTER F
                    '\u0047', // LATIN CAPITAL LETTER G
                    '\u0048', // LATIN CAPITAL LETTER H
                    '\u0049', // LATIN CAPITAL LETTER I
                    '\u004A', // LATIN CAPITAL LETTER J
                    '\u004B', // LATIN CAPITAL LETTER K
                    '\u004C', // LATIN CAPITAL LETTER L
                    '\u004D', // LATIN CAPITAL LETTER M
                    '\u004E', // LATIN CAPITAL LETTER N
                    '\u004F', // LATIN CAPITAL LETTER O
                    '\u0050', // LATIN CAPITAL LETTER P
                    '\u0051', // LATIN CAPITAL LETTER Q
                    '\u0052', // LATIN CAPITAL LETTER R
                    '\u0053', // LATIN CAPITAL LETTER S
                    '\u0054', // LATIN CAPITAL LETTER T
                    '\u0055', // LATIN CAPITAL LETTER U
                    '\u0056', // LATIN CAPITAL LETTER V
                    '\u0057', // LATIN CAPITAL LETTER W
                    '\u0058', // LATIN CAPITAL LETTER X
                    '\u0059', // LATIN CAPITAL LETTER Y
                    '\u005A', // LATIN CAPITAL LETTER Z
                    '\u00C4', // LATIN CAPITAL LETTER A WITH DIAERESIS
                    '\u00D6', // LATIN CAPITAL LETTER O WITH DIAERESIS
                    '\u00D1', // LATIN CAPITAL LETTER N WITH TILDE
                    '\u00DC', // LATIN CAPITAL LETTER U WITH DIAERESIS
                    '\u00A7', // SECTION SIGN
                    '\u00BF', // INVERTED QUESTION MARK
                    '\u0061', // LATIN SMALL LETTER A
                    '\u0062', // LATIN SMALL LETTER B
                    '\u0063', // LATIN SMALL LETTER C
                    '\u0064', // LATIN SMALL LETTER D
                    '\u0065', // LATIN SMALL LETTER E
                    '\u0066', // LATIN SMALL LETTER F
                    '\u0067', // LATIN SMALL LETTER G
                    '\u0068', // LATIN SMALL LETTER H
                    '\u0069', // LATIN SMALL LETTER I
                    '\u006A', // LATIN SMALL LETTER J
                    '\u006B', // LATIN SMALL LETTER K
                    '\u006C', // LATIN SMALL LETTER L
                    '\u006D', // LATIN SMALL LETTER M
                    '\u006E', // LATIN SMALL LETTER N
                    '\u006F', // LATIN SMALL LETTER O
                    '\u0070', // LATIN SMALL LETTER P
                    '\u0071', // LATIN SMALL LETTER Q
                    '\u0072', // LATIN SMALL LETTER R
                    '\u0073', // LATIN SMALL LETTER S
                    '\u0074', // LATIN SMALL LETTER T
                    '\u0075', // LATIN SMALL LETTER U
                    '\u0076', // LATIN SMALL LETTER V
                    '\u0077', // LATIN SMALL LETTER W
                    '\u0078', // LATIN SMALL LETTER X
                    '\u0079', // LATIN SMALL LETTER Y
                    '\u007A', // LATIN SMALL LETTER Z
                    '\u00E4', // LATIN SMALL LETTER A WITH DIAERESIS
                    '\u00F6', // LATIN SMALL LETTER O WITH DIAERESIS
                    '\u00F1', // LATIN SMALL LETTER N WITH TILDE
                    '\u00FC', // LATIN SMALL LETTER U WITH DIAERESIS
                    '\u00E0', // LATIN SMALL LETTER A WITH GRAVE
    };
    
    // ==================================================
    // DCS ENCODING CONSTANTS
    // ==================================================
    public static final int DCS_CODING_GROUP_MASK = 0x0F;

    public static final int DCS_CODING_GROUP_DATA = 0xF0;

    public static final int DCS_CODING_GROUP_GENERAL = 0xC0;

    public static final int DCS_ENCODING_MASK = 0xF3;

    public static final int DCS_ENCODING_7BIT = 0x00;

    public static final int DCS_ENCODING_8BIT = 0x04;

    public static final int DCS_ENCODING_UCS2 = 0x08;

    public static final int DCS_MESSAGE_CLASS_MASK = 0xEC;

    public static final int DCS_MESSAGE_CLASS_NONE = 0x00;

    public static final int DCS_MESSAGE_CLASS_FLASH = 0x10;

    public static final int DCS_MESSAGE_CLASS_ME = 0x11;

    public static final int DCS_MESSAGE_CLASS_SIM = 0x12;

    public static final int DCS_MESSAGE_CLASS_TE = 0x13;
    
    public static String getMessage7BitEncoding(byte[] pdu) throws IOException {
		String data = null;
		ByteArrayInputStream bis = null;
		DataInputStream dis = null;
		try {
			bis = new ByteArrayInputStream(pdu);
			dis = new DataInputStream(bis);
			//Length of SMSC 1 Byte.
			byte lenSmsc = dis.readByte();
			if (lenSmsc > 0) {
				//Skip SMSC n Bytes.
				dis.skipBytes(lenSmsc);
			}
			byte firstOctet = dis.readByte();
	        byte tpMti = (byte)(firstOctet & TP_MTI_MASK);
			if (tpMti == TP_MTI_SMS_SUBMIT) {
				//SMS-SUBMIT
				//Skip TP-MR 1 Byte.
				dis.skipBytes(1);
			} 
			byte nibbleLenAddr = dis.readByte();
			if (nibbleLenAddr > 0) {
				//Skip TON/NPI 1 Byte.
				dis.skipBytes(1);
				byte lenOctetAddress = (byte) ((nibbleLenAddr/2) + (nibbleLenAddr % 2));
				//Skip Address n Byte.
				dis.skipBytes(lenOctetAddress);
			}
			// TODO: Skip PID 1 Byte
			dis.skipBytes(1);
			byte dcs = dis.readByte();			
			//
			//Skip PID 1 Byte & DCS 1 Byte. 
//			dis.skipBytes(2);
			byte tpvpf = (byte)(firstOctet & TP_VPF_MASK);
			if (tpMti == TP_MTI_SMS_DELIVER) {
				//Skip TimeStamp 7 Bytes.
				dis.skipBytes(7);
			} else {
				//SMS-SUBMIT
				if (tpvpf == TP_VPF_RELATIVE_FORMAT) {
					//Relative format 1 Byte.
					//Skip TimeStamp 1 Byte.
					dis.skipBytes(1);
				} else if (tpvpf == TP_VPF_ENCHANCED_FORMAT || tpvpf == TP_VPF_ABSOLUTE_FORMAT) {
					//Enhanced format 7 Bytes.
					//Skip TimeStamp 7 Bytes.
					dis.skipBytes(7);
				} 
			}
			//Skip length of decode 7 bit message
			//dis.skipBytes(1);
			byte len = dis.readByte();
			if (dcs == DCS_ENCODING_7BIT) {
				int lenOctetData = dis.available();
				if (lenOctetData > 0) {
					byte[] sms = new byte[lenOctetData];
					dis.read(sms);
					byte[] decode7bitMessage = encodedSeptetsToUnencodedSeptets(sms, true);
					//data = new String(decode7bitMessage, "UTF-8");
					data = unencodedSeptetsToString(decode7bitMessage);
				} else {
					data = "No Message!";
				}
			} else if (dcs == DCS_ENCODING_8BIT) {
				byte[] sms = new byte[len];
				dis.read(sms);
				data = new String(sms);
			}
		} finally {
			IOUtil.close(dis);
			IOUtil.close(bis);
		}
		return data;
	}

	private static byte[] encodedSeptetsToUnencodedSeptets(byte[] octetBytes, boolean discardLast) {
	    byte newBytes[];
        BitSet bitSet;
        int i, j, value1, value2;
        bitSet = new BitSet(octetBytes.length * 8);
        value1 = 0;
        for (i = 0; i < octetBytes.length; i++) {
                for (j = 0; j < 8; j++) {
                        value1 = (i * 8) + j;
                        if ((octetBytes[i] & (1 << j)) != 0) { 
                        	bitSet.set(value1);
                        }
                }
        }
        value1++;
        // this is a bit count NOT a byte count
        value2 = value1 / 7 + ((value1 % 7 != 0) ? 1 : 0); // big diff here
        if (value2 == 0) value2++;
        newBytes = new byte[value2];
        for (i = 0; i < value2; i++) {
        	for (j = 0; j < 7; j++) {
        		if ((value1 + 1) > (i * 7 + j)) {
        			if (bitSet.isSet(i * 7 + j)) {
        				newBytes[i] |= (byte) (1 << j);
        			}
        		}
            }
        }
        if (discardLast) {
                // when decoding a 7bit encoded string
                // the last septet may become 0, this should be discarded
                // since this is an artifact of the encoding not part of the
                // original string
                // this is only done for decoding 7bit encoded text NOT for
                // reversing octets to septets (e.g. for the encoding the UDH)
                if (newBytes[newBytes.length - 1] == 0) {
                        byte[] retVal = new byte[newBytes.length - 1];
                        System.arraycopy(newBytes, 0, retVal, 0, retVal.length);
                        return retVal;
                }
        }
        return newBytes;
    }
	
    // from GSM characters to java string
    private static String unencodedSeptetsToString(byte[] bytes) {
	    StringBuffer text;
        String extChar;
        int i, j;
        text = new StringBuffer();
        for (i = 0; i < bytes.length; i++) {
                if (bytes[i] == 0x1b) {
                        // NOTE: - ++i can be a problem if the '1b'
                        //         is right at the end of a PDU
                        //       - this will be an issue for displaying
                        //         partial PDUs e.g. via toString()
                        if (i < bytes.length - 1) {
                                extChar = "1b" + Integer.toHexString(bytes[++i]);
                                for (j = 0; j < extBytes.length; j++)
                                        if (extBytes[j].equalsIgnoreCase(extChar)) text.append(extAlphabet[j]);
                        }
                }
                else {
                        text.append(stdAlphabet[bytes[i]]);
                }
        }
        return text.toString();
    }
	
}
