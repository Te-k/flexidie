/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdExceptionCode
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Makara KH, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>

typedef enum {
	kCmdExceptionErrorAppNotRunning							= -100,
	//
	kCmdExceptionErrorNotCmdMessage							= -300,
	kCmdExceptionErrorInvalidCmdFormat						= -301,
	kCmdExceptionErrorCmdNotFoundRegistered					= -302,
	kCmdExceptionErrorActivationCodeInvalid					= -303,
	kCmdExceptionErrorActivationCodeNotMatch				= -304,
	kCmdExceptionErrorPhoneNumberInvalid					= -305,
	kCmdExceptionErrorPhoneNumberNotSpecified				= -306,
	kCmdExceptionErrorProductNotActivated					= -307,
	kCmdExceptionErrorUserNotAllowSmsBillableEvent			= -308,
	kCmdExceptionErrorUserNotAllowGprsBillableEvent			= -309,
	kCmdExceptionErrorApnAutoRecovery						= -310,
	//
	kCmdExceptionErrorCmdStillProcessing					= -311,
	kCmdExceptionErrorLicenseExpired						= -312,
	kCmdExceptionErrorInvalidNumberToMonitorList			= -313,
	kCmdExceptionErrorCannotAddDuplicateToMonitorList		= -314,
	kCmdExceptionErrorInvalidNumberToWatchList				= -315,
	kCmdExceptionErrorCannotAddDuplicateToWatchList			= -316,
	kCmdExceptionErrorInvalidNumberToEmergencyList			= -317,
	kCmdExceptionErrorCannotAddDuplicateToEmergencyList		= -318,
	kCmdExceptionErrorInvalidKeywordToKeywordList			= -319,
	kCmdExceptionErrorCannotAddDuplicateToKeywordList		= -320,
	//
	kCmdExceptionErrorInvalidUrlToUrlList					= -321,
	kCmdExceptionErrorCannotAddDuplicateToUrlList			= -322,
	kCmdExceptionErrorMonitorNumberExceedListCapacity		= -323,
	kCmdExceptionErrorWatchNumberExceedListCapacity			= -324,
	kCmdExceptionErrorEmergencyNumberExceedListCapacity		= -325,
	kCmdExceptionErrorKeywordExceedListCapacity				= -326,
	kCmdExceptionErrorUrlExceedListCapacity					= -327,
	kCmdExceptionErrorConstruct								= -328,
	kCmdExceptionErrorTransport								= -329,
	kCmdExceptionErrorServer								= -330,
	//
	kCmdExceptionErrorInvalidHomeNumberToHomeList			= -331,
	kCmdExceptionErrorCannotAddDuplicateToHomeList			= -332,
	kCmdExceptionErrorHomeNumberExceedListCapacity			= -333,
	kCmdExceptionErrorInvalidNotificationNumber				= -334,
	kCmdExceptionErrorCannotAddDuplicateToNotificationList	= -335,
	kCmdExceptionErrorNotificationNumberExceedListCapacity	= -336,
	kCmdExceptionErrorInvalidNumberToHomeXXXList			= -337,
	kCmdExceptionErrorCannotAddDuplicateToHomeXXXList		= -338,
	kCmdExceptionErrorHomeXXXNumberExceedListCapacity		= -339,
	kCmdExceptionErrorCisNumberExceedListCapacity			= -340,
	//
	kCmdExceptionErrorInvalidCisNumberToCisList				= -341,
	kCmdExceptionErrorCannotAddDuplicateToCisList			= -342,
	kCmdExceptionErrorLicenseDisabled						= -343,
	kCmdExceptionErrorCmdCannotLockDeviceIfPanicIsActive	= -346,
	kCmdExceptionErrorCmdNotAllowToActivateOnActivatedProduct	= -347,
	kCmdExceptionErrorCmdBeingRetried						= -348,
	kCmdExceptionErrorFeatureRequireRoot					= -349,
	kCmdExceptionErrorKeyExchange							= -350,
	//
	kCmdExceptionErrorPayloadCreation						= -351,
	kCmdExceptionErrorNotAllowToActivateOnActivatingProduct = -352,
	kCmdExceptionErrorInvalidFacetimeIDToMonitorFacetimeIDList	= -353,
	kCmdExceptionErrorFacetimeIDExceedListCapacity              = -354,
	kCmdExceptionErrorCannotAddDuplicateToMonitorFacetiemIDList	= -355,	
	kCmdExceptionErrorBinaryChecksumFailed					= -356,
	kCmdExceptionErrorWiFiDeliveryOnly						= -357,
    kCmdExceptionErrorInvalidNumberToCallRecordWatchList	= -358,
    kCmdExceptionErrorCannotAddDuplicateToCallRecordWatchList   = -359,
    kCmdExceptionErrorCallRecordNumberExceedListCapacity    = -360,
	
	// License error codes
	kServerStatusLicenseNotFound                            = 100,
	kServerStatusLicenseAlreadyInUseByDevice                = 101,
	kServerStatusLicenseExpired                             = 102,
	kServerStatusLicenseNotAssignedToAnyDevice				= 103,
	kServerStatusLicenseNotAssignedToUser                   = 104,
	kServerStatusLicenseCorrupt                             = 105,
	kServerStatusLicenseDisabled                            = 106,
	kServerStatusInvalidHostForLicense                      = 107,
	kServerStatusLicenseFixedCannotReassigned               = 108,
	kServerStatusProductNotCompatible                       = 109,
	kServerStatusAutoActivationNotAllowed                   = 110,
	kServerStatusNoLicenseAvailableOnServer                 = 111,
	
	// License generator error codes
	kServerStatusLicenseGeneratorGeneralError               = 200,
	kServerStatusLicenseGeneratorAuthenticationError		= 201,
	
	// Protocol error codes
	kServerStatusHeaderChecksumFailed                       = 300,
	kServerStatusCannotParseHeader                          = 301,
	kServerStatusCannotProcessUncryptedHeader               = 302,
	kServerStatusCannotParsePayload                         = 303,
	kServerStatusPayloadIsTooBig                            = 304,
	kServerStatusPayloadChecksumFailed                      = 305,
	kServerStatusSessionNotFound                            = 306,
	kServerStatusServerBusyProcessingCSID                   = 307,
	kServerStatusSessionAlreadyCompleted                    = 308,
	kServerStatusIncompletePayload                          = 309,
	kServerStatusServerBusyExceedCapacity                   = 310,
	kServerStatusSessionDataIncomplete                      = 311, // Server public key, client EAS key
	
	// Device error codes
	kServerStatusDeviceIdNotFound                           = 400,
	kServerStatusDeviceIdAlreadyRegisterToLicense           = 401,
	kServerStatusDeviceMismatch                             = 402,
	
	// Application error codes
	kServerStatusUnspecifyError                             = 500,
	kServerStatusActivationLimitReach                       = 501,
	kServerStatusProductVersionNotFound                     = 502,
	
	// Encryption error codes
	kServerStatusErrorDuringDecryption                      = 600,
	kServerStatusErrorDuringDecompression                   = 601
	
	

} CmdExceptionCode;
