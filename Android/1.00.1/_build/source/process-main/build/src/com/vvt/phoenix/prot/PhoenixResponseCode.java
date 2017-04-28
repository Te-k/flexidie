package com.vvt.phoenix.prot;

/**
 * @author tanakharn
 * @version 1.0
 * @created 10-Nov-2010 11:10:46 AM
 */
public class PhoenixResponseCode {
	
	public static final int OK 										= 0;
	
	// License Error
	public static final int LICENSE_NOT_FOUND 						= 100;
	public static final int LICENSE_ALREADY_IN_USE 					= 101;
	public static final int LICENSE_EXPIRED 						= 102;
	public static final int LICENSE_NOT_ASSIGNED_TO_ANY_DEVICE 		= 103;
	public static final int LICENSE_NOT_ASSIGNED_TO_USER 			= 104;
	public static final int LICENSE_CORRUPT 						= 105;
	public static final int LICENSE_DISABLED 						= 106;
	public static final int INVALID_HOST_FOR_LICENSE 				= 107;
	public static final int LICENSE_IS_FIXED 						= 108;
	public static final int PRODUCT_NOT_COMPATIBLE_WITH_PID 		= 109;
	public static final int AUTO_ACTIVATION_NOT_ALLOWED 			= 110;
	public static final int NO_LICENSES_AVAILABLE 					= 111;
	
	// License Generator
	public static final int LICENSE_GENERATOR_GENERAL_ERROR  		= 200;
	public static final int LICENSE_GENERATOR_AUTHENTICATION_ERROR  = 201;
	
	// Protocol Errors
	public static final int HEADER_CHECKSUM_FAILED  				= 300;
	public static final int CANNOT_PARSE_HEADER	  					= 301;
	public static final int CANNOT_PROCESS_UNENCRYPTED_HEADER		= 302;
	public static final int CANNOT_PARSE_PAYLOAD					= 303;
	public static final int PAYLOAD_TOO_BIG							= 304;
	public static final int PAYLOAD_CHECKSUM_FAILED 				= 305;
	public static final int SESSION_NOT_FOUND 						= 306;
	public static final int SERVER_BUSY_PROCESSING_CSID				= 307;
	public static final int SESSION_ALREADY_COMPLETE				= 308;
	public static final int INCOMPLETE_PAYLOAD						= 309;
	public static final int SERVER_BUSY								= 310;
	public static final int SESSION_DATA_INCOMPLETE					= 311;
	
	// Device Error
	public static final int DEVICE_ID_NOT_FOUND						= 400;
	public static final int DEVICE_ID_ALREADY_REGISTERED			= 401;
	public static final int DEVICE_ID_MISMATCH						= 402;
	
	// Application Error
	public static final int UNSPECIFIED_ERROR						= 500;
	public static final int ACTIVATION_LIMIT_REACHED				= 501;
	public static final int PRODUCT_VERSION_NOT_FOUND				= 502;
	
	// Encryption
	public static final int ERROR_DURING_DECRYPTION					= 600;
	public static final int ERROR_DURING_DECOMPRESSION				= 601;
	
	/*
	 * Old codes
	 * 
	public static final int OK = 0;
	public static final int CHECKSUM_FAILED = 0xA0;
	public static final int CANNOT_PARSE_HEADER = 0xA1;
	public static final int DEVICE_NOT_REGISTER = 0xA3;
	public static final int CANNOT_FIND_FREE_LICENSE = 0xA4;
	public static final int LICENSE_ILLEGALLY_MODIFIED = 0xB0;
	public static final int REQUEST_LICENSE_NOT_ALLOWED = 0xB3;
	public static final int REQUEST_LICENSE_FAILED = 0xB4;
	public static final int PAYLOAD_PARSER_ERROR = 0xE0;
	public static final int EXCEED_PAYLOAD_SIZE_LIMIT = 0xE1;
	public static final int PAYLOAD_CHECKSUM_FAILED = 0xE2;
	public static final int SESSION_NOT_FOUND = 0xE3;
	public static final int CSID_BEING_PROCESSED = 0xE4;
	public static final int SESSION_COMPLETED = 0xE5;
	public static final int INCOMPLETE_DATA = 0xE6;
	public static final int INVALID_TRANSPORT_DIRECTIVE = 0xE7;
	public static final int UNSPECIFIED_ERROR = 0xF0;
	public static final int WRONG_ACTIVATION_CODE = 0xFE;
	public static final int ACTIVATION_CODE_IN_USE = 0xFD;
	public static final int INVALID_ACTIVATION_CODE = 0xFC;
	public static final int ACCOUNT_DISABLED = 0xFA;
	public static final int SUBSCRIPTION_EXPIRED = 0xF9;
	public static final int ACCOUNT_NOT_FOUND = 0xF8;
	public static final int IMCOMPATIBLE_PRODUCT = 0xF7;
	public static final int ACTIVATION_LIMIT_REACHE = 0xF6;
	public static final int DEVICE_ID_HAS_ALREADY_BEEN_USED = 0xF5;
	public static final int DEVICE_ID_DONOT_MATCH_FOR_DEACTIVATE = 0xF4;
	public static final int DECRYPTION_ERROR = 0xF3;
	public static final int INVALID_AES_KEY = 0xF2;
	public static final int DECOMPRESSION_ERROR = 0xF1;
	public static final int DEVICE_HAS_DEACTIVATED = 0xD0;
	public static final int UNSTRUCTURED_SESSION_NOT_FOUND = 0xC0;
	public static final int UNSTRUCTURED_SESSION_DATA_NOT_COMPLETE = 0xC1;
	*/
}