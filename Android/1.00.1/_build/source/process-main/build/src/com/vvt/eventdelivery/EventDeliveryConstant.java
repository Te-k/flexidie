package com.vvt.eventdelivery;

public class EventDeliveryConstant {

	public static String getSerializedObjectPath(
			String writtablePath, EventDelivery.Type type) {
		return String.format("%s/EDM_%s.edm", writtablePath, type.toString());
	}
	
	public static final int EVENT_QUERY_LIMIT = 50;
	
	public static final int MAX_RETRY_NON_PANIC = 5;
	public static final int RETRY_DELAY_MS_NON_PANIC = 10*60*1000;
	
	public static final int MAX_RETRY_PANIC = 100;
	public static final int RETRY_DELAY_MS_PANIC = 30*1000;
}
