/*
 *  CommandCodeEnum.h
 *  ProtocolBuilder
 *
 *  Created by Pichaya Srifar on 7/26/11.
 *  Copyright 2011 Vervata. All rights reserved.
 *
 */

typedef enum {
	NOT_AVAILABLE								= 0,
	//
	SEND_EVENTS									= 1,
	SEND_ACTIVATE								= 2,
	SEND_DEACTIVATE								= 3,
	SEND_HEARTBEAT								= 4,
	GET_CONFIGURATION							= 5,
	GET_CSID									= 6,
	SEND_CLEAR_CSID								= 7,
	GET_ACTIVATION_CODE							= 8,
	GET_ADDRESSBOOK								= 9,
	SEND_ADDRESSBOOK_FOR_APPROVAL				= 10,
	//
	SEND_ADDRESSBOOK							= 11,
	GET_COMMUNICATION_DIRECTIVE					= 16,
	GET_TIME									= 17,
	SEND_MESSAGE								= 18,	// Obsolete
	GET_PROCESS_PROFILE,								// Obsolete
	SEND_RUNNING_PROCESSES,								// Obsolete
	GET_PROCESS_BLACK_LIST,								// Obsolete
	//
	GET_SOFTWARE_UPDATE							= 22,	// Obsolete
	GET_INCOMPATIBLE_APPLICATION_DEFINITIONS	= 23,
	SEND_CALL_IN_PROGRESS_NORTIFICATION			= 24,	// Obsolete
	SEND_RASK,											// Obsolete
	SEND_INSTALLED_APPLICATIONS					= 25,
	SEND_CAMERA_IMAGE							= 26,	// Obsolete
	SEND_RUNNING_APPLICATIONS					= 27,
	SEND_APPLICATION_PROFILE					= 28,
	SEND_BOOKMARKS								= 29,
	SEND_URL_PROFILE							= 30,
	//
	GET_APPLICATION_PROFILE						= 31,
	GET_URL_PROFILE								= 32,
	GET_ACTIVATION_CODE_FOR_ACCOUNT				= 33,
	SEND_APPLICATION_INSTANCE_IDENTIFIER		= 34,
	GET_BOOKMARKS								= 35,
	SEND_CALENDAR								= 36,
	SEND_NOTE									= 37,
	SEND_SMS									= 38,
	GET_AUDIO_RECORDING_SCHEDULE				= 39,
	GET_BINARY									= 40,
	//
	GET_SUPPORTED_IM							= 41,
    GET_SNAPSHOT_RULES                          = 42,
    SEND_SNAPSHOT_RULES                         = 43,
    GET_MONITOR_APPLICATIONS                    = 44,
    SEND_MONITOR_APPLICATIONS                   = 45,
    SEND_DEVICE_SETTINGS                        = 46,
    SEND_TEMPORAL_APPLICATION_CONTROL           = 47,
    GET_TEMPORAL_APPLICATION_CONTROL            = 48,
    SEND_ACCESS_POINTS                          = 49,
    //
    GET_ACCESS_POINT_CONTROL_LISTS              = 50,
    SEND_NETWORK_ALERT_CRITERIA                 = 51,
    GET_NETWORK_ALERT_CRITERIA                  = 52,
    SEND_NETWORK_ALERT                          = 53,
    GET_EMPLOYEE_CREDENTIAL_LISTING             = 54,
    GET_APPSCREENSHOT_RULE                      = 55
} CommandCode;