package com.vvt.http.request;

import java.util.HashMap;
import java.util.Map;

public enum MethodType {

	GET(0),
	POST(1);
	
	private static final Map<Integer, MethodType> typesByValue = new HashMap<Integer, MethodType>();

	private final int number;

	static {
		for (MethodType type : MethodType.values()) {
			typesByValue.put(type.number, type);
		}
	}

	private MethodType(int value) {
		this.number = value;
	}

	public int getNumber() {
		return number;
	}

	public static MethodType forValue(int value) {
		return typesByValue.get(value);
	}
}
