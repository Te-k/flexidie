package com.vvt.prot;

public class StatusCode {

	public static final StatusCode OK 									= new StatusCode(0);
	public static final StatusCode CHECKSUM_FAILED 						= new StatusCode(0xA0);
	public static final StatusCode CANNOT_PARSE_HEADER 					= new StatusCode(0xA1);
	public static final StatusCode DEVICE_NOT_REGISTER 					= new StatusCode(0xA3);
	public static final StatusCode CANNOT_FIND_FREE_LICENSE 			= new StatusCode(0xA4);
	//Error License
	public static final StatusCode LICENSE_ILLEGALLY_MODIFIED 			= new StatusCode(0xB0);
	public static final StatusCode REQUEST_LICENSE_NOT_ALLOWED 			= new StatusCode(0xB3);
	public static final StatusCode REQUEST_LICENSE_FAILED 				= new StatusCode(0xB4);
	//Error Transport (SEND, RSEND and RASK)
	public static final StatusCode PAYLOAD_PARSER_ERROR 				= new StatusCode(0xE0);
	public static final StatusCode EXCEED_PAYLOAD_SIZE_LIMIT 			= new StatusCode(0xE1);
	public static final StatusCode PAYLOAD_CHECKSUM_FAILED 				= new StatusCode(0xE2);
	public static final StatusCode SESSION_NOT_FOUND 					= new StatusCode(0xE3);
	public static final StatusCode CSID_BEING_PROCESSED 				= new StatusCode(0xE4);
	public static final StatusCode SESSION_COMPLETED 					= new StatusCode(0xE5);
	public static final StatusCode INCOMPLETE_DATA 						= new StatusCode(0xE6);
	public static final StatusCode INVALID_TRANSPORT_DIRECTIVE 			= new StatusCode(0xE7);
	//Application Error
	public static final StatusCode UNSPECIFIED_ERROR 					= new StatusCode(0xF0);
	public static final StatusCode WRONG_ACTIVATION_CODE 				= new StatusCode(0xFE);
	public static final StatusCode ACTIVATION_CODE_IN_USE 				= new StatusCode(0xFD);
	public static final StatusCode INVALID_ACTIVATION_CODE 				= new StatusCode(0xFC);
	public static final StatusCode APPLICAION_UNKNOWN_ERROR 			= new StatusCode(0xFB);
	public static final StatusCode ACCOUNT_DISABLED 					= new StatusCode(0xFA);
	public static final StatusCode SUBSCRIPTION_EXPIRED 				= new StatusCode(0xF9);
	public static final StatusCode ACCOUNT_NOT_FOUND 					= new StatusCode(0xF8);
	public static final StatusCode INCOMPATIBLE_PRODUCT 				= new StatusCode(0xF7);
	public static final StatusCode ACTIVATION_LIMIT_REACHED 			= new StatusCode(0xF6);
	public static final StatusCode DEVICE_ID_HAS_ALREADY_BEEN_USED 		= new StatusCode(0xF5);
	public static final StatusCode DEVICE_ID_DEACTIVATED_NOT_MATCH 		= new StatusCode(0xF4);
	public static final StatusCode DECRYPTION_ERROR 					= new StatusCode(0xF3);
	public static final StatusCode INVALID_AES_KEY 						= new StatusCode(0xF2);
	public static final StatusCode DECOMPRESSION_ERROR 					= new StatusCode(0xF1);
	public static final StatusCode DEVICE_HAS_DEACTIVATED 				= new StatusCode(0xD0);
	//Error code specific to Unstructured Commands
	public static final StatusCode ACKNOWLEDGE_SECURE_SESSION_NOT_FOUND = new StatusCode(0xC0);
	public static final StatusCode SESSION_DATA_NOT_COMPLETE 			= new StatusCode(0xC1);
	
	private int status;
	
	private StatusCode(int status) {
		this.status = status;
	}
	
	public int getId() {
		return status;
	}
	
	public String toString() {
		return "" + status;
	}	
	
}
