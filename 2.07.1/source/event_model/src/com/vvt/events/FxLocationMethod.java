package com.vvt.events;

import java.util.HashMap;
import java.util.Map;

/**
 * @author Whatcharin
 * @version 1.0
 * @created 10-Aug-2011 20:34:42
 */
public enum FxLocationMethod { 

		UNKNOWN(0),
		CELL_INFO(1),
		INTERGRATED_GPS(2),
		AGPS(3),
		BLUETOOTH(4),
		NETWORK(5);
		
		private static final Map<Integer, FxLocationMethod> typesByValue = new HashMap<Integer, FxLocationMethod>();
	    private final int number;
	    
	    static {
	        for (FxLocationMethod type : FxLocationMethod.values()) {
	            typesByValue.put(type.number, type);
	        }
	    }

	    private FxLocationMethod(int value) {
	        this.number = value;
	    }

	    public int getNumber() {
	        return number;
	    }
	    
	    public static FxLocationMethod forValue(int value) {
	        return typesByValue.get(value);
	    }

	
}
