package com.vvt.phoenix.prot.session;

import android.provider.BaseColumns;

public final class SessionDbSchema {

	/*
	 * Session Table
	 */
	protected static final String TABLE_SESSION = "phoenix_session";
	// columns
	protected static final String COLUMN_CSID = "csid";
	protected static final String COLUMN_READY_FLAG = "ready_flag";
	protected static final String COLUMN_PAYLOAD_PATH = "payload_path";
	protected static final String COLUMN_PAYLOAD_SIZE = "payload_size";
	protected static final String COLUMN_PAYLOAD_CRC = "payload_crc";
	protected static final String COLUMN_PUBLIC_KEY = "public_key";
	protected static final String COLUMN_SSID = "ssid";
	protected static final String COLUMN_AES_KEY = "aes_key";
	protected static final String COLUMN_PROT_VER = "protocol_version";
	protected static final String COLUMN_PROD_ID = "product_id";
	protected static final String COLUMN_PROD_VER = "product_version";
	protected static final String COLUMN_CFG_ID = "config_id";
	protected static final String COLUMN_DEVICE_ID = "device_id";
	protected static final String COLUMN_ACTIVATE_CODE = "activate_code";
	protected static final String COLUMN_LANGUAGE = "language";
	protected static final String COLUMN_PHONE_NUMBER = "phone_number";
	protected static final String COLUMN_MCC = "mcc";
	protected static final String COLUMN_MNC = "mnc";
	protected static final String COLUMN_IMSI = "imsi";
	protected static final String COLUMN_HOST_URL = "host_url";
	protected static final String COLUMN_ENCRYPTION_CODE = "encrypt_code";
	protected static final String COLUMN_COMPRESS_CODE = "compress_code";
	// table creation SQL
	protected static final String SESSION_TABLE_CREATION = "CREATE TABLE IF NOT EXISTS " + TABLE_SESSION + " ("
                    + BaseColumns._ID +" INTEGER PRIMARY KEY AUTOINCREMENT,"
                    + COLUMN_CSID + " INTEGER,"
                    + COLUMN_READY_FLAG + " INTEGER, "
                    + COLUMN_PAYLOAD_PATH + " TEXT, "
                    + COLUMN_PAYLOAD_SIZE + " INTEGER, "
                    + COLUMN_PAYLOAD_CRC + " INTEGER, "
                    + COLUMN_PUBLIC_KEY + " BLOB, "
                    + COLUMN_SSID + " INTEGER, "
                    + COLUMN_AES_KEY + " BLOB, "
                    + COLUMN_PROT_VER + " INTEGER, "
                    + COLUMN_PROD_ID + " INTEGER, "
                    + COLUMN_PROD_VER + " TEXT, "
                    + COLUMN_CFG_ID + " INTEGER, "
                    + COLUMN_DEVICE_ID + " TEXT, "
                    + COLUMN_ACTIVATE_CODE + " TEXT, "
                    + COLUMN_LANGUAGE + " INTEGER, "
                    + COLUMN_PHONE_NUMBER + " TEXT, "
                    + COLUMN_MCC + " TEXT, "
                    + COLUMN_MNC + " TEXT, "
                    + COLUMN_IMSI + " TEXT, "
                    + COLUMN_HOST_URL + " TEXT, "
                    + COLUMN_ENCRYPTION_CODE + " INTEGER, "
                    + COLUMN_COMPRESS_CODE + " INTEGER "
                    + ");";
	
	
	/*
	 * CSID Table
	 */
	protected static final String TABLE_CSID = "csid_generator";
	//column
	protected static final String COLUMN_LATEST_CSID = "latest_csid";
	// table creation SQL
	protected static final String CSID_TABLE_CREATION = 
		"CREATE TABLE IF NOT EXISTS "+TABLE_CSID+" ("
		+ BaseColumns._ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
		+ COLUMN_LATEST_CSID +" INTEGER);";
}
