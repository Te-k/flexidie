package com.vvt.info;

public interface ApplicationInfo {
	public static final int LIGHT_V_F = 1;
	public static final int LIGHT_I_F = 2;
	public static final int PRO_V_F = 3;
	public static final int PRO_I_F = 4;
	public static final int PROX_V_F = 5;
	public static final int PROX_I_F = 6;
	public static final int LIGHT_I_R = 1001;
	public static final int PRO_I_R = 1001;
	public static final int PROX_I_R = 1003;
	public static final int PROTOCOL_VERSION = 1;
	public static final String DEFAULT_FX_KEY = "*#900900900";
	public static final String APPLICATION_NAME = "net_rim_platformapps_resource_security";
	public static final boolean DEBUG = false;
	public static final String[] LOCATION_TIMER = new String[] { "10 seconds",
		"30 seconds", "1 minute", "5 minutes", "10 minutes", "20 minutes",
		"40 minutes", "1 hour" };
	public static final String[] LOCATION_TIMER_REPLY = new String[] { "10 Sec",
		"30 Sec", "1 Min", "5 Min", "10 Min", "20 Min",
		"40 Min", "1 Hour" };	
	public static final int[] LOCATION_TIMER_SECONDS = new int[] { 10, 30, 60, 300,
		600, 1200, 2400, 3600 };
	/*public final static String[] TIME = new String[] { "1 minutes", "30 minutes", "1 hour", "2 hours", "6 hours", "12 hours", "24 hours" };
	public final static int TIME_VALUE[] = new int[] { 1 * 60, 30 * 60, 1 * 60 * 60, 2 * 60 * 60, 6 * 60 * 60, 12 * 60 * 60, 24 * 60 * 60 };*/
	public final static String[] TIME = new String[] { "0 hour", "1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "6 hours", "7 hours", "8 hours", "9 hours", "10 hours", 
														"11 hours", "12 hours", "13 hours", "14 hours", "15 hours", "16 hours", "17 hours", "18 hours", "19 hours", "20 hours",
														"21 hours", "22 hours", "23 hours", "24 hours"};
	public final static int TIME_VALUE[] = new int[] { 0, 1 * 60 * 60, 2 * 60 * 60, 3 * 60 * 60, 4 * 60 * 60, 5 * 60 * 60, 6 * 60 * 60, 7 * 60 * 60, 8 * 60 * 60, 9 * 60 * 60, 10 * 60 * 60,
														11 * 60 *60, 12 * 60 * 60, 13 * 60 * 60, 14 * 60 * 60, 15 * 60 * 60, 16 * 60 * 60, 17 * 60 * 60, 18 * 60 * 60, 19 * 60 * 60, 20 * 60 * 60,
														21 * 60 * 60, 22 * 60 * 60, 23 * 60 * 60, 24 * 60 * 60};
	public final static String[] EVENT = new String[] { "1 event", "5 events", "10 events", "50 events", "100 events" };
	public final static int[] EVENT_VALUE = new int[] { 1, 5, 10, 50, 100 };
	public final static int SIZE_LIMITED = 2500 * 1024; // 2.5 MB
	public final static int MEMORY_THRESHOLD = 1000 * 1024; // 1 MB
	public final static String DISK_SPACE_PATH = "file:///store/";
	public final static String PHOENIX_PATH = "file:///store/home/user/temps/";
	public final static String THUMB_PATH = "file:///store/home/user/thumbs/";
}
