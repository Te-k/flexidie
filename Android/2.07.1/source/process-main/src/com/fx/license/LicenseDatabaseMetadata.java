package com.fx.license;

public class LicenseDatabaseMetadata {

	public static final String AUTHORITY = "com.fx.dalvik.license";
	public static final String DB_NAME = "license.db";
	
	private LicenseDatabaseMetadata() {
		// Disable instantiation
	}
	
	public final class License {
		public static final String TABLE_NAME = "license";
		public static final String URI = "content://" + AUTHORITY + "/" + TABLE_NAME;
		
		public static final String ACTIVATION_STATUS = "activation_status";
		public static final String ACTIVATION_CODE = "activation_code";
		public static final String SERVER_HASH = "server_hash";
		public static final String CONFIGURATION_ID = "configuration_id";
	}
	
}
