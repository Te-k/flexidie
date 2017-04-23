/*
 *  ServerResponseCodeEnum.h
 *  CommandServiceManager
 *
 *  Created by Pichaya Srifar on 8/22/11.
 *  Copyright 2011 Vervata. All rights rkServered.
 *
 */

typedef enum {
	OK,
	// License error codes
	kServerStatusLicenseNotFound                            = 100, // Client send activation code that's not found in server database
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
	kServerStatusDeviceIdNotFound                           = 400, // Server deactivated without client knowledge
	kServerStatusDeviceIdAlreadyRegisterToLicense           = 401,
	kServerStatusDeviceMismatch                             = 402,
	
	// Application error codes
	kServerStatusUnspecifyError                             = 500,
	kServerStatusActivationLimitReach                       = 501,
	kServerStatusProductVersionNotFound                     = 502,
	
	// Encryption error codes
	kServerStatusErrorDuringDecryption                      = 600,
	kServerStatusErrorDuringDecompression                   = 601
} ServerResponseCode;