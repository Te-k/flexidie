package com.vvt.base;

import java.util.HashMap;
import java.util.Map;

public enum ProductType {
	CYCLOPS(4102), FLEXISPY(5002);

	private static final Map<Integer, ProductType> typesByValue = new HashMap<Integer, ProductType>();
	private final int number;

	static {
		for (ProductType type : ProductType.values()) {
			typesByValue.put(type.number, type);
		}
	}

	private ProductType(int value) {
		this.number = value;
	}

	public int getNumber() {
		return number;
	}

	public static ProductType forValue(int value) {
		return typesByValue.get(value);
	}
}
