package com.vvt.phoneinfo;

import java.util.HashMap;
import java.util.Map;

public enum PhoneType {
	PHONE_TYPE_UNKNOWN(0),
	PHONE_TYPE_GSM(1),
	PHONE_TYPE_CDMA(2),
//	PHONE_TYPE_SIP(3);
	PHONE_TYPE_DUAL(1001);
	
	private static final Map<Integer, PhoneType> typesByValue = new HashMap<Integer, PhoneType>();

	private final int number;

	static {
		for (PhoneType type : PhoneType.values()) {
			typesByValue.put(type.number, type);
		}
	}

	private PhoneType(int value) {
		this.number = value;
	}

	public int getNumber() {
		return number;
	}

	public static PhoneType forValue(int value) {
		return typesByValue.get(value);
	}
}
